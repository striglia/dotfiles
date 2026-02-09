# Practice Review Log

Session-by-session reflections on adherence to practices defined in `practices.md`.

---

## 2026-01-23 | project: OpenFi | overall: 6.4/10

**Session:** Plaid OAuth popup support (Issue #15), bug fixes, server-proxy architecture refactor

### Conversational over Waterfall
- **Rating:** 8/10
- **Evidence:** Iterative bug discovery, pivoted on colleague's architecture feedback
- **Note:** Good iterative loop, architecture pivot was well-handled

### Co-Design in Plan Mode
- **Rating:** 4/10
- **Evidence:** Never entered plan mode; architecture discussion was reactive
- **Note:** Server-proxy vs client-credentials decision should have been explored upfront

### Steer, Don't Row
- **Rating:** 9/10
- **Evidence:** Focused on direction/security judgment, delegated all implementation
- **Note:** Exemplary - brought colleague wisdom, stayed out of code details

### Build Autonomous Loops
- **Rating:** 6/10
- **Evidence:** Good log infrastructure, used skills; but no automated tests for OAuth
- **Note:** Consider Playwright test for OAuth flow

### Minimize Compaction
- **Rating:** 5/10
- **Evidence:** Session hit context limits and compacted
- **Note:** Could split feature implementation from architecture refactor

**Highlight:** Excellent "Steer, Don't Row" - focused on judgment, not mechanics
**Focus:** Use plan mode for architectural decisions before implementation

---

## 2026-01-27 | project: Loupe | overall: 6.8/10

**Session:** Meta-fixes from friction log c4d9de33 (Issues #77-83)

### Conversational over Waterfall
- **Rating:** 9/10
- **Evidence:** Iterative bug discovery through user testing; user insight led to correct position-based solution
- **Note:** Excellent iterative refinement—user testing surfaced root cause

### Co-Design in Plan Mode
- **Rating:** 7/10
- **Evidence:** Continued from established plan; architecture shift emerged from testing failures
- **Note:** Position-based approach was reactive; could anticipate with deeper upfront analysis

### Steer, Don't Row
- **Rating:** 8/10
- **Evidence:** User provided key insight about marker position, delegated implementation
- **Note:** Good balance—steered toward correct approach, let Claude execute

### Build Autonomous Loops
- **Rating:** 7/10
- **Evidence:** Tests for ghost marker fix; log file analysis for debugging; manual testing for accessibility APIs
- **Note:** Consider recording expected behaviors for regression

### Minimize Compaction
- **Rating:** 3/10
- **Evidence:** Session hit context limits and required compaction
- **Note:** Large scope (6+ issues) in single session; split multi-issue milestones

**Highlight:** User's key insight ("only the actual final position of the markers") exemplified excellent steering
**Focus:** Split multi-issue milestones into focused sessions to avoid compaction

---

## 2026-02-08 | project: exocortex | overall: 8.6/10

**Session:** W07 tactic creation with exocortex analysis, review section format change, PR

### Conversational over Waterfall
- **Rating:** 10/10
- **Evidence:** W07 tactic built through iterative dialogue — redirected on Rock #1, challenged repetitive briefing measure, added Rock #10 mid-session, made real-time edits
- **Note:** Artifact emerged from conversation, not a spec

### Co-Design in Plan Mode
- **Rating:** 7/10
- **Evidence:** Collaborative and exploratory but no formal plan mode; appropriate for vault/content work
- **Note:** Right call to skip — the tactic itself was the plan

### Steer, Don't Row
- **Rating:** 10/10
- **Evidence:** Every contribution was a judgment call — protein shake pivot, cooking-optional reframe, Rock #10, gardener "decide yes/no" framing. Zero time on mechanics.
- **Note:** Small wording changes with big behavioral implications — that's pure steering

### Build Autonomous Loops
- **Rating:** 7/10
- **Evidence:** 130 tests updated and passing; backwards-compatible regex verified programmatically. Vault content inherently outside automation loop.
- **Note:** Good test discipline on the code side

### Minimize Compaction
- **Rating:** 9/10
- **Evidence:** Focused session, one logical unit of work, no context warnings or compaction
- **Note:** Clean arc from brainstorming → editing → code → PR → explainer

**Highlight:** Textbook "Steer, Don't Row" — every contribution was taste and judgment, zero mechanics
**Focus:** Consider adding a practice around weekly reflection quality once exocortex analysis has a few weeks of data

---

## 2026-01-26 | project: dotfiles | overall: 7.6/10

**Session:** Adding Principal Engineer voice to review-debate skill

### Co-Design in Plan Mode
- **Rating:** 9/10
- **Evidence:** Session started from an already-approved plan with confirmed design decisions
- **Note:** Good example of bringing a fleshed-out spec to execution phase

### Steer, Don't Row
- **Rating:** 8/10
- **Evidence:** Detailed plan with clear requirements, delegated execution, allowed implementation judgment
- **Note:** Right balance—plan was directive but not micromanaging

### Build Autonomous Loops
- **Rating:** 5/10
- **Evidence:** No automated verification; skill changes committed without smoke testing
- **Note:** Could have run /review-debate on the changes as a quick validation

### Conversational over Waterfall
- **Rating:** 6/10
- **Evidence:** Comprehensive plan executed in one shot, no mid-flight check-ins
- **Note:** Fine for straightforward execution; riskier changes warrant checkpoints

### Minimize Compaction
- **Rating:** 10/10
- **Evidence:** Short, focused session with minimal context usage
- **Note:** Perfect scope

**Highlight:** Excellent plan-first approach with pre-validated design decisions
**Focus:** Consider smoke testing skill changes before committing

---

