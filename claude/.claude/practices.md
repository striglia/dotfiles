# My Development Practices

Personal practices I'm actively working to improve. Used by `/practice-review` for end-of-session reflection.

---

## Spec & Planning Work

### Conversational over Waterfall
- Engage iteratively with specs rather than building everything upfront
- Ask clarifying questions early, before deep implementation
- Share partial progress to validate direction
- Treat specs as living conversations, not fixed contracts

**Signs I'm doing well:** Asking questions, showing incremental work, pivoting based on feedback
**Signs I'm slipping:** Building large features before checking in, "big reveal" moments, rework after misunderstanding

### Co-Design in Plan Mode
- Use plan mode to co-design approaches before committing to implementation
- Even for well-specified tasks, pause to consider design alternatives together
- Bring messy, half-formed concepts early rather than polishing them in isolation
- Let Claude help shape the idea, not just execute a finished spec

**Signs I'm doing well:** Starting sessions in plan mode, sharing rough ideas, exploring alternatives before building
**Signs I'm slipping:** Arriving with fully-formed specs, skipping design discussion, treating Claude as executor not collaborator

### Steer, Don't Row
- Spend time on requirements and direction, not implementation details
- Focus on injecting taste and wisdom - that's the highest-leverage use of my time
- Let Claude handle the mechanical work while I focus on "what" and "why"
- Stay out of unimportant implementation details
- My value-add is judgment, priorities, and quality standards

**Signs I'm doing well:** Giving feedback on direction and quality, delegating implementation, focusing on requirements clarity
**Signs I'm slipping:** Dictating implementation details, micro-managing code style, doing work Claude could do

---

## Automation & Feedback Loops

### Build Autonomous Loops
- Invest in automation that lets Claude operate without manual check-ins
- Don't do manual testing when you can write automated tests
- Don't inspect logs by hand when logs can be made available to Claude
- Don't verify by hand when you can write assertions or tests
- Use TDD loops, compilation, type checking, formatting as automated feedback
- Goal: reduce ambiguity in the design space and close loops faster

**Signs I'm doing well:** Writing tests before asking Claude to implement, setting up tooling that Claude can run, investing in automation upfront
**Signs I'm slipping:** Being the human-in-the-loop for things that could be programmatic, manually verifying output, copy-pasting logs into chat

---

## Context & Session Management

### Minimize Compaction
- Prefer shorter, focused sessions over marathon sessions that hit context limits
- Use targeted file reads instead of dumping entire files
- Be intentional about what context is loaded
- Exit and restart sessions when context is getting heavy rather than compacting
- **Assess scope BEFORE starting** — if a task looks large, split into sessions upfront

**Scope triggers** (any of these → plan session boundaries first):
- Issue touches >2 subsystems (e.g., backend + client + hosting)
- Issue checklist has 4+ items
- Title contains "migrate", "productionize", "refactor", or "overhaul"
- Expected output is >10 files or >5 commits
- Multiple languages/runtimes involved (e.g., TypeScript + Swift + HTML)

**Splitting strategy**: Each session should produce an independently committable unit. Prefer vertical slices (infrastructure → integration → testing → cleanup) over horizontal ones.

**Signs I'm doing well:** Sessions end naturally, scope assessed upfront, proactive splitting, <10 files per session
**Signs I'm slipping:** Hitting context warnings, 10+ files in a session, "just one more thing" scope creep, no scope check at start

---

## Template for Adding Practices

<!--
### [Practice Name]
- Bullet points describing the practice
- What it looks like in action
- Why it matters

**Signs I'm doing well:** [Observable positive indicators]
**Signs I'm slipping:** [Observable negative indicators]
-->
