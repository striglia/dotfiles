---
name: export-session
description: Export the current Claude Code session to JSONL/Markdown with an auto-generated descriptive filename based on session content (user)
allowed-tools: Bash(*), Read(*)
---

# Export Session

Export the current Claude Code session to a file with a descriptive name based on the conversation content.

## Usage

```bash
/export-session [options]
```

**Options**:
- `--format=jsonl|md|both` - Output format (default: both)
- `--output=<dir>` - Output directory (default: current directory)
- `--gist` - Upload to GitHub Gist and return shareable URL
- `--html` - Generate nicely formatted HTML (requires `uvx claude-code-transcripts`)

**Examples**:
```bash
/export-session                           # Export JSONL + MD to current dir
/export-session --output=transcripts      # Export to transcripts/ folder
/export-session --gist                    # Upload HTML transcript to Gist
/export-session --gist --output=transcripts  # Both: local copy + Gist
```

## When to Use This Skill

- User says `/export-session`
- User wants to save the conversation history
- User needs a backup of the current session
- User wants to share or document a session

## What This Does

1. **Finds the current session** from `~/.claude/projects/` directory
2. **Analyzes session content** to generate a descriptive filename
3. **Exports to JSONL** with full conversation history (one JSON object per line)
4. **Exports to Markdown** for easier reading
5. **Optionally uploads to Gist** for shareable URLs (with `--gist`)
6. **Optionally generates HTML** using Simon Willison's `claude-code-transcripts` tool

## Workflow

### Step 1: Locate Current Session

```bash
# Convert current directory to Claude's project path format
PROJECT_DIR=$(pwd | sed 's/\//-/g')
SESSION_DIR="$HOME/.claude/projects/$PROJECT_DIR"

# Find the most recent session file (exclude agent files)
LATEST_SESSION=$(ls -t "$SESSION_DIR"/*.jsonl 2>/dev/null | grep -v "agent-" | head -1)
```

### Step 2: Generate Descriptive Filename

Extract key information from the session to create a meaningful filename.

**Smart message selection**:
- Skip meta messages (`isMeta == true`)
- Skip command messages (`<command-name>...</command-name>`)
- Skip very short messages (< 15 chars)
- Find first substantial user message
- Fall back to combining multiple messages if needed

```bash
# Find first substantial user message
FIRST_MSG=$(jq -r '
  select(.type == "user" and .isMeta != true) |
  .message.content // "" |
  # Remove command tags and cleanup
  gsub("<command-name>.*?</command-name>"; "") |
  gsub("<[^>]+>"; "") |
  gsub("\\s+"; " ") |
  gsub("^\\s+|\\s+$"; "")
' "$LATEST_SESSION" | while read -r line; do
  # Skip empty or very short lines
  if [ -n "$line" ] && [ ${#line} -ge 15 ]; then
    echo "$line"
    break
  fi
done | head -1)

# Create a slug from the message
SLUG=$(echo "$FIRST_MSG" |
  head -c 100 |
  tr '[:upper:]' '[:lower:]' |
  sed 's/[^a-z0-9 ]//g' |
  tr -s ' ' |
  tr ' ' '-' |
  sed 's/^-//;s/-$//')

# If slug is empty or too short, use timestamp
if [ -z "$SLUG" ] || [ ${#SLUG} -lt 10 ]; then
  SLUG="session-$(date +%Y%m%d-%H%M%S)"
fi

# Add timestamp suffix for uniqueness
TIMESTAMP=$(date +%Y%m%d-%H%M)
FILENAME="${SLUG}-${TIMESTAMP}"
```

### Step 3: Export to JSONL

```bash
# Export full session as JSONL (just copy the file)
cp "$LATEST_SESSION" "claude-session-${FILENAME}.jsonl"
```

### Step 4: Create Markdown Summary (Optional)

Generate a readable markdown version with just the conversation:

