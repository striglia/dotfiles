---
name: capture-knowledge
description: Persist corrections and teaching moments as knowledge items in CLAUDE.md. Triggered inline when the user corrects Claude, not at end-of-session.
allowed-tools: Read, Edit, Write, Glob, Grep, AskUserQuestion
---

# Capture Knowledge

**Core Purpose:** Turn corrections into persistent knowledge at the moment they happen — as a side effect of the correction itself, not a separate documentation task.

> This is the inline complement to `/retro`. Where `/retro` does batch end-of-session analysis, `/capture-knowledge` persists a single correction immediately.

## When to Trigger

**Automatic offer (behavioral — see global CLAUDE.md rule):**

Claude should recognize correction patterns and offer to capture. The offer is a one-liner, not a workflow interruption:

> "Worth saving? I can add this to [target]: **[proposed rule]**"

The user says yes, tweaks wording, or dismisses. Three seconds, not thirty.

**Correction patterns to recognize:**

| Pattern | Example |
|---------|---------|
| Direct correction | "no, use X not Y" |
| Convention teaching | "we always...", "the convention here is..." |
| Preference statement | "I prefer...", "by default you should..." |
| Tool/library preference | "use uv, not pip", "don't call fetch directly" |
| Architecture rule | "all API calls go through the service layer" |
| Process rule | "always run tests before committing" |
| Anti-pattern warning | "never do X because..." |
| Naming convention | "we use kebab-case for filenames" |

**Do NOT offer when:**

- The correction is situational ("no, I meant this specific file" — not generalizable)
- The correction is already documented (check target file first)
- The user seems frustrated or rushed (read the room)
- It's a simple misunderstanding, not a reusable rule

## Explicit Invocation

User says `/capture-knowledge` with or without a description:

```
/capture-knowledge
/capture-knowledge "use uv not pip for Python deps"
```

When invoked explicitly, review recent conversation for uncaptured corrections and propose them.

## Capture Workflow

### Step 1: Draft the Knowledge Item

Distill the correction into a single, actionable rule. Good knowledge items are:

- **Imperative** — tells Claude what to do, not what happened
- **Scoped** — clear when it applies
- **Concise** — one to two lines
- **Self-contained** — doesn't require context from the conversation

**Good:**
```
- Always use `uv` for Python dependency management, not `pip`
```

**Bad:**
```
- The user prefers uv over pip because they mentioned it's faster and handles virtual environments better
```

**Good:**
```
- Don't call `fetch()` directly — use the wrapper in `src/lib/api-client.ts` which handles auth, retries, and error normalization
```

**Bad:**
```
- There's a fetch wrapper that should be used instead of fetch
```

### Step 2: Determine Target

Use this decision framework (same as `/retro`):

| Signal | Target |
|--------|--------|
| "In this project..." / project-specific convention | `./CLAUDE.md` (project) |
| "I always want..." / cross-project preference | `~/.claude/CLAUDE.md` (global) |
| "When doing X, also do Y" / skill-specific | Relevant skill file |
| Tool or language preference | `~/.claude/CLAUDE.md` (global) |
| Codebase convention (naming, structure) | `./CLAUDE.md` (project) |
| Architecture rule | `./CLAUDE.md` or `./ARCHITECTURE.md` (project) |

When ambiguous, **default to project CLAUDE.md** — it's easier to promote to global later than to remove a premature global rule.

### Step 3: Present for Review

Show the user what will be written and where:

```
💡 Capture this?

Target: ./CLAUDE.md → Conventions section
Rule: "Always use `uv` for Python dependency management, not `pip`"

(y / edit / n)
```

Use AskUserQuestion with options:
- **Save** — write as proposed
- **Edit** — let user rephrase (show proposed text, accept their revision)
- **Skip** — don't save, continue working

### Step 4: Write to Target

1. **Read the target file** to find the right section
2. **Check for duplicates** — if a similar rule exists, update rather than duplicate
3. **Append to the appropriate section:**
   - If a matching section exists (e.g., "Conventions", "Tool Preferences"), add there
   - If no matching section, create one with a clear heading
   - If the file doesn't exist yet, create it with the standard CLAUDE.md structure
