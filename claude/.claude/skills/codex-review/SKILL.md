---
name: codex-review
description: Code review using OpenAI Codex in headless mode. Alternative to review-debate for external perspective. Use manually or as part of /work.
allowed-tools: Bash(git:*), Bash(gh:*), Bash(codex:*), Read, Grep, Glob
---

# Codex Review

External code review using OpenAI's Codex CLI in headless mode. Provides a fresh perspective from a different model family.

## When to Use

- Manual: `/codex-review` - Review current branch changes
- Automatic: Invoked by `/work review` when configured
- When you want a second opinion from a different model
- When review-debate feels like too much ceremony for medium-sized changes

## When to SKIP

**Skip for trivial changes:**

- Single-line fixes (typos, obvious bugs)
- Changes under 10 lines with no logic changes
- Documentation-only updates
- Dependency version bumps

## Prerequisites

```bash
# Codex CLI must be installed
command -v codex &> /dev/null || echo "Install: https://github.com/openai/codex"

# Must be authenticated
codex login  # if not already logged in
```

## Configuration

Set your preferred model in `~/.codex/config.toml`:

```toml
model = "gpt-5.2"  # or whatever model you prefer
```

Or pass via CLI: `codex exec -m gpt-5.2 ...`

---

## Step 1: Gather Context

**Get the diff and issue context:**

```bash
# Get current branch
BRANCH=$(git branch --show-current)

# Extract issue number from branch (format: {num}-{slug})
ISSUE_NUM=$(echo "$BRANCH" | grep -oE '^[0-9]+')

# Get the diff
DIFF=$(git diff origin/main..HEAD)

# Get issue context if available
if [ -n "$ISSUE_NUM" ]; then
  ISSUE_CONTEXT=$(gh issue view "$ISSUE_NUM" --json title,body -q '"Issue #\(.title)\n\n\(.body)"' 2>/dev/null || echo "")
fi
```

**Assess complexity:**

| Change Size         | Action            |
| ------------------- | ----------------- |
| < 10 lines, obvious | Skip review       |
| 10-100 lines        | Run codex-review  |
| > 100 lines         | Definitely review |

If skipping: "Skipping codex-review: trivial change"

---

## Step 2: Run Codex Review

Call codex in headless mode with a structured review prompt.

**Build the prompt:**

````bash
PROMPT=$(cat <<'PROMPT_EOF'
You are reviewing code changes. Be thorough but constructive.

## Requirements
{ISSUE_CONTEXT}

## The Changes
```diff
{DIFF}
````

## Your Task

Review these changes and provide:

### Critical Issues (blocks merge)

- Bugs that would cause failures
- Security vulnerabilities
- Logic errors that violate requirements

### Improvements (should fix before merge)

- Missing error handling
- Edge cases not covered
- Test gaps
- Performance concerns

### Suggestions (optional polish)

- Code clarity improvements
- Alternative approaches worth considering

### Strengths

- What's done well (be specific)

For each issue, provide:

- **Location**: file:line or code quote
- **Problem**: What's wrong
- **Fix**: How to address it (be specific)

Be direct. If the code is good, say so briefly. Don't pad with generic praise.
PROMPT_EOF
)

# Substitute actual values

PROMPT="${PROMPT//\{ISSUE_CONTEXT\}/$ISSUE_CONTEXT}"
PROMPT="${PROMPT//\{DIFF\}/$DIFF}"

````

**Execute the review:**

```bash
# Run codex in exec (headless) mode
# - workspace-write sandbox: can read files for context
# - JSON output for structured parsing
echo "$PROMPT" | codex exec \
  --sandbox workspace-write \
  --output-last-message /tmp/codex-review-output.md \
  -
````

**Note**: The `-` at the end means read prompt from stdin.

---

## Step 3: Process Results

Read the output and present to user:

```bash
# Get the review output
REVIEW=$(cat /tmp/codex-review-output.md)
```

**Parse severity:**

Look for these sections in the output:

- "Critical Issues" → **FIX NOW**
- "Improvements" → **SHOULD FIX**
- "Suggestions" → **CONSIDER**
- "Strengths" → **INFO**

---

## Step 4: Take Action

### For FIX NOW (Critical Issues)

If Codex found critical issues:

1. Read each issue carefully
2. Verify it's a real problem (not hallucination)
3. Fix confirmed issues using Edit tool
4. Re-run codex-review to verify fix

### For SHOULD FIX (Improvements)

For each improvement:

1. If quick (<5 min): fix it
2. If longer but important: fix it
3. If out of scope: note for follow-up issue

### For CONSIDER (Suggestions)

- Evaluate each suggestion
- Implement if clearly better
- Otherwise, document why skipped

---

## Step 5: Report Results

Output this format:

```
## Codex Review Complete

### Model
{model used, e.g., gpt-5.2}

### Fixed (N items)
- [what you fixed]

### Noted for Follow-up (N items)
- [valid but out of scope]

### Skipped (N items)
- [suggestion]: [why skipped]

### Verdict
[Ready to proceed / Needs more work]
```

---

## Integration with /work

This skill can be invoked by `/work review` as an alternative to `/review-debate`.

**To enable codex-review in `/work`**, add to CLAUDE.md:

```markdown
review-method: codex-review
```

**To use review-debate** (default):

```markdown
review-method: review-debate
```

**Why choose codex-review:**

- Faster for medium-sized changes (single model call vs 3 parallel subagents)
- External perspective (different model family catches different issues)
- Less ceremony than adversarial debate pattern

**Why choose review-debate:**

- More thorough for large/architectural changes
- Explicitly surfaces trade-offs through adversarial positions
- Better for complex decisions with multiple valid approaches

---

## Tips

1. **Trust but verify**: Codex can hallucinate issues. Always verify before fixing.
2. **Context matters**: Include issue context so Codex understands requirements.
3. **Model choice**: Newer models (gpt-5.2) are better at code review than older ones.
4. **Sandbox mode**: workspace-write allows reading surrounding code for context.
5. **Iterate**: If Codex finds major issues, fix and re-review.

---

## Example Session

```bash
$ /codex-review

Gathering context...
- Branch: 42-add-user-auth
- Issue: #42 - Add user authentication
- Diff: 87 lines changed

Running codex review...
- Model: gpt-5.2
- Sandbox: workspace-write

## Codex Review Output

### Critical Issues
None found.

### Improvements
1. **Location**: auth.ts:34
   **Problem**: Missing rate limiting on login endpoint
   **Fix**: Add rate limiter middleware: `app.use('/login', rateLimit({ max: 5, windowMs: 60000 }))`

2. **Location**: auth.ts:52
   **Problem**: Password comparison not timing-safe
   **Fix**: Use `crypto.timingSafeEqual()` instead of `===`

### Suggestions
1. Consider adding login attempt logging for security audit trail

### Strengths
- Clean separation of auth middleware
- Proper use of httpOnly cookies for tokens

---

## Codex Review Complete

### Model
gpt-5.2

### Fixed (2 items)
- Added rate limiting to login endpoint
- Switched to timing-safe password comparison

### Noted for Follow-up (1 item)
- Login attempt logging (out of scope for this PR)

### Skipped (0 items)

### Verdict
Ready to proceed
```
