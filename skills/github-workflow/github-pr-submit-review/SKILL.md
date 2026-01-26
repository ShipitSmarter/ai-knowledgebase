---
name: github-pr-submit-review
description: Submit PR reviews directly to GitHub with line comments. Use when asked to review a PR and post feedback directly to GitHub (not local-only).
license: MIT
compatibility: Requires gh (GitHub CLI) authenticated and with repo permissions.
metadata:
  author: shipitsmarter
  version: "1.0"
---

# GitHub PR Submit Review Skill

Submit formal code reviews directly to GitHub PRs with line-specific comments and verdicts.

**This is for posting reviews TO GitHub.** For local-only review feedback, use the `reviewer` agent default workflow or `pr-review` skill instead.

---

## Prerequisites Check (MUST DO FIRST)

**Before attempting ANY GitHub PR review, verify the required tools are available.**

### Step 0: Check GitHub CLI

```bash
# Check if gh is installed
which gh

# Check if gh is authenticated
gh auth status
```

### If GitHub CLI is NOT installed or NOT authenticated

**STOP and inform the user:**

```
I cannot submit PR reviews directly to GitHub because the GitHub CLI (gh) is not installed/authenticated.

To enable this feature, please set up the GitHub CLI:

## Installation

**macOS:**
brew install gh

**Linux (Debian/Ubuntu):**
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install gh

**Windows:**
winget install GitHub.cli
# or
choco install gh

**Other:** See https://cli.github.com/manual/installation

## Authentication

After installation, authenticate with GitHub:

gh auth login

Follow the prompts to:
1. Choose GitHub.com (or GitHub Enterprise)
2. Choose HTTPS protocol
3. Authenticate via browser or paste a token

## Verify Setup

gh auth status

You should see: "Logged in to github.com as <username>"

---

Once gh is set up, I can submit PR reviews directly to GitHub for you.
```

**Do NOT proceed with the review workflow until gh is available and authenticated.**

### If GitHub CLI IS available

Continue with the workflow below.

---

## Additional Prerequisites

1. **Repository access:** You need write access to submit reviews on the target repo.

2. **PR URL:** User provides a GitHub PR URL like:
   - `https://github.com/owner/repo/pull/123`
   - Or just PR number if in the correct repo

---

## Workflow Overview

| Step | Action | Tool |
|------|--------|------|
| 1 | Parse PR URL and validate access | `gh pr view` |
| 2 | Fetch PR diff and context | `gh pr diff`, `gh api` |
| 3 | Analyze changes thoroughly | Code review process |
| 4 | Prepare review comments | Structure per format below |
| 5 | Confirm with user before submitting | Always ask |
| 6 | Submit review to GitHub | `gh api` |

---

## Step 1: Parse PR URL & Validate

Extract owner, repo, and PR number from URL:

```bash
# From URL: https://github.com/ShipitSmarter/viya-app/pull/456
# Extract: owner=ShipitSmarter, repo=viya-app, pr_number=456

# Validate we can access this PR
gh pr view 456 --repo ShipitSmarter/viya-app --json number,title,state,author,headRefName,baseRefName
```

If the repo is the current working directory:
```bash
gh pr view 456 --json number,title,state,author,headRefName,baseRefName,url
```

---

## Step 2: Fetch PR Context

```bash
# Get PR metadata
gh pr view <number> --json title,body,author,headRefName,baseRefName,commits,files,additions,deletions

# Get the full diff
gh pr diff <number>

# Get list of changed files with stats
gh pr diff <number> --name-only

# Get existing review comments (to avoid duplicates)
gh api repos/{owner}/{repo}/pulls/{number}/comments --jq '.[] | {path: .path, line: .line, body: .body}'

# Get PR review status
gh api repos/{owner}/{repo}/pulls/{number}/reviews --jq '.[] | {user: .user.login, state: .state}'
```

---

## Step 3: Analyze Changes

Apply the same thorough review process as local reviews:

1. **Understand the PR purpose** from title/description
2. **Review each file** for:
   - Correctness
   - Type safety
   - Error handling
   - Test coverage
   - Code style/conventions
3. **Note specific lines** that need feedback

**Important:** Track line numbers from the diff for commenting.

---

## Step 4: Prepare Review Comments

**MANDATORY: Every GitHub review submission MUST include line-specific comments.**

Structure your review into:

### A. Line-specific comments (REQUIRED)

You MUST include:
1. **ALL issues found** - Every blocking issue and suggestion gets a line comment at the exact location
2. **EXACTLY 2 positive comments** - Not 1, not 3, not 0. Pick the 2 best parts of the code.

For each comment, note:
- **File path** (exact path as shown in diff)
- **Line number** (in the new version of the file)
- **Comment body** (short, direct, friendly - see comment style below)

