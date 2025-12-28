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
- User says `/git-workflow push` (when ready to create PR)

## Mandatory Rules

1. **NEVER commit directly to main branch**
2. **ALWAYS create a feature branch from an issue**
3. **ALWAYS use proper commit message format: `#{number}: {title}`**
4. **ALWAYS create a Pull Request - never merge without PR**
5. **ALWAYS include "Closes #{number}" in PR body**

## Core Workflow

The complete workflow has four phases:

1. **Start**: `/git-workflow {issue-number}` - Create feature branch
2. **Commit**: `/git-workflow commit` - Stage and commit changes
3. **Push**: `/git-workflow push` - Push branch and create PR
4. **Review**: `/fix-pr-feedback` - Address reviewer feedback and iterate

## Phase 1: Start Working on Issue

**When**: User provides an issue number (e.g., `/git-workflow 42`)

**Steps**:

1. **Validate prerequisites**:
   - Check current branch is `main`: `git branch --show-current`
   - If not on main, error: "Must be on main branch. Currently on: {branch}"
   - Check for uncommitted changes: `git diff-index --quiet HEAD --`
   - If dirty, error: "You have uncommitted changes. Commit or stash them first."

2. **Update main branch**:
   - Run: `git pull origin main`

3. **Fetch issue details**:
   - Run: `gh issue view {issue_num} --json title,state -q '{title: .title, state: .state}'`
   - Parse the JSON response to extract title and state
   - Display: "Issue #{issue_num}: {title}" and "State: {state}"
   - If state is "CLOSED", warn: "Warning: This issue is already closed."

4. **Create feature branch**:
   - Generate slug from issue title:
     - Convert to lowercase
     - Replace spaces with hyphens
     - Remove non-alphanumeric characters except hyphens
     - Truncate to 50 characters
   - Branch name format: `{issue-number}-{slug}`
     - Example: `42-add-user-authentication`
   - Run: `git checkout -b "{branch_name}"`

5. **Confirm success**:
   - Display: "✓ Created branch: {branch_name}"
   - Display next steps:
     ```
     Next steps:
       1. Make your changes
       2. Run: /git-workflow commit
       3. Run: /git-workflow push
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

5. **Create commit**:
   - Fetch issue title: `gh issue view {issue_num} --json title -q .title`
   - Format commit message: `#{issue_num}: {issue_title}`
   - Run: `git commit -m "{commit_msg}"`

6. **Confirm success**:
   - Display: "✓ Committed: {commit_msg}"
   - Show latest commit: `git log -1 --oneline`
   - Display: "Next step: /git-workflow push"

## Phase 3: Push and Create PR

**When**: User says `/git-workflow push` (must be on a feature branch with commits)

**Steps**:

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
   - Format PR title: `{issue_title} (#{issue_num})`
   - Format PR body:
     ```
     Closes #{issue_num}

     ## Summary
     {issue_title}

     ## Changes
     {commits}
     ```
   - Run: `gh pr create --title "{pr_title}" --body "{pr_body}" --base main`
   - Get PR URL: `gh pr view --json url -q .url`

6. **Confirm success**:
   - Display: "✓ Created PR: {pr_url}"
   - Display: "Next: Wait for code review, then use `/fix-pr-feedback` to address comments."

## Phase 4: Feedback Loop with Reviewers

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

**Format**: `#{issue-number}: {issue-title}`

**Examples**:
- `#8: Fix wasteful test process and auto-run behavior`
- `#42: Add user authentication`
- `#123: Update API to use GraphQL instead of REST`

**Why this format**:
- GitHub automatically links to issue
- Clear traceability
- Consistent across all commits in the project

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
