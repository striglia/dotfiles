---
name: markdown-fetch
description: Fetch a webpage's content as clean markdown using markdown.new, stripping away HTML/JS/CSS to focus on the actual content. Use when you need to read a webpage for its information, not its structure.
allowed-tools: WebFetch, Bash(curl:*)
---

# Markdown Fetch

Fetch a webpage's content as clean, readable markdown via [markdown.new](https://markdown.new). Use this when you care about **what a page says**, not how it's built.

## When to Use

- When the user asks you to read, summarize, or reference a webpage's content
- When `WebFetch` fails on a URL (403, bot-blocking, Cloudflare challenges) — markdown.new acts as an intermediary that can often bypass these restrictions
- When the user says "fetch this page", "what does this page say", "summarize this article", etc.
- When you need clean text from a page cluttered with nav, ads, and boilerplate HTML
- Do **not** use this when the user cares about the actual HTML structure, DOM, JavaScript behavior, or CSS — use `WebFetch` directly for those cases

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
