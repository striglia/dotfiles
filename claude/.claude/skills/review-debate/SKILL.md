---
name: review-debate
description: Adversarial subagent review using Advocate vs Critic debate pattern. Surfaces issues through structured opposition, then synthesizes into actionable decisions. Use before committing code, finalizing plans, or making significant decisions.
allowed-tools: Task, Bash(git diff:*), Bash(git log:*), Bash(gh issue:*), Read, Grep, Glob, Edit
---

# Review Debate

Structured adversarial review using parallel subagents with opposing perspectives.

## When to Use

- Before pushing code (auto-invoked by `/git-workflow push`)
- Before finalizing a significant plan or design
- When you want a thorough self-review of any artifact
- Explicit: `/review-debate` or `/review-debate {context}`

## When to SKIP

**Skip this pattern for trivial changes:**
- Single-line fixes (typos, obvious bugs)
- Changes under 20 lines with no logic changes
- Documentation-only updates
- Dependency version bumps

For these, a quick manual review is sufficient.

## Core Concept

Two subagents debate from opposing perspectives:
- **Advocate**: Argues FOR the current approach
- **Critic**: Finds every possible problem

You (parent agent) synthesize into:
- **FIX NOW**: Quick wins, embarrassing issues
- **DEFER**: Valid but out of scope → create tickets
- **IGNORE**: Subjective, hypothetical

---

## Step 1: Gather Context

**For code reviews:**
```bash
git diff origin/main..HEAD
gh issue view {issue_num} --json title,body
```

The diff IS your context. Only read full files if the diff is confusing without surrounding code.

**For decisions/plans:** Read the document or articulate the decision and its goals.

---

## Step 2: Assess Complexity

Before spawning subagents:

| Change Size | Action |
|------------|--------|
| < 20 lines, obvious | Skip debate, proceed |
| 20-100 lines | Run debate |
| > 100 lines or architectural | Definitely debate |

If skipping: "Skipping review-debate: trivial change"

---

## Step 3: Launch Parallel Subagents

Call the Task tool TWICE in a single message to run them in parallel.

### Subagent A: The Advocate

Use Task tool with these parameters:
- description: "Advocate for changes"
- subagent_type: "general-purpose"
- model: "sonnet"
- prompt: (see template below)

**Advocate Prompt Template:**

```
# Role: Advocate

You are reviewing code changes. ARGUE FOR MERGING them.

## What's Being Reviewed
[one-line description]

## Requirements
[issue title and body]

## The Changes
[paste the diff]

## Your Task

1. **Goal Achievement**: How do changes accomplish the goal?
2. **Implementation Quality**: What's done well?
3. **Preemptive Rebuttals**: What might a critic say, and why is it not a real problem?

## Output Format

### Strengths
- [specific strength with code reference]

### Preemptive Rebuttals
- **Concern**: [what critic might say]
  **Rebuttal**: [why not a problem, with evidence]

Be specific. Reference actual code.
```

### Subagent B: The Critic

Use Task tool with:
- description: "Critique changes harshly"
- subagent_type: "general-purpose"
- model: "sonnet"
- prompt: (see template below)

**Critic Prompt Template:**

```
# Role: Harsh Critic

You are reviewing code changes. FIND EVERY PROBLEM.

## What's Being Reviewed
[one-line description]

## Requirements
[issue title and body]

## The Changes
[paste the diff]

## Your Task

Find ALL issues by severity:

### Critical (blocks merge)
- Bugs causing failures
- Security vulnerabilities
- Requirement violations

### Significant (should fix)
- Logic errors, edge cases
- Missing error handling
- Missing tests

### Minor (nice to fix)
- Clarity, naming
- Documentation gaps

### Observations (notable, not problems)
- Scope creep
- Alternative approaches

## Output Format

For each issue:
- **Location**: file:line or quote
- **Issue**: What's wrong
- **Evidence**: Why it's a problem
- **Severity**: Critical/Significant/Minor/Observation

Be harsh. Don't hold back.
```

---

## Step 4: Synthesize the Debate

After both return, YOU must deliberate. Follow this exact process:

### 4a. List all Critic issues

Write them out:
```
Critic found:
1. [Critical] Missing null check in auth.js:42
2. [Significant] No test for edge case X
3. [Minor] Variable name unclear
...
```

### 4b. Check Advocate rebuttals

For each Critic issue, ask:
- Did Advocate preemptively address this?
- If yes, is the rebuttal convincing?

### 4c. Classify each issue

For each issue, ask these questions IN ORDER:

1. **Is it real?** Does the code actually have this problem, or is it hypothetical?
   - If hypothetical → likely IGNORE

2. **Is it in scope?** Does fixing this serve the original goal/issue?
   - If out of scope but valid → DEFER

3. **Is it quick?** Can you fix it in under 5 minutes?
   - If quick and real → FIX NOW
   - If slow but important → DEFER

