---
name: work
description: Complete feature branch workflow - creates feature branch, commits with proper formatting, creates PR. Works with or without GitHub issues. Use when implementing features, fixing bugs, or user says "/work". MANDATORY - never commit directly to main, always use feature branches and PRs.
allowed-tools: Bash(git:*), Bash(gh:*)
---

# Work

Complete workflow for implementing features — works with or without GitHub Issues.

## When to Use This Skill

**Recognize user intent, not literal phrases:**

Invoke this skill immediately when the user indicates they want you to:

- Start working on a GitHub issue (by number or URL)
- Implement a feature tracked by an issue
- Fix a bug tracked by an issue
- Make code changes associated with an issue
- Implement a feature or fix without a GitHub issue
- Start any feature branch work

**Action: Invoke `/work` (with or without issue number) as your FIRST response**

Do NOT:

- Fetch the issue yourself
- Create a todo list first
- Start making changes
- Create branches manually

The skill handles the complete workflow from start to finish.

**Explicit invocation**:

- User says `/work 42` or `/work {issue-number}`
- User says `/work` (no args — will prompt for issue or proceed without one)
- User says `/work commit` (when on a feature branch)
- User says `/work review` (self-review with subagent debate)
- User says `/work push` (auto-runs review, then creates PR)

## Mandatory Rules

1. **NEVER commit directly to main branch**
2. **ALWAYS create a feature branch** (from an issue or a description)
3. **ALWAYS use proper commit message format** (see Commit Message Format section)
4. **ALWAYS create a Pull Request - never merge without PR**
5. **ALWAYS include "Closes #{number}" in PR body** when working from an issue
6. **Session transcripts are opt-in** - never upload a transcript or workspace history unless the user explicitly approves that specific external upload after being informed what it contains and where it will go. Without approval, omit the transcript and continue the commit, review, push, and PR workflow.

## Core Workflow

The complete workflow has five phases:

1. **Start**: `/work [issue-number]` - Create feature branch (enters plan mode for non-trivial tasks)
2. **Commit**: `/work commit` - Stage and commit changes
3. **Review**: `/work review` - Self-review with subagent debate (MANDATORY)
4. **Push**: `/work push` - Push branch and create PR
5. **Feedback**: `/fix-pr-feedback` - Address reviewer feedback and iterate

## Phase 1: Start Working

**When**: User invokes `/work` (with or without an issue number)

**Steps**:

1. **Detect worktree context**:
   - Check if in a worktree: `git rev-parse --git-dir` vs `git rev-parse --git-common-dir`
   - If `.git` dir differs from common dir, we're in a worktree
   - Store result for later steps

2. **Validate prerequisites**:
   - Get current branch: `git branch --show-current`
   - **If NOT in a worktree**:
     - If not on `main`, error: "Must be on main branch. Currently on: {branch}"
   - **If in a worktree**:
     - Accept current branch as base (worktrees can't checkout main - it's used elsewhere)
     - Note the base branch name for display
   - Check for uncommitted changes: `git diff-index --quiet HEAD --`
   - If dirty, error: "You have uncommitted changes. Commit or stash them first."

3. **Update base branch**:
   - **If NOT in a worktree**: `git pull origin main`
   - **If in a worktree**: `git pull origin {current_branch}` (or skip if branch has no upstream)

4. **Resolve issue context** (determines `has_issue` for all subsequent phases):

   Resolution order:
   1. **Explicit issue number provided** (e.g., `/work 42`): set `has_issue = true`, `issue_num = 42`. This ALWAYS takes precedence, even if `skip-github-issues: true` is set in CLAUDE.md.
   2. **CLAUDE.md contains `skip-github-issues: true`** and no explicit number: set `has_issue = false`. Prompt the user for a short description of the work (1-2 sentences).
   3. **No number provided and no opt-out flag**: Ask the user: "Do you have a GitHub issue for this work? (enter number/URL, or 'no')"
      - If user provides a number/URL: extract issue number, set `has_issue = true`
      - If user says "no" (or equivalent): set `has_issue = false`. Ask for a short description of the work.

   After this step, two variables flow through all remaining phases:
   - `has_issue` (bool)
   - `description` (string — issue title if `has_issue`, user-provided description otherwise)

