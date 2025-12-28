---
name: plan-to-issues
description: Converts implementation plans (plan.md files) into structured GitHub issues using gh CLI. Use when you have a plan file and want to create tracking issues, or when converting project plans into issue trackers.
allowed-tools: Read, Bash(gh:*)
---

# Plan to Issues

Converts implementation plan files into structured GitHub issues with proper task breakdowns, dependencies, and acceptance criteria.

## Quick Usage

```bash
# Convert current plan to issues
/plan-to-issues

# Convert specific plan file
/plan-to-issues path/to/plan.md

# Preview without creating
/plan-to-issues --dry-run

# Start numbering from specific number
/plan-to-issues --start-number 12

# Add labels to all issues
/plan-to-issues --label enhancement --label spike
```

## What This Skill Does

1. **Finds the plan file**: Searches common locations if path not provided:
   - `.claude/plans/*.md`
   - `plan.md`, `PLAN.md`, `implementation-plan.md`
   - Current directory `*.md` files

2. **Analyzes plan structure**: Identifies implementation steps, file dependencies, and logical groupings

3. **Creates GitHub issues**: Uses `gh issue create` with:
   - Clear titles with issue numbers (e.g., "#012: Extend Data Models")
   - Detailed descriptions and objectives
   - Task checklists using `- [ ]` format
   - Acceptance criteria
   - Files to modify/create
   - Dependencies on other issues

## Instructions

When this skill is invoked:

1. **Locate the plan file**:
   - If path provided, use that
   - Otherwise search `.claude/plans/`, then project root for `*.md` files
   - Ask user to confirm if multiple plans found

2. **Parse the plan**:
   - Identify main sections (e.g., "Step 1", "Phase 1", numbered items)
   - Extract files to modify/create
   - Note dependencies between steps
   - Find acceptance criteria or success criteria

3. **Design issue breakdown**:
   - Group related tasks into logical issues
   - Each issue should represent a cohesive unit of work
   - Aim for 5-10 issues for typical plans (adjust based on size)
   - Maintain sequential order for dependent work
   - Group by architectural layer (data, UI, integration) when possible

4. **Determine issue numbering**:
   - Check existing issues: `gh issue list --state all --json number --jq 'max_by(.number).number'`
   - Start from next number, or use `--start-number` if provided

5. **Create issues** using this format:

```bash
gh issue create \
  --title "#012: Clear Descriptive Title" \
  --body "$(cat <<'ISSUE_EOF'
## Objective
Brief description of what this issue accomplishes

## Tasks
- [ ] Specific actionable task 1
- [ ] Specific actionable task 2
- [ ] Specific actionable task 3

## Acceptance Criteria
- Clear criterion 1
- Clear criterion 2

## Files to Modify
- path/to/file1.js
- path/to/file2.css

## New Files
- path/to/new-file.js

## Dependencies
- Issue #011 (must be completed first)
ISSUE_EOF
)"
```

6. **Handle options**:
   - `--dry-run`: Show what would be created without actually creating issues
   - `--start-number N`: Start issue numbering from N
   - `--label LABEL`: Add `--label LABEL` to each gh command (can be repeated)

7. **Provide summary**:
   - List all created issues with URLs
   - Show recommended implementation order if dependencies exist
   - Note any decisions made about grouping

## Plan Format Guidelines

This skill works best with plans that have:

**Clear sections**:
```markdown
## 1. Extend Data Models
Description of what this step does

## 2. Create UI Components
Description of what this step does
```

**File lists**:
```markdown
Files to modify:
- src/model.js
- src/schema.js

New files:
- src/components/MyComponent.js
```

**Dependencies**:
```markdown
Dependencies: Step 1 must be completed first
```

**Acceptance criteria**:
```markdown
Acceptance Criteria:
- Schema validates correctly
- All tests pass
- Mobile responsive
```

## Grouping Strategy

Group tasks into issues based on:
1. **Architectural layers**: Data models together, UI components together, integration separately
2. **File proximity**: Related files that change together
3. **Natural dependencies**: Don't split dependent steps across issues
4. **Work size**: Each issue should be completable in 1-4 hours

## Examples

### Example 1: Simple Plan

```markdown
# Implementation Plan

## Step 1: Add validation
- Update validation.js
- Add tests

## Step 2: Create UI
- Create form.js
- Add styling
```

Creates 2 issues:
- #001: Add Validation
- #002: Create UI

### Example 2: Complex Plan with Dependencies

```markdown
# Feature Implementation

## Data Layer
1. Extend schema
2. Add validation
3. Update loader

## UI Layer
1. Create components
2. Add styles

## Integration
1. Wire up main app
2. Add tests

Dependencies: UI depends on Data Layer
```

Creates 3 issues:
- #001: Data Layer Extensions (schema, validation, loader)
- #002: UI Components and Styling
- #003: Integration and Testing (depends on #001, #002)

## Tips

- **Be specific in titles**: Instead of "Update code", use "Extend DataLoader for new data sources"
- **Include file paths**: Helps developers know exactly what to modify
- **Note dependencies**: Guides implementation order
- **Add acceptance criteria**: Makes completion clear
- **Use task checklists**: Breaks work into reviewable chunks

## Verification

After creating issues:
```bash
# View created issues
gh issue list

# View specific issue
gh issue view 12
```
