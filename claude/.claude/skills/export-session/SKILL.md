---
name: export-session
description: Export the current Claude Code session to JSONL/Markdown with an auto-generated descriptive filename based on session content
allowed-tools: Bash(*), Read(*)
---

# Export Session

Export the current Claude Code session to a file with a descriptive name based on the conversation content.

## Usage

```bash
/export-session [--format=jsonl|md|both]
```

**Format options**:
- `jsonl` - Export only JSONL (default if format not specified)
- `md` - Export only Markdown
- `both` - Export both JSONL and Markdown

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
7. **Both formats**: Always create both JSONL and Markdown
8. **JSONL is primary**: Just copy the original file, don't convert to JSON array
