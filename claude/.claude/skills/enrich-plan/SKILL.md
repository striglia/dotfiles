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

Conduct multiple rounds of questioning using `AskUserQuestion`. Each round should:

1. **Focus on a specific dimension** (rotate through these):
   - Technical implementation approach
   - Data model and state management
   - UI/UX behavior and edge cases
   - Error handling and failure modes
   - Performance and scalability
   - Security and privacy
   - Testing strategy
   - Migration and rollout
   - Dependencies and blocking concerns
   - Future extensibility

2. **Ask 1-4 questions per round** (use multi-question format)

3. **Build on previous answers** - each round should go deeper based on what was learned

4. **Continue until**:
   - All critical dimensions are covered
   - User signals completion
   - No more non-obvious questions remain

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

If the original plan came from a GitHub issue:

1. **Ask user for confirmation**: "Would you like me to post this enriched plan as a comment on issue #X?"

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

Use these as starting points - always customize based on the specific document:

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

## Interview Best Practices

0. **Use the right tool**: use the AskUserQuestionTool

1. **Start broad, go deep**: First questions establish context, later questions drill into specifics

2. **Follow the energy**: If user has strong opinions on a topic, explore it thoroughly

3. **Challenge assumptions**: "You said X - but what if that assumption is wrong?"

4. **Explore alternatives**: "Is there another way to achieve this that we should consider?"

5. **Quantify when possible**: "How many users/requests/items are we talking about?"

6. **Think adversarially**: What could go wrong? What would a malicious user do?

7. **Consider the future**: "If we need to extend this in 6 months, will this design accommodate?"

## Output Format

The enriched spec should include ALL of the following. This format is designed to be **self-sufficient** - a future implementer reading only this document should have everything they need.

```markdown
# [Feature Name]

## Overview
[Original or refined overview - what are we building and why]

## Key Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| [Topic] | [What we decided] | [WHY we decided this - the reasoning from the interview] |
| [Topic] | [What we decided] | [WHY - include tradeoffs considered] |

## Interview Insights

Key context that emerged from the planning discussion:
- **[Insight]**: [Context that informed the design but doesn't fit elsewhere]
- **[Constraint discovered]**: [Something we learned that shapes implementation]
- **[User preference]**: [Specific request or preference expressed]

## Requirements

### Functional Requirements
- [Explicit requirement with acceptance criteria]

### Non-Functional Requirements
- [Performance, security, accessibility, etc. with specific targets]

## Technical Design

### Architecture Overview
[How the pieces fit together]

### Data Model
[Full schema with field types and examples, not just field names]

### Component/Module Structure
[What files/modules, their responsibilities, how they interact]

### API Changes
[Endpoints, signatures, request/response examples]

## UI/UX Behavior

### User Flows
[Step-by-step flows for primary scenarios]

### States
- **Loading**: [What user sees]
- **Empty**: [What user sees when no data]
- **Error**: [What user sees on failure]
- **Success**: [Normal state]

### Interactions
[Click behaviors, transitions, feedback]

## Edge Cases & Error Handling

| Scenario | Behavior | Rationale |
|----------|----------|-----------|
| [Specific edge case] | [Exactly what happens] | [Why this approach] |
| [Error condition] | [Recovery behavior] | [Why this fallback] |
| [Missing data] | [Default behavior] | [Why this default] |

## Testing Strategy
- **Critical path**: [Most important scenario to test]
- **Edge cases**: [Which edge cases need test coverage]
- **How to test failures**: [Approach for testing error paths]

## Implementation Notes
- [Specific patterns to follow from existing codebase]
- [Gotchas or things to watch out for]
- [Dependencies or ordering constraints]

## Out of Scope (and why)
- **[Feature/enhancement]**: Deferred because [specific reason]
- **[Complexity]**: Not needed for MVP because [reason]

## Open Questions
- [Anything that couldn't be resolved and needs future decision]

---
*This is the authoritative implementation spec, developed using `/enrich-plan`.*
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

Claude: I've read the spec for "User Activity Dashboard". The doc covers
the basic features but I have questions about several areas. Let me start
with the data layer:

[AskUserQuestion with 3 questions about data aggregation, retention, and access patterns]

User: [Provides answers - e.g., "90 day retention, aggregate daily, users see only their own data"]

Claude: Good context. The retention policy of 90 days makes sense. Now about
the UI - I noticed the spec mentions "real-time updates" but doesn't specify
the behavior:

[AskUserQuestion about real-time behavior, loading states, conflict resolution]

User: [Provides answers]

[... several more rounds ...]

Claude: I think we've covered the major dimensions. Let me write the enriched
spec back to SPEC.md with all the decisions we've made.

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
