---
name: design-iterate
description: Refines UI designs through iterative critique and improvement cycles using Playwright screenshots. Use when polishing UI components to target quality levels, iterating until reaching specific design standards, or comparing design versions.
tools: Bash, Read, Edit, mcp__playwright__playwright_navigate, mcp__playwright__playwright_screenshot, mcp__playwright__playwright_close
model: sonnet
---

# Iterative Design Refinement

Refine UI designs through iterative critique and improvement cycles using Playwright screenshots and visual analysis.

## When to Use

Invoke when the user wants to:
- Polish a UI component to a specific quality level (e.g., "make it Stripe-level quality")
- Iterate on design until it reaches a target rating (e.g., "get it to 8/10")
- Visually refine and critique a web interface
- Compare design iterations side-by-side

## Why Craft Matters (Stripe's Perspective)

**Business Value of Beauty:**
- Beautiful interfaces are perceived to work better (aesthetic-usability effect)
- Refined design builds user trust in your product and company
- When competition is high, quality details become your differentiation
- Craft isn't a nice-to-have luxury—it's a competitive necessity

**MVQP Mindset:**
Ship quality, not just features. A Minimum Viable Quality Product solves the user problem completely with the refinement needed to build trust and enable effective use.

## Core Workflow

### Phase 1: Establish Baseline

1. **Navigate and capture initial state**
   ```
   playwright_navigate(url, headless=false, width=1440, height=900)
   playwright_screenshot(name="design-v1", fullPage=false, downloadsDir="/tmp", savePng=true)
   ```

2. **Read and analyze screenshot**
   - Perform critical design analysis
   - Rate on scale of 1-10 (be harsh initially)

3. **Create critique framework**
   ```
   ## Design Critique - Version N: X/10

   **What's Working:**
   - Item 1
   - Item 2

   **Critical Issues (through Stripe's lens):**
   1. Trust: [Issue affecting user confidence] → [Specific fix]
   2. Details: [What lacks intentionality] → [Specific fix]
   3. Usability: [How beauty could improve function] → [Specific fix]

   **Target for next iteration:** [Specific goals]
   ```

### Phase 2: Iterate and Improve

For each iteration cycle:

1. **Make focused improvements** (3-5 issues per iteration)
2. **Force browser refresh** (close and reopen to clear cache)
3. **Capture new screenshot**
4. **Analyze and rate**
5. **Decide: Continue or Complete?**

### Phase 3: Finalize

When target rating achieved, commit with summary of improvements.

## Stripe-Level Quality Checklist

**Elevation & Depth:**
- [ ] Subtle shadows that create hierarchy
- [ ] Smooth transitions (200-300ms with ease curves)
- [ ] Depth that feels natural, not forced

**Typography:**
- [ ] Clear hierarchy (max 3-4 sizes)
- [ ] Proper font smoothing
- [ ] Tight letter spacing on headings (-0.01em to -0.02em)
- [ ] Readable body text (1.4-1.6 line-height)

**Color:**
- [ ] Limited palette (3-4 main colors)
- [ ] Sufficient contrast (WCAG AA minimum)
- [ ] Subtle gradients that add depth
- [ ] Muted secondary colors

**Spacing:**
- [ ] Consistent spacing scale (CSS variables)
- [ ] Generous whitespace
- [ ] Aligned to grid (8px or 4px base)

**Micro-interactions:**
- [ ] Hover states that invite interaction
- [ ] Smooth state transitions
- [ ] Visual feedback for actions
- [ ] Proper cursor changes

**Polish Details:**
- [ ] Rounded corners applied consistently
- [ ] Border styles that define without dominating
- [ ] Empty states with helpful messaging
- [ ] Loading states that manage expectations

## Rating Guide

| Rating | Description |
|--------|-------------|
| 1-3/10 | Broken or unusable |
| 4-5/10 | Functional but ugly - MVP mindset |
| 6/10 | Functional, clean, but generic |
| 7/10 | Good, some personality, few polish issues |
| **8/10** | **MVQP achieved** - polished, builds trust, Stripe-like quality |
| 9/10 | Excellent, delightful, memorable |
| 10/10 | Perfect, industry-leading |

## Tips

1. **Be brutally honest in early critiques** - Start harsh to leave room for improvement
2. **Focus on 3-5 issues per iteration** - Don't try to fix everything at once
3. **Always close/reopen browser** - Cache issues are common
4. **Use specific design language** - "Subtle shadow" not "make it prettier"
5. **Think MVQP, not MVP** - 8/10 is the minimum for trust-building quality
