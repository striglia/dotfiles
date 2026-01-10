---
name: roadmap-to-milestone-and-issues
description: Transforms high-level goals into structured GitHub milestones and issues. Uses extended thinking to decompose objectives into independent, actionable work items. Can recursively use /enrich-plan for deeper specification.
allowed-tools: Read, Bash(gh:*), Bash(git:*), Glob, Grep, Task, AskUserQuestion
---

# Roadmap to Milestones and Issues

Transform high-level project goals into well-structured GitHub milestones with independent, actionable issues.

## Quick Usage

```bash
# Provide a goal directly
/roadmap-to-milestone-and-issues "Add AI-powered cooking assistant with voice interaction"

# Provide a goal with context file
/roadmap-to-milestone-and-issues "Implement Phase 2" --context CLAUDE.md

# Dry run - preview without creating
/roadmap-to-milestone-and-issues "Add user authentication" --dry-run

# Enrich issues with deep questioning
/roadmap-to-milestone-and-issues "Build meal planning feature" --enrich
```

## Core Philosophy

### Think Deeply, Structure Wisely

This skill uses **extended thinking (ultrathink)** to:
- Decompose vague goals into concrete deliverables
- Identify hidden dependencies and prerequisites
- Surface architectural decisions that affect scope
- Find natural boundaries between work items

### Independent Issues Are Key

Each issue should:
- Stand alone - completable without waiting for other issues (within the milestone)
- Have clear acceptance criteria
- Be scoped to 1-4 hours of work
- Advance the milestone's objective

### Milestones Group Related Work

Milestones should:
- Represent a coherent capability or phase
- Have a clear "done" state
- Contain 3-10 issues typically
- Be achievable in days to weeks, not months

## Workflow

### Phase 1: Gather Context

1. **Capture the goal**:
   - If provided as argument, use that
   - Otherwise, ask user: "What high-level goal would you like to break down?"

2. **Research the codebase**:
   - Read CLAUDE.md, README.md, any existing roadmap files
   - Explore current architecture with Glob/Grep
   - Identify existing patterns, conventions, and constraints
   - Note what infrastructure already exists vs. needs building

3. **Ask clarifying questions** (2-3 rounds max):
   - Use `AskUserQuestion` to resolve ambiguities
   - Focus on scope boundaries and priorities
   - Example questions:
     - "Should this include [related feature] or is that separate?"
     - "What's the MVP vs. nice-to-have split?"
     - "Are there external dependencies or integrations to consider?"

### Phase 2: Ultrathink Decomposition

**Use extended thinking to deeply analyze the goal.**

Structure your thinking around:

```
1. GOAL ANALYSIS
   - What is the user actually trying to achieve?
   - What does "done" look like?
   - What are the implicit requirements?

2. CAPABILITY MAPPING
   - What new capabilities are needed?
   - What existing capabilities can be leveraged?
   - What's the dependency graph between capabilities?

3. NATURAL BOUNDARIES
   - Where are the architectural seams?
   - What can be built/tested independently?
   - What requires coordination vs. isolation?

4. MILESTONE DESIGN
   - What are the logical phases or deliverables?
   - What's the minimum viable progression?
   - Should there be 1 milestone or multiple?

5. ISSUE DECOMPOSITION (per milestone)
   - What are the atomic units of work?
   - How do we maximize parallelism?
   - What's the right granularity (1-4 hours per issue)?

6. RISK ASSESSMENT
   - What could go wrong?
   - What needs spike/research first?
   - What has unclear scope that needs /enrich-plan?
```

### Phase 3: Enrich Complex Issues (Optional)

For issues that are complex or ambiguous:

1. **Identify candidates**: Issues with unclear scope, multiple implementation approaches, or significant risk

2. **Spawn /enrich-plan subagent**:
   ```
   Use the Task tool to spawn a subagent that runs /enrich-plan on a temporary
   spec file for the issue. The subagent will:
   - Ask probing questions about the specific issue
   - Flesh out edge cases and acceptance criteria
   - Return an enriched specification
   ```

3. **Integrate enriched content**: Fold the subagent's findings into the issue body

**When to enrich**:
- `--enrich` flag provided: Enrich ALL issues
- Without flag: Only enrich issues you identify as high-risk or ambiguous
- Ask user: "Issue X seems complex. Should I run /enrich-plan to flesh it out?"

### Phase 4: Create GitHub Artifacts

1. **Create milestone(s)**:
   ```bash
   gh api repos/{owner}/{repo}/milestones -f title="Milestone Title" -f description="Description" -f state="open"
   ```

2. **Get milestone number**:
   ```bash
   gh api repos/{owner}/{repo}/milestones --jq '.[] | select(.title=="Milestone Title") | .number'
   ```

