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

**Signs I'm doing well:** Sessions end naturally, context stays manageable, no compaction needed
**Signs I'm slipping:** Hitting context warnings, compacting mid-session, losing important context

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
