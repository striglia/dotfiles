---
name: practice-review
description: End-of-session reflection on personal development practices. Tracks adherence to user-defined practices over time, surfaces trends, and helps compound skills through consistent feedback.
allowed-tools: Read, Write, Glob, Grep, Task
---

# Practice Review

**Core Purpose:** Help the user compound their development skills by providing consistent, evidence-based feedback on how well they're adhering to their own stated practices.

> This is not about improving Claude's automation (that's `/retro`). This is about helping the *user* reflect on and improve their own habits.

## When to Use

**Proactive suggestion (end of substantive sessions):**
- Session involved meaningful work (not just quick questions)
- Session touched areas covered by defined practices
- Phrase as: "This session touched [practice area]. Want to run `/practice-review` to reflect on how it went?"

**Explicit invocation:**
- User says `/practice-review` or "how did I do on my practices?"
- User asks for practice feedback or reflection

**Do NOT suggest when:**
- Very short sessions (< 5 back-and-forth exchanges)
- Session was purely informational/research
- User seems rushed or frustrated

## Files

- **Practices definition:** `~/.claude/practices.md`
- **Review log:** `~/.claude/practice-reviews.md`

## Review Process

### Phase 1: Load Context

1. Read `~/.claude/practices.md` to understand what practices to evaluate
2. Read recent entries from `~/.claude/practice-reviews.md` (last 5-10 sessions) for trend context
3. Identify which practices are relevant to this session

### Phase 2: Gather Evidence

For each relevant practice, scan the session for:

**Positive signals:**
- Actions that align with the practice
- Questions asked that show good habits
- Decisions that reflect the practice

**Negative signals:**
- Moments that violated the practice
- Missed opportunities to apply the practice
- Patterns that suggest slipping

**Neutral observations:**
- Context that might explain behavior
- Constraints that affected choices

Be specific. Quote or reference actual moments from the session.

### Phase 3: Rate and Reflect

For each relevant practice:
1. **Rating:** 1-10 scale based on evidence
2. **Evidence:** Specific examples from this session
3. **Trend:** Compare to recent sessions (↑ improving, → stable, ↓ slipping)
4. **Note:** One sentence on what went well or what to focus on

### Phase 4: Present to User

Format output as:

```
## Practice Review - [Date]

**Session:** [brief description of what was worked on]
**Project:** [project name if identifiable]

### [Practice Name]
- **Rating:** X/10 [trend arrow if history exists]
- **Evidence:** [specific examples from session]
- **Note:** [observation or suggestion]

### [Next Practice...]

---

### Overall: X/10

**Highlight:** [One thing that went particularly well]
**Focus for next time:** [One thing to be mindful of]

---
Log this review? (y/n)
```

### Phase 5: Log Review

If user confirms, append to `~/.claude/practice-reviews.md`:

```markdown
## [YYYY-MM-DD] | project: [name] | overall: X/10

### [Practice Name]
- **Rating:** X/10
- **Evidence:** [brief]
- **Note:** [brief]

[repeat for each practice reviewed]

---

```

## Trend Calculation

When reading historical reviews:

1. Parse ratings for each practice from recent entries
2. Calculate simple moving average (last 5 sessions)
3. Compare current session to average:
   - Current > avg + 1: ↑ (improving)
   - Current < avg - 1: ↓ (slipping)
   - Otherwise: → (stable)

Display as: `Rating: 7/10 (↑ from 5.2 avg)`

## Rating Guide

- **9-10:** Exemplary - actively demonstrated the practice, clear positive examples
- **7-8:** Good - followed the practice, minor misses
- **5-6:** Mixed - some adherence, some slips, room for improvement
- **3-4:** Struggled - practice was relevant but largely not followed
- **1-2:** Missed - clear opportunity to apply practice, didn't happen

Be calibrated but not harsh. The goal is useful feedback, not judgment.

## Tips

1. **Only review relevant practices** - Skip practices that didn't apply to this session
2. **Be specific** - Vague feedback isn't actionable
3. **Acknowledge constraints** - Sometimes circumstances prevent ideal practice
4. **Focus on patterns** - One slip isn't a trend, repeated slips are
5. **Celebrate wins** - Positive reinforcement matters
6. **Keep logs concise** - Reviews should be scannable, not essays
7. **Respect user's time** - If they decline logging, don't push

## Weekly Rollup (Optional)

If user requests, generate a weekly summary:

```markdown
## Week of [date] | Summary

| Practice | Avg | Trend | Sessions |
|----------|-----|-------|----------|
| Practice 1 | 7.2 | ↑ | 4 |
| Practice 2 | 6.0 | → | 3 |

**Wins this week:** [summary]
**Focus for next week:** [summary]
```
