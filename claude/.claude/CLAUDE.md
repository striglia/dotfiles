# Global Claude Code Instructions

## Core Principles

- **Simplicity First**: Make every change as simple as possible. Impact minimal code.
- **No Laziness**: Find root causes. No temporary fixes. Senior developer standards.
- **Minimal Impact**: Changes should only touch what's necessary. Avoid introducing bugs.

## Workflow Philosophy

### Plan Mode Default
- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan immediately—don't keep pushing
- Use plan mode for verification steps, not just building
- Write detailed specs upfront to reduce ambiguity

### Verification Before Done
- Never mark a task complete without proving it works
- Diff behavior between main and your changes when relevant
- Ask yourself: "Would a staff engineer approve this?"
- Run tests, check logs, demonstrate correctness

### Demand Elegance (Balanced)
- For non-trivial changes: pause and ask "is there a more elegant way?"
- If a fix feels hacky: "Knowing everything I know now, implement the elegant solution"
- Skip this for simple, obvious fixes—don't over-engineer
- Challenge your own work before presenting it

### Autonomous Bug Fixing
- When given a bug report: just fix it. Don't ask for hand-holding
- Point at logs, errors, failing tests—then resolve them
- Zero context switching required from the user
- Go fix failing CI tests without being told how

### Self-Improvement Loop
- After ANY correction from the user: update `tasks/lessons.md` with the pattern
- Write rules for yourself that prevent the same mistake
- Ruthlessly iterate on these lessons until mistake rate drops
- Review lessons at session start for relevant project

### Task Management
1. **Plan First**: Write plan to `tasks/todo.md` with checkable items
2. **Verify Plan**: Check in before starting implementation
3. **Track Progress**: Mark items complete as you go
4. **Explain Changes**: High-level summary at each step
5. **Document Results**: Add review section to `tasks/todo.md`
6. **Capture Lessons**: Update `tasks/lessons.md` after corrections

## Workflow Preferences

- **auto-git-workflow**: Always use the `/git-workflow` skill (not manual git commands) for feature branch work. Follow the skill step-by-step—every phase is mandatory. Complete phases without pausing for explicit user prompts.
- **auto-cleanup-after-merge**: After merging a PR (whether user merges or Claude merges), automatically clean up local git: checkout main, pull, delete merged feature branches.
- **practice-review-prompts**: At the end of substantive sessions (meaningful work, not quick questions), offer to run `/practice-review` if the session touched areas covered by `~/.claude/practices.md`. Phrase as: "This session touched [area]. Want to run `/practice-review` to reflect on how it went?"
- **reconstruct-before-pr**: Always reconstruct history before pushing PR (automatic in git-workflow Phase 3.5). Set `skip-history-reconstruction: true` to disable.
- **test-commit-style: together** — Keep tests with their implementation in the same commit during history reconstruction. Alternative: `separate` to put tests in their own commit.

## Subagent Strategy

**When to use subagents:**
- Use subagents liberally to keep main context window clean
- Offload research, exploration, and parallel analysis to subagents
- For complex problems, throw more compute at it via subagents
- One task per subagent for focused execution

**Context management:**
- **Cap output returned to main context**: Subagents should return concise summaries (key findings, not full transcripts). If the user needs detail, they'll ask.
- **Write verbose findings to temp files**: For large analysis tasks (mining session logs, scanning git history), have subagents write full reports to `/tmp/` and return only the summary + file path.
- **Avoid context overflow**: Dumping multiple large subagent reports into the main conversation causes compaction and context loss. Summarize first, detail on demand.

## Process Artifact Discoverability

When creating new files that agents should consult (like `insights.md`, `ARCHITECTURE.md`, or similar process artifacts):

- **Update CLAUDE.md in the same commit** — don't ask, just do it. If a file's purpose is to be read by future agents, it must be referenced from the file every agent reads at session start.
- **Include the file in relevant sections**: Add a brief description of what the file contains and when to consult it.
- **This is not optional**: Creating an agent-facing file without updating CLAUDE.md is like adding a tool without documenting it.

## Bug Fix Workflow

When implementing ANY bugfix—whether from:
- A bug report ("X is not working", "X is broken")
- A plan that fixes a bug
- A PR review comment about a bug
- A failing test investigation

**ALWAYS:**
1. Invoke `/tdd-bugfix` skill FIRST, before writing any fix code
2. Write a failing test that reproduces the bug
3. THEN implement the fix
4. Never rationalize skipping tests because code is "hard to test"
   - If testing requires infrastructure, BUILD the infrastructure
   - That infrastructure has value for future development
   - "Manual testing" is not acceptable for agentic workflows

## Development Conventions

- **Playwright screenshots**: Always use `downloadsDir: "/tmp"` when taking screenshots to avoid polluting ~/Downloads

## Skills Editing Workflow

When editing skills in `~/.claude/skills/`:
1. Skills are stored in a git repo (dotfiles)
2. After editing, commit changes: `cd ~/.claude/skills && git add . && git commit -m "Update {skill-name}: {description}"`
3. Push to remote: `git push`

## Skill File Locations

When looking for skill files (referenced by `/skill-name` or in skill invocations):

1. **Check project-local first**: `.claude/skills/` in the current project directory
2. **Then check global**: `~/.claude/skills/`

Project-local skills take precedence over global skills with the same name. This allows projects to override or customize global skills.

## Validate User Assumptions

When user references specific files/repos by name:
1. Search to verify they exist
2. If found in different locations than stated, mention it: "I found X in {actual} instead of {stated}"
3. If not found where stated, ask for clarification before proceeding

## Research Before Implementing

When asked to add a pattern/feature:
1. Search for existing examples (Glob/Grep)
2. Read 2-3 examples to understand the pattern
3. Read target file to understand structure
4. Make comprehensive updates (not just minimum)
5. Only ask if pattern is unclear or examples conflict

## Architecture Principle Hierarchy

General principles live in the `architecture-astronaut` agent. Project-specific applications and nuances live in each project's `ARCHITECTURE.md`.

**Bidirectional sync:**

1. **When updating a project's ARCHITECTURE.md with a new principle:**
   - Ask: Is this principle general or project-specific?
   - If general → add to `architecture-astronaut` agent, keep project ARCHITECTURE.md as application/example
   - If project-specific → keep only in project ARCHITECTURE.md

2. **When updating `architecture-astronaut` with a new principle:**
   - Vet relevant project ARCHITECTURE.md files for compliance
   - Projects don't need to duplicate—general principles can live only in the agent
   - Add project-specific entries only when the application is nuanced for that project

3. **After any architectural change:**
   - Run `architecture-astronaut` to verify code compliance
   - Report findings proactively, don't wait to be asked

## Architecture Review

Projects may have an **ARCHITECTURE.md** file (generated by `/establish-ai`) that documents design philosophy, core principles, and patterns. When working on non-trivial projects:

1. Check for ARCHITECTURE.md at project root or in docs/
2. Read it before making architectural changes
3. Use the **architecture-astronaut** agent for code structure reviews, integration planning, or evaluating architectural decisions
4. Update ARCHITECTURE.md when making significant architectural changes

## Plan Quality Requirements

Plans are validated by a Stop hook before completion. Include these sections or the hook will block:

**Required sections:**

1. **Success Criteria** - Measurable outcomes, not vague goals
   - Bad: "tests pass" | Good: "all 23 unit tests pass"
   - Bad: "works correctly" | Good: "API returns 200 for valid input, 400 for invalid"
   - Bad: "code is clean" | Good: "no ESLint errors, coverage >= 80%"

2. **Stopping Conditions** - BOTH completion triggers AND early termination
   - Bad: "when done" | Good: "when CI green AND all criteria checked"
   - Must include abort conditions: "Stop EARLY if: dependency unavailable OR blocking bug"
   - Pattern: "Stop when ALL: [list]" + "Stop EARLY if ANY: [list]"

3. **Verification** - Concrete check for each success criterion
   - Commands: `npm test`, `curl localhost:3000/health`
   - Observable behaviors: "Click X, see Y"
   - Specific outputs: "Log shows 'Migration complete'"

**Why this matters:** Without clear stopping conditions, agents require user nudges ("yes continue", "keep going") or stop prematurely. Measurable criteria enable autonomous completion.
