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

   **Critical Issues:**
   1. ❌ Issue with specific suggestion
   2. ❌ Issue with specific suggestion
   3. ❌ Issue with specific suggestion

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

### Stripe-Level Quality Checklist

**Elevation & Depth:**
- [ ] Subtle shadows (avoid heavy drop shadows)
- [ ] Layered visual hierarchy
- [ ] Smooth transitions (200-300ms with ease curves)

**Typography:**
- [ ] Clear hierarchy (max 3-4 sizes)
- [ ] Proper font smoothing (-webkit-font-smoothing, -moz-osx-font-smoothing)
- [ ] Tight letter spacing on headings (-0.01em to -0.02em)
- [ ] Readable body text (1.4-1.6 line-height)

**Color:**
- [ ] Limited palette (3-4 main colors)
- [ ] Sufficient contrast (WCAG AA minimum)
- [ ] Subtle gradients (not harsh)
- [ ] Muted secondary colors

**Spacing:**
- [ ] Consistent spacing scale (use CSS variables)
- [ ] Generous whitespace
- [ ] Aligned to grid (8px or 4px base)

**Micro-interactions:**
- [ ] Hover states on interactive elements
- [ ] Smooth state transitions
- [ ] Visual feedback for actions
- [ ] Proper cursor changes (grab, pointer, etc.)

**Polish Details:**
- [ ] Rounded corners (0.375rem - 0.75rem)
- [ ] Border styles (1px solid, subtle colors)
- [ ] Empty states with helpful messaging
- [ ] Loading states
- [ ] Error states

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

**1-3/10**: Broken or unusable
**4-5/10**: Functional but ugly
**6/10**: Functional, clean, but generic
**7/10**: Good, some personality, few polish issues
**8/10**: Very good, polished, Stripe-like quality
**9/10**: Excellent, delightful, memorable
**10/10**: Perfect, industry-leading design

## Tips for Success

1. **Be brutally honest in early critiques** - Start harsh (5/10) to leave room for improvement
2. **Focus on 3-5 issues per iteration** - Don't try to fix everything at once
3. **Always close/reopen browser** - Cache issues are common
4. **Use specific design language** - "Subtle shadow" not "make it prettier"
5. **Take full-page screenshots** - Capture mobile views too
6. **Document the journey** - Save all version screenshots for comparison
7. **Stop at target** - Don't over-optimize (8/10 is great for MVP)

## Example Invocations

```
User: "Use playwright to refine this component's design. Iterate until
it's at least 8/10 Stripe-quality."

User: "Take screenshots and critique the dashboard design. Make it beautiful
and iterate until it's production-ready."

User: "Polish the login form to 8/10 quality using visual iteration."