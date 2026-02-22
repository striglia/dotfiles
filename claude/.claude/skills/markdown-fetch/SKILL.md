---
name: markdown-fetch
description: Fetch a webpage's content as clean markdown using markdown.new. Use this as the DEFAULT approach for any web fetch where you need to read page content — articles, docs, blog posts, reference pages. Only use raw WebFetch when you specifically need HTML structure, DOM layout, JavaScript behavior, or CSS.
allowed-tools: WebFetch, Bash(curl:*)
---

# Markdown Fetch

**Default rule: if you're fetching a page to read its content, use markdown.new.** Only bypass this and use raw `WebFetch` if you need the HTML/DOM/JS itself.

Fetch a webpage's content as clean, readable markdown via [markdown.new](https://markdown.new). The service strips nav, ads, boilerplate, and markup — returning only the actual content.

## Content vs. Structure — Pick One

| You need... | Use... |
|---|---|
| What the page says (article, docs, blog post, reference) | **markdown.new** (this skill) |
| The HTML structure, DOM tree, or CSS | `WebFetch` directly |
| JavaScript behavior or rendered DOM | `WebFetch` directly |
| A page's raw source | `WebFetch` directly |

When in doubt: if you'd summarize it or quote from it, use markdown.new.

## When to Use

- Reading any article, documentation page, blog post, or reference material
- Summarizing or quoting from a webpage
- When the user says "fetch this page", "what does this page say", "read this URL", etc.
- When `WebFetch` fails (403, bot-blocking, JS-gated content) — markdown.new uses a real browser and often succeeds where raw fetch fails
- Any time you just need the words on the page, not the markup around them

## How markdown.new Works

Prepend `https://markdown.new/` to any URL. The service fetches the page, extracts the main content, and returns clean markdown.

```
https://markdown.new/https://example.com/some/article
```

The service handles JavaScript-rendered pages, paywalls (partially), and common anti-bot measures better than a raw fetch because it uses a real browser under the hood.

## Workflow

### Step 1: Build the markdown.new URL

Take the target URL and prepend `https://markdown.new/`:

```
Target:   https://blog.example.com/post/123
Fetch:    https://markdown.new/https://blog.example.com/post/123
```

If the user provides a URL without a scheme, add `https://` first.

### Step 2: Fetch via WebFetch (preferred)

Use `WebFetch` with the markdown.new URL and a prompt that extracts the content the user needs:

```
WebFetch(
  url: "https://markdown.new/https://blog.example.com/post/123",
  prompt: "Return the full article content as markdown"
)
```

The prompt should reflect what the user is looking for — a summary, specific sections, the full text, etc.

### Step 3: Fall back to curl if WebFetch fails

If WebFetch returns a 403 or other error, try curl:

```bash
curl -sL --max-time 30 "https://markdown.new/https://blog.example.com/post/123"
```

### Step 4: Present the content

Return the markdown content to the user. If the user asked for a summary, summarize it. If they asked for specific information, extract it. If they just said "fetch this", return the key content in a readable format.

## Tips for Claude

- **Always use the markdown.new URL, not the original URL** — that's the whole point of this skill. The service does the content extraction for you.
- **Keep the prompt in WebFetch specific** — "Return the full article content" works better than a vague "What is this page about?"
- **If markdown.new itself fails**, fall back to fetching the original URL directly with `WebFetch` — sometimes the original works fine and the intermediary isn't needed.
- **Don't over-process** — if the user just wants to read what's on a page, give them the markdown content without heavy summarization unless they asked for it.
- **URL encoding** — the target URL after `markdown.new/` does not need to be URL-encoded. Pass it as-is.
