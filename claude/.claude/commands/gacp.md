---
description: "Git Add Commit Push - Intelligently stage, commit with contextual messages, and push changes"
allowed-tools: ["Bash"]
---

# Git Add Commit Push (GACP)

Intelligently analyzes the current git repository state, stages all changes, generates a contextual commit message based on the changes, commits, and pushes to remote.

Usage: `/gacp`

This command will:
1. Check if current directory is a git repository
2. Analyze current git status and file changes
3. Stage all unstaged changes
4. Generate an intelligent commit message based on file types and change patterns
5. Commit with the generated message
6. Push to remote (with user confirmation on conflicts)

The commit message generation considers:
- File types (tests, docs, config, source code)
- Change types (added, modified, deleted files)
- Project context and existing commit message patterns

Safety features:
- Never overwrites git history
- Stops on push conflicts and asks user to resolve manually
- Shows what will be committed before proceeding
- Gracefully handles repositories without remotes

Requirements:
- Must be run from within a git repository
- Git must be configured with user credentials

I'll execute the following workflow:

## Step 1: Verify Git Repository
```bash
git rev-parse --git-dir
```

## Step 2: Check Current Status
```bash
git status --porcelain
git diff --cached --name-only
git diff --name-only
```

## Step 3: Stage Changes
```bash
git add .
```

## Step 4: Analyze Changes for Commit Message
```bash
git diff --cached --name-only --diff-filter=A  # Added files
git diff --cached --name-only --diff-filter=M  # Modified files  
git diff --cached --name-only --diff-filter=D  # Deleted files
git log --oneline -3                           # Recent commit style
```

## Step 5: Generate and Apply Commit
```bash
git commit -m "<generated-message>

🤖 Generated with /gacp command

Co-Authored-By: Claude <noreply@anthropic.com>"
```

## Step 6: Push to Remote
```bash
git remote -v                                  # Check for remotes
git push                                       # Push changes
```

Let me start by checking the repository status: