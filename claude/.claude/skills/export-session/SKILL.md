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

This skill is a thin wrapper around Simon Willison's `claude-code-transcripts` tool.

### For --gist (upload to GitHub Gist):

```bash
uvx claude-code-transcripts local --gist
```

This will:
1. Show a picker to select the session (default: most recent)
2. Generate HTML transcript
3. Upload to GitHub Gist
4. Return a gistpreview.github.io URL

### For --output (local save):

```bash
uvx claude-code-transcripts local -o <output_dir>
```

### For current session without picker:

```bash
# Find current session
PROJECT_DIR=$(pwd | sed 's/\//-/g')
SESSION_DIR="$HOME/.claude/projects/$PROJECT_DIR"
LATEST_SESSION=$(ls -t "$SESSION_DIR"/*.jsonl 2>/dev/null | grep -v "agent-" | head -1)

# Convert with gist upload
uvx claude-code-transcripts json "$LATEST_SESSION" --gist

# Or convert locally
uvx claude-code-transcripts json "$LATEST_SESSION" -o <output_dir>
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

Transcript: https://gistpreview.github.io/?abc123/index.html"
```

## References

- claude-code-transcripts: https://github.com/simonw/claude-code-transcripts
- Simon's blog post: https://simonwillison.net/2025/Dec/25/claude-code-transcripts/