### B. Overall review comment

**Keep it CONCISE** - 3-5 sentences max summarizing:
- What was reviewed
- Key findings (brief list)
- What needs to be addressed

Do NOT repeat all the line comments in the summary - that's what line comments are for.

### C. Review verdict

One of:
- `APPROVE` - Good to merge
- `REQUEST_CHANGES` - Blocking issues must be addressed
- `COMMENT` - Feedback only, not blocking

---

## Step 5: MANDATORY Confirmation Before Submitting

**CRITICAL: You MUST ask the user for explicit Y/n confirmation before submitting ANY review to GitHub. Never skip this step.**

Show the complete review and use the question tool to ask:

```markdown
## Review Ready to Submit

**PR:** #456 - Add bulk shipment actions
**Verdict:** REQUEST_CHANGES

### Overall Comment:
[The exact summary that will be posted - keep it CONCISE, 3-5 sentences max]

### Line Comments ([total count]):

**Issues ([count]):**
1. `src/components/ShipmentList.vue:45` - please avoid `any` here if possible!
2. `src/composables/useBulkActions.ts:23` - missing `await` here
3. `src/composables/useBulkActions.ts:67` - please remove logs if not needed

**Positive ([count] - must be exactly 2):**
1. `src/utils/validation.ts:12` - nice approach here 👍
2. `src/composables/useBulkActions.ts:45` - good use of type guards!

---

**Submit this review to GitHub? (Y/n)**
```

**Wait for explicit "Y" or "yes" before proceeding. If user says "n", "no", or anything else, do NOT submit.**

---

## Step 6: Submit Review to GitHub

### Method: GitHub API via gh

The `gh pr review` command is limited. Use the API directly for line comments.

#### Submit Review with Line Comments

```bash
# Create a pending review with comments, then submit
gh api repos/{owner}/{repo}/pulls/{number}/reviews \
  --method POST \
  -f event='REQUEST_CHANGES' \
  -f body='Overall review summary here' \
  -f 'comments[][path]=src/components/ShipmentList.vue' \
  -f 'comments[][line]=45' \
  -f 'comments[][body]=Please fix this type issue' \
  -f 'comments[][path]=src/composables/useBulkActions.ts' \
  -f 'comments[][line]=23' \
  -f 'comments[][body]=Missing error handling here'
```

#### Using JSON payload (recommended for multiple comments)

```bash
# Write review payload to temp file
cat > /tmp/review-payload.json << 'EOF'
{
  "event": "REQUEST_CHANGES",
  "body": "## Review Summary\n\nOverall the PR looks good but there are a few issues to address.\n\n### Key Findings\n- Type safety issue in ShipmentList\n- Missing error handling in useBulkActions\n\nPlease address these and I'll approve!",
  "comments": [
    {
      "path": "src/components/ShipmentList.vue",
      "line": 45,
      "body": "Please avoid using `any` here - you could type this as `Shipment[]` instead."
    },
    {
      "path": "src/composables/useBulkActions.ts", 
      "line": 23,
      "body": "This async call should have error handling. What happens if the API fails?"
    },
    {
      "path": "src/composables/useBulkActions.ts",
      "line": 67,
      "side": "RIGHT",
      "body": "Nice implementation! Just a suggestion: consider extracting this to a separate function for reusability."
    }
  ]
}
EOF

# Submit via API
gh api repos/{owner}/{repo}/pulls/{number}/reviews \
  --method POST \
  --input /tmp/review-payload.json
```

#### Review without line comments (simple)

```bash
gh pr review <number> --request-changes --body "Review summary here"
# or
gh pr review <number> --approve --body "LGTM! Nice work."
# or  
gh pr review <number> --comment --body "Some thoughts, not blocking."
```

---

## Line Number Determination

**Critical:** GitHub's review API uses the line number in the **new version** of the file (right side of diff).

### From unified diff

```diff
@@ -40,6 +42,10 @@ export function useShipments() {
   const loading = ref(false)
   const error = ref<Error | null>(null)
+  
+  const fetchShipments = async () => {  // Line 45 in new file
+    // Missing error handling here       // Line 46 in new file
+  }
```

The `+42,10` means new file starts at line 42 with 10 lines. Count from there.

### Using gh to get line info

```bash
# Get diff with line numbers visible
gh pr diff <number> | head -100
```

---

## Comment Formatting

**Keep comments SHORT and DIRECT.** Use "please" for issues. Be friendly but concise.

### Issue Comments (for blocking/suggestions)

**Good - short and direct:**
```markdown
please avoid using `any` here if possible!
```

```markdown
missing `await` here - router navigation is async
```

```markdown
please remove logs if not needed anymore
```

