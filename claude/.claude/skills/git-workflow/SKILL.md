---
name: git-workflow
description: Complete feature branch workflow - creates feature branch, commits with proper formatting, creates PR. Works with or without GitHub issues. Use when implementing features, fixing bugs, or user says "/git-workflow". MANDATORY - never commit directly to main, always use feature branches and PRs.
allowed-tools: Bash(git:*), Bash(gh:*)
---

# Git Workflow

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

**Action: Invoke `/git-workflow` (with or without issue number) as your FIRST response**

Do NOT:

- Fetch the issue yourself
- Create a todo list first
- Start making changes
- Create branches manually

The skill handles the complete workflow from start to finish.

**Explicit invocation**:

- User says `/git-workflow 42` or `/git-workflow {issue-number}`
- User says `/git-workflow` (no args — will prompt for issue or proceed without one)
- User says `/git-workflow commit` (when on a feature branch)
- User says `/git-workflow review` (self-review with subagent debate)
- User says `/git-workflow push` (auto-runs review, then creates PR)

## Mandatory Rules

1. **NEVER commit directly to main branch**
2. **ALWAYS create a feature branch** (from an issue or a description)
3. **ALWAYS use proper commit message format** (see Commit Message Format section)
4. **ALWAYS create a Pull Request - never merge without PR**
5. **ALWAYS include "Closes #{number}" in PR body** when working from an issue
6. **Export session transcript** on initial commit only - run `/export-session --gist` and include URL in commit message (default: ON, opt-out via CLAUDE.md). Follow-up commits (via `/fix-pr-feedback` or manual) do not include transcripts.

## Core Workflow

The complete workflow has six phases:

1. **Start**: `/git-workflow [issue-number]` - Create feature branch
2. **Commit**: `/git-workflow commit` - Stage and commit changes
3. **Review**: `/git-workflow review` - Self-review with subagent debate (MANDATORY)
3.5. **Reconstruct**: (automatic) - Clean up commit history before push
4. **Push**: `/git-workflow push` - Push branch and create PR
5. **Feedback**: `/fix-pr-feedback` - Address reviewer feedback and iterate

## Phase 1: Start Working

