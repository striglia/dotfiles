---
name: git-workflow
description: Complete GitHub issue workflow - creates feature branch, commits with proper formatting, creates PR. Use when implementing features, fixing bugs, or user says "/git-workflow". MANDATORY - never commit directly to main, always use feature branches and PRs.
allowed-tools: Bash(git:*), Bash(gh:*)
---

# Git Workflow for GitHub Issues

Complete workflow for implementing features tracked in GitHub Issues.

## When to Use This Skill

**Recognize user intent, not literal phrases:**

Invoke this skill immediately when the user indicates they want you to:

- Start working on a GitHub issue (by number or URL)
- Implement a feature tracked by an issue
- Fix a bug tracked by an issue
- Make code changes associated with an issue

**Action: Invoke `/git-workflow {issue-number}` as your FIRST response**

Do NOT:

- Fetch the issue yourself
- Create a todo list first
- Start making changes
- Create branches manually

The skill handles the complete workflow from start to finish.

**Explicit invocation**:

- User says `/git-workflow 42` or `/git-workflow {issue-number}`
- User says `/git-workflow commit` (when on a feature branch)
- User says `/git-workflow review` (self-review with subagent debate)
- User says `/git-workflow push` (auto-runs review, then creates PR)

## Mandatory Rules

1. **NEVER commit directly to main branch**
2. **ALWAYS create a feature branch from an issue**
3. **ALWAYS use proper commit message format: `#{number}: {title}`**
4. **ALWAYS create a Pull Request - never merge without PR**
5. **ALWAYS include "Closes #{number}" in PR body**
6. **Export session transcript** on initial commit only - run `/export-session --gist` and include URL in commit message (default: ON, opt-out via CLAUDE.md). Follow-up commits (via `/fix-pr-feedback` or manual) do not include transcripts.

## Core Workflow

The complete workflow has six phases:

1. **Start**: `/git-workflow {issue-number}` - Create feature branch
2. **Commit**: `/git-workflow commit` - Stage and commit changes
3. **Review**: `/git-workflow review` - Self-review with subagent debate (MANDATORY)
3.5. **Reconstruct**: (automatic) - Clean up commit history before push
4. **Push**: `/git-workflow push` - Push branch and create PR
5. **Feedback**: `/fix-pr-feedback` - Address reviewer feedback and iterate

## Phase 1: Start Working on Issue

**When**: User provides an issue number (e.g., `/git-workflow 42`)

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

4. **Fetch issue details**:
   - Run: `gh issue view {issue_num} --json title,state -q '{title: .title, state: .state}'`
   - Parse the JSON response to extract title and state
   - Display: "Issue #{issue_num}: {title}" and "State: {state}"
   - If state is "CLOSED", warn: "Warning: This issue is already closed."

5. **Create feature branch**:
   - Generate slug from issue title:
     - Convert to lowercase
     - Replace spaces with hyphens
     - Remove non-alphanumeric characters except hyphens
     - Truncate to 50 characters
   - Branch name format: `{issue-number}-{slug}`
     - Example: `42-add-user-authentication`
   - Run: `git checkout -b "{branch_name}"`

6. **Confirm success**:
   - Display: "✓ Created branch: {branch_name}"
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
   - If no issue number found, error: "Cannot extract issue number from branch '{branch}'. Branch should be named like: 42-feature-name"

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
   - Fetch issue title: `gh issue view {issue_num} --json title -q .title`
   - Format commit message (with transcript if this is the first commit):

     ```
     #{issue_num}: {issue_title}

     Transcript: {gist_url}  # Only on initial commit

     🤖 Generated with [Claude Code](https://claude.com/claude-code)

     Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
     ```

   - For follow-up commits (no transcript):

     ```
     #{issue_num}: {description of changes}

     🤖 Generated with [Claude Code](https://claude.com/claude-code)

     Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
     ```

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
   - Extract issue number from branch name

2. **Invoke `/review-debate`**:

   Run `/review-debate` with context:

   ```
   /review-debate

   Context: Code changes for issue #{issue_num}: {issue_title}
   ```

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
- Only 1-2 commits on branch (nothing to clean up)
- All commits already look semantic (no "fix typo", "WIP", iteration patterns)
- User has `skip-history-reconstruction: true` in CLAUDE.md
- User explicitly skips at preview prompt