4. **Keep the edit minimal** — add one line, don't reorganize the file

### Step 5: Confirm and Continue

Brief confirmation, then immediately continue the interrupted work:

```
Added to ./CLAUDE.md. Continuing...
```

No ceremony. The whole capture should feel like a two-second aside, not a workflow interruption.

## Section Mapping

When adding to an existing CLAUDE.md, place items in the most appropriate section:

| Knowledge Type | Section Name |
|---------------|-------------|
| Tool preferences | `## Tool Preferences` or `## Conventions` |
| Code patterns | `## Conventions` or `## Key Patterns` |
| Architecture rules | `## Architecture` |
| Process/workflow | `## Workflow` or `## Development Process` |
| Gotchas/warnings | `## Gotchas` |
| Naming conventions | `## Conventions` |
| Testing rules | `## Testing` or `## Conventions` |

If the target CLAUDE.md has different section names, match the existing structure rather than imposing this mapping.

## Deduplication

Before writing, search the target file for:

1. **Exact match** — rule already exists → skip, tell user
2. **Semantic overlap** — similar rule exists → propose updating the existing rule
3. **Contradiction** — existing rule says the opposite → flag to user, ask which is correct

## Examples

### Example 1: Tool Preference (Global)

```
User: "use uv, not pip"

Claude: Got it, using uv.

  Worth saving? I can add to ~/.claude/CLAUDE.md:
  "Always use `uv` for Python dependency management, not `pip`"

User: yes

[Writes to ~/.claude/CLAUDE.md → Tool Preferences section]

Claude: Added. Installing with uv...
```

### Example 2: Code Convention (Project)

```
User: "don't call fetch directly, use the wrapper in src/lib/api-client"

Claude: Understood, switching to the api-client wrapper.

  Worth saving? I can add to ./CLAUDE.md → Conventions:
  "Don't call `fetch()` directly — use the wrapper in `src/lib/api-client.ts`
  which handles auth, retries, and error normalization"

User: "make it shorter — just say it handles auth and retries"

[Writes revised version to ./CLAUDE.md]

Claude: Added. Using api-client for the request...
```

### Example 3: Situational — Don't Capture

```
User: "no, the other file — I meant utils.ts not helpers.ts"

[This is navigation, not a rule. Don't offer to capture.]
```

### Example 4: Already Documented

```
User: "always run tests before committing"

[Claude checks CLAUDE.md, finds "## Workflow" with "Run tests before pushing"]

Claude: That's already in CLAUDE.md — I should have followed it. Running tests now.
```

### Example 5: Explicit Invocation

```
User: /capture-knowledge

Claude: Scanning recent conversation for uncaptured knowledge...

Found 2 items:

1. **Target: ./CLAUDE.md → Conventions**
   "Use `zod` for runtime validation at API boundaries, not manual checks"

2. **Target: ~/.claude/CLAUDE.md → Tool Preferences**
   "Prefer `vitest` over `jest` for new TypeScript projects"

Save both? (y / edit / skip individual items)
```

## Integration with /retro

`/capture-knowledge` and `/retro` serve different purposes:

| | `/capture-knowledge` | `/retro` |
|---|---|---|
| **When** | Inline, at moment of correction | End of session |
| **Scope** | Single knowledge item | Full session analysis |
| **Trigger** | User corrects Claude | Explicit or proactive |
| **Output** | One line added to CLAUDE.md | Multiple proposals across files |
| **Friction** | ~3 seconds | ~2 minutes |

`/retro` should check for items that `/capture-knowledge` already persisted and skip them. Conversely, `/retro` catches corrections that happened too fast to capture inline.

## Tips

1. **Read the room** — if the user is heads-down debugging, don't interrupt with capture offers
2. **One at a time** — never batch multiple capture offers; handle each correction individually
3. **Brevity is respect** — the offer and confirmation should each be one line
4. **Default to project scope** — global rules should be clearly universal
5. **Don't over-capture** — not every correction is a pattern worth persisting
6. **Continue immediately** — after capturing, resume the interrupted work without pause
7. **Check before writing** — always read the target file first to avoid duplicates
