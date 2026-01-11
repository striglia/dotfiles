---
name: retro
description: Analyze current session for workflow improvements. Finds manual corrections, workflow friction, and missed automation. Proposes concrete changes to skills and CLAUDE.md.
allowed-tools: Read, Edit, Write, Glob, Grep, AskUserQuestion
---

# Retrospective Analysis

Analyze the current session to identify improvements that would make Claude Code more autonomous and effective.

## When to Use

**Explicit invocation:**
- User says `/retro`, `/reflect`, or "what should we automate?"
- End of a long coding session
- After the user made several manual corrections

**Proactive suggestion (high confidence only):**
- Only suggest if 3+ clear correction patterns detected
- Phrase as: "I noticed some workflow friction this session. Want me to run `/retro` to propose improvements?"

## Analysis Process

### Phase 1: Scan Conversation for Patterns

Look for these signals in user messages:

**Workflow Friction (user nudging next steps):**
- Single-word continuations: "push", "commit", "continue", "yes", "do it"
- Terse commands that continue obvious workflows
- Questions like "what's next?" or "now what?"

**Explicit Corrections:**
- "no, do X instead"
- "you should have..."
- "always do X when..."
- "don't forget to..."
- "why didn't you..."
- "I told you to..."

**Teaching Moments:**
- "in this project we..."
- "the convention here is..."
- "we always..."
- "by default you should..."

**Missing Automation:**
- User running commands Claude could have run
- User providing information Claude could have gathered
- User asking Claude to check something it should have checked proactively

### Phase 2: Categorize Each Finding

For each identified improvement:

1. **What's the fix?** - Concrete change needed
2. **Where does it go?**
   - Project CLAUDE.md → project-specific conventions
   - Global ~/.claude/CLAUDE.md → cross-project preferences
   - Existing skill → enhance a skill's instructions
   - New skill → pattern warrants its own skill
3. **Confidence level** - How certain are we this is a real pattern vs one-off?

### Phase 3: Generate Proposals

For each finding, generate:
- **Evidence**: Quote or reference from the conversation
- **Diagnosis**: What went wrong / what was missing
- **Proposal**: Concrete diff or addition
- **Target file**: Exact path to modify

### Phase 4: Present to User

Format output as:

```
## Session Retrospective

Analyzed this session for automation opportunities.

### Workflow Friction
1. **[Title]**
   - Evidence: [what happened]
   - Proposal: [concrete change]
   - Target: [file path]

### Corrections Made
1. **[Title]**
   - Evidence: [user quote]
   - Proposal: [concrete change]
   - Target: [file path]

### Missing Automation
1. **[Title]**
   - Evidence: [what was missed]
   - Proposal: [concrete change]
   - Target: [file path]

---
Apply changes? I can update files directly or show diffs first.
```

## Decision Framework: Where Do Changes Go?

Use judgment based on these heuristics:

| Signal | Likely Target |
|--------|---------------|
| "In this project..." | `./CLAUDE.md` |
| "I always want..." | `~/.claude/CLAUDE.md` |
| "When doing X, also do Y" | Relevant skill file |
| Pattern spans multiple skills | `~/.claude/CLAUDE.md` or new skill |
| Very specific to one workflow | Existing skill enhancement |
| Entirely new capability | New skill |

## Examples

### Example 1: Workflow Auto-Continue

**Evidence:** User said "push" to continue after commit
**Diagnosis:** git-workflow requires explicit prompts between phases
**Proposal:** Add to project CLAUDE.md:
```markdown
## Workflow Preferences
auto-git-workflow: true
```
**Target:** `./CLAUDE.md`

### Example 2: Missing CI Setup

**Evidence:** User asked "do we need testing/CI integration" after /establish-ai
**Diagnosis:** establish-ai didn't create CI by default
**Proposal:** Add Phase 5 "Ensure CI" to establish-ai
**Target:** `~/.claude/skills/establish-ai/SKILL.md`

### Example 3: Global Preference

**Evidence:** User corrected "use uv, not pip" across multiple projects
**Diagnosis:** Claude defaulting to pip when uv is preferred
**Proposal:** Add to global CLAUDE.md:
```markdown
## Tool Preferences
- Always use `uv` for Python dependency management, not `pip`
```
**Target:** `~/.claude/CLAUDE.md`

## Confidence Calibration

**High confidence (propose proactively):**
- Same correction made 2+ times in session
- Explicit "always" or "never" statements
- Clear workflow friction (single-word nudges to continue)

**Medium confidence (propose when asked):**
- Single correction that seems generalizable
- Implicit preferences inferred from user behavior
- Patterns that might be context-specific

**Low confidence (mention but don't propose):**
- One-off corrections that might be situational
- Ambiguous signals
- Changes that could have unintended consequences

## Tips

1. **Quote the user** - Evidence should be traceable to specific messages
2. **Be concrete** - Show exact file paths and diffs, not vague suggestions
3. **Prefer minimal changes** - One-line additions are better than rewrites
4. **Respect existing structure** - Add to existing sections when possible
5. **Ask when uncertain** - If unsure where a change belongs, ask the user
6. **Don't over-generalize** - Not every correction is a pattern