```bash
# Extract conversation to markdown
cat > "claude-session-${FILENAME}.md" << 'MDEOF'
# Claude Code Session Export

**Exported**: $(date)
**Session ID**: $(basename "$LATEST_SESSION" .jsonl)
**Messages**: $(wc -l < "$LATEST_SESSION")

---

$(jq -r '
  select(.type == "user" or .type == "assistant") |
  if .type == "user" then
    "## 👤 User\n\n" + (.message.content // "")
  elif .type == "assistant" then
    "## 🤖 Assistant\n\n" + (.message.content // "")
  else
    empty
  end
' "$LATEST_SESSION")
MDEOF
```

### Step 5: Report Results

Display summary of what was exported:

```bash
echo "✓ Session exported successfully!"
echo ""
echo "Files created:"
echo "  📄 claude-session-${FILENAME}.jsonl ($(du -h "claude-session-${FILENAME}.jsonl" | cut -f1))"
echo "  📝 claude-session-${FILENAME}.md ($(du -h "claude-session-${FILENAME}.md" | cut -f1))"
echo ""
echo "Session info:"
echo "  Messages: $(wc -l < "$LATEST_SESSION")"
echo "  Session ID: $(basename "$LATEST_SESSION" .jsonl)"
```

## Output Format

### JSONL Export Structure

