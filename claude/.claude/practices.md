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
- **Build test infrastructure at project/feature start**, not piecemeal per-bug
- Set up the testing framework, CI, linting *before* the first feature — not after the third bug
- Don't do manual testing when you can write automated tests
- Don't inspect logs by hand when logs can be made available to Claude
- Don't verify by hand when you can write assertions or tests
- Use TDD loops, compilation, type checking, formatting as automated feedback
- Goal: reduce ambiguity in the design space and close loops faster

**Signs I'm doing well:** Test framework set up before first feature, tooling established upfront (not retrofitted), Claude can run full verify loop without human intervention
**Signs I'm slipping:** Adding tests one-off per bug without framework, manually verifying output, no test infrastructure until 3+ features are built, copy-pasting logs into chat

---

## Context & Session Management

### Scope Before You Start
- **First action in any session: assess scope** — before writing any code
- If scope is too large, split into sessions. Do this BEFORE starting, not after hitting context limits
- The failure mode is never "I scoped correctly but let context bloat" — it's always "I skipped the scope check"
- Each session should produce one independently committable unit

**Scope triggers** (any of these → plan session boundaries first):
- Issue touches >2 subsystems (e.g., backend + client + hosting)
- Issue checklist has 4+ items
- Title contains "migrate", "productionize", "refactor", or "overhaul"
- Expected output is >10 files or >5 commits
- Multiple languages/runtimes involved (e.g., TypeScript + Swift + HTML)

**Splitting strategy**: Prefer vertical slices (infrastructure → integration → testing → cleanup) over horizontal ones.

**Signs I'm doing well:** Scope assessed as first action, sessions end naturally, proactive splitting, <10 files per session
**Signs I'm slipping:** Diving into code before scoping, "just one more thing" scope creep, 10+ files in a session, no scope check at session start

---

## Graduated (Probationary)

Practices that are now habits. Still tracked in reviews, but only mentioned if they regress below 7/10. If a graduated practice drops below 7 in two consecutive sessions, it moves back to active.

### Steer, Don't Row
- Spend time on requirements and direction, not implementation details
- Focus on injecting taste and wisdom — highest-leverage use of my time
- Let Claude handle mechanical work; focus on "what" and "why"
- My value-add is judgment, priorities, and quality standards

**Graduated:** 2026-02-10 (8.4 avg over 8 sessions, 7/8 at 8+)
**Regression threshold:** <7 in 2 consecutive sessions → re-activate

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
