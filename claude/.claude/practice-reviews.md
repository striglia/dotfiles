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