**Steps**:

1. **Check skip conditions**:
   - Count commits: `git rev-list --count origin/main..HEAD`
   - If ≤ 2 commits, display: "Only {n} commits - skipping reconstruction" and proceed to Phase 4
   - Read commit messages: `git log origin/main..HEAD --pretty=format:"%s"`
   - Check for messy patterns (case-insensitive): "fix", "typo", "wip", "temp", "try", "test", "debug", "cleanup", "oops"
   - If no messy patterns found, display: "Commits already look clean - skipping reconstruction" and proceed to Phase 4
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
   - If no issue number found, error: "Cannot extract issue number from branch '{branch}'"

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
   - Fetch issue title: `gh issue view {issue_num} --json title -q .title`
   - Get commit list: `git log origin/main..HEAD --pretty=format:"- %s"`
   - **Check for explainer gist**: `cat /tmp/explainer-gist-url-* 2>/dev/null | head -1`
     - Explainer files are SHA-suffixed (e.g., `/tmp/explainer-gist-url-af4ba6`). Glob picks up whichever branch's explainer is present.
   - Format PR title: `{issue_title}`
   - Format PR body (with explainer if available):

     ```
     > **[PR Explainer](GIST_URL)** — narrative walkthrough for reviewers

     Closes #{issue_num}

     ## Summary
     {issue_title}

     ## Changes
     {commits}
     ```

     (Omit the explainer line if no `/tmp/explainer-gist-url-*` file exists)

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
   - Stage and commit: `git add insights.md && git commit -m "#{issue_num}: Add cross-session insight"`
   - Push: `git push`

7. **Confirm success**:
   - Display: "✓ Created PR: {pr_url}"
   - Display: "Next: Wait for code review, then use `/fix-pr-feedback` to address comments."

## Phase 5: Feedback Loop with Reviewers

**When**: After PR is created and reviewers provide feedback

**Overview**: Iterate with reviewers to finalize the PR before merging.

**Process**:

1. **Wait for review feedback**:
   - Reviewers comment on PR with suggestions, questions, or requested changes
   - CI/CD checks may fail and require fixes
   - GitHub will notify you of new comments

2. **Address feedback using `/fix-pr-feedback`**:
   - Run: `/fix-pr-feedback` (auto-detects PR from current branch)
   - Or: `/fix-pr-feedback {pr-url}` (specify PR explicitly)

   This command will:
   - Fetch all review comments since last commit
   - Filter out non-actionable feedback (bot messages, status updates)
   - Check for failing CI/test runs and investigate failures
   - Analyze feedback and make wise decisions about what to implement
   - Fix critical issues and low-effort improvements
   - Skip items already tracked in GitHub issues (defer to future work)
   - Create focused commits for each category of fixes
   - Push updates to the PR
   - Comment on PR explaining decisions and rationale

3. **Iterate as needed**:
   - Reviewers may request additional changes
   - Run `/fix-pr-feedback` again to address new comments
   - Continue until reviewers approve

4. **Merge when approved**:
   - Once reviewers approve and CI passes, PR is ready to merge
   - User or maintainer merges on GitHub
   - GitHub automatically closes the linked issue (via "Closes #{number}")
   - GitHub automatically deletes the feature branch (if configured)

**Key principles**:

- Be responsive to feedback - address comments promptly
- Make wise decisions - not all feedback requires immediate action
- Communicate clearly - explain your decisions in PR comments
- Keep commits focused - group related fixes together
- Test thoroughly - ensure fixes don't break existing functionality

**For detailed workflow**: See `/fix-pr-feedback` command documentation

## Branch Naming Convention

**Format**: `{issue-number}-{slug}`

**Examples**:

- Issue #8: "Fix wasteful test process" → `8-fix-wasteful-test-process`
- Issue #42: "Add user authentication" → `42-add-user-authentication`
- Issue #123: "Update API to use GraphQL instead of REST" → `123-update-api-to-use-graphql-instead-of-rest`

**Why this format**:

- Issue number at start enables easy extraction with regex `^[0-9]+`
- No ambiguity - each branch maps to exactly one issue
- Human-readable and git-friendly

## Commit Message Format

