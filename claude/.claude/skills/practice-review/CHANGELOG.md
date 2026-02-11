# Practice Review Skill — Changelog

Records how this skill evolves over time. Updated roughly monthly, or when meaningful changes are made.

---

## 2026-02-10 — Probationary Graduation + Periodic Audit (Phase 7)

**What changed:**
1. **Probationary graduation model** — Graduated practices are still rated every session but only surfaced to the user if they regress below 7/10. Two consecutive sub-7 scores trigger a re-activation proposal. This replaced the binary "graduated = no longer tracked" model.
2. **Phase 7: Periodic Practices Audit** — After every 8 reviews, the skill now prompts a full practices audit: statistical analysis of all history, trend identification, and concrete evolution proposals. This makes the meta-review self-triggering instead of requiring manual initiation.
3. **Updated graduation threshold** — Changed from "9+ over 5+ sessions" to "8+ over 5+ sessions (or 9+ over 4+)" to better match reality.

**Why:** After 8 reviews, the first manual audit revealed that Phase 6 (per-review evolution checks) wasn't sufficient — the user had to manually trigger a zoom-out review of the entire practice set. The audit also revealed that binary graduation was too aggressive; the user wanted continued monitoring with reduced noise.

**Evidence from first audit:**
- "Steer, Don't Row": 8.4 avg over 8 sessions → first probationary graduation
- "Minimize Compaction": 1-to-10 variance → sharpened to "Scope Before You Start"
- "Build Autonomous Loops": stable 6-7 plateau → definition sharpened with specific infrastructure-first criteria

**Practices changes made alongside this skill update:**
- Graduated: "Steer, Don't Row" (probationary)
- Sharpened: "Minimize Compaction" → "Scope Before You Start"
- Sharpened: "Build Autonomous Loops" (more specific success criteria)

---

## 2026-02-08 — Add Practices Evolution (Phase 6)

**What changed:** Added Phase 6 "Practices Evolution" to the review process. After logging the review, the skill now checks whether any practices should graduate (mastered habits), be added (emerging patterns), or be sharpened (high-variance definitions).

**Why:** After 4 sessions of reviews, a pattern emerged: some practices (like "Steer, Don't Row") were consistently scoring 9-10 and creating tracking noise, while review notes kept suggesting new practices that never got promoted to `practices.md`. The practices were static while the user was growing.

**Three evolution types:**
- **Graduate** — 9+ over 5+ sessions → move to "Graduated" section
- **Add** — recurring "Focus" notes or emerging patterns → propose new practice
- **Sharpen** — variance > 4 points → propose splitting or adding triggers

**Evidence from reviews:**
- "Steer, Don't Row": 9, 8, 8, 10 — candidate for graduation
- "Minimize Compaction": 5, 3, 10, 9 — candidate for sharpening
- "Weekly Reflection Quality": suggested in 2026-02-08 review — candidate for addition
