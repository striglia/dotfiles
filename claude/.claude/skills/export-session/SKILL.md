---
name: export-session
description: Export the current Claude Code session to HTML transcript and optionally upload to GitHub Gist (user)
allowed-tools: Bash(*), Read(*)
---

# Export Session

Export the current Claude Code session as a shareable HTML transcript using Simon Willison's `claude-code-transcripts` tool.

## Usage

```bash
/export-session [options]
```

**Options**:
- `--gist` - Upload to GitHub Gist and return shareable URL
- `--output=<dir>` - Save HTML locally to directory

**Examples**:
```bash
/export-session --gist              # Upload to Gist, get shareable URL
/export-session --output=transcripts  # Save HTML locally
```

## Implementation

This skill wraps Simon Willison's `claude-code-transcripts` tool. Since Claude Code runs non-interactively, we must find the session file directly (the `local` subcommand requires an interactive picker).

### Step 1: Find the current session file

```bash
# Build the project path (replace / with -)
PROJECT_PATH=$(pwd | sed 's/\//-/g')
SESSION_DIR="$HOME/.claude/projects/$PROJECT_PATH"

# Get the most recent non-agent session
SESSION_FILE=$(ls -t "$SESSION_DIR"/*.jsonl 2>/dev/null | grep -v "agent-" | head -1)
echo "Session: $SESSION_FILE"
```

### Step 2: Redact secrets

```bash
REDACTED_FILE=$(python3 "$HOME/.claude/skills/export-session/redact_secrets.py" scan "$SESSION_FILE")
if [ $? -ne 0 ]; then
    echo "ERROR: Secrets detected after redaction. Export aborted."
    exit 1
fi
echo "Using redacted file: $REDACTED_FILE"
```

### Step 3a: For --gist (upload to GitHub Gist):

```bash
uvx claude-code-transcripts json "$REDACTED_FILE" --gist
```

Returns a gisthost.github.io URL (Simon's fork of gistpreview that handles larger files).

### Step 3b: For --output (local save):

```bash
uvx claude-code-transcripts json "$REDACTED_FILE" -o <output_dir>
```

Creates `index.html` and `page-*.html` files in the output directory.

### Step 4: Cleanup

```bash
# Remove the temp directory created by redact_secrets.py
rm -rf "$(dirname "$REDACTED_FILE")"
```

## Prerequisites

```bash
# uv (for uvx)
command -v uvx &> /dev/null || curl -LsSf https://astral.sh/uv/install.sh | sh

# gh CLI (for --gist)
command -v gh &> /dev/null || brew install gh
gh auth status || gh auth login
```

## Typical Workflow

```bash
# After completing work, get shareable transcript link
/export-session --gist

# Include in commit message:
git commit -m "Fix mobile chart issues

Transcript: https://gisthost.github.io/?abc123/index.html"
```

## References

- claude-code-transcripts: https://github.com/simonw/claude-code-transcripts
- gisthost (gistpreview fork for larger files): https://github.com/simonw/gisthost.github.io
- Simon's blog post: https://simonwillison.net/2025/Dec/25/claude-code-transcripts/
