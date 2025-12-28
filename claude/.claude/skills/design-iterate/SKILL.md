---
name: iterative-design-refinement
description: Refines UI designs through iterative critique and improvement cycles using Playwright screenshots. Use when polishing UI components to target quality levels, iterating until reaching specific design standards, or comparing design versions.
allowed-tools: Bash, Read, mcp__playwright__playwright_navigate, mcp__playwright__playwright_screenshot, mcp__playwright__playwright_close
---

# Iterative Design Refinement Skill

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
- Users get better outcomes from products they find beautiful and compelling

**MVQP Mindset:**
Ship quality, not just features. A Minimum Viable Quality Product solves the user problem completely with the refinement needed to build trust and enable effective use.

## Prerequisites

- Development server must be running (e.g., `make dev`)
- Playwright must be available for screenshots
- CSS/styling files must be editable

## Core Workflow

### Phase 1: Establish Baseline

1. **Navigate and capture initial state**
   ```bash
   # Start dev server in background if needed
   make dev (run_in_background=true)

   # Navigate with Playwright
   playwright_navigate(url, headless=false, width=1440, height=900)

   # Take screenshot (using /tmp for automatic cleanup)
   playwright_screenshot(name="design-v1", fullPage=false, downloadsDir="/tmp", savePng=true)
   ```

2. **Read and analyze screenshot**
   - Use Read tool to view the screenshot
   - Perform critical design analysis
   - Rate on scale of 1-10 (be harsh initially)

3. **Create critique framework**
   Use this structure:
   ```
   ## Design Critique - Version N: X/10

   **What's Working:**
   - ✅ Item 1
   - ✅ Item 2

   **Critical Issues (through Stripe's lens):**
   1. ❌ Trust: [Issue affecting user confidence] → [Specific fix]
   2. ❌ Details: [What lacks intentionality] → [Specific fix]
   3. ❌ Usability: [How beauty could improve function] → [Specific fix]

   **MVQP Check:**
   - Does it solve the problem completely? [Yes/No + gap]
   - Does it build trust in the product/company? [Yes/No + what's missing]
   - Are details differentiated or generic? [Assessment]

   **Target for next iteration:** [Specific goals]
   ```

### Phase 2: Iterate and Improve

For each iteration cycle:

1. **Make focused improvements**
   - Edit CSS/styling files
   - Focus on 3-5 specific issues per iteration
   - Use established design principles (see Design Principles section)

2. **Force browser refresh**
   ```bash
   # Close and reopen browser to clear cache
   playwright_close()
   playwright_navigate(url)
   sleep 3  # Wait for full load
   playwright_screenshot(name="design-v{N}", downloadsDir="/tmp", savePng=true)
   ```

3. **Analyze improvements**
   - Read new screenshot
   - Compare to previous version
   - Update rating
   - Identify remaining issues

4. **Decide: Continue or Complete?**
   - If rating < target: Make next iteration
   - If rating >= target: Finalize and commit

### Phase 3: Finalize

1. **Commit improvements**
   ```bash
   git add [changed-files]
   git commit -m "Polish [component] design to [rating]/10 quality

   - Specific improvement 1
   - Specific improvement 2
   - Overall outcome"
   ```

2. **Document final state**
   - Final screenshot
   - Final rating with justification
   - Summary of key improvements

## Design Principles

### Stripe's Philosophy: Craft as Business Value

**Core Beliefs:**
- **MVQP over MVP**: Build a Minimum Viable _Quality_ Product that solves the user problem completely, with refinement that helps them use it effectively and builds trust
- **Aesthetic-Usability Effect**: Beautiful things are perceived to work better and get better outcomes
- **Trust Through Beauty**: Refined design isn't decoration—it builds user confidence in your product and company
- **Differentiation Through Details**: When competition is high, quality in details becomes the differentiator
- **Objectivity in Beauty**: There's continuity in what people find beautiful—it's not purely subjective

### Stripe-Level Quality Checklist