**Format**: `#{issue-number}: {title-or-description}`

**Initial commit** (with transcript, unless opted out):

```
#{issue-number}: {issue-title}

Transcript: {gist-url}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

**Follow-up commits** (no transcript):

```
#{issue-number}: {description of changes}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

**Examples**:

- Initial: `#8: Fix wasteful test process and auto-run behavior` (with transcript)
- Follow-up: `#8: Fix formatting for CI` (no transcript)
- Follow-up: `#8: Address review feedback on error handling` (no transcript)

**Why this format**:

- GitHub automatically links to issue
- Clear traceability
- Consistent across all commits in the project
- Transcript link on initial commit provides full context of LLM-assisted development (à la Simon Willison)
- Follow-up commits don't need separate transcripts - they're part of the same PR context

## Error Handling

**Common errors and solutions**:

1. **"gh: command not found"**
   - Error: GitHub CLI not installed
   - Solution: Tell user to install: `brew install gh` (macOS) or see https://cli.github.com/

2. **"fatal: not a git repository"**
   - Error: Not in a git repository
   - Solution: Tell user to initialize git or navigate to correct directory

3. **"error: remote origin already exists"** or git network errors
   - Error: Git/GitHub connectivity issue
   - Solution: Have user check git remote configuration: `git remote -v`

4. **"could not resolve host github.com"**
   - Error: Network connectivity
   - Solution: Tell user to check internet connection

5. **Issue number extraction fails**
   - Error: Branch name doesn't follow convention
   - Solution: Branch must start with issue number (e.g., `42-feature-name`)

## Tips for Claude

- Always show the user what you're doing at each step
- If git/gh commands fail, display the error and explain what went wrong
- The workflow is rigid by design - follow the exact steps
- Issue number is the single source of truth (stored in branch name)
- Multiple commits to same branch are fine - all will be included in PR
- If user is already on a feature branch, detect issue number automatically
- **Worktree detection**: Check `git rev-parse --git-dir` vs `git rev-parse --git-common-dir` - if they differ, you're in a worktree. Worktrees can't checkout `main` (it's already checked out in the main repo), so create feature branches from the worktree's current branch instead.
- Generate transcript with `/export-session --gist` on the **initial commit only** (unless `skip-session-transcripts: true` in CLAUDE.md)
- Include the transcript URL in the first commit message for full development context
- Follow-up commits (fixes, feedback responses) don't need transcripts - they're part of the same PR
- This follows Simon Willison's approach: https://simonwillison.net/2025/Dec/25/claude-code-transcripts/

### Self-Review Phase Tips

See `/review-debate` skill for detailed guidance on:

- Spawning parallel Advocate and Critic subagents
- Synthesizing debate into actionable decisions
- FIX NOW vs DEFER vs IGNORE classification criteria

### History Reconstruction Tips

- **Always create backup first** - the backup branch is your safety net
- **Verify with `git diff`** - after reconstruction, diff against backup must be empty
- **Domain extraction** - look at the directory structure to group related files
- **Keep tests together** - by default, keep test files with their implementation
- **Preserve issue reference** - reconstructed commits should still reference the issue number
- **Roll back on any error** - if verification fails, restore from backup immediately
- **Preview before executing** - always show the proposed reconstruction and wait for confirmation

## Session Transcript Opt-Out

To disable automatic session transcript export for a project, add this to CLAUDE.md:

```markdown
skip-session-transcripts: true
```

This is useful for:

- Private/sensitive projects where transcripts shouldn't be public
- Quick fixes where full transcript context isn't valuable
- Projects with strict data handling requirements

## History Reconstruction Opt-Out

To disable automatic history reconstruction before pushing PRs, add this to CLAUDE.md:

```markdown
skip-history-reconstruction: true
```

This is useful for:

- Projects that prefer preserving the raw development history
- Quick fixes where the commit history is already clean
- Situations where you want to manually control commit structure

## Test Commit Style Configuration

To control how tests are grouped during history reconstruction, add to CLAUDE.md:

```markdown
test-commit-style: together   # Keep tests with implementation (default)
test-commit-style: separate   # Put tests in their own commit after implementation
```

The `together` style (default) is recommended for easier code review - reviewers see the test alongside the code it tests.
