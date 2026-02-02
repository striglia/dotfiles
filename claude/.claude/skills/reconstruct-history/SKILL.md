---
name: reconstruct-history
description: Transform messy git history into clean, semantic commits. Use before pushing PRs or when commit history needs cleanup.
allowed-tools: Bash(git:*)
---

# Reconstruct History

Transform messy development history (try A, fix typo, try B, WIP) into clean, semantic commits optimized for code reviewers.

## When to Use

- Before pushing a PR (automatic in `/git-workflow push`)
- Manually with `/reconstruct-history` when you want to clean up commits
- After a messy development session with many small commits

## Skip Conditions

Check these first - if any are true, skip reconstruction:

- Only 1-2 commits on branch (nothing to clean up)
- All commits already look semantic (no "fix typo", "WIP", iteration patterns)
- User has `skip-history-reconstruction: true` in CLAUDE.md

## Workflow

### 1. Check Skip Conditions

```bash
# Count commits ahead of main
git rev-list --count origin/main..HEAD

# If ≤ 2 commits, skip
# Read commit messages
git log origin/main..HEAD --pretty=format:"%s"
```

Check for messy patterns (case-insensitive): "fix", "typo", "wip", "temp", "try", "test", "debug", "cleanup", "oops"

If no messy patterns found, display: "Commits already look clean - skipping reconstruction"

### 2. Create Safety Backup

```bash
BACKUP_BRANCH="${BRANCH}-backup-$(date +%s)"
git branch "$BACKUP_BRANCH"
```

Display: "✓ Backup created: {BACKUP_BRANCH}"

### 3. Analyze the Diff

```bash
git diff --name-status origin/main...HEAD
```

Parse file paths to extract domains and types. Build a map of files to their logical groups.

### 4. Group Files into Logical Chunks

Use these heuristics (priority order):

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

### 5. Order Chunks by Dependency

1. Migrations/schema first (other code depends on them)
2. Dependencies second
3. Types before implementation
4. Implementation before tests (if separated)
5. Configuration after code
6. Documentation last

### 6. Show Preview and Get Confirmation

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

Wait for user confirmation. If user declines, skip reconstruction.

### 7. Execute Reconstruction

```bash
# Reset to merge base, keeping all changes staged
git reset --soft $(git merge-base HEAD origin/main)
git reset HEAD  # Unstage all files

# For each chunk in order:
for chunk in chunks:
    git add ${chunk.files}
    git commit -m "${chunk.message}"
```

**Commit message format**:
```
{prefix} {description}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

### 8. Verify No Code Loss

```bash
# This diff should be empty - same code, different history
git diff "${BACKUP_BRANCH}"..HEAD --stat
```

- If diff is NOT empty:
  - Display: "⚠️ Code mismatch detected! Rolling back..."
  - Run: `git reset --hard "${BACKUP_BRANCH}"`
  - Display: "Restored to backup. Original commits preserved."

- If diff IS empty:
  - Display: "✓ Verification passed - no code loss"
  - Display: "✓ Reconstructed {M} commits into {N} clean commits"

### 9. Cleanup

The backup branch remains for safety.

Display: "Backup branch '{BACKUP_BRANCH}' preserved. Delete with: git branch -D {BACKUP_BRANCH}"

## Tips

- **Always create backup first** - the backup branch is your safety net
- **Verify with `git diff`** - after reconstruction, diff against backup must be empty
- **Domain extraction** - look at the directory structure to group related files
- **Keep tests together** - by default, keep test files with their implementation
- **Preserve issue reference** - if on an issue branch, reconstructed commits should still reference the issue number
- **Roll back on any error** - if verification fails, restore from backup immediately
- **Preview before executing** - always show the proposed reconstruction and wait for confirmation

## Configuration

### Opt-Out

Add to CLAUDE.md to disable:
```markdown
skip-history-reconstruction: true
```

### Test Commit Style

Add to CLAUDE.md:
```markdown
test-commit-style: together   # Keep tests with implementation (default)
test-commit-style: separate   # Put tests in their own commit
```
