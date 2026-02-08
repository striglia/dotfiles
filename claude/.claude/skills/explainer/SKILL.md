---
name: explainer
description: Generate a narrative HTML explainer for the current branch, upload as private gist, and link in PR description. Educates code reviewers about WHY changes were made, not just what changed.
allowed-tools: Bash(git:*), Bash(gh:*), Bash(cat /tmp/explainer*), Read, Grep, Glob, Write(/tmp/explainer*)
---

# PR Explainer

Generate a self-contained HTML document that tells the story of a branch for code reviewers. Upload as a private GitHub gist and link from the PR description.

## When to Use

- `/explainer` - Generate explainer for the current branch
- Before or after PR creation (auto-detects)
- As part of the `/git-workflow` chain (before push)
- When you want to give reviewers rich context beyond a PR description

## Philosophy

**This is NOT an annotated diff.** This is a narrative document that educates a code reviewer.

- Focus on WHY the code exists, not WHAT the code is
- Explain the semantic and functional changes in human terms
- Show code only when it genuinely aids understanding — most of the time, prose is better
- Flag risks and areas needing scrutiny — guide reviewer attention to high-value areas
- Include scope boundaries (what's NOT in this PR) only when relevant to prevent confusion
- The narrative structure should align with the commit structure — if they diverge, that's a signal the commits may need reorganizing

## Step 1: Gather Context

```bash
# Get the base branch
BASE_BRANCH=$(git merge-base HEAD origin/main)

# Full diff
git diff origin/main..HEAD

# Commit history with messages
git log origin/main..HEAD --pretty=format:"%H%n%s%n%b%n---"

# Changed files summary
git diff --stat origin/main..HEAD

# File list for understanding scope
git diff --name-status origin/main..HEAD
```

Also read key files if needed to understand the broader context of the change. Use your judgment — don't read everything, but do read enough to explain the change coherently.

If a PR already exists, also gather:
```bash
gh pr view --json title,body,number -q '{title: .title, body: .body, number: .number}'
```

## Step 2: Analyze the Change

Before writing HTML, think through:

1. **What is this branch doing?** One-sentence summary a non-engineer could understand.
2. **What motivated it?** The problem, the opportunity, or the goal.
3. **What are the major decisions?** Choices that had alternatives. Why this approach over others?
4. **What are the tensions?** Trade-offs that were made. What was sacrificed and why?
5. **What are the risks?** Where should reviewers look most carefully? What might break?
6. **What's the commit structure?** How does the work decompose? Does each commit tell a coherent story?
7. **What's NOT here?** (Only if relevant) Deferred work, intentional omissions, scope boundaries.

## Step 3: Generate the HTML

Write a self-contained HTML file to `/tmp/explainer.html`.

### Content Guidelines

**Narrative structure**: The agent decides the best structure per PR. Options include:
- **By concept/component** — group by feature area (preferred when commits are semantic)
- **By decision** — organize around the key choices made
- **Chronological** — how the work evolved (good for exploratory branches)

The structure should align with the final commit structure. If you find yourself organizing the narrative differently than the commits, note this — it may indicate the commits need reorganizing.

**Length scales with complexity**:
- Small PRs (< 50 lines): 2-5 minute read. Hit the key points, respect reviewer time.
- Medium PRs (50-200 lines): 5-10 minute read. Explain decisions and trade-offs.
- Large PRs (200+ lines): 10-15 minute read. Full context, architecture decisions, risk analysis.

**Code inclusion rules**:
- Default: NO code. Explain in prose.
- Include code when: the specific implementation IS the decision (algorithm choice, API design, data structure)
- Include diffs when: the before/after contrast is the clearest way to show what changed
- Never include code just because it changed — only because seeing it helps understanding

**Risk callouts**:
- Explicitly flag areas where you want extra reviewer scrutiny
- Frame as "I'd appreciate extra eyes on X because Y"
- Be honest about uncertainty — reviewers respect transparency

### HTML Requirements

The HTML must be **completely self-contained** — all CSS and JS inline. No external dependencies.

**Design principles**:
- Clean typography (system font stack, good line-height, readable widths)
- Syntax highlighting for any code blocks (inline CSS, not a library)
- Collapsible sections where they reduce clutter without hiding important content
- A table of contents / navigation if the document has 3+ major sections
- Interactive elements only when they serve education, not decoration
- Dark/light mode support via `prefers-color-scheme`
- Print-friendly (the HTML should look good printed/PDF'd)

**Structure template** (adapt per PR — this is a starting point, not a rigid format):

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>[Branch Name] — PR Explainer</title>
  <style>
    /* Self-contained styles:
       - System font stack
       - Max-width ~720px content area, centered
       - Good typographic rhythm (1.6 line-height for body)
       - Syntax highlighting via CSS classes
       - Collapsible sections with <details>/<summary>
       - Color scheme: light default, dark via prefers-color-scheme
       - Subtle visual hierarchy: section dividers, callout boxes for risks
       - Print styles: hide nav, expand all collapsed sections
    */
  </style>
</head>
<body>
  <!-- Navigation (if 3+ sections) -->
  <!-- One-sentence summary: what this PR does in plain language -->
  <!-- Motivation: why this work exists -->
  <!-- Major sections: organized by concept, decision, or chronology -->
  <!--   Each section: narrative prose, code only when earned -->
  <!-- Risk callouts: areas needing extra scrutiny -->
  <!-- Scope boundaries (if relevant): what's NOT in this PR -->
  <!-- Commit guide: how the commits map to the narrative -->
  <script>
    /* Minimal JS for interactivity:
       - Smooth scroll for TOC links
       - Collapsible section state (optional)
       - Nothing that requires a framework
    */
  </script>
</body>
</html>
```

**Quality bar**: The HTML should look like a well-crafted technical blog post. Think Stripe's engineering blog or Julia Evans' explanations — clear, opinionated, educational.

## Step 4: Upload as Private Gist

```bash
# Create private gist from the HTML file
GIST_URL=$(gh gist create /tmp/explainer.html --desc "PR Explainer: [branch-name]" 2>&1 | tail -1)
echo "Gist URL: $GIST_URL"
```

The gist URL will look like `https://gist.github.com/username/abc123`. The raw HTML is viewable via the "Raw" button on GitHub, or via:
```
https://gist.githack.com/username/abc123/raw/explainer.html
```

Display both URLs to the user:
- Gist page: for viewing on GitHub
- Raw HTML: for direct browser viewing with full interactivity

## Step 5: Link to PR (Detect & Adapt)

### If PR already exists:

```bash
# Get current PR body
CURRENT_BODY=$(gh pr view --json body -q .body)

# Prepend explainer link
gh pr edit --body "$(cat <<EOF
> **[PR Explainer](${GIST_URL})** — narrative walkthrough for reviewers

${CURRENT_BODY}
EOF
)"
```

Display: "Explainer linked in PR description."

### If no PR yet:

Save the gist URL for later use:

```bash
# Save for git-workflow to pick up
echo "${GIST_URL}" > /tmp/explainer-gist-url

# Also save the raw URL
echo "${RAW_URL}" >> /tmp/explainer-gist-url
```

Display:
```
Explainer uploaded: [gist URL]
Raw HTML: [raw URL]

No PR found yet. Gist URL saved — will be included when PR is created.
(Saved to /tmp/explainer-gist-url for /git-workflow to pick up)
```

## Integration with /git-workflow

The `/git-workflow` Phase 4 (Push and Create PR) should check for a saved explainer URL:

```bash
# In git-workflow Phase 4, before creating PR:
if [ -f /tmp/explainer-gist-url ]; then
  EXPLAINER_URL=$(head -1 /tmp/explainer-gist-url)
  # Include in PR body
fi
```

When detected, prepend the explainer link to the PR body in the same format:
```
> **[PR Explainer](URL)** — narrative walkthrough for reviewers
```

After successfully including in the PR, clean up:
```bash
rm /tmp/explainer-gist-url
```

## Error Handling

1. **No commits on branch**: "No changes to explain — branch is identical to main."
2. **`gh` not authenticated**: "GitHub CLI not authenticated. Run `gh auth login` first."
3. **Gist creation fails**: Save HTML to `/tmp/explainer.html` and print path. "Gist upload failed. HTML saved locally: /tmp/explainer.html"
4. **Very large diff** (>2000 lines): Focus on the most important changes. Note in the explainer: "This is a large change. This explainer focuses on the key decisions and risks."

## Tips for Claude

- **Read commit messages carefully** — they often contain rationale that should be expanded in the narrative
- **Look at the commit structure** — semantic commits tell you how the author thought about the change
- **Don't explain obvious code** — if a reviewer can read `if (user.isAdmin)`, you don't need to explain it
- **DO explain non-obvious choices** — "We used a Map instead of an Object because..."
- **Be opinionated** — this isn't a neutral description, it's the author explaining their work
- **Admit uncertainty** — "I'm not 100% sure this handles the race condition correctly" is more useful than silence
- **Make it scannable** — bold key terms, use headers, keep paragraphs short
- **The explainer should make the actual code review faster** — after reading it, the reviewer should know exactly where to focus
