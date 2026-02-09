---
name: explainer
description: Generate a narrative HTML explainer for the current branch, upload as private gist, and link in PR description. Educates code reviewers about WHY changes were made, not just what changed.
allowed-tools: Bash(git:*), Bash(gh:*), Bash(cat /tmp/explainer*), Bash(lint-mermaid*), Bash(mmdc:*), Read, Grep, Glob, Write(/tmp/explainer*)
---

# PR Explainer

Generate a self-contained HTML document that tells the story of a branch for code reviewers. Upload as a private GitHub gist and link from the PR description.

## When to Use

- `/explainer` - Generate explainer for the current branch
- Before or after PR creation (auto-detects)
- As part of the `/git-workflow` chain (before push)
- When you want to give reviewers rich context beyond a PR description

## Philosophy

**This is NOT a second code review.** This is a document that builds intuition — a reviewer who reads it should *get* the change before they ever look at a diff.

- **Visuals over prose** — diagrams, flow charts, tables, and annotated snippets communicate faster than paragraphs. If you're writing more than 3-4 sentences in a row, ask: would a diagram be clearer?
- **Build intuition, don't explain every detail** — give the reviewer a mental model of the change, not a line-by-line walkthrough. They can read the code themselves; what they can't get from the diff is the *why* and the *shape* of the decision space.
- **Make it a delight to read** — this should feel like a well-designed blog post, not a compliance document. Short paragraphs, visual variety, white space, personality. A reviewer should *want* to read it.
- Flag risks and areas needing scrutiny — guide reviewer attention to high-value areas
- Include scope boundaries (what's NOT in this PR) only when relevant to prevent confusion
- The narrative structure should align with the commit structure — if they diverge, that's a signal the commits may need reorganizing

## File Naming

All temp files include a shortened git SHA (last 6 chars of HEAD) to avoid conflicts when multiple branches have explainers in flight:

```bash
SHA=$(git rev-parse --short=6 HEAD)
# HTML:     /tmp/explainer-${SHA}.html
# Gist URL: /tmp/explainer-gist-url-${SHA}
```

## Step 1: Gather Context

```bash
# Compute the SHA suffix used for all temp files
SHA=$(git rev-parse --short=6 HEAD)

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

Write a self-contained HTML file to `/tmp/explainer-${SHA}.html`.

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

**Prefer visuals over prose**:
- **Mermaid diagrams** for flows, sequences, state machines, and architecture (see Diagram Guide below)
- **Tables** for comparisons, option trade-offs, before/after summaries
- **Annotated code snippets** (short, with callout comments) when the implementation IS the decision
- **Diff fragments** only when the before/after contrast is the clearest way to show what changed
- A wall of paragraphs is a failure mode. Break it up visually.

#### Diagram Guide (Mermaid)

Use [Mermaid.js](https://mermaid.js.org/) for all diagrams. Write Mermaid specs inside `<pre class="mermaid">` tags — the library renders them automatically on page load.

**Pick the right diagram type:**

| Scenario | Mermaid Type | Example Use |
|----------|-------------|-------------|
| Request/data flow | `flowchart LR` | HTTP request through middleware → handler → DB |
| Component interaction | `sequenceDiagram` | Service A calls Service B, gets response, updates cache |
| State changes | `stateDiagram-v2` | PR status: draft → open → review → merged |
| Before/after architecture | `flowchart TD` (two side-by-side) | Old vs new module structure |
| Decision tree | `flowchart TD` | "If config exists → load it, else → use defaults" |
| Timeline/phases | `gantt` | Migration phases or rollout plan |
| Class/module relationships | `classDiagram` | How new modules relate to existing ones |

**Mermaid authoring tips:**
- Keep diagrams focused — 5-12 nodes max. Split complex flows into multiple diagrams.
- Use descriptive node labels: `Auth["Auth Middleware"]` not just `A`
- Use notes and annotations in sequence diagrams: `Note over A,B: This is the critical path`
- Style important nodes: `style CriticalNode fill:#f96,stroke:#333`
- Test your Mermaid syntax mentally — common pitfalls: unquoted labels with special chars, missing direction specifiers

**Risk callouts**:
- Explicitly flag areas where you want extra reviewer scrutiny
- Frame as "I'd appreciate extra eyes on X because Y"
- Be honest about uncertainty — reviewers respect transparency

### HTML Requirements

The HTML must require **no build step** — all custom CSS and JS inline. CDN-hosted libraries (like Mermaid.js) are fine since the file is always viewed online.

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
       - Mermaid diagrams: center them, give breathing room
    */
    .mermaid { text-align: center; margin: 1.5em 0; }
  </style>
  <!-- Mermaid.js for diagram rendering -->
  <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
  <script>mermaid.initialize({ startOnLoad: true, theme: 'neutral' });</script>
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

**Quality bar**: The HTML should feel like a Julia Evans zine or a well-designed Stripe engineering post — visual, opinionated, and something you'd actually enjoy reading. If it reads like a design doc or a code review comment thread, you've missed the mark.

## Step 3.5: Validate Mermaid Diagrams

**MANDATORY** — run this before uploading the gist. Mermaid syntax is fragile (parentheses, colons, special chars in labels cause silent render failures).

```bash
~/.claude/skills/lint-mermaid.sh /tmp/explainer-${SHA}.html
```

This extracts every `<pre class="mermaid">` block and validates it via `mmdc` (Mermaid CLI). If any block fails:

1. Read the error to identify the problematic syntax
2. Fix the HTML file
3. Re-run the linter until all blocks pass

**Common Mermaid pitfalls:**
- **Parentheses in `stateDiagram` labels** — `()` denotes state descriptions, not grouping. Use `—` or rephrase instead of `(BUG: ...)`.
- **Colons in labels** — Some diagram types parse `:` as a separator. Rephrase or use quotes.
- **Special chars in flowchart nodes** — Use quoted labels: `A["Label with (parens)"]` instead of `A(Label with parens)`.

**Prerequisite:** `npm install -g @mermaid-js/mermaid-cli` (one-time setup).

## Step 4: Upload as Private Gist

```bash
# Create private gist from the HTML file
GIST_URL=$(gh gist create /tmp/explainer-${SHA}.html --desc "PR Explainer: [branch-name]" 2>&1 | tail -1)

# Derive the viewable URL (renders the HTML in-browser instead of showing source)
# Replace gist.github.com with gist.githack.com and append /raw/filename
# Input:  https://gist.github.com/username/abc123
# Output: https://gist.githack.com/username/abc123/raw/explainer-${SHA}.html
VIEWABLE_URL="$(echo "$GIST_URL" | sed 's|gist.github.com|gist.githack.com|')/raw/explainer-${SHA}.html"

echo "Gist: $GIST_URL"
echo "Viewable: $VIEWABLE_URL"
```

The **viewable URL** is what goes in the PR — it renders the HTML directly in the browser with full interactivity, dark/light mode, etc. The plain gist URL just shows source code on GitHub, which defeats the purpose.

Display both URLs to the user:
- Viewable HTML (for PR link and sharing): the githack URL
- Gist page (for editing/deleting): the gist.github.com URL

## Step 5: Link to PR (Detect & Adapt)

### If PR already exists:

```bash
# Get current PR body
CURRENT_BODY=$(gh pr view --json body -q .body)

# Prepend explainer link (use viewable URL, not plain gist URL)
gh pr edit --body "$(cat <<EOF
> **[PR Explainer](${VIEWABLE_URL})** — narrative walkthrough for reviewers

${CURRENT_BODY}
EOF
)"
```

Display: "Explainer linked in PR description."

### If no PR yet:

Save the gist URL for later use:

```bash
# Save the viewable URL for git-workflow to pick up (this is the link that goes in the PR)
echo "${VIEWABLE_URL}" > /tmp/explainer-gist-url-${SHA}
```

Display:
```
Viewable: [viewable URL]
Gist: [gist URL]

No PR found yet. Viewable URL saved — will be included when PR is created.
(Saved to /tmp/explainer-gist-url-${SHA} for /git-workflow to pick up)
```

## Integration with /git-workflow

The `/git-workflow` Phase 4 (Push and Create PR) should check for a saved explainer URL:

```bash
# In git-workflow Phase 4, before creating PR:
if [ -f /tmp/explainer-gist-url-${SHA} ]; then
  EXPLAINER_URL=$(head -1 /tmp/explainer-gist-url-${SHA})
  # Include in PR body
fi
```

When detected, prepend the explainer link to the PR body in the same format:
```
> **[PR Explainer](URL)** — narrative walkthrough for reviewers
```

After successfully including in the PR, clean up:
```bash
rm /tmp/explainer-gist-url-${SHA}
```

## Error Handling

1. **No commits on branch**: "No changes to explain — branch is identical to main."
2. **`gh` not authenticated**: "GitHub CLI not authenticated. Run `gh auth login` first."
3. **Gist creation fails**: Save HTML to `/tmp/explainer-${SHA}.html` and print path. "Gist upload failed. HTML saved locally: /tmp/explainer-${SHA}.html"
4. **Very large diff** (>2000 lines): Focus on the most important changes. Note in the explainer: "This is a large change. This explainer focuses on the key decisions and risks."

## Tips for Claude

- **Reach for a Mermaid diagram first** — before writing a paragraph, ask: can I show this as a `flowchart`, `sequenceDiagram`, or `stateDiagram-v2` instead? Use `<pre class="mermaid">` blocks. Visuals build intuition faster than prose.
- **Build a mental model, not a changelog** — the reader should finish with an intuitive understanding of the change's shape, not a memorized list of what happened. Think "here's how to think about this" not "here's everything that changed."
- **Keep it tight** — short paragraphs (2-3 sentences max), lots of headings, visual variety. If a section feels like a wall of text, break it up or replace prose with a visual.
- **Be opinionated and have personality** — this isn't a neutral description, it's the author explaining their work with conviction. It's okay to be casual, direct, even funny where appropriate.
- **Admit uncertainty** — "I'm not 100% sure this handles the race condition correctly" is more useful than silence
- **Read commit messages carefully** — they often contain rationale that should be expanded in the narrative
- **The explainer should make the reviewer excited to review** — not obligated. After reading it, they should know exactly where to focus and feel like their time will be well spent.
