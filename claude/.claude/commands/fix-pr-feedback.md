---
description: "Address PR review feedback by making wise decisions, implementing selected fixes, and documenting rationale in PR comments"
allowed-tools: ["Bash", "Read", "Write", "Edit", "Grep", "Glob"]
---

# Fix PR Feedback

Fetches PR review comments and feedback since the last commit, makes wise decisions about what to implement, systematically addresses selected feedback with focused commits, and documents all decisions in a PR comment.

Usage: `/fix-pr-feedback [pr-url]`

Examples:
- `/fix-pr-feedback` - Auto-detect PR from current branch
- `/fix-pr-feedback https://github.com/striglia/house-pal/pull/42` - Use specific PR URL

This command will:
1. Extract PR number from the URL
2. Verify you're on the correct branch for the PR
3. Check for failing CI/test runs and investigate failures
4. Fetch all PR review comments and feedback
5. Filter for feedback newer than the last commit
6. Check GitHub issues to see what's already planned
7. Analyze and make wise decisions about what to implement
8. Implement selected fixes systematically
9. Create focused commits for each category of fixes
10. Push the updates
11. Comment on the PR explaining what was done and why

Prerequisites:
- Must have checked out the PR branch locally
- GitHub CLI (`gh`) must be installed and authenticated
- Must be run from within the git repository

Safety features:
- Verifies correct branch before proceeding
- Only shows feedback since last commit (avoids duplicate work)
- Checks GitHub issues to avoid duplicate work
- Makes wise decisions about what to implement vs defer
- Groups related fixes into logical commits
- Documents all decisions with PR comment explaining rationale

I'll execute the following workflow:

## Step 1: Parse PR URL and Extract Number

```bash
bash << 'SCRIPT'
pr_url="$ARGUMENTS"

# If no URL provided, auto-detect from current branch
if [ -z "$pr_url" ]; then
  echo "No PR URL provided, auto-detecting from current branch..."
  pr_number=$(gh pr view --json number -q .number 2>/dev/null)

  if [ -z "$pr_number" ]; then
    echo "Error: Could not auto-detect PR from current branch"
    echo "Usage: /fix-pr-feedback [pr-url]"
    echo "Either provide a PR URL or checkout a branch with an associated PR"
    exit 1
  fi

  pr_url=$(gh pr view --json url -q .url)
  echo "✓ Auto-detected PR #$pr_number from current branch"
else
  # Extract PR number from provided URL
  pr_number=$(echo "$pr_url" | grep -oE 'pull/[0-9]+' | grep -oE '[0-9]+')

  if [ -z "$pr_number" ]; then
    echo "Error: Could not extract PR number from URL: $pr_url"
    echo "Expected format: https://github.com/user/repo/pull/123"
    exit 1
  fi
fi

echo "Processing PR #$pr_number: $pr_url"
SCRIPT
```

## Step 2: Verify Correct Branch

```bash
bash << 'SCRIPT'
current_branch=$(git branch --show-current)
pr_branch=$(gh pr view "$pr_number" --json headRefName -q .headRefName)

if [ "$current_branch" != "$pr_branch" ]; then
  echo "Error: Current branch ($current_branch) doesn't match PR branch ($pr_branch)"
  echo "Please checkout: git checkout $pr_branch"
  exit 1
fi

echo "✓ On correct branch: $current_branch"
SCRIPT
```

## Step 3: Check for Failing CI/Test Runs

```bash
bash << 'SCRIPT'
echo "Checking PR status checks..."
gh pr checks "$pr_number" || true

# Get failed check details
failed_checks=$(gh pr view "$pr_number" --json statusCheckRollup --jq '
  [.statusCheckRollup[] | select(.conclusion == "FAILURE")] | length
')

if [ "$failed_checks" -gt 0 ]; then
  echo "⚠️ Found $failed_checks failing status check(s)"
  echo "Fetching failed run logs..."

  # Get the latest failed run ID
  failed_run_id=$(gh pr view "$pr_number" --json statusCheckRollup --jq '
    [.statusCheckRollup[] | select(.conclusion == "FAILURE")] | .[0].detailsUrl
  ' | grep -oE 'runs/[0-9]+' | head -1 | cut -d'/' -f2)

  if [ -n "$failed_run_id" ]; then
    echo "Viewing logs for run ID: $failed_run_id"
    gh run view "$failed_run_id" --log-failed > /tmp/pr-$pr_number-failed-tests.log
    echo "Failed test logs saved to /tmp/pr-$pr_number-failed-tests.log"
  fi
else
  echo "✓ All status checks passing"
fi
SCRIPT
```

**Action:** If tests are failing, I will:
1. Review the failed test logs
2. Identify the root cause of failures
3. Fix the issues (e.g., missing dependencies, configuration errors, test bugs)
4. Verify fixes locally with `npm test` if applicable
5. Commit and push the fix before proceeding with review feedback

## Step 4: Fetch All PR Feedback

```bash
gh pr view "$pr_number" \
  --json comments,reviews \
  --jq '{
    reviews: [.reviews[] | {
      author: .author.login,
      state: .state,
      body: .body,
      submitted_at: .submittedAt,
      comments: [.comments[]? | {
        body: .body,
        path: .path,
        line: .position,
        created_at: .createdAt,
        diff_hunk: .diffHunk
      }]
    }],
    comments: [.comments[] | {
      author: .author.login,
      body: .body,
      created_at: .createdAt
    }]
  }' > /tmp/pr-feedback-$pr_number.json
```

## Step 5: Filter for Feedback Since Last Commit