5. **Fetch issue details** (only if `has_issue = true`):
   - Run: `gh issue view {issue_num} --json title,state,body -q '{title: .title, state: .state, body: .body}'`
   - Parse the JSON response to extract title, state, and body
   - Display: "Issue #{issue_num}: {title}" and "State: {state}"
   - If state is "CLOSED", warn: "Warning: This issue is already closed."
   - Set `description = {title}`

6. **Scope check** (only if `has_issue = true` — skip when working without an issue):
   - Analyze the issue body for scope signals:
     - Count checklist items (`- [ ]` lines)
     - Count distinct subsystems mentioned (backend, client, UI, config, docs, hosting, etc.)
     - Check title for migration/refactor keywords: "migrate", "productionize", "refactor", "overhaul"
     - Estimate files likely affected based on the scope description
   - **If any trigger fires** (4+ checklist items, >2 subsystems, migration keyword, or likely >10 files):
     - Display a scope warning and proposed session split:
       ```
       Scope check: This issue looks large ({reason}).
       Suggested session boundaries:
         Session 1: {scope} (~N files)
         Session 2: {scope} (~N files)
         ...
       Each session produces an independently committable unit.
       Want to split into sessions, or tackle it all at once?
       ```
     - Wait for user response
     - If user chooses to split: create a branch for Session 1 only, note the remaining sessions
     - If user chooses all-at-once: proceed, but note the scope for practice review
   - **If no triggers fire**: proceed silently (don't slow down small issues)

6.5. **Co-design check** (plan mode by default, skip for trivial tasks):

   **Enter plan mode** (call `EnterPlanMode`) if ANY of these apply:
   - Any scope trigger fired in step 6
   - Issue involves a new feature (not a simple fix/chore)
   - Issue body mentions architecture, design decisions, or multiple approaches
   - User description (when no issue) suggests non-trivial work
   - Working without an issue and description is more than one sentence

   **Skip plan mode** ONLY if ALL of these apply:
   - Single-file or few-file change
   - Clear, specific task (bug fix with obvious solution, typo, config change)
   - No architectural decisions involved
   - User explicitly says "just do it" or equivalent

   **Mechanics:**
   - Call `EnterPlanMode` tool — user gets a prompt to accept/decline
   - If user accepts: explore the codebase, design the approach, present a plan for approval via `ExitPlanMode`
   - If user declines: proceed without plan mode (continue to step 7)
   - This ensures the user co-designs the approach BEFORE any code is written, but AFTER the issue context is known

7. **Create feature branch**:
   - Generate slug from description:
     - Convert to lowercase
     - Replace spaces with hyphens
     - Remove non-alphanumeric characters except hyphens
     - Truncate to 50 characters
   - Branch name format:
     - **With issue**: `{issue-number}-{slug}` (e.g., `42-add-user-authentication`)
     - **Without issue**: `{slug}` (e.g., `add-user-authentication`)
   - Run: `git checkout -b "{branch_name}"`

8. **Confirm success**:
   - Display: "Created branch: {branch_name}"
   - Display next steps:
     ```
     Next steps:
       1. Make your changes
       2. Run: /work commit
       3. Run: /work review
       4. Run: /work push
     ```

## Phase 2: Commit Changes

**When**: User says `/work commit` (must be on a feature branch)

**Steps**:

1. **Validate prerequisites**:
   - Get current branch: `git branch --show-current`
   - If branch is "main", error: "Cannot commit directly to main. Create a feature branch first."
   - Extract issue number from branch name using regex: `^[0-9]+`
   - If no issue number found: set `has_issue = false` (this is normal for issue-free branches)

2. **Check for changes**:
   - Run: `git diff-index --quiet HEAD --`
   - If no changes, display: "No changes to commit." and exit

3. **Show what will be committed**:
   - Run: `git status --short`
   - Display: "Changes to commit:" followed by the status output

4. **Stage all changes**:
   - Run: `git add .`

5. **Run format verification** (belt and suspenders):
   - PostToolUse hooks should have formatted files, but verify to catch race conditions
   - Detect project type and run appropriate formatter:
     - If `package.json` exists: `npm run format 2>/dev/null || npx prettier --write . 2>/dev/null`
     - If `Cargo.toml` or `src-tauri/Cargo.toml` exists: `cargo fmt`
     - If `pyproject.toml` exists: `ruff format . 2>/dev/null || black . 2>/dev/null`
   - Re-stage if formatters made changes: `git add .`
   - This prevents CI failures from formatting issues that slipped through hooks

6. **Generate transcript** (opt-in, initial commit only):
   - Check if CLAUDE.md contains `skip-session-transcripts: true`; if so, skip this step.
   - Check if the user explicitly approved this specific transcript upload in the current conversation. Do not infer approval from a general request to commit, push, or use `/work`.
   - If approval is absent, skip transcript generation and continue the workflow without a transcript line.
   - If approved, confirm this is the branch's first commit with `git rev-list --count origin/main..HEAD`; follow-up commits never include transcripts.
   - Run `/export-session --gist`, capture the URL, and include it in the initial commit message.

7. **Create commit**:
   - **With issue**: Fetch issue title: `gh issue view {issue_num} --json title -q .title`
   - Format commit message per the Commit Message Format section (with/without issue prefix, transcript on initial commit only)
   - Run: `git commit -m "{commit_msg}"`

8. **Confirm success**:
   - Display: "✓ Committed: {commit_msg}"
   - Show latest commit: `git log -1 --oneline`
   - Display: "Next step: /work review"

## Phase 3: Self-Review

**When**: After commit, before push. This phase is MANDATORY - never skip to push without reviewing first.

**Purpose**: Catch issues before they go to human reviewers.

**Steps**:

1. **Validate prerequisites**:
   - Get current branch: `git branch --show-current`
   - If branch is "main", error: "Nothing to review on main branch."
   - Extract issue number from branch name (if present, set `has_issue = true`)

2. **Invoke `/review-debate`**:

   Run `/review-debate` with context:

   - **With issue**: `Context: Code changes for issue #{issue_num}: {issue_title}`
   - **Without issue**: `Context: Code changes on branch {branch_name}`

   The review-debate skill handles:
   - Gathering the diff and issue context
   - Spawning parallel Advocate and Critic subagents
   - Synthesizing their debate into FIX NOW / DEFER / IGNORE buckets
   - Making quick fixes and creating deferred issues
   - Reporting results

   See `/review-debate` skill documentation for full details.

3. **Confirm completion**:
   - Display: "✓ Self-review complete"
   - Display: "Ready for: /work push"

## Phase 4: Push and Create PR

**When**: User says `/work push` (must be on a feature branch with commits)

**Steps**:

0. **Verify review was completed**:
   - Phase 3 (Review) must have been executed before reaching this phase
   - If you skipped Phase 3, STOP and go back - do not proceed to push

1. **Validate prerequisites**:
   - Get current branch: `git branch --show-current`
   - If branch is "main", error: "Cannot push from main branch."
   - Extract issue number from branch name using regex: `^[0-9]+`
   - If no issue number found: set `has_issue = false` (this is normal for issue-free branches)

2. **Check for commits to push**:
   - Run: `git diff origin/main..HEAD --quiet && git diff --quiet`
   - If no commits, display: "No commits to push." and exit

3. **Push branch**:
   - Check if remote branch exists: `git ls-remote --heads origin "{branch}"`
   - If exists: `git push`
   - If not exists (first push): `git push -u origin "{branch}"`
   - Display: "✓ Pushed to origin/{branch}"

4. **Check if PR already exists**:
   - Run: `gh pr view --json url -q .url 2>/dev/null`
   - If PR exists, display: "✓ PR already exists: {pr_url}" and exit

5. **Create PR**:
   - **With issue**: Fetch issue title: `gh issue view {issue_num} --json title -q .title`
   - **Without issue**: Use the first commit subject or branch name as the title
   - Get commit list: `git log origin/main..HEAD --pretty=format:"- %s"`
   - **Check for explainer gist**: `cat /tmp/explainer-gist-url-* 2>/dev/null | head -1`
     - Explainer files are SHA-suffixed (e.g., `/tmp/explainer-gist-url-af4ba6`). Glob picks up whichever branch's explainer is present.
   - Format PR title: `{issue_title}` (with issue) or `{first commit subject / branch slug}` (without issue)
   - Format PR body:
     ```
     > **[PR Explainer](GIST_URL)** — narrative walkthrough for reviewers  ← omit if no /tmp/explainer-gist-url-* file

     Closes #{issue_num}  ← omit when has_issue = false

     ## Summary
     {description}

     ## Changes
     {commits}
     ```

   - Run: `gh pr create --title "{pr_title}" --body "{pr_body}" --base main`
   - Get PR URL: `gh pr view --json url -q .url`
   - Clean up explainer URL file if used: `rm -f /tmp/explainer-gist-url-*`

6. **Cross-session insights check**:
   - Check if `insights.md` or `insights.markdown` exists in the project root
   - If not found, skip to step 7
   - If found, read the file to understand the format
   - Reflect: "Did I learn something surprising on this branch — especially something guided by user feedback — that would matter to an agent on a different branch?"
   - An insight qualifies if it is:
     - **Non-obvious**: An agent wouldn't discover it from reading a single file
     - **Durable**: Will still be true in a month
     - **Generalizable**: Applies beyond the specific ticket
   - If nothing qualifies, skip to step 7 — not every branch produces an insight
   - If something qualifies, append a new entry to the insights file following its existing format
   - Stage and commit:
     - **With issue**: `git add insights.md && git commit -m "#{issue_num}: Add cross-session insight"`
     - **Without issue**: `git add insights.md && git commit -m "Add cross-session insight"`
   - Push: `git push`

7. **Confirm success**:
   - Display: "✓ Created PR: {pr_url}"
   - Display: "Next: Wait for code review, then use `/fix-pr-feedback` to address comments."

## Phase 5: Feedback Loop with Reviewers

**When**: After PR is created and reviewers provide feedback.

Run `/fix-pr-feedback` (auto-detects PR from current branch) or `/fix-pr-feedback {pr-url}`. Iterate until reviewers approve and CI passes. See `/fix-pr-feedback` skill for full details.

On merge: if linked to an issue, GitHub auto-closes it via the `Closes #{number}` line.

## Branch Naming Convention

Slug rules: lowercase, spaces→hyphens, strip non-alphanumeric (except hyphens), truncate to 50 chars.

- **With issue**: `{issue-number}-{slug}` — e.g., `42-add-user-authentication`
- **Without issue**: `{slug}` — e.g., `add-user-authentication`

Issue number at start enables extraction via regex `^[0-9]+`. No leading number → `has_issue = false`.

## Commit Message Format

Subject line: `#{issue-number}: {description}` (with issue) or `{description}` (without issue).

**Template** (initial commit includes Transcript line; follow-ups omit it):

```
[#{N}: ]{description}        ← #{N}: prefix only when has_issue

Transcript: {gist-url}       ← initial commit only when explicitly approved

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

**Examples**: `#8: Fix wasteful test process` (with issue) · `Fix wasteful test process` (without issue)

## Error Handling

- **`gh` not found**: Tell user to install GitHub CLI (`brew install gh`)
- **Not a git repo / network errors**: Display error, tell user to check setup (`git remote -v`, internet)
- **No issue number in branch name**: NOT an error — set `has_issue = false` and proceed normally

## Tips for Claude

- Show the user what you're doing at each step; display errors with explanations
- The workflow is rigid by design — follow the exact steps in order
- `has_issue = true`: issue number is the source of truth (from branch name regex `^[0-9]+`)
- `has_issue = false`: branch slug and description drive naming and commit messages
- If already on a feature branch, detect issue number automatically (if present)
- **Worktree detection**: `git rev-parse --git-dir` vs `--git-common-dir` — if they differ, you're in a worktree. Create branches from current branch (can't checkout `main`).
- **Worktree path discipline**: When in a worktree, ALL file operations (Read, Edit, Write, Grep, Glob) MUST use the worktree's path as the base, not the main repo path. The worktree has its own complete copy of the repo. If you search from the main repo path and then edit those paths, your changes land in the wrong checkout. Always derive paths from the CWD, not from hardcoded or previously-seen repo paths.
- **Transcripts**: opt-in and initial commit only. Never upload without explicit approval for that specific external upload; `skip-session-transcripts: true` is a hard project-level prohibition.
- **Self-review**: see `/review-debate` skill for Advocate/Critic subagent details

## CLAUDE.md Configuration Flags

Add any of these to a project's CLAUDE.md to customize behavior:

| Flag | Effect |
|---|---|
| `skip-session-transcripts: true` | Prohibit transcript uploads for this project |
| `skip-github-issues: true` | Skip issue prompt; use description-only branches. Explicit `/work 42` still overrides. |
