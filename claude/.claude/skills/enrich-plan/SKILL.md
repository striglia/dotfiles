---
name: enrich-plan
description: Enriches design documents through deep, probing interviews. Reads a SPEC.md file and asks non-obvious questions about technical implementation, UI/UX, concerns, tradeoffs, edge cases, and more until the spec is comprehensive.
allowed-tools: Read, Write, Edit, Glob, Grep, AskUserQuestion
---

# Enrich Plan Skill

Transform high-level design documents into comprehensive, implementation-ready specs through rigorous, probing interviews.

## When to Use

Invoke when the user has:
- A GitHub issue describing a feature
- A PRD (Product Requirements Document)
- A rough spec or design doc
- Any written plan that needs fleshing out

## Quick Usage

```bash
# Enrich a spec file
/enrich-plan SPEC.md

# Enrich a plan in .claude/plans
/enrich-plan .claude/plans/feature-plan.md

# Auto-detect spec file in current directory
/enrich-plan
```

## Core Philosophy

### Self-Sufficiency is Paramount

The enriched spec (especially when posted to GitHub) must be **completely self-sufficient**. A future implementer - human or AI - reading ONLY this document should have everything needed to build the feature correctly.

This means:
- Capture the WHY, not just the WHAT
- Include rationale for every decision
- Document edge cases explicitly
- Don't assume context from the interview is obvious

### Non-obvious questions only

Never ask:
- Questions the document already answers
- Questions with obvious answers from context
- Generic checklist questions

**Instead, probe deeply:**
- Edge cases the author likely hasn't considered
- Implicit assumptions that need validation
- Integration points with existing systems
- Failure modes and recovery strategies
- Tradeoffs between competing approaches

## Workflow

### Phase 1: Read and Analyze

1. **Locate the spec file**:
   - If path provided, use that
   - Otherwise ask for it

2. **Deep read the document**:
   - Understand the feature/change being proposed
   - Identify what's explicitly stated vs. implied
   - Note any gaps, ambiguities, or unstated assumptions
   - Map dependencies on existing code/systems

3. **Research the codebase**:
   - Find related existing code
   - Understand current patterns and conventions
   - Identify integration points
   - Note any constraints from existing architecture

### Phase 2: Interview Loop

Conduct **4-6 rounds** of questioning using `AskUserQuestion`. Blend calibration with topic questions naturally - don't make calibration feel like a separate interrogation.

#### Early Questions (Rounds 1-2)

Weave in calibration while exploring the most obvious gaps:
- "What's the riskiest or most uncertain part of this?" (calibration)
- "How firm is this - validating decisions or exploring options?" (calibration)
- [First topic question based on obvious gap in the spec]

This surfaces where to spend time. Skip dimensions that don't matter for this feature.

#### Middle Questions (Rounds 3-4)

Go deeper on high-uncertainty areas. Cover dimensions **proportional to risk**:
- Technical implementation approach
- Data model and state management
- UI/UX behavior and edge cases
- Error handling and failure modes
- Performance and scalability
- Security and privacy
- Accessibility (if user-facing)
- Success metrics ("How will we know this worked?")
- Testing strategy
- Migration and rollout
- Dependencies and blocking concerns

#### Handling "I Don't Know" Answers

| Topic Type | Response |
|------------|----------|
| Critical path | Push harder - this is a real gap that needs resolution |
| Nice-to-have | Flag as open question, move on |
| Repeated vagueness | Switch to recommendations: "Here's what I'd suggest..." |

#### Exit Criteria

Stop when:
- Critical path decisions are resolved (no blocking "I don't know"s)
- User signals readiness or fatigue
- You could explain the feature to a new implementer

**Target: sufficient to implement with confidence, not perfection.**

### Phase 3: Write Enriched Spec

1. **Preserve original structure** where possible
2. **Add new sections** for discovered requirements
3. **Annotate with decisions** made during interview - include RATIONALE, not just the decision
4. **Include explicit tradeoff documentation** - what alternatives were considered and why rejected
5. **Capture interview insights** - context that emerged from Q&A that shapes implementation
6. **Document all edge cases** discussed, with explicit handling
7. **Write back to the original file** (or create new if requested)

