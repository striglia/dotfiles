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
- **Skill changelog:** `~/.claude/skills/practice-review/CHANGELOG.md` — records how this skill evolves over time (~monthly)

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

For each relevant **active** practice:
1. **Rating:** 1-10 scale based on evidence
2. **Evidence:** Specific examples from this session
3. **Trend:** Compare to recent sessions (↑ improving, → stable, ↓ slipping)
4. **Note:** One sentence on what went well or what to focus on

For each relevant **graduated (probationary)** practice:
1. **Rating:** Still rate internally using the same 1-10 scale
2. **Only surface to user if score < 7** — if 7+, these practices stay quiet
3. If < 7 in this session, flag it: include in the review with a regression warning
4. Track consecutive sub-7 scores; two in a row triggers re-activation proposal

### Phase 4: Present to User

Format output as:

```
## Practice Review - [Date]

**Session:** [brief description of what was worked on]
**Project:** [project name if identifiable]

### [Active Practice Name]
- **Rating:** X/10 [trend arrow if history exists]
- **Evidence:** [specific examples from session]
- **Note:** [observation or suggestion]

### [Next Active Practice...]

### Graduated practices: [holding steady | ⚠️ regression]
- If all graduated practices scored 7+: "Holding steady — no regression."
- If any scored < 7: Show full rating + evidence + regression warning for those practices only.

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

### Phase 6: Practices Evolution

After logging the review, check whether any practices should evolve. This phase proposes concrete edits to `~/.claude/practices.md` — the user approves or rejects each one.

**Three evolution types:**

**Graduate (Probationary)** — Quiet down practices that have become habits.
- Trigger: Consistently 8+ over 5+ sessions (or 9+ over 4+)
- Action: Propose moving to "Graduated (Probationary)" section in practices.md
- Effect: Still rated every session, but only surfaced to user if score drops below 7
- Re-activation: Two consecutive sessions below 7 → propose moving back to active
- Rationale: Tracking mastered habits creates noise, but probationary status catches regression

**Add** — Promote emerging patterns to real practices.
- Trigger: A "Focus for next time" note appears across 2+ reviews, OR a clear new pattern emerges in the session
- Action: Propose a new practice with name, bullets, and "Signs I'm doing well / slipping"
- Rationale: The review process sees patterns the user might not notice

**Sharpen** — Split or refine practices with high variance.
- Trigger: Rating variance > 4 points across sessions (e.g., 3 one week, 10 the next)
- Action: Propose splitting into sub-practices or adding more specific triggers
- Rationale: High variance suggests the practice definition is too broad to be actionable

**Format:**

```
### Practices Evolution

**Graduate "Steer, Don't Row"?**
Scores: 9, 8, 8, 10 across 4 sessions. This looks like a habit, not a practice.
→ Move to Graduated section? (y/n)

**Add "Weekly Reflection Quality"?**
Emerged from two sessions of exocortex analysis work. Proposed definition:
- [draft practice definition]
→ Add to practices.md? (y/n)
```

Only propose evolutions when there's clear evidence. Not every review needs this section — skip it if nothing qualifies. When in doubt, wait another session for more data.

### Phase 7: Practices Audit (Periodic)

After Phase 6, check whether a full practices audit is due. This is the "zoom out" step — instead of evolving one practice at a time, review the entire system.

**Trigger:** Count reviews in `practice-reviews.md` since the last audit entry (entries tagged `(audit)` in the header). If 8+ reviews since last audit, or no audit has ever been done, suggest:

```
You have N reviews since the last practices audit. Want to do a full audit of your practices?
This looks at the whole history — trends, plateaus, graduation candidates, and whether the practice set is still serving you.
```

**If user accepts, run the audit:**

1. **Parse all review history** — extract every rating for every practice
2. **Compute statistics per practice:**
   - Average rating (all-time and last 5 sessions)
   - Variance (max - min across all sessions)
   - Trend (improving, stable, slipping)
3. **Present summary table:**

```
| Practice | Avg (all) | Avg (last 5) | Variance | Signal |
|----------|-----------|--------------|----------|--------|
| Practice 1 | 7.2 | 8.0 | Low | Improving |
| Practice 2 | 6.0 | 6.1 | Very high | Sharpen? |
```

4. **Identify candidates** for each evolution type:
   - **Graduate:** avg 8+ over 5+ sessions, low variance
   - **Sharpen:** variance > 4 points, or stable plateau for 5+ sessions
   - **Add:** recurring "Focus" notes (2+ mentions), emerging patterns
   - **Re-activate:** graduated practice with regression
   - **Retire:** practice no longer relevant to current work
5. **Propose specific edits** to `practices.md` for each candidate
6. **Log the audit** as a special entry in `practice-reviews.md`:

```markdown
## [YYYY-MM-DD] | practices audit (audit)

**Reviews analyzed:** N (since [date])

### Changes Made
- Graduated: [list]
- Sharpened: [list]
- Added: [list]
- No change: [list]

### Statistics
[summary table]

---
```

**If user declines:** Note the count and move on. Don't re-prompt until 4 more reviews accumulate.

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
