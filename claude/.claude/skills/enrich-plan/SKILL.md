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

**Non-obvious questions only.** Never ask:
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
3. **Annotate with decisions** made during interview
4. **Include explicit tradeoff documentation**
5. **Write back to the original file** (or create new if requested)

### Phase 4: Post Back to GitHub (if applicable)

If the original plan came from a GitHub issue:

1. **Ask user for confirmation**: "Would you like me to post this enriched plan as a comment on issue #X?"

2. **If confirmed**, post a summary comment including:
   - Key decisions table
   - User flows overview
   - Technical approach highlights
   - Out of scope items
   - Note that the plan was developed using `/enrich-plan`

3. **Format for GitHub**: Use markdown tables, collapsible sections for lengthy details

Example:
```bash
gh issue comment {issue-number} --body "## Enriched Implementation Plan

After running through the \`/enrich-plan\` skill...

| Topic | Decision |
|-------|----------|
| ... | ... |

*This plan was developed using the \`/enrich-plan\` skill to systematically clarify requirements.*"
```

This creates a documented audit trail linking the GitHub issue to the implementation decisions.

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

The enriched spec should include:

```markdown
# [Feature Name]

## Overview
[Original or refined overview]

## Decisions Made
- **[Topic]**: [Decision] - [Rationale]
- **[Topic]**: [Decision] - [Rationale]

## Requirements

### Functional Requirements
- [Explicit requirement from interview]

### Non-Functional Requirements
- [Performance, security, etc.]

## Technical Design
[Detailed implementation approach]

### Data Model
[If applicable]

### API Changes
[If applicable]

### UI/UX Behavior
[Detailed interaction flows]

## Edge Cases & Error Handling
- **[Scenario]**: [Behavior]

## Testing Strategy
- [What to test and how]

## Rollout Plan
- [Migration, feature flags, etc.]

## Open Questions
- [Anything still unresolved]

## Tradeoffs Accepted
- **[Tradeoff]**: We chose [A] over [B] because [reason]
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

User: [Provides answers]

Claude: Good context. The retention policy of 90 days makes sense. Now about
the UI - I noticed the spec mentions "real-time updates" but doesn't specify
the behavior:

[AskUserQuestion about real-time behavior, loading states, conflict resolution]

User: [Provides answers]

[... several more rounds ...]

Claude: I think we've covered the major dimensions. Let me write the enriched
spec back to SPEC.md with all the decisions we've made.

[Writes comprehensive spec]
```
