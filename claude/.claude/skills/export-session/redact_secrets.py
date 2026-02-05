#!/usr/bin/env python3
"""Redact secrets from Claude Code session JSONL files.

Subcommands:
    redact  — Apply regex redaction to a JSONL file, write cleaned copy
    extract — Pull all string values from JSONL into a flat text file
    scan    — Chain redact + extract + detect-secrets; exits 1 if secrets remain

Typical usage from a skill:
    REDACTED=$(python3 redact_secrets.py scan "$SESSION_FILE")
"""

import argparse
import json
import os
import re
import subprocess
import sys
import tempfile
from collections import Counter
from pathlib import Path

# ---------------------------------------------------------------------------
# Tier 1: prefix-based, high-confidence patterns
# ---------------------------------------------------------------------------
TIER1_PATTERNS: list[tuple[str, re.Pattern]] = [
    # Anthropic
    ("ANTHROPIC_KEY", re.compile(r"sk-ant-[A-Za-z0-9_-]{20,}")),
    # OpenAI
    ("OPENAI_KEY", re.compile(r"sk-proj-[A-Za-z0-9_-]{20,}")),
    ("OPENAI_KEY", re.compile(r"sk-[A-Za-z0-9]{20}T3BlbkFJ[A-Za-z0-9]{20,}")),
    # AWS
    ("AWS_ACCESS_KEY", re.compile(r"AKIA[0-9A-Z]{16}")),
    # GitHub
    ("GITHUB_TOKEN", re.compile(r"gh[pousr]_[A-Za-z0-9_]{36,}")),
    # GitLab
    ("GITLAB_TOKEN", re.compile(r"glpat-[A-Za-z0-9_-]{20,}")),
    # Stripe
    ("STRIPE_KEY", re.compile(r"[sr]k_live_[A-Za-z0-9]{24,}")),
    # Slack bot/user tokens
    ("SLACK_TOKEN", re.compile(r"xox[bpoa]-[A-Za-z0-9-]{10,}")),
    # Slack webhooks
    ("SLACK_WEBHOOK", re.compile(r"https://hooks\.slack\.com/services/T[A-Za-z0-9_/]{30,}")),
    # Google API
    ("GOOGLE_API_KEY", re.compile(r"AIza[A-Za-z0-9_-]{35}")),
    # SendGrid
    ("SENDGRID_KEY", re.compile(r"SG\.[A-Za-z0-9_-]{22,}\.[A-Za-z0-9_-]{22,}")),
    # npm
    ("NPM_TOKEN", re.compile(r"npm_[A-Za-z0-9]{36,}")),
    # PyPI
    ("PYPI_TOKEN", re.compile(r"pypi-[A-Za-z0-9_-]{50,}")),
    # JWT (three base64 sections separated by dots)
    ("JWT", re.compile(r"eyJ[A-Za-z0-9_-]{10,}\.eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}")),
    # Private key blocks
    ("PRIVATE_KEY", re.compile(r"-----BEGIN (?:RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----[^\-]+-----END (?:RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----", re.DOTALL)),
    # Basic auth in URLs
    ("BASIC_AUTH_URL", re.compile(r"https?://[^:@\s]+:[^@\s]{8,}@[^\s]+")),
]

# ---------------------------------------------------------------------------
# Tier 2: keyword-context patterns (value after keyword, min 16 chars)
# ---------------------------------------------------------------------------
TIER2_PATTERN = re.compile(
    r"""(?i)(?:password|passwd|secret|token|api_key|apikey|api-key|access_key|auth)"""
    r"""[\s]*[=:]\s*['"]?([A-Za-z0-9_/+\-.]{16,})['"]?""",
)

REDACTED_PLACEHOLDER = "[REDACTED:{label}]"


def redact_string(text: str, counter: Counter) -> str:
    """Apply all redaction patterns to a single string value."""
    for label, pattern in TIER1_PATTERNS:
        new_text = pattern.sub(REDACTED_PLACEHOLDER.format(label=label), text)
        if new_text != text:
            count = len(pattern.findall(text))
            counter[label] += count
            text = new_text

    # Tier 2: keyword-context — replace only the captured group
    for m in TIER2_PATTERN.finditer(text):
        secret_val = m.group(1)
        replacement = REDACTED_PLACEHOLDER.format(label="SECRET_VALUE")
        text = text.replace(secret_val, replacement, 1)
        counter["SECRET_VALUE"] += 1

    return text