**Remember**: This spec may be posted to GitHub. Write it as if the reader has zero context from the interview.

### Phase 4: Post Back to GitHub (if applicable)

If the original spec came from a GitHub issue, **propose outputting to the same issue**:

1. **Ask user for confirmation**: "Would you like me to post this to issue #X? I can either edit the issue body or add as a comment."

2. **If confirmed**, post the COMPLETE enriched spec. Do NOT summarize or compress.

   **Critical framing**: The GitHub comment must be **self-sufficient**. Future implementers (including other Claude Code sessions) will ONLY have access to this issue. They won't have:
   - The local enriched spec file
   - The interview transcript
   - Context from this conversation

   **You MUST include:**
   - Every decision with its rationale (the WHY, not just the WHAT)
   - All edge cases discussed, with explicit handling
   - Error scenarios and fallbacks
   - UI/UX behavior details (loading states, empty states, error states)
   - Testing strategy highlights
   - Key insights from the interview that informed decisions
   - Out of scope items with explanation of WHY they're deferred

3. **Use collapsible sections for organization**, not truncation:
   ```markdown
   <details>
   <summary>Edge Cases & Error Handling (click to expand)</summary>

   | Scenario | Behavior | Rationale |
   |----------|----------|-----------|
   | No profile exists | Show generic recommendation | Safe default for new users |

   </details>
   ```

4. **Format for scannability**: Use tables with rationale columns, clear headers, and visual hierarchy. But NEVER sacrifice completeness for brevity.

5. **Include authoritative footer**:
   ```markdown
   ---
   *This is the authoritative implementation spec, developed using `/enrich-plan`. Future implementers should treat this document as the source of truth.*
   ```

**Why this matters**: GitHub issues are the persistent record. Local spec files may not exist when someone else picks up the work. The comment IS the spec.

## Question Categories

Use these as starting points - always customize based on the specific document.

### Which Categories to Prioritize

| Spec Type | High Priority | Lower Priority |
|-----------|---------------|----------------|
| Backend/API | Technical, Data, Error Handling, Security | UI/UX, Accessibility |
| UI Feature | UI/UX, Accessibility, Error Handling | Performance, Migration |
| Data Migration | Data, Migration, Testing, Error Handling | UI/UX, Accessibility |
| New Product | Success Metrics, Technical, UI/UX | Migration (none yet) |
| Bug Fix | Error Handling, Testing | Most others (scope is narrow) |

### Technical Implementation
- "The doc mentions X - but what happens when Y occurs simultaneously?"
- "This approach requires Z - have you considered the implications for existing W?"
- "There are two ways to implement this: A (pros/cons) vs B (pros/cons) - which direction?"

### Data & State
- "Where does this state live? Who owns it? What's the source of truth?"
- "What happens to this data when [edge case]?"
- "How do we handle the transition from old data shape to new?"

### UI/UX Behavior
- "What does the user see during the loading/pending state?"
- "If the user does X while Y is in progress, what happens?"
- "How does this interact with [existing feature] when both are active?"

### Error Handling
- "What's the user experience when [specific failure] happens?"
- "How do we recover from a partial failure in this multi-step operation?"
- "What's the fallback if [dependency] is unavailable?"

### Performance & Scale
- "This works for N items - what about 10N? 100N?"
- "What's the cost of this operation at scale? Is it acceptable?"
- "Are there any N+1 query risks or similar patterns here?"

### Security & Privacy
- "Who can see/modify this data? Is that the right access model?"
- "What happens if a malicious user sends [unexpected input]?"
- "Are we logging anything we shouldn't? Exposing anything sensitive?"

### Testing Strategy
- "What's the most critical scenario to test here?"
- "How do we test the failure modes without causing real failures?"
- "What would a regression in this feature look like?"

### Migration & Rollout
- "Can we ship this incrementally or is it all-or-nothing?"
- "What's the rollback plan if something goes wrong?"
- "Do we need a feature flag? What are the flag states?"

### Dependencies & Blockers
- "This depends on X - what if X changes or is removed?"
- "Are there any ordering constraints with other planned work?"
- "What external systems/APIs does this touch?"