4. **Would it embarrass you?** If a human reviewer found this, would you be embarrassed?
   - If yes → FIX NOW regardless of time

### Classification Table

| Bucket | Criteria | Examples |
|--------|----------|----------|
| **FIX NOW** | Real bug, <5 min, or embarrassing | Null check, typo, obvious edge case |
| **DEFER → Issue** | Valid, out of scope, AND has clear milestone/label | "Add to milestone X", "label: area/auth" |
| **DEFER → Skip** | Valid but vague; no obvious home | "Maybe refactor someday", "could add tests" |
| **IGNORE** | Subjective, hypothetical, already considered | "I'd name it differently", "what if 100x scale" |

---

## Step 5: Execute Decisions

### FIX NOW items
- Make the fix immediately using Edit tool
- Note what you fixed

### DEFER items

**Before creating any issue, apply the "milestone or label" test:**

1. **Can you assign a specific milestone?** If yes, the issue has clear relevance to planned work.
2. **Can you assign a meaningful label?** (e.g., `area/goals`, `bug`, `enhancement`) If yes, it's at least categorizable.
3. **If neither applies:** Be skeptical. This repo moves fast—issues without clear homes become noise.

**Decision tree for DEFER items:**

```
DEFER item identified
    │
    ├─► Has obvious milestone? ─► CREATE with milestone
    │
    ├─► Has obvious label(s)? ─► CREATE with label(s)
    │
    └─► Neither? ─► ASK USER or SKIP
            │
            └─► "Found [issue]. Can't identify milestone/label.
                 Create issue anyway, or skip?"
```

**When you DO create an issue:**
```bash
gh issue create \
  --title "[concise title]" \
  --body "Discovered during self-review of #[issue_num].

[description]

Context: Deferred to keep scope focused." \
  --milestone "[milestone name]" \  # if applicable
  --label "deferred-review" \       # always add this
  --label "[area label]"            # if applicable
```

**When you SKIP creating an issue:**
- Note it in the "Ignored" section with reason: "No clear milestone/label; likely to go stale"
- This is the RIGHT choice for vague improvements in a fast-moving repo

### IGNORE items
- Document WHY in one line each (audit trail)

---

## Step 6: Report Results

Output this format:

```
## Review Debate Complete

### Fixed (N items)
- [what you fixed]

### Deferred (N items)
- [title] → [link to created issue]

### Ignored (N items)
- [issue]: [one-line reason]

### Verdict
[Ready to proceed / Needs more work before proceeding]
```

---

## Worked Example

**Scenario**: Reviewing a 50-line change that adds input validation to a form.

**Critic found:**
1. [Critical] SQL injection possible if input contains quotes
2. [Significant] No test for empty string case
3. [Minor] Variable `x` should be named `userInput`
4. [Observation] Could use a validation library instead
5. [Observation] Could add more comprehensive logging

**Advocate said:**
- "The validation handles the injection case via parameterized queries elsewhere"
- "Empty string is handled by the required attribute on the HTML input"

**Synthesis:**

| Issue | Rebuttal Valid? | Classification | Reasoning |
|-------|----------------|----------------|-----------|
| SQL injection | YES - checked, parameterized queries used | IGNORE | Advocate's evidence checks out |
| No empty string test | PARTIAL - HTML helps but JS should validate too | FIX NOW | 2 min to add, embarrassing if found |
| Rename `x` | No rebuttal | IGNORE | Subjective style preference |
| Use library | No rebuttal | DEFER → Issue | Valid; fits milestone "Forms v2", label `area/forms` |
| Add logging | No rebuttal | DEFER → Skip | Vague; no clear milestone or label; would go stale |

**Actions:**
- Added empty string validation (FIX NOW)
- Created issue #47: "Evaluate validation library for forms" with milestone "Forms v2" (DEFER → Issue)
- Skipped issue for logging: no clear home, noted in Ignored section
- Ignored: SQL injection (rebutted), variable naming (subjective)

**Output:**
```
## Review Debate Complete

### Fixed (1 item)
- Added empty string validation to form handler

### Deferred (1 item)
- Evaluate validation library → #47 (milestone: Forms v2)

### Ignored (3 items)
- SQL injection: Parameterized queries already handle this
- Variable naming: Subjective preference, code is clear enough
- Comprehensive logging: No clear milestone/label; skipped to avoid stale issue

### Verdict
Ready to proceed
```

---

## Tips

1. **Embed context explicitly** - Subagents only see what's in their prompt
2. **Use Sonnet** - Code review needs nuance; Haiku is too shallow
3. **Run in parallel** - Both subagents are independent
4. **Be decisive** - Your job is to DECIDE, not collect opinions
5. **Bias toward original goal** - Requirements are the tiebreaker
6. **Document IGNORE** - Future you wants to know why
7. **Fewer issues > more issues** - In fast-moving repos, issues without clear homes become noise. Skip creating issues you can't milestone or label. An observation noted in "Ignored" is better than a stale issue.