The JSONL file contains one JSON object per line (same format as Claude Code's internal storage):

```jsonl
{"type": "user", "message": {"role": "user", "content": "..."}, "timestamp": "2025-12-29T07:33:10.504Z", ...}
{"type": "assistant", "message": {"role": "assistant", "content": [...]}, ...}
{"type": "tool-result", ...}
```

Each line is a complete JSON object. To process:

```bash
# Read all lines as JSON array
jq -s '.' file.jsonl

# Filter specific message types
jq 'select(.type == "user")' file.jsonl

# Count messages
wc -l < file.jsonl
```

### Markdown Export Structure

The Markdown file contains:
- Session metadata (date, ID, message count)
- Conversation formatted as alternating User/Assistant sections
- Tool calls and results are included in assistant sections
- Clean, readable format for sharing or documentation

## Filename Examples

Based on session content:

- First message: "is it possible to dump a claude code session to file?"
  → `is-it-possible-to-dump-a-claude-code-session-to-file-20251229-0733.jsonl`

- First message: "Add dark mode toggle"
  → `add-dark-mode-toggle-20251229-1045.jsonl`

- First message: "Fix bug in user authentication"
  → `fix-bug-in-user-authentication-20251229-1520.jsonl`

- Empty/short first message:
  → `session-20251229-0733.jsonl`

## Error Handling

**No session found**:
```
Error: No Claude Code session found for this project
Project: /Users/username/project
```

**Session directory doesn't exist**:
```
Error: No Claude sessions found for current directory
Run 'claude' first to create a session
```

**jq not installed**:
```
Error: jq is required but not installed
Install with: brew install jq
```

## --output Flag: Custom Output Directory

When `--output=<dir>` is specified, create the directory if it doesn't exist and save files there:

```bash
OUTPUT_DIR="${OUTPUT_DIR:-.}"  # Default to current directory

# Create directory if needed
mkdir -p "$OUTPUT_DIR"

# Export files to the specified directory
cp "$LATEST_SESSION" "$OUTPUT_DIR/claude-session-${FILENAME}.jsonl"
# ... same for .md file
```

**Report output location**:
```bash
echo "Files created in: $OUTPUT_DIR/"
echo "  📄 $OUTPUT_DIR/claude-session-${FILENAME}.jsonl"
echo "  📝 $OUTPUT_DIR/claude-session-${FILENAME}.md"
```

## --gist Flag: Upload to GitHub Gist

When `--gist` is specified, generate HTML using `claude-code-transcripts` and upload to Gist with BOTH the HTML (human-readable) and JSONL (machine-readable) files.

### Prerequisites Check

```bash
# Check if gh CLI is installed and authenticated
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is required for --gist"
    echo "Install with: brew install gh"
    echo "Then run: gh auth login"
    exit 1
fi

# Check if uvx is available
if ! command -v uvx &> /dev/null; then
    echo "Error: uvx is required for --gist (part of uv)"
    echo "Install with: curl -LsSf https://astral.sh/uv/install.sh | sh"
    exit 1
fi
```

### Generate HTML + JSONL and Upload to Gist

**Important**: Use the two-step approach to include BOTH HTML and JSONL in the gist:

```bash
# Step 1: Generate HTML + JSONL to a temp directory
TEMP_DIR=$(mktemp -d)/transcript
uvx claude-code-transcripts json "$LATEST_SESSION" --json -o "$TEMP_DIR"

# Step 2: Upload ALL files (HTML + JSONL) to gist
GIST_URL=$(gh gist create "$TEMP_DIR"/* --public)

# Step 3: Extract gist ID and construct preview URL
GIST_ID=$(echo "$GIST_URL" | grep -o '[^/]*$')
PREVIEW_URL="https://gistpreview.github.io/?${GIST_ID}/index.html"

# Step 4: Report results
echo ""
echo "✓ Uploaded to GitHub Gist!"
echo ""
echo "  📖 $PREVIEW_URL"
echo ""
echo "  (Raw gist: $GIST_URL)"
```

This creates a gist containing:
- `index.html` - Human-readable summary page
- `page-001.html`, `page-002.html`, etc. - Paginated transcript
- `<session-id>.jsonl` - Raw machine-readable session data

### Combined Usage (--gist + --output)

When both flags are specified:
1. First export JSONL/MD to the output directory (local backup)
2. Then run the gist upload

```bash
# Example output for combined usage:
echo "✓ Session exported successfully!"
echo ""
echo "Local files:"
echo "  📄 transcripts/claude-session-${FILENAME}.jsonl"
echo "  📝 transcripts/claude-session-${FILENAME}.md"
echo ""
echo "GitHub Gist:"
echo "  📖 https://gistpreview.github.io/?abc123/index.html"
echo ""
echo "Add to commit message:"
echo "  Transcript: https://gistpreview.github.io/?abc123/index.html"
```

## Tips

- The JSONL export is an exact copy of Claude Code's internal format
- JSONL is more efficient than JSON arrays for streaming and processing
- The Markdown export is human-readable but excludes technical details
- Filename is based on the FIRST real user message (not meta messages or commands)
- Timestamp suffix ensures uniqueness even for similar conversations
- Sessions are per-project - each project directory has its own sessions

## Implementation Notes for Claude

1. **Always validate** session directory exists before attempting export
2. **Handle edge cases**: empty sessions, meta-only messages, very long first messages
3. **Truncate slugs** to reasonable length (50-100 chars) to avoid filesystem issues
4. **Sanitize filenames**: remove special characters that could cause issues
5. **Show progress**: Let user know what's happening at each step
6. **Report errors clearly**: If jq missing, session not found, etc.
7. **Both formats**: Always create both JSONL and Markdown by default
8. **JSONL is primary**: Just copy the original file, don't convert to JSON array
9. **Parse flags**: Check for `--output=<dir>`, `--gist`, `--format=<type>` in args
10. **For --gist**: Use the TWO-STEP approach:
    - Step 1: `uvx claude-code-transcripts json <session> --json -o <temp_dir>`
    - Step 2: `gh gist create <temp_dir>/* --public`
    - This ensures BOTH HTML and JSONL are in the same gist
11. **Output the preview URL prominently**: `https://gistpreview.github.io/?<gist_id>/index.html`
12. **Install check**: Before using --gist, verify `gh` and `uvx` are available

## Typical Workflow for Tool Development

When building a tool and wanting to record the session:

```bash
# 1. After completing the tool, export session to transcripts folder
/export-session --output=transcripts

# 2. Or upload to Gist for sharing
/export-session --gist

# 3. Include the gist link in your commit message:
git commit -m "Add JSON formatter tool

Transcript: https://gistpreview.github.io/?abc123/index.html"
```

## References

- Simon Willison's approach: https://simonwillison.net/2025/Dec/25/claude-code-transcripts/
- claude-code-transcripts tool: https://github.com/simonw/claude-code-transcripts
- Example transcript: https://gistpreview.github.io/?07b9099049de2debfae8908aa550b56a/index.html