def walk_and_redact(obj, counter: Counter):
    """Recursively walk a JSON structure, redacting string values in place."""
    if isinstance(obj, dict):
        return {k: walk_and_redact(v, counter) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [walk_and_redact(item, counter) for item in obj]
    elif isinstance(obj, str):
        return redact_string(obj, counter)
    return obj


def extract_strings(obj, out: list[str]):
    """Recursively extract all string values from a JSON structure."""
    if isinstance(obj, dict):
        for v in obj.values():
            extract_strings(v, out)
    elif isinstance(obj, list):
        for item in obj:
            extract_strings(item, out)
    elif isinstance(obj, str):
        out.append(obj)


# ---------------------------------------------------------------------------
# Subcommand: redact
# ---------------------------------------------------------------------------
def cmd_redact(session_file: str, output_dir: str) -> tuple[str, Counter, int]:
    """Redact secrets from a JSONL file. Returns (output_path, counter, lines_touched)."""
    counter: Counter = Counter()
    lines_touched = 0
    os.makedirs(output_dir, exist_ok=True)
    outpath = os.path.join(output_dir, "redacted.jsonl")

    with open(session_file, "r") as fin, open(outpath, "w") as fout:
        for line in fin:
            line = line.rstrip("\n")
            if not line:
                fout.write("\n")
                continue

            before_count = sum(counter.values())
            try:
                obj = json.loads(line)
                obj = walk_and_redact(obj, counter)
                fout.write(json.dumps(obj, ensure_ascii=False) + "\n")
            except json.JSONDecodeError:
                # Malformed line — apply string-level regex only
                redacted_line = redact_string(line, counter)
                fout.write(redacted_line + "\n")

            if sum(counter.values()) > before_count:
                lines_touched += 1

    return outpath, counter, lines_touched


# ---------------------------------------------------------------------------
# Subcommand: extract
# ---------------------------------------------------------------------------
def cmd_extract(jsonl_file: str, output_dir: str) -> str:
    """Extract all string values from a JSONL file into a flat text file."""
    outpath = os.path.join(output_dir, "extracted.txt")
    strings: list[str] = []

    with open(jsonl_file, "r") as f:
        for line in f:
            line = line.rstrip("\n")
            if not line:
                continue
            try:
                obj = json.loads(line)
                extract_strings(obj, strings)
            except json.JSONDecodeError:
                strings.append(line)

    with open(outpath, "w") as fout:
        for s in strings:
            fout.write(s + "\n")

    return outpath


# ---------------------------------------------------------------------------
# Subcommand: scan (chains redact + extract + detect-secrets)
# ---------------------------------------------------------------------------
def cmd_scan(session_file: str) -> int:
    """Full pipeline: redact → extract → detect-secrets. Prints redacted path on success."""
    tmpdir = tempfile.mkdtemp(prefix="session_redact_")

    # 1. Redact
    redacted_path, counter, lines_touched = cmd_redact(session_file, tmpdir)

    if sum(counter.values()) > 0:
        print(f"Redacted {sum(counter.values())} secret(s) in {lines_touched} line(s):", file=sys.stderr)
        for label, count in counter.most_common():
            print(f"  - {count}x {label}", file=sys.stderr)
    else:
        print("No secrets found by regex redaction.", file=sys.stderr)

    # 2. Extract text for scanning
    extracted_path = cmd_extract(redacted_path, tmpdir)

    # 3. Run detect-secrets on extracted text
    try:
        result = subprocess.run(
            [
                "uvx", "detect-secrets", "scan",
                "--disable-plugin", "HexHighEntropyString",
                "--disable-plugin", "IPPublicDetector",
                extracted_path,
            ],
            capture_output=True,
            text=True,
            timeout=60,
        )
        if result.returncode != 0:
            # detect-secrets itself errored — treat as non-fatal warning
            print(f"Warning: detect-secrets exited {result.returncode}: {result.stderr.strip()}", file=sys.stderr)
            print("Proceeding with regex-only redaction.", file=sys.stderr)
        else:
            scan_output = json.loads(result.stdout)
            findings = scan_output.get("results", {})
            secrets_found = any(findings.get(f) for f in findings)

            if secrets_found:
                print("ERROR: detect-secrets found potential secrets after redaction:", file=sys.stderr)
                for filepath, detections in findings.items():
                    for det in detections:
                        print(f"  - {det.get('type', 'unknown')}: line {det.get('line_number', '?')}", file=sys.stderr)
                return 1
            else:
                print("Session verified clean by detect-secrets.", file=sys.stderr)
    except FileNotFoundError:
        print("Warning: uvx/detect-secrets not found. Proceeding with regex-only redaction.", file=sys.stderr)
    except subprocess.TimeoutExpired:
        print("Warning: detect-secrets timed out. Proceeding with regex-only redaction.", file=sys.stderr)
    except (json.JSONDecodeError, KeyError):
        print("Warning: Could not parse detect-secrets output. Proceeding with regex-only redaction.", file=sys.stderr)

    # Success — print the path to stdout for the caller to capture
    print(redacted_path)
    return 0


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(description="Redact secrets from Claude Code session JSONL files.")
    sub = parser.add_subparsers(dest="command", required=True)

    # redact
    p_redact = sub.add_parser("redact", help="Redact secrets from a JSONL file")
    p_redact.add_argument("session_file", help="Path to session JSONL file")
    p_redact.add_argument("--output-dir", help="Output directory (default: temp dir)")

    # extract
    p_extract = sub.add_parser("extract", help="Extract strings from JSONL to flat text")
    p_extract.add_argument("jsonl_file", help="Path to JSONL file")
    p_extract.add_argument("--output-dir", help="Output directory (default: temp dir)")

    # scan
    p_scan = sub.add_parser("scan", help="Redact + extract + detect-secrets scan")
    p_scan.add_argument("session_file", help="Path to session JSONL file")

    args = parser.parse_args()

    if args.command == "redact":
        output_dir = args.output_dir or tempfile.mkdtemp(prefix="session_redact_")
        outpath, counter, lines = cmd_redact(args.session_file, output_dir)
        if sum(counter.values()) > 0:
            print(f"Redacted {sum(counter.values())} secret(s) in {lines} line(s):", file=sys.stderr)
            for label, count in counter.most_common():
                print(f"  - {count}x {label}", file=sys.stderr)
        print(outpath)

    elif args.command == "extract":
        output_dir = args.output_dir or tempfile.mkdtemp(prefix="session_redact_")
        outpath = cmd_extract(args.jsonl_file, output_dir)
        print(outpath)

    elif args.command == "scan":
        sys.exit(cmd_scan(args.session_file))


if __name__ == "__main__":
    main()
