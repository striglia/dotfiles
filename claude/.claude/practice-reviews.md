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

## 2026-02-09 | project: OpenFi | overall: 4.0/10 (retroactive)

**Session:** PR #125 — Productionize Backend: Standardize on Firebase Functions (Issue #113). 46 files, 13 commits, 12,646 additions.

### Conversational over Waterfall
- **Rating:** 3/10
- **Evidence:** Entire backend migration built in one session before check-in. 46-file "big reveal."
- **Note:** Many decision points warranted incremental feedback.

### Co-Design in Plan Mode
- **Rating:** 2/10
- **Evidence:** No plan mode for the most architecturally significant PR in the project. Key decisions (rate limiting, security model, URL resolution) made without co-design.
- **Note:** The session that most needed plan mode.

### Steer, Don't Row
- **Rating:** 6/10
- **Evidence:** Good high-level vision (security, testing, runbook) but 12,646 additions suggests insufficient mid-session steering.
- **Note:** You can't steer what you can't see.

### Build Autonomous Loops
- **Rating:** 8/10
- **Evidence:** 19 Jest tests, ESLint, TypeScript compilation, swift build/test, self-review via review-debate. Strongest automation across all sessions.
- **Note:** Upfront investment in Jest + ESLint pays forward.

### Minimize Compaction
- **Rating:** 1/10
- **Evidence:** 46 files, 13 commits in one session. Had 4 natural breakpoints that could have been separate sessions.
- **Note:** 4 sessions crammed into 1.

**Highlight:** Strongest "Build Autonomous Loops" across all sessions — Jest infra + self-review pipeline.
**Focus:** Practices compound — plan mode → focused sessions → incremental check-ins. Skipping all at once multiplies the cost.

---

## 2026-02-09 | project: OpenFi | overall: 7.4/10

**Session:** Issue #137 — Audit and fix user-facing URLs to use tryopenfi.com (Firebase auth links, DEPLOYMENT.md)

### Steer, Don't Row
- **Rating:** 9/10
- **Evidence:** One issue URL in, one merged PR out. Zero implementation guidance needed.
- **Note:** Textbook delegation for a well-scoped issue.

### Conversational over Waterfall
- **Rating:** 7/10
- **Evidence:** Handed off well-scoped issue, no mid-session check-ins needed given small scope.
- **Note:** Appropriate for the size — not every session needs deep dialogue.

### Co-Design in Plan Mode
- **Rating:** 5/10
- **Evidence:** No plan mode. Subdomain choice (api.tryopenfi.com for auth) decided without discussion.
- **Note:** "api" in a password reset link might confuse users — worth a quick co-design next time.

### Build Autonomous Loops
- **Rating:** 6/10
- **Evidence:** TypeScript build verified, self-review ran. No automated test for link domain (hard to test without real payments).
- **Note:** Build check was the right minimum for infra changes.

### Minimize Compaction
- **Rating:** 10/10
- **Evidence:** Short focused session, single issue, no context pressure.
- **Note:** Perfect scope for a worktree session.

**Highlight:** Excellent "Steer, Don't Row" — one instruction, one merged PR, almost zero steering needed.
**Focus:** For infra changes with user-facing implications, a quick plan-mode check-in could surface better options.

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

## 2026-02-10 | project: exocortex | overall: 7.8/10