**Elevation & Depth:**
- [ ] Subtle shadows that create hierarchy (avoid heavy drop shadows)
- [ ] Layered visual hierarchy that guides the eye
- [ ] Smooth transitions (200-300ms with ease curves)
- [ ] Depth that feels natural, not forced

**Typography:**
- [ ] Clear hierarchy (max 3-4 sizes) that communicates importance
- [ ] Proper font smoothing (-webkit-font-smoothing, -moz-osx-font-smoothing)
- [ ] Tight letter spacing on headings (-0.01em to -0.02em)
- [ ] Readable body text (1.4-1.6 line-height)
- [ ] Typography that builds trust through clarity

**Color:**
- [ ] Limited palette (3-4 main colors) with purpose
- [ ] Sufficient contrast (WCAG AA minimum) for usability
- [ ] Subtle gradients that add depth (not harsh)
- [ ] Muted secondary colors that support, don't distract
- [ ] Color choices that feel confident and professional

**Spacing:**
- [ ] Consistent spacing scale (use CSS variables)
- [ ] Generous whitespace that creates calm and focus
- [ ] Aligned to grid (8px or 4px base)
- [ ] Breathing room that shows confidence in simplicity

**Micro-interactions:**
- [ ] Hover states that invite interaction
- [ ] Smooth state transitions that feel polished
- [ ] Visual feedback for actions that builds trust
- [ ] Proper cursor changes (grab, pointer, etc.)
- [ ] Interactions that feel responsive and alive

**Polish Details:**
- [ ] Rounded corners (0.375rem - 0.75rem) applied consistently
- [ ] Border styles (1px solid, subtle colors) that define without dominating
- [ ] Empty states with helpful, human messaging
- [ ] Loading states that manage expectations
- [ ] Error states that maintain trust even when things go wrong
- [ ] Every pixel intentional—no "good enough" compromises

### Common Issues to Fix

**Round 1 (5/10 → 6.5/10):**
- Add card shadows by default
- Improve column visual separation
- Enhance typography (weights, sizes)
- Add max-width constraints
- Polish empty states

**Round 2 (6.5/10 → 7.5/10):**
- Refine color palette
- Add subtle gradients/backgrounds
- Improve spacing consistency
- Polish badges and labels
- Better hover states

**Round 3 (7.5/10 → 8.5/10):**
- Fine-tune shadows and elevation
- Perfect font rendering
- Micro-interaction polish
- Color harmony adjustments
- Final spacing tweaks

## Rating Guide

**1-3/10**: Broken or unusable - fails to solve the problem
**4-5/10**: Functional but ugly - MVP mindset, no trust-building
**6/10**: Functional, clean, but generic - lacks confidence and differentiation
**7/10**: Good, some personality, few polish issues - getting there but details need work
**8/10**: MVQP achieved - polished, builds trust, Stripe-like quality with intentional details
**9/10**: Excellent, delightful, memorable - differentiated through craft, joy in use
**10/10**: Perfect, industry-leading design - every detail serves both form and function

## Tips for Success

1. **Be brutally honest in early critiques** - Start harsh (5/10) to leave room for improvement
2. **Focus on 3-5 issues per iteration** - Don't try to fix everything at once
3. **Always close/reopen browser** - Cache issues are common
4. **Use specific design language** - "Subtle shadow" not "make it prettier"
5. **Take full-page screenshots** - Capture mobile views too
6. **Document the journey** - Save all version screenshots for comparison
7. **Think MVQP, not MVP** - 8/10 is the minimum for trust-building quality
8. **Ask "Does this build trust?"** - Every design choice should inspire confidence
9. **Details differentiate** - When everything works, craft is what sets you apart
10. **Beauty serves function** - Don't add decoration; refine until form and function marry

## Example Invocations

```
User: "Use playwright to refine this component's design. Iterate until
it's at least 8/10 Stripe-quality."

User: "Take screenshots and critique the dashboard design. Make it beautiful
and iterate until it's production-ready."

User: "Polish the login form to 8/10 quality using visual iteration."