```bash
bash << 'SCRIPT'
last_commit_time=$(git log -1 --format=%aI)
echo "Last commit: $last_commit_time"
echo "Filtering for feedback after this time..."

jq --arg last_commit "$last_commit_time" '
  {
    new_reviews: [.reviews[] | select(.submitted_at > $last_commit)],
    new_comments: [.comments[] | select(.created_at > $last_commit)]
  }
' /tmp/pr-feedback-$pr_number.json > /tmp/new-feedback-$pr_number.json

new_count=$(jq '[.new_reviews[], .new_comments[]] | length' /tmp/new-feedback-$pr_number.json)

if [ "$new_count" -eq 0 ]; then
  echo "No new feedback since last commit"
  exit 0
fi

echo "Found $new_count new feedback items"
SCRIPT
```

## Step 6: Filter Out Non-Actionable Comments

```bash
bash << 'SCRIPT'
# Filter out status updates and bot connector messages
jq '
  {
    new_reviews: [.new_reviews[] |
      select(.body | test("^## 🤖 Fix PR Feedback") | not) |
      select(.body | test("^## 🤖 Critical Bug Fix") | not)
    ],
    new_comments: [.new_comments[] |
      select(.author != "chatgpt-codex-connector") |
      select(.body | test("^@codex review") | not) |
      select(.body | test("^## 🤖 Fix PR Feedback") | not) |
      select(.body | test("^## 🤖 Critical Bug Fix") | not)
    ]
  }
' /tmp/new-feedback-$pr_number.json > /tmp/actionable-feedback-$pr_number.json

actionable_count=$(jq '[.new_reviews[], .new_comments[]] | length' /tmp/actionable-feedback-$pr_number.json)
echo "Filtered to $actionable_count actionable items"
SCRIPT
```

## Step 7: Display Actionable Feedback

```bash
jq -r '
  if ([.new_reviews[], .new_comments[]] | length) == 0 then
    "No actionable feedback found since last commit."
  else
    "=== ACTIONABLE FEEDBACK ===\n\n" +
    (if (.new_reviews | length) > 0 then
      "REVIEWS (" + (.new_reviews | length | tostring) + "):\n\n" +
      (.new_reviews[] |
        "From: " + .author + " (" + .state + ")\n" +
        .body + "\n" +
        (if (.comments | length) > 0 then
          "\nInline comments:\n" +
          (.comments[] |
            "  " + (.path // "unknown") + ":" + ((.line // 0) | tostring) + "\n" +
            "  " + .body + "\n"
          )
        else "" end) +
        "\n---\n\n"
      )
    else "" end) +
    (if (.new_comments | length) > 0 then
      "COMMENTS (" + (.new_comments | length | tostring) + "):\n\n" +
      (.new_comments[] |
        "From: " + .author + "\n" +
        .body + "\n\n---\n\n"
      )
    else "" end)
  end
' /tmp/actionable-feedback-$pr_number.json
```

## Step 8: Check GitHub Issues for Planned Work

```bash
gh issue list --limit 50 --json number,title,state,labels --jq '.[] | "#\(.number): \(.title) [\(.state)]"'
```

This helps avoid implementing feedback that's already tracked in issues for future work.

## Step 9: Analyze Feedback and Make Wise Decisions

I will now:
1. Read and understand all feedback items
2. Categorize them:
   - Critical bugs or security issues
   - Low-effort improvements with clear benefits
   - Items already tracked in GitHub issues (skip)
   - Items already addressed in previous commits (skip)
   - Nice-to-haves that can be deferred
3. Make wise decisions about what to implement NOW:
   - Honor any explicit commitments made by the user
   - Fix critical issues and low-effort improvements
   - Respect the project's backlog and phase goals
   - Skip items already tracked in issues
4. Identify dependencies between selected fixes
5. Plan the order of implementation

## Step 10: Implement Selected Fixes

For each selected feedback item:
1. Locate the relevant files using Grep/Read
2. Implement the necessary changes using Edit/Write
3. **Test Gap Analysis** - Ask: "Should tests have caught this bug/issue?"
   - If YES: Add/update tests to prevent regression
   - Consider: unit tests, integration tests, or smoke tests
   - Examples:
     - Import errors → smoke test that imports the module
     - Logic bugs → unit test for the specific case
     - Integration issues → integration/E2E test
4. Verify changes don't break existing functionality
5. Run tests locally to confirm fixes work
6. Group related fixes together

## Step 11: Create Focused Commits

```bash
# For each logical group of fixes:
git add <relevant-files>

git commit -m "Address PR #$pr_number feedback: <summary>

<detailed list of fixes>

Addresses feedback from: <reviewer-names>

🤖 Generated with /fix-pr-feedback

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

## Step 12: Push Updates

```bash
git push
echo "✓ Pushed updates to PR #$pr_number"
echo "✓ View PR: $pr_url"
```

## Step 13: Comment on PR with Decision Summary

CRITICAL: Always post a comment explaining what was done and why.

```bash
gh pr comment "$pr_number" --body "$(cat <<'EOF'
## 🤖 Fix PR Feedback - Completed

Processed [N] feedback comments since last commit and made the following decisions:

### ✅ Implemented

[List each fix with:
- What was done
- Why it was important
- Commit reference if applicable]

### ⏭️ Skipped (with rationale)

[List each skipped item with:
- What the feedback was
- Why it was skipped (already tracked in issue #X, deferred to future phase, already addressed, etc.)
]

### Summary

[Brief summary of overall approach and decision-making rationale]

🤖 Generated with /fix-pr-feedback
EOF
)"
```

This ensures reviewers understand the thought process and can verify decisions were made wisely.

Let me start by parsing the PR URL from arguments:

$ARGUMENTS