```markdown
oops, this looks like a leftover
```

```markdown
`index` as key is not ideal, please use something unique if possible
```

```markdown
please try to avoid `as` casting - convert explicitly instead:
`const testMode = !!route.meta.testMode`
```

```markdown
can be deleted ig
```

```markdown
this looks a bit sus? 🤔
```

**Only add code examples when truly helpful, keep them minimal:**
```markdown
please add error handling here:

\`\`\`typescript
try {
  await performAction()
} catch (error) {
  // handle error
}
\`\`\`
```

### Positive Comments (EXACTLY 2 per review)

**Short and genuine - not over-the-top:**
```markdown
nice approach here 👍
```

```markdown
good use of type guards!
```

```markdown
I like this - clean and readable
```

```markdown
nice!
```

```markdown
great job on this 👍
```

**Pick comments that highlight genuinely good patterns, not just "code exists".**

---

## Review Event Types

| Event | When to use |
|-------|-------------|
| `APPROVE` | Code is good, ready to merge |
| `REQUEST_CHANGES` | Blocking issues that must be fixed |
| `COMMENT` | Feedback/questions, not blocking merge |

**Guidelines:**
- Use `REQUEST_CHANGES` for: bugs, missing tests, type safety violations, security issues
- Use `COMMENT` for: suggestions, questions, minor improvements
- Use `APPROVE` for: code that meets quality standards (can still have minor suggestions)

---

## Error Handling

### Common errors

| Error | Cause | Solution |
|-------|-------|----------|
| `Resource not accessible` | No write access | Check repo permissions |
| `Pull request not found` | Wrong repo/number | Verify PR URL |
| `Validation failed` | Invalid line number | Check line exists in diff |
| `Review cannot be requested` | PR is draft/closed | Check PR state first |

### Verify before submit

```bash
# Check PR is open
gh pr view <number> --json state --jq '.state'

# Check you have access
gh api repos/{owner}/{repo}/collaborators/{your-username}/permission --jq '.permission'
```

---

## Complete Example

User provides: `https://github.com/ShipitSmarter/viya-app/pull/456`

```bash
# 1. Fetch PR info
gh pr view 456 --repo ShipitSmarter/viya-app --json title,body,files,additions,deletions

# 2. Get diff
gh pr diff 456 --repo ShipitSmarter/viya-app

# 3. [Analyze code - identify issues]

# 4. Prepare and submit review
cat > /tmp/review.json << 'EOF'
{
  "event": "REQUEST_CHANGES",
  "body": "Thanks for this! Found a few things to address - type safety issue and missing error handling. Also needs test coverage for the new composable. Please fix and ping me for re-review!",
  "comments": [
    {
      "path": "src/components/ShipmentList.vue",
      "line": 45,
      "body": "please avoid using `any` here if possible!"
    },
    {
      "path": "src/composables/useBulkActions.ts",
      "line": 23,
      "body": "missing error handling here - what happens if the API call fails?"
    },
    {
      "path": "src/composables/useBulkActions.ts",
      "line": 89,
      "body": "please remove logs if not needed anymore"
    },
    {
      "path": "src/utils/validation.ts",
      "line": 12,
      "body": "nice approach here 👍"
    },
    {
      "path": "src/composables/useBulkActions.ts",
      "line": 67,
      "body": "good use of type guards!"
    }
  ]
}
EOF

gh api repos/ShipitSmarter/viya-app/pulls/456/reviews \
  --method POST \
  --input /tmp/review.json
```

**Note:** The example has 3 issue comments + exactly 2 positive comments = 5 total line comments.

---

## Quick Reference

```bash
# View PR
gh pr view <number> --json title,body,state,files

# Get diff  
gh pr diff <number>

# Simple review (no line comments)
gh pr review <number> --approve --body "LGTM!"
gh pr review <number> --request-changes --body "Please fix..."
gh pr review <number> --comment --body "Some thoughts..."

# Review with line comments (use API)
gh api repos/{owner}/{repo}/pulls/{number}/reviews \
  --method POST \
  --input review.json
```

---

## Related Skills

| Skill | When to Use |
|-------|-------------|
| `pr-review` | Local PR review workflow with checklist |
| `code-review` | Quick code convention checking |
| `github-workflow` | PR creation and Git conventions |

---

## Safety Notes

1. **ALWAYS ask Y/n confirmation before submitting** - Never submit without explicit user approval
2. **ALWAYS include line comments** - All issues + exactly 2 positive comments
3. **Keep comments SHORT** - Direct and friendly, not verbose essays
4. **Be constructive** - This is public feedback visible to the whole team
5. **Check PR state** - Don't review closed or merged PRs
6. **Avoid duplicate comments** - Check existing review comments first