### Accessibility
- "How will keyboard-only users navigate this?"
- "What do screen reader users hear at each step?"
- "Are there color contrast or motion sensitivity concerns?"

### Success Metrics
- "How will we know this feature succeeded?"
- "What would make you consider this a failure?"
- "Are there metrics we should track from day one?"

### Meta-Questions (High Value)
These often surface better insights than dimension-by-dimension probing:
- "What are you most uncertain about in this design?"
- "What part do you expect to be hardest?"
- "Is there anything you've been assuming that might not be true?"
- "What would 'good enough' look like for v1?"

## Interview Best Practices

1. **Use `AskUserQuestion`** - the right tool for multi-question rounds
2. **Follow the energy** - if user has strong opinions, explore thoroughly
3. **Challenge assumptions** - "What if that assumption is wrong?"
4. **Quantify** - "How many users/requests/items are we talking about?"
5. **Think adversarially** - what could go wrong? What would a malicious user do?
6. **Synthesize periodically** - "Let me confirm what we've established..." prevents drift

## Interview Anti-Patterns

Avoid these common mistakes:
1. **Checklist interrogation** - mechanically asking every category regardless of relevance
2. **Ignoring signals** - pushing on topics where user is clearly confident/decided
3. **Premature depth** - diving deep before understanding the overall shape
4. **Forgetting calibration** - asking detailed questions without knowing what's uncertain

## Output Format

The enriched spec must be **self-sufficient** - a future implementer reading ONLY this document should have everything needed.

**Critical**: Don't omit detail to keep the doc short. Include every decision, rationale, and edge case discussed. Use collapsible sections for length, not truncation.

**Required sections** (include all that apply):

```markdown
# [Feature Name]

## Overview
## Key Decisions (table: Decision | Choice | Rationale)
## Interview Insights (context that shaped the design)
## Requirements (functional + non-functional)
## Technical Design (architecture, data model, components, APIs)
## UI/UX Behavior (flows, states: loading/empty/error/success)
## Edge Cases & Error Handling (table: Scenario | Behavior | Rationale)
## Testing Strategy
## Implementation Notes
## Out of Scope (and why)
## Open Questions

---
*Authoritative spec developed using `/enrich-plan`.*
```

## Tips for Success

1. **Read the whole document first** - don't start questioning until you understand the full picture

2. **Research before asking** - check the codebase to understand context

3. **Ask "why" not just "what"** - understanding intent helps identify better solutions

4. **Don't accept vague answers** - push for specifics, examples, numbers

5. **Keep a mental model** - track what's been decided vs. still open

6. **Know when to stop** - diminishing returns are real, don't over-engineer

## Example Session

```
User: /enrich-plan SPEC.md

[Claude reads SPEC.md, researches codebase]

Claude: I've read the spec for "User Activity Dashboard". Before diving in,
let me calibrate:

[AskUserQuestion: "What's the riskiest/most uncertain part?" and "How firm is this - validating or exploring?"]

User: "Most uncertain about the real-time updates - not sure if we need them.
Pretty firm on everything else, just need to nail down details."

Claude: Got it - I'll focus most on the real-time question, lighter touch elsewhere.
Let's start there:

[AskUserQuestion about real-time: necessity, fallback if dropped, user expectations]

User: "Actually, polling every 30s is fine. Real-time was nice-to-have."

Claude: That simplifies things significantly. Quick check on the data layer:

[AskUserQuestion: retention policy, access patterns - confident answers expected]

User: "90 days, users see only their own data."

Claude: Clear. Since you mentioned the rest is firm, anything I should
double-check before I write this up?

User: "Nope, looks good."

Claude: Writing the enriched spec now.

[Writes comprehensive spec including:]
- Key Decisions table with rationale column (e.g., "90-day retention | Balances storage costs with useful history")
- Interview Insights section (e.g., "User emphasized spouse collaboration - influenced shareable URL decision")
- Full edge case table (e.g., "No activity data | Show encouraging empty state | New users shouldn't feel broken")
- UI states (loading, empty, error, success)
- Implementation notes specific to the codebase

Claude: Would you like me to post this to GitHub issue #42?

User: Yes

[Posts FULL enriched spec as comment, not a summary, using collapsible sections for length]
```
