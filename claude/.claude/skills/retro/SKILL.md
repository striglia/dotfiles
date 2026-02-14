---
name: retro
description: Analyze current session for workflow improvements. Finds manual corrections, workflow friction, and missed automation. Proposes concrete changes to skills and CLAUDE.md.
allowed-tools: Read, Edit, Write, Glob, Grep, AskUserQuestion, Task
---

# Retrospective Analysis

**Core Purpose:** Compound Claude's effectiveness over time by systematically converting session learnings into persistent automation.

> "The key differentiator isn't the sophistication of the AI models—it's the willingness to redesign workflows rather than simply layering agents onto legacy processes."

This skill implements a **Reflexion pattern**: analyze session → extract learnings → propose changes → validate → apply. Each retro should make future sessions measurably more autonomous.

## When to Use

**Explicit invocation:**
- User says `/retro`, `/reflect`, or "what should we automate?"
- End of a long coding session
- After the user made several manual corrections

**Proactive suggestion (high confidence only):**
- Only suggest if 3+ clear correction patterns detected
- Phrase as: "I noticed some workflow friction this session. Want me to run `/retro` to propose improvements?"

## Analysis Process

### Phase 1: Quantify Session Friction

Before pattern analysis, establish baseline metrics:

```
Session Metrics:
├── Nudge Count: [N] (single-word continuations like "yes", "push", "continue")
├── Correction Count: [N] (explicit "no, do X" corrections)
├── Teaching Moments: [N] (user explaining preferences)
├── Questions Asked: [N] (times user was asked to clarify)
└── Friction Score: [Low/Medium/High] (overall autonomy assessment)
```

These metrics enable tracking improvement over time.

**Inline capture dedup:** The `capture-knowledge` rule in global CLAUDE.md persists corrections inline during the session. In Phase 4, delegate dedup checking to a Sonnet subagent (via Task tool with `model=sonnet`). Pass proposed changes in the task prompt. The subagent reads project CLAUDE.md and `~/.claude/CLAUDE.md`, compares against proposals, and returns only those not already covered by existing rules. Note which proposals were "(already captured inline)" in the output. This keeps dedup work out of the main retro context.

### Phase 2: Scan for Both Problems AND Successes

**PROBLEMS to fix:**

**Workflow Friction (user nudging next steps):**
- Single-word continuations: "push", "commit", "continue", "yes", "do it"
- Terse commands that continue obvious workflows
- Questions like "what's next?" or "now what?"
- User waiting for Claude to act autonomously

**Explicit Corrections:**
- "no, do X instead"
- "you should have..."
- "always do X when..."
- "don't forget to..."
- "why didn't you..."
- "I told you to..."
- "that's not how we..."
- "actually, I meant..."

**Teaching Moments:**
- "in this project we..."
- "the convention here is..."
- "we always..."
- "by default you should..."
- "I prefer..."
- "we use X not Y"

**Missing Automation:**
- User running commands Claude could have run
- User providing information Claude could have gathered
- User asking Claude to check something it should have checked proactively
- Manual steps that should be skill invocations

**Skill Underutilization:**
- Situations where an existing skill should have been invoked
- Workflows that match skill triggers but weren't automated
- Manual multi-step processes that skills handle

**SUCCESSES to codify:**

**What Worked Well:**
- Patterns Claude followed that user appreciated
- Autonomous decisions that were correct
- Skill invocations that saved time
- Tool choices that matched user preferences

**Implicit Preferences Validated:**
- Assumptions Claude made that were confirmed correct
- Workflow choices user didn't object to

### Phase 3: Multi-Agent Debate (Higher Quality Analysis)

Use the Task tool to spawn TWO parallel subagents with opposing perspectives:

**Subagent A - The Advocate (find successes to preserve):**
```
Analyze this session for patterns worth KEEPING:
- What did Claude do autonomously that worked well?
- What assumptions proved correct?
- What should we codify as expected behavior?
- What skills were used effectively?

Be specific. Quote user reactions. Identify patterns, not one-offs.
```

**Subagent B - The Critic (find failures to fix):**
```
Analyze this session for FRICTION and FAILURES:
- Where did Claude require nudging to continue?
- What corrections did the user make?
- What should Claude have known/done automatically?
- What skills should have been invoked but weren't?

Be harsh. Quote user frustration. Don't dismiss patterns as edge cases.
```

**Deliberation:** After collecting both perspectives, synthesize findings:
- Where do advocate and critic agree?
- For disagreements, which has stronger evidence?
- What's the minimum viable change to address each issue?

### Phase 4: Categorize and Prioritize

For each finding, determine:

1. **What's the fix?** - Concrete, minimal change
2. **Where does it go?**
   - Project CLAUDE.md → project-specific conventions
   - Global ~/.claude/CLAUDE.md → cross-project preferences
   - Existing skill → enhance a skill's instructions
   - New skill → pattern warrants its own skill
3. **Confidence level** - High/Medium/Low (see calibration below)
4. **Impact** - How often will this improvement matter?
5. **Effort** - One-liner vs. significant change

**Prioritization:** `Impact × Confidence / Effort`

### Phase 5: Validate Proposals

Before presenting, mentally test each proposal:

1. **Counterfactual test:** Would this change have prevented the friction?
2. **Side-effect check:** Could this cause new problems?
3. **Scope check:** Is this too narrow (one-off) or too broad (over-generalized)?
4. **Existing coverage:** Does a skill or rule already cover this?

Remove proposals that fail validation.

### Phase 6: Present to User

Format output as:

```
## Session Retrospective

### Session Metrics
- Nudge count: [N]
- Correction count: [N]
- Friction score: [Low/Medium/High]

### High-Priority Improvements

1. **[Title]** (Impact: High, Confidence: High)
   - Evidence: [specific quote or event]
   - Root cause: [why this happened]
   - Proposal: [concrete diff]
   - Target: [exact file path]
   - Validation: [why this would have helped]

### Medium-Priority Improvements
[...]

### Patterns to Preserve (Successes)

1. **[Title]**
   - Evidence: [what worked]
   - Action: [codify in CLAUDE.md / keep doing]

### Proactive Suggestions for Next Session

Based on this session, consider:
- Invoking `/[skill]` when [trigger condition]
- Setting up [automation] for [recurring pattern]

---
Apply changes? I can update files directly or show diffs first.
```

## Decision Framework: Where Do Changes Go?

| Signal | Likely Target |
|--------|---------------|
| "In this project..." | `./CLAUDE.md` |
| "I always want..." | `~/.claude/CLAUDE.md` |
| "When doing X, also do Y" | Relevant skill file |
| Pattern spans multiple skills | `~/.claude/CLAUDE.md` or new skill |
| Very specific to one workflow | Existing skill enhancement |
| Entirely new capability | New skill |
| Should happen automatically | Skill trigger condition |

## Examples

### Example 1: Workflow Auto-Continue

**Evidence:** User said "push" to continue after commit
**Root cause:** /work requires explicit prompts between phases
**Proposal:** Add to global CLAUDE.md:
```markdown
## Workflow Preferences
- **auto-work**: When on a feature branch, complete the full /work (commit → review → push → PR) without pausing for explicit prompts at each phase.
```
**Target:** `~/.claude/CLAUDE.md`
**Validation:** Would have eliminated 3 single-word nudges

### Example 2: Missing Skill Invocation

**Evidence:** User manually ran tests, fixed errors, committed - workflow that /tdd-bugfix handles
**Root cause:** Claude didn't recognize bug-fix pattern as skill trigger
**Proposal:** Add to skill description or CLAUDE.md:
```markdown
## Proactive Skill Usage
- When fixing bugs, proactively invoke `/tdd-bugfix` for regression-safe fixes
```
**Target:** `~/.claude/CLAUDE.md` or enhance tdd-bugfix trigger docs

### Example 3: Tool Preference

**Evidence:** User corrected "use uv, not pip"
**Root cause:** Claude defaulting to pip when uv is preferred
**Proposal:** Add to global CLAUDE.md:
```markdown
## Tool Preferences
- Always use `uv` for Python dependency management, not `pip`
```
**Target:** `~/.claude/CLAUDE.md`

### Example 4: Success Pattern to Preserve

**Evidence:** Claude proactively ran `npm test` after code changes, user appreciated
**Action:** This is working - no change needed, but note for confidence

## Confidence Calibration

**High confidence (propose proactively):**
- Same correction made 2+ times in session
- Explicit "always" or "never" statements
- Clear workflow friction (single-word nudges to continue)
- User expressed appreciation for a pattern

**Medium confidence (propose when asked):**
- Single correction that seems generalizable
- Implicit preferences inferred from user behavior
- Patterns that might be context-specific

**Low confidence (mention but don't propose):**
- One-off corrections that might be situational
- Ambiguous signals
- Changes that could have unintended consequences

## The Compounding Effect

Each retro contributes to a **virtuous cycle**:

```
Session N:
├── Friction detected → Retro → Rule added
│
Session N+1:
├── Rule prevents friction → More autonomous
├── New friction detected → Retro → More rules
│
Session N+M:
├── Most common patterns automated
├── Claude acts autonomously by default
└── Human intervention only for novel situations
```

**Goal:** Over time, the nudge count and correction count should trend toward zero as automation compounds.

## Meta-Validation: When /retro Itself Is Modified

If the current session involved improving or modifying the `/retro` skill itself, prompt the user:

> "This session modified /retro. Want me to run /retro on this session to validate the changes work?"

This catches meta-improvements:
- Does the enhanced skill detect friction patterns correctly?
- Does the output format work as intended?
- Are there improvements to the improvement process itself?

User can decline - but the prompt ensures the opportunity isn't missed.

## Tips

1. **Quote the user** - Evidence should be traceable to specific messages
2. **Be concrete** - Show exact file paths and diffs, not vague suggestions
3. **Prefer minimal changes** - One-line additions are better than rewrites
4. **Respect existing structure** - Add to existing sections when possible
5. **Ask when uncertain** - If unsure where a change belongs, ask the user
6. **Don't over-generalize** - Not every correction is a pattern
7. **Mine successes** - What worked is as important as what failed
8. **Validate before proposing** - Would this change actually help?
9. **Suggest skill usage** - Point toward existing automation for next session
10. **Track metrics** - Quantifying friction enables measuring improvement