**Session:** Create CRM pages for Griffin Black associates (#211) — 3 people pages + 15 backlink edits

### Steer, Don't Row
- **Rating:** 9/10
- **Evidence:** Fully-specified plan with exact file/line references for every edit. Zero implementation management — just requirements and verification criteria.
- **Note:** Textbook delegation of a mechanical task.

### Conversational over Waterfall
- **Rating:** 7/10
- **Evidence:** Plan built in prior planning session with iterative discovery. Execution session was appropriately direct — spec was complete and correct.
- **Note:** Right call — for well-scoped mechanical tasks, pure execution is fine.

### Co-Design in Plan Mode
- **Rating:** 7/10
- **Evidence:** Plan mode used in prior session to co-design approach. This session executed that plan.
- **Note:** Good pattern: co-design in plan mode, then hand off for execution.

### Build Autonomous Loops
- **Rating:** 6/10
- **Evidence:** Verification via git grep with expected hit counts. Review-debate ran. Vault content inherently hard to test programmatically.
- **Note:** Grep verification criteria baked into the plan was a good lightweight automation pattern.

### Minimize Compaction
- **Rating:** 10/10
- **Evidence:** 10 files changed, one commit, no context pressure. Clean arc from plan to PR.
- **Note:** Well-scoped from the start, no scope creep.

**Highlight:** Perfect scoping — plan-specified mechanical task executed in one clean pass with no wasted context.
**Focus:** The grep-based verification criteria pattern is worth replicating for future vault editing tasks.

---

## 2026-02-10 | project: exocortex | overall: 7.6/10

**Session:** `exo project new` CLI subcommand — implementation, backlink migration, PR, GitHub issue for backlinking tool

### Steer, Don't Row
- **Rating:** 8/10
- **Evidence:** Plan provided upfront, execution delegated. Good mid-session corrections: backfill existing projects, fix "2025" in filename, catch missing history reconstruction step. Minor dock: insurance file content pasted from dry-run rather than created via CLI.
- **Note:** Mid-session corrections were high-quality steering that improved the PR.

### Conversational over Waterfall
- **Rating:** 8/10
- **Evidence:** Plan from prior co-design session. Iterative corrections during execution — backfill request, filename fix, reconstruct step check, skill edit. Timely course corrections, not big reveals.
- **Note:** Good pattern of watching work happen and steering in real-time.

### Co-Design in Plan Mode
- **Rating:** 7/10
- **Evidence:** Plan built in prior session. Execution session appropriately skipped plan mode. Filed GitHub issue #214 for backlinking tool instead of over-engineering inline.
- **Note:** Filing an issue instead of building the backlinking tool was good scope discipline.

### Build Autonomous Loops
- **Rating:** 7/10
- **Evidence:** 27 tests written and passing. Review-debate subagent caught empty-name validation bug — a real issue that got fixed before merge.
- **Note:** Self-review catching a real edge case is the autonomous loop working as designed.

### Minimize Compaction
- **Rating:** 8/10
- **Evidence:** 19 files but logically coherent (one feature + one migration). No context warnings or compaction. Clean session arc. Backfill added ~14 files but was the same conceptual change.
- **Note:** Borderline scope but right call — backfill belongs with the feature that establishes the convention.

**Highlight:** Catching missing history reconstruction step and immediately improving the skill. Meta-steering — improving the process while using it.
**Focus:** Dog-food new tools end-to-end rather than working around them (insurance file was pasted, not CLI-created).

---

## 2026-02-10 | practices audit (audit)

**Reviews analyzed:** 8 (2026-01-23 through 2026-02-10)

### Statistics

| Practice | Avg | Last 5 Avg | Variance | Signal |
|----------|-----|------------|----------|--------|
| Steer, Don't Row | 8.4 | 8.6 | Low (outlier: mega-session) | Graduated (probationary) |
| Conversational/Waterfall | 7.3 | 7.0 | Medium | Healthy — no change |
| Minimize Compaction | 7.0 | 7.8 | Enormous (1–10) | Sharpened |
| Build Autonomous Loops | 6.5 | 6.6 | Very low | Sharpened |
| Co-Design in Plan Mode | 6.0 | 6.2 | High (2–9) | Keep — still needs work |

### Changes Made
- **Graduated (probationary):** "Steer, Don't Row" — 8.4 avg, 7/8 sessions at 8+. Still tracked, only surfaces if <7.
- **Sharpened:** "Minimize Compaction" → "Scope Before You Start" — the failure is always skipping scope assessment, never in-session management. Reframed around the actual failure mode.
- **Sharpened:** "Build Autonomous Loops" — added infrastructure-first criteria. The one 8/10 was when test framework was built upfront; the 5-7 scores were piecemeal additions.
- **No change:** "Conversational over Waterfall" — healthy 7.3 avg, no action needed.
- **No change:** "Co-Design in Plan Mode" — 6.0 avg, still the weakest practice. Needs continued focus.

### Skill Updates
- Added Phase 7 (Periodic Practices Audit) to self-trigger after every 8 reviews
- Added probationary graduation model (quiet unless regression)
- Updated graduation threshold to 8+ over 5+ sessions

---