3. **Create issues** with milestone assignment:
   ```bash
   gh issue create \
     --title "Clear, actionable title" \
     --milestone "Milestone Title" \
     --body "$(cat <<'ISSUE_EOF'
   ## Objective
   What this issue accomplishes and why it matters.

   ## Context
   Background information and how this fits into the larger goal.

   ## Tasks
   - [ ] Specific actionable task 1
   - [ ] Specific actionable task 2
   - [ ] Specific actionable task 3

   ## Acceptance Criteria
   - [ ] Criterion 1 (testable)
   - [ ] Criterion 2 (testable)

   ## Files to Modify/Create
   - `path/to/file1.swift`
   - `path/to/new-file.swift` (new)

   ## Technical Notes
   Implementation hints, patterns to follow, gotchas to avoid.

   ## Out of Scope
   What this issue explicitly does NOT cover (handled elsewhere).

   ---
   *Generated by `/roadmap-to-milestone-and-issues`*
   ISSUE_EOF
   )"
   ```

### Phase 5: Report Results

Provide a summary:

```
## Created Milestone(s)

### Milestone: {title}
{description}

Issues:
1. #{num}: {title} - {one-line summary}
2. #{num}: {title} - {one-line summary}
...

### Recommended Order
1. Start with: #{num} (no dependencies)
2. Then: #{num}, #{num} (can be parallel)
3. Finally: #{num} (depends on above)

### Notes
- {Any decisions made during decomposition}
- {Issues flagged for /enrich-plan but not enriched}
- {Risks or open questions}
```

## Issue Quality Checklist

Before creating each issue, verify:

- [ ] **Title is actionable**: Starts with verb (Add, Create, Implement, Fix, Update)
- [ ] **Objective is clear**: One sentence explaining the "what" and "why"
- [ ] **Tasks are specific**: Each checkbox is a concrete action, not vague
- [ ] **Acceptance criteria are testable**: Can objectively verify done/not-done
- [ ] **Scope is bounded**: Clear "out of scope" section prevents creep
- [ ] **Context is sufficient**: New implementer can start without asking questions
- [ ] **Files are identified**: Specific paths, not "various files"

## Milestone Design Patterns

### Single Milestone (Most Common)
Use when the goal is cohesive:
- "Add dark mode support"
- "Implement user authentication"
- "Create recipe import feature"

### Multiple Milestones
Use when the goal has distinct phases:
- "Build AI cooking assistant" →
  - Milestone 1: Voice Input Infrastructure
  - Milestone 2: Recipe Context Integration
  - Milestone 3: Conversational UI

### Spike + Implementation
Use when there's significant uncertainty:
- Milestone 1: Research Spike (time-boxed exploration)
- Milestone 2: Implementation (informed by spike findings)

## Handling Uncertainty

| Situation | Action |
|-----------|--------|
| Technical approach unclear | Create "Spike: Research X" issue first |
| Scope seems too large | Ask user to prioritize, split into milestones |
| Dependencies on external systems | Note in issue, flag as potential blocker |
| Multiple valid approaches | Document options in issue, let implementer decide |
| Need user input | Use AskUserQuestion before creating |

## Integration with /enrich-plan

The `/enrich-plan` skill can be invoked recursively for complex issues:

```
Spawn a Task subagent with:

prompt: |
  Run /enrich-plan on the following issue specification. Ask probing questions
  to flesh out edge cases, technical decisions, and acceptance criteria.
  Return the enriched specification.

  Issue: {issue title}
  Current spec:
  {draft issue body}

subagent_type: general-purpose
```

The subagent will:
1. Read the draft specification
2. Ask 2-4 rounds of clarifying questions via AskUserQuestion
3. Return an enriched version with detailed requirements

## Example Session

```
User: /roadmap-to-milestone-and-issues "Add AI cooking assistant that can answer questions while cooking"

Claude: [Reads CLAUDE.md, explores codebase architecture]

Claude: Let me clarify the scope:
[AskUserQuestion: "Voice interaction too, or text-only for v1?" + "Should it control timers, or just answer questions?"]

User: Text-only first, and yes it should be able to set/manage timers.

Claude: [Extended thinking: analyzing capabilities needed, finding natural boundaries...]

Claude: I'll create one milestone with 6 issues:

**Milestone: AI Cooking Assistant v1**

1. #15: Add chat UI component to RecipeDetailView
2. #16: Create CookingAssistantService for LLM integration
3. #17: Implement timer management system
4. #18: Add recipe context injection for AI responses
5. #19: Create cooking session state management
6. #20: Integrate assistant with timer controls

Issue #16 seems complex - should I run /enrich-plan to flesh out the LLM integration details?

User: Yes, enrich that one.

Claude: [Spawns /enrich-plan subagent for issue #16]
[Subagent asks questions, returns enriched spec]

Claude: [Creates milestone and all 6 issues]

Done! Created milestone "AI Cooking Assistant v1" with 6 issues.
Recommended starting point: #15 and #17 (can be parallel, no dependencies).
```

## Tips

1. **Start broad, then narrow**: Understand the full goal before decomposing
2. **Err toward more issues**: Smaller scope = clearer progress = easier review
3. **Name things well**: Issue titles should be scannable in a list
4. **Link related issues**: Use "Related: #X" in issue bodies
5. **Flag risks explicitly**: Unknown unknowns kill projects
6. **Trust the process**: Ultrathink before typing `gh issue create`