**When**: User invokes `/git-workflow` (with or without an issue number)

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
   1. **Explicit issue number provided** (e.g., `/git-workflow 42`): set `has_issue = true`, `issue_num = 42`. This ALWAYS takes precedence, even if `skip-github-issues: true` is set in CLAUDE.md.
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
       2. Run: /git-workflow commit
       3. Run: /git-workflow review
       4. Run: /git-workflow push
     ```

## Phase 2: Commit Changes

**When**: User says `/git-workflow commit` (must be on a feature branch)

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

6. **Generate transcript** (default: ON, initial commit only):
   - Skip this step if this is a follow-up commit (branch already has commits ahead of main)
   - Check if branch has prior commits: `git rev-list --count origin/main..HEAD`
   - If count > 0, skip transcript generation - this is a follow-up commit
   - If count == 0 (first commit on branch):
     - Check if CLAUDE.md contains `skip-session-transcripts: true`
     - If opt-out is set, skip this step
     - Otherwise, run: `/export-session --gist` to upload session transcript
     - Capture the gist URL from output
     - This creates a permanent record of the initial development session

7. **Create commit**:
   - **With issue**: Fetch issue title: `gh issue view {issue_num} --json title -q .title`
   - Format commit message per the Commit Message Format section (with/without issue prefix, transcript on initial commit only)
   - Run: `git commit -m "{commit_msg}"`

8. **Confirm success**:
   - Display: "✓ Committed: {commit_msg}"
   - Show latest commit: `git log -1 --oneline`
   - Display: "Next step: /git-workflow review"

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
   - Display: "Ready for: /git-workflow push (will auto-reconstruct history if needed)"

## Phase 3.5: Reconstruct History

**When**: Automatically triggered as part of `/git-workflow push` before pushing. Can also be invoked directly with `/git-workflow reconstruct`.

**Purpose**: Transform messy development history (try A, fix typo, try B, WIP) into clean, semantic commits optimized for code reviewers.

**Skip Conditions** (check these first):
- User has `skip-history-reconstruction: true` in CLAUDE.md
- User explicitly skips at preview prompt

**Steps**:

1. **Check skip conditions**:
   - Check if CLAUDE.md contains `skip-history-reconstruction: true` - if so, skip

2. **Create safety backup**:
   ```bash
   BACKUP_BRANCH="${BRANCH}-backup-$(date +%s)"
   git branch "$BACKUP_BRANCH"
   ```
   - Display: "✓ Backup created: {BACKUP_BRANCH}"

3. **Analyze the diff**:
   - Get all changed files: `git diff --name-status origin/main...HEAD`
   - Parse file paths to extract domains and types
   - Build a map of files to their logical groups

4. **Group files into logical chunks** (priority order):

   Use these heuristics to assign files to chunks:

   | Priority | Category | Pattern Examples | Commit Prefix |
   |----------|----------|------------------|---------------|
   | 1 | Schema/migrations | `**/migrations/**`, `*.sql`, `schema.*` | `chore(db):` |
   | 2 | Dependencies | `package.json`, `Cargo.toml`, `*.lock`, `go.mod` | `chore(deps):` |
   | 3 | Binary assets | `*.png`, `*.jpg`, `*.woff`, `*.ico` | `chore(assets):` |
   | 4 | Type definitions | `*.d.ts`, `**/types/**`, `**/interfaces/**` | `chore(types):` |
   | 5 | Feature by domain | Extract from path (e.g., `/components/auth/` → "auth") | `feat({domain}):` |
   | 6 | Configuration | `*.config.*`, `.env*`, `*.toml`, `*.yaml` | `chore(config):` |
   | 7 | Documentation | `*.md`, `docs/**`, `README*` | `docs:` |

   **Chunking rules**:
   - Extract "feature domain" from paths: `/components/auth/Login.tsx` → "auth"
   - **Keep tests WITH implementation** (configurable via `test-commit-style` in CLAUDE.md):
     - `together` (default): `Login.tsx` and `Login.test.tsx` in same commit
     - `separate`: Tests in their own commit after implementation
   - Never split a single file across commits
   - Target 5-15 files per commit (reviewable size)
   - If a chunk exceeds 15 files, split by subdirectory

5. **Order chunks by dependency**:
   - Migrations/schema first (other code depends on them)
   - Dependencies second
   - Types before implementation
   - Implementation before tests (if separated)
   - Configuration after code
   - Documentation last

6. **Show preview and get confirmation**:
   ```
   Proposed reconstruction ({N} clean commits from {M} original):

   1. chore(deps): Update dependencies
      - package.json
      - package-lock.json

   2. feat(auth): Add user authentication
      - src/components/auth/Login.tsx
      - src/components/auth/Login.test.tsx
      - src/services/authService.ts

   3. docs: Update README
      - README.md

   Backup branch: feature-42-backup-1738234567
   Proceed with reconstruction? [Y/n]
   ```

   - Wait for user confirmation
   - If user declines, display: "Skipping reconstruction - keeping original commits" and proceed to Phase 4

7. **Execute reconstruction**:
   ```bash
   # Reset to merge base, keeping all changes staged
   git reset --soft $(git merge-base HEAD origin/main)
   git reset HEAD  # Unstage all files

   # For each chunk in order:
   for chunk in chunks:
       git add ${chunk.files}
       git commit -m "${chunk.message}"
   ```

   **Commit message format for reconstructed commits**:
   ```
   {prefix} {description}

   🤖 Generated with [Claude Code](https://claude.com/claude-code)

   Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
   ```

8. **Verify no code loss**:
   ```bash
   # This diff should be empty - same code, different history
   git diff "${BACKUP_BRANCH}"..HEAD --stat
   ```

   - If diff is NOT empty:
     - Display: "⚠️ Code mismatch detected! Rolling back..."
     - Run: `git reset --hard "${BACKUP_BRANCH}"`
     - Display: "Restored to backup. Original commits preserved."
     - Proceed to Phase 4 with original history

   - If diff IS empty:
     - Display: "✓ Verification passed - no code loss"
     - Display: "✓ Reconstructed {M} commits into {N} clean commits"

9. **Cleanup** (optional):
   - The backup branch remains for safety
   - Display: "Backup branch '{BACKUP_BRANCH}' preserved. Delete with: git branch -D {BACKUP_BRANCH}"
   - Proceed to Phase 4

## Phase 4: Push and Create PR

**When**: User says `/git-workflow push` (must be on a feature branch with commits)

**Steps**:

0. **Verify review was completed**:
   - Phase 3 (Review) must have been executed before reaching this phase
   - If you skipped Phase 3, STOP and go back - do not proceed to push

0.5. **Run history reconstruction**:
   - Execute Phase 3.5 (Reconstruct History) before proceeding
   - This will either clean up the history or skip if not needed
   - Wait for Phase 3.5 to complete before continuing

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

Transcript: {gist-url}       ← initial commit only (unless skip-session-transcripts)

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
- **Transcripts**: initial commit only, via `/export-session --gist` (unless `skip-session-transcripts: true`)
- **Self-review**: see `/review-debate` skill for Advocate/Critic subagent details
- **History reconstruction**: always backup first, verify with `git diff`, roll back on mismatch. If branch is issue-linked, preserve the issue number reference in reconstructed commits.

## CLAUDE.md Configuration Flags

Add any of these to a project's CLAUDE.md to customize behavior:

| Flag | Effect |
|---|---|
| `skip-session-transcripts: true` | Skip `/export-session --gist` on initial commit |
| `skip-history-reconstruction: true` | Skip Phase 3.5 history cleanup before push |
| `skip-github-issues: true` | Skip issue prompt; use description-only branches. Explicit `/git-workflow 42` still overrides. |
| `test-commit-style: together` | (default) Keep tests with implementation in reconstruction |
| `test-commit-style: separate` | Put tests in their own commit during reconstruction |
