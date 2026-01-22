---
name: pr-review
description: Senior engineer code review patterns for Vue/TypeScript projects. Use when reviewing PRs, verifying checklists, or writing release notes.
license: MIT
compatibility: Requires git CLI and gh (GitHub CLI) for PR operations.
metadata:
  author: shipitsmarter
  version: "1.0"
---

# PR Review Skill

Comprehensive pull request review that verifies all checklist items, checks code quality against project conventions, and writes customer-focused release notes.

---

## Trigger

When user asks to:
- Review a PR
- Check PR checklist
- Validate code before merge
- Write release notes for a PR

---

## Prerequisites

- Must be in the `viya-app` repository
- Must have an open PR (auto-detected from current branch, or specify PR number)
- Must have `gh` CLI authenticated
- **Branch must be up-to-date with main** (merged or rebased)

---

## Process Overview

```
┌─────────────────────────────────────────────────────────────┐
│  0. Verify Branch is Mergeable                              │
│     └── Auto-update if behind main (rebase preferred)       │
├─────────────────────────────────────────────────────────────┤
│  1. Detect PR & Gather Context                              │
│     └── Check for associated plan in agents/plan/           │
├─────────────────────────────────────────────────────────────┤
│  2. Run Automated Checks                                    │
│     ├── ESLint & Prettier                                   │
│     ├── TypeScript type-check                               │
│     └── Build verification                                  │
├─────────────────────────────────────────────────────────────┤
│  3. Review Code Changes                                     │
│     ├── Component structure (script order)                  │
│     ├── General conventions                                 │
│     ├── Sanity check (console.logs, TODOs, etc.)           │
│     └── Full commit history review                          │
├─────────────────────────────────────────────────────────────┤
│  4. Evaluate Test Coverage                                  │
│     └── Intelligent test strategy decision                  │
├─────────────────────────────────────────────────────────────┤
│  5. Verify Plan Completion & Release Strategy               │
│     ├── All tasks completed                                 │
│     ├── Open questions resolved                             │
│     └── Release strategy defined                            │
├─────────────────────────────────────────────────────────────┤
│  6. Generate Review Report & Release Notes                  │
│     └── ALWAYS include release notes in report              │
├─────────────────────────────────────────────────────────────┤
│  7. Update PR on GitHub (with confirmation)                 │
│     ├── Check off verified checklist items                  │
│     ├── Add release notes to PR description                 │
│     └── Use GitHub API directly (not gh pr edit)            │
└─────────────────────────────────────────────────────────────┘
```

**Important:** Release notes are ALWAYS generated as part of the review, even for internal/chore PRs. The review is not complete until release notes are written and added to the PR description.

---

## Step 0: Verify Branch is Mergeable

Before starting the review, ensure the branch is up-to-date with main. **Automatically update the branch if needed.**

### Check merge status

```bash
# Fetch latest main
git fetch origin main

# Check if branch is behind main
git rev-list --left-right --count origin/main...HEAD
# Output: "X Y" where X = commits behind, Y = commits ahead
# If X > 0, branch needs to be updated

# Alternative: Check PR mergeable status via GitHub
gh pr view --json mergeable,mergeStateStatus
```

### Expected states

| State | Action |
|-------|--------|
| `MERGEABLE` + `CLEAN` | Proceed with review |
| `MERGEABLE` + `BEHIND` | **Auto-update branch** (see below) |
| `MERGEABLE` + `UNSTABLE` | CI is failing - note in review |
| `CONFLICTING` | Stop - conflicts must be resolved manually |
| `UNKNOWN` | GitHub is calculating - wait and retry |

### If branch is behind main - Auto-update

**Automatically rebase the branch** (preferred for clean history):

```bash
# Ensure working directory is clean
git status --porcelain

# If clean, proceed with rebase
git fetch origin main
git rebase origin/main

# If rebase succeeds, push
git push --force-with-lease
```

**Strategy selection:**

1. **Rebase (default)** - Use when:
   - Working directory is clean
   - No merge conflicts expected
   - Produces cleaner commit history

2. **Merge (fallback)** - Use when:
   - Rebase fails due to conflicts
   - Branch has been shared/collaborated on

**Auto-update flow:**

```
┌─────────────────────────────────────┐
│ Branch is behind main               │
└─────────────────┬───────────────────┘
                  ▼
┌─────────────────────────────────────┐
│ Check working directory is clean    │
│ git status --porcelain              │
└─────────────────┬───────────────────┘
                  ▼
        ┌─────────┴─────────┐
        │ Clean?            │
        └─────────┬─────────┘
           Yes    │    No
            ▼     │     ▼
┌───────────────┐ │ ┌───────────────────┐
│ Try rebase    │ │ │ Stop & ask user   │
│ git rebase    │ │ │ to stash/commit   │
│ origin/main   │ │ └───────────────────┘
└───────┬───────┘ │
        ▼         │
   ┌────┴────┐    │
   │Success? │    │
   └────┬────┘    │
   Yes  │   No    │
    ▼   │    ▼    │
┌──────┐│┌────────────────┐
│ Push ││ Abort rebase    │
│ with ││ git rebase      │
│ lease││ --abort         │
└──────┘│└───────┬────────┘
        │        ▼
        │ ┌────────────────┐
        │ │ Try merge      │
        │ │ git merge      │
        │ │ origin/main    │
        │ └───────┬────────┘
        │         ▼
        │    ┌────┴────┐
        │    │Success? │
        │    └────┬────┘
        │    Yes  │   No
        │     ▼   │    ▼
        │ ┌──────┐│┌────────────────┐
        │ │ Push ││ Stop - manual  │
        │ └──────┘││ conflict       │
        │         ││ resolution     │
        │         │└────────────────┘
        └─────────┘
```

**Commands to execute:**

```bash
# 1. Check for uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
  echo "ERROR: Working directory not clean. Please commit or stash changes first."
  exit 1
fi

# 2. Fetch latest main
git fetch origin main

# 3. Try rebase first
if git rebase origin/main; then
  echo "Rebase successful"
  git push --force-with-lease
else
  echo "Rebase failed, trying merge..."
  git rebase --abort
  
  # 4. Try merge as fallback
  if git merge origin/main -m "Merge main into $(git branch --show-current)"; then
    echo "Merge successful"
    git push
  else
    echo "ERROR: Merge conflicts detected. Manual resolution required."
    git merge --abort
    exit 1
  fi
fi
```

**Report to user:**

After auto-update, report what was done:

```markdown
**Branch updated**

✅ Rebased `chore/agents-setup` onto `origin/main` (2 commits)
✅ Pushed with `--force-with-lease`

Continuing with review...
```

### If there are merge conflicts

Stop the review and provide clear instructions:

```markdown
**Merge conflicts detected**

Auto-update failed due to conflicts. Please resolve manually:

**Conflicting files:**
- `src/components/Example.vue`
- `src/utils/helpers.ts`

**Steps to resolve:**
```bash
git fetch origin main
git rebase origin/main
# Resolve conflicts in your editor
git add .
git rebase --continue
git push --force-with-lease
```

Let me know when conflicts are resolved, and I'll continue the review.
```

---

## Step 1: Detect PR & Gather Context

### Auto-detect PR from current branch

```bash
# Get current branch
git branch --show-current

# Get PR number for current branch
gh pr view --json number,title,body,url,headRefName,baseRefName

# Get all commits in the PR
git log origin/main..HEAD --oneline

# Get all changed files
gh pr diff --name-only
```

If no PR exists for current branch, prompt user to provide a PR number or create one.

### Get full diff for review

```bash
# Get the complete diff for the PR
gh pr diff

# Get changed files with stats
gh pr diff --stat
```

---

## Step 2: Run Automated Checks

### 2.1 ESLint Check

```bash
npm run lint
```

**Pass criteria:** No errors (warnings are acceptable but should be noted)

**Common issues:**
- Import sorting violations
- Unused imports
- Relative import paths (should use `@/`)
- Missing component registration

### 2.2 Prettier Check

```bash
npm run format:check
```

**Pass criteria:** All files formatted correctly

**Fix command:** `npm run format`

### 2.3 TypeScript Type Check

```bash
npm run type-check
```

**Pass criteria:** No type errors

### 2.4 Build Verification

```bash
npm run build-only:prod
```

**Pass criteria:** Build completes without errors

### Collecting Build Failures

If any automated check fails, collect the error output for the summary:

```markdown
### Build Failures

**ESLint errors (3):**
- `src/components/shipment/ShipmentList.vue:45` - 'ref' is defined but never used
- `src/components/shipment/ShipmentList.vue:67` - Import should use '@/' prefix
- `src/views/ShipmentPage.vue:12` - Import order violation

**TypeScript errors (1):**
- `src/composables/useShipment.ts:23` - Type 'string' is not assignable to type 'number'
```

---

## Step 3: Review Code Changes

### 3.1 Component Structure Check

For each changed `.vue` file, verify the script follows the **mandatory order**:

1. Types & interfaces
2. Composables
3. Constants
4. Services
5. Props & emits
6. Models
7. Refs & reactives
8. Computed
9. Functions
10. Watchers
11. Lifecycle hooks (always last)

**How to check:**

Read each `.vue` file and verify the script section order. Look for violations like:
- Lifecycle hooks appearing before functions
- Refs defined before composables
- Watchers before functions

**Report format:**

```markdown
**Component Structure Issues:**

| File | Issue | Line |
|------|-------|------|
| `ShipmentList.vue` | Watchers before functions | 89 |
| `ShipmentCard.vue` | Lifecycle hook before computed | 45 |
```

### 3.2 General Conventions Check

Review all changed files for:

| Convention | Check | Example Violation |
|------------|-------|-------------------|
| Arrow functions | No `function` declarations (except where needed) | `function handleClick()` → `const handleClick = ()` |
| Absolute imports | All imports use `@/` prefix | `import from '../../'` → `import from '@/'` |
| File naming | `.ts` files kebab-case, `.vue` PascalCase | `myComponent.vue` → `MyComponent.vue` |
| No `any` types | Use `unknown` with type guards | `data: any` → `data: unknown` |
| Template rules | No `props.` prefix, no `()` on handlers | `@click="fn()"` → `@click="fn"` |
| v-for keys | Never use array index as key | `:key="index"` → `:key="item.id"` |
| Attribute order | Bindings before directives | `v-if` before `:prop` is wrong |

### 3.3 Sanity Check

Search for items that should not be in production code:

```bash
# Console statements
rg "console\.(log|warn|error|debug)" --type vue --type ts

# Debug statements
rg "debugger" --type vue --type ts

# TODO/FIXME comments
rg "(TODO|FIXME|HACK|XXX):" --type vue --type ts

# Commented-out code (heuristic: multiple consecutive comment lines)
# Manual review needed
```

**Exceptions:**
- `console.error` in error handlers may be intentional
- TODOs with ticket references (e.g., `// TODO(VIYA-123): ...`) are acceptable

### 3.4 Full Commit History Review

Review all commits in the PR:

```bash
git log origin/main..HEAD --format="%h %s"
```

**Verify:**
- All commits follow conventional commit format (`feat:`, `fix:`, `chore:`, etc.)
- No WIP or fixup commits that should be squashed
- Commit messages are meaningful

**Check with user:**
- "Are all these changes intentional?"
- "Should any commits be squashed before merge?"

---

## Step 4: Evaluate Test Coverage

### Intelligent Test Strategy

> **Full details:** See [Testing Strategy](../../../docs/testing-strategy.md) for comprehensive guidance on when to write E2E vs unit tests, critical flows to cover, and coverage expectations.

Based on the type of changes, determine appropriate test coverage:

| Change Type | Recommended Tests | Rationale |
|-------------|-------------------|-----------|
| New composable (`use*.ts`) | Unit tests | Pure logic, easily testable in isolation |
| New utility function | Unit tests | Stateless, deterministic |
| New Vue component | Unit tests + consider E2E | Component behavior + integration |
| New page/view | E2E (Playwright) | User journey, integration with routing |
| API integration changes | Unit tests with mocks | Verify request/response handling |
| Form with validation | Unit + E2E | Logic in unit, UX in E2E |
| Bug fix | Test that reproduces the bug | Prevent regression |
| Refactoring | Existing tests should pass | No new tests needed if behavior unchanged |

### Test Coverage Check

```bash
# Find changed source files
gh pr diff --name-only | grep -E '\.(vue|ts)$' | grep -v '\.spec\.|\.test\.|__tests__'

# For each source file, check for corresponding test
# src/composables/useShipment.ts → src/composables/__tests__/useShipment.spec.ts
# src/components/Foo/Bar.vue → src/components/Foo/__tests__/Bar.spec.ts
```

### Report Missing Tests

```markdown
### Test Coverage Analysis

**Changes requiring tests:**

| File | Type | Test Status | Recommendation |
|------|------|-------------|----------------|
| `src/composables/useShipmentBulk.ts` | Composable | ❌ Missing | Add unit tests |
| `src/views/BulkActionsPage.vue` | Page | ❌ Missing | Add E2E test |
| `src/components/BulkActionButton.vue` | Component | ✅ Has tests | - |

**Suggested test files to create:**
- `src/composables/__tests__/useShipmentBulk.spec.ts`
- `playwright/tests/bulk-actions.spec.ts`
```

---

## Step 5: Verify Plan Completion & Release Strategy

For feature PRs, check the associated plan in `agents/plan/`.

### 5.1 Find Associated Plan

```bash
# List all plans
ls agents/plan/*.md

# Search for plan by feature name (from branch or PR title)
grep -l "<feature-keyword>" agents/plan/*.md
```

If no plan exists for a significant feature, flag as a warning.

### 5.2 Plan Completion Checklist

Review the plan file and verify:

| Check | What to Look For |
|-------|------------------|
| **Status** | Should be "Review" or "Complete" |
| **Tasks** | All tasks should be checked `[x]` |
| **Open Questions** | All questions should be resolved `[x]` |
| **Release Strategy** | Must be defined (see below) |

### 5.3 Release Strategy Verification

Every feature PR must have a release strategy. See the **planning** skill for full release strategy documentation.

**Quick reference - check the plan for:**

```markdown
## Release Strategy

### Release Type
- [ ] Silent - No notification needed
- [ ] Standard - Release notes + docs
- [ ] Gradual - Feature flag + CS notification
- [ ] Breaking - Advance notice required
```

**Required elements by release type:**

| Release Type | Feature Flag | CS Notification | Documentation |
|--------------|--------------|-----------------|---------------|
| Silent | No | No | Release notes only |
| Standard | Optional | No | Release notes + in-app docs |
| Gradual | **Required** | **Required** | Full communication |
| Breaking | **Required** | **Required** + advance notice | Migration guide |

### 5.4 CS Notification Check

For Gradual or Breaking releases, verify the plan includes:

- [ ] **What changed** - User-facing description
- [ ] **Who is affected** - Customer segments, workflows
- [ ] **When** - Release date and rollout timeline
- [ ] **Talking points** - Key benefits for CS to communicate
- [ ] **Known limitations** - Edge cases CS should know

**If CS notification is required but missing:**

```markdown
**Missing CS Notification**

This PR includes a gradual/breaking release but the plan is missing CS notification details.

Please update `agents/plan/<feature>.md` with:
- What changed (user perspective)
- Who is affected
- Rollout timeline
- Talking points for CS
- Known limitations
```

### 5.5 Feature Flag Check

For Gradual releases, verify:

- [ ] Feature flag name defined (`feature-<name>`)
- [ ] Rollout plan documented (phases, timeline)
- [ ] Rollback plan documented

```bash
# Check if feature flag is used in code
rg "isFeatureEnabled.*feature-<name>" src/
```

### 5.6 Documentation Check

Verify documentation has been created or updated for user-facing changes.

**Documentation locations:**

| Type | Location | When Required |
|------|----------|---------------|
| In-app docs | `src/docs/pages/` | New features, workflow changes |
| Release notes | PR description | All user-facing changes |
| API docs | Generated from OpenAPI | API changes |
| External docs | Notion/Help center | Major features |

**Check for documentation updates:**

```bash
# Check if docs were added/modified in this PR
gh pr diff --name-only | grep -E "^src/docs/"

# Check docs registry for new pages
git diff origin/main..HEAD -- src/docs/registry.ts
```

**Documentation requirements by release type:**

| Release Type | In-App Docs | Release Notes | External Docs |
|--------------|-------------|---------------|---------------|
| Silent | No | Yes | No |
| Standard | **Yes** | Yes | Optional |
| Gradual | **Yes** | Yes | **Yes** |
| Breaking | **Yes** | Yes + migration | **Yes** |

**If documentation is missing:**

```markdown
**Missing Documentation**

This PR includes user-facing changes but documentation is missing.

**Required:**
- [ ] In-app docs in `src/docs/pages/<feature>/`
- [ ] Register in `src/docs/registry.ts`
- [ ] Update `src/docs/hierarchy.ts` for navigation

Use the `docs-writing` skill for guidance on creating documentation.
```

**Documentation quality checklist:**

- [ ] Written for end users (not developers)
- [ ] Explains the "why" not just the "how"
- [ ] Includes screenshots for UI features
- [ ] Follows voice & tone guidelines (friendly, confident)
- [ ] Registered in docs system for discoverability

### 5.7 Report Plan Status

Include in the review report:

```markdown
### Plan Status

**Plan file:** `agents/plan/bulk-shipment-actions.md`

| Check | Status |
|-------|--------|
| All tasks complete | ✅ 7/7 tasks done |
| Open questions resolved | ⚠️ 1/2 resolved |
| Release type defined | ✅ Gradual |
| Feature flag configured | ✅ `feature-bulk-actions` |
| CS notification prepared | ❌ Missing |
| Documentation updated | ✅ In-app docs added |

**Action required:** Add CS notification section to plan before merge.
```

### When No Plan Exists

For PRs without a plan:

| PR Type | Plan Required? |
|---------|----------------|
| Bug fix | No |
| Chore/refactor | No |
| Small enhancement | No (but recommended) |
| New feature | **Yes** |
| Breaking change | **Yes** |

If a plan should exist but doesn't:

```markdown
**Missing Plan**

This PR introduces a new feature but has no associated plan in `agents/plan/`.

Consider creating `agents/plan/<feature-name>.md` with:
- Overview and goals
- Release strategy
- CS notification (if gradual release)

You can proceed without a plan for small changes, but larger features benefit from documented planning.
```

---

## Step 6: Generate Review Report

Compile all findings into a structured report:

```markdown
## PR Review: #<number> - <title>

**Branch:** `<branch-name>` → `main`
**Commits:** <count> commits
**Files changed:** <count> files

---

### Checklist Status

| Item | Status | Notes |
|------|--------|-------|
| ESLint & Prettier | ✅ Pass | No errors |
| Component structure | ⚠️ Warning | 1 file needs attention |
| Unit tests | ❌ Missing | 2 files need tests |
| General conventions | ✅ Pass | All conventions followed |
| Sanity check | ⚠️ Warning | 2 console.log found |
| Commit history | ✅ Pass | All commits valid |
| Plan complete | ✅ Pass | All tasks done |
| Release strategy | ⚠️ Warning | CS notification missing |

---

### Issues Found

#### Critical (must fix before merge)

1. **Missing unit tests**
   - `src/composables/useShipmentBulk.ts` - New composable has no tests
   - Recommendation: Create `src/composables/__tests__/useShipmentBulk.spec.ts`

#### Warnings (recommended to fix)

1. **Console.log statements** in `src/views/ShipmentPage.vue`
   - Line 123: `console.log('debug', data)`
   - Line 156: `console.log('response', response)`

2. **Component script order** in `src/components/shipment/ShipmentList.vue`
   - Watchers (line 89) appear before functions (line 95)

---

### Plan Status

**Plan file:** `agents/plan/bulk-shipment-actions.md`

| Check | Status |
|-------|--------|
| All tasks complete | ✅ 7/7 |
| Open questions resolved | ✅ 2/2 |
| Release type | Gradual |
| Feature flag | ✅ `feature-bulk-actions` |
| CS notification | ❌ Missing |
| Documentation | ✅ In-app docs |

---

### Commit History

| Hash | Message | Valid |
|------|---------|-------|
| `abc1234` | feat(shipment): add bulk actions | ✅ |
| `def5678` | fix(shipment): correct button alignment | ✅ |
| `ghi9012` | chore: cleanup imports | ✅ |

---

### Proposed Release Notes

#### 🚀 New
- **Bulk actions for shipments** - You can now select multiple shipments and perform actions on them all at once, saving time on repetitive tasks.

#### ⚙️ Improved
- Enhanced shipment list performance with optimized data loading.

#### 🐞 Fixed
- Fixed button alignment issue in the shipment actions toolbar.

---

### Verdict

**⚠️ CONDITIONAL PASS**

The PR is ready for merge after addressing:
1. Add unit tests for `useShipmentBulk` composable
2. Remove console.log statements (or confirm they're intentional)

---

### Summary for Follow-up Agent

If handing off to another agent to fix issues:

```json
{
  "pr_number": 123,
  "status": "conditional_pass",
  "blocking_issues": [
    {
      "type": "missing_tests",
      "file": "src/composables/useShipmentBulk.ts",
      "action": "Create unit tests in src/composables/__tests__/useShipmentBulk.spec.ts"
    }
  ],
  "warnings": [
    {
      "type": "console_log",
      "file": "src/views/ShipmentPage.vue",
      "lines": [123, 156],
      "action": "Remove or confirm intentional"
    },
    {
      "type": "script_order",
      "file": "src/components/shipment/ShipmentList.vue",
      "issue": "Watchers before functions",
      "action": "Reorder script sections"
    }
  ]
}
```
```

---

## Step 7: Update PR on GitHub

### 7.1 Check Off Verified Items

**IMPORTANT: Always ask for confirmation before updating the PR.**

```markdown
I've completed the review. Here's what I found:

✅ ESLint & Prettier - PASS
✅ General conventions - PASS  
⚠️ Component structure - 1 warning
❌ Unit tests - Missing for 2 files
⚠️ Sanity check - 2 console.logs

**Do you want me to:**
1. Check off the passing items in the PR checklist on GitHub?
2. Add the proposed release notes to the PR description?

Please confirm before I update the PR.
```

### 7.2 Update PR Body

Once confirmed, write the new PR body to a file and use the GitHub API directly:

```bash
# Write the new PR body to a temporary file
cat > /tmp/pr-body.md << 'EOF'
## Summary

[Summary of changes]

### What's New
[List of additions]

### Changes
[List of modifications]

## Release Notes

### 🚀 New
- **Feature name** - User-facing description of the benefit

### ⚙️ Improved
- Description of improvements

### 🐞 Fixed
- Description of bug fixes

## My PR created in accordance:
- [x] no errors from eslint & prettier 
- [x] components are nicely structured
- [x] core functionality covered with unit tests
- [x] changes comply with general conventions
- [x] sanity check completed
- [x] confirmed all checkboxes truthfully
EOF

# Update PR using GitHub API (more reliable than gh pr edit)
gh api repos/{owner}/{repo}/pulls/{pr_number} -X PATCH -f body="$(cat /tmp/pr-body.md)"
```

**Why use the API directly?**

The `gh pr edit --body` command can silently fail due to GraphQL warnings about deprecated Projects (classic). Using `gh api` with a PATCH request is more reliable.

### 7.3 Release Notes Format

Release notes should always be included in the PR description. Use this format:

```markdown
## Release Notes

### 🚀 New
- **Feature name** - User-facing description focusing on the benefit, not technical details

### ⚙️ Improved
- **Area improved** - What's better and why it matters to users

### 🐞 Fixed
- **Issue fixed** - What was wrong and that it's now resolved

### ⚙️ Internal (for non-user-facing changes)
- Technical improvements that don't affect users directly
```

**Writing good release notes:**
- Focus on **user benefits**, not technical implementation
- Use active voice: "You can now..." instead of "Added ability to..."
- Keep it concise: 1-2 sentences per item
- Group related changes together
- For internal/chore PRs, use "⚙️ Internal" section

### 7.4 Example: Complete PR Update

```bash
# 1. Create the PR body file
cat > /tmp/pr-body.md << 'EOF'
## Summary

Add bulk export functionality for shipments, allowing users to export multiple shipments at once.

### What's New
- Bulk selection in shipment list
- Export to CSV/Excel formats
- Progress indicator for large exports

## How to Use
1. Select shipments using checkboxes
2. Click "Export" button
3. Choose format (CSV or Excel)

## Release Notes

### 🚀 New
- **Bulk shipment export** - You can now select multiple shipments and export them all at once to CSV or Excel, saving time on repetitive export tasks.

## My PR created in accordance:
- [x] no errors from eslint & prettier 
- [x] components are nicely structured
- [x] core functionality covered with unit tests
- [x] changes comply with general conventions
- [x] sanity check completed
- [x] confirmed all checkboxes truthfully
EOF

# 2. Update the PR via GitHub API
gh api repos/ShipitSmarter/viya-app/pulls/123 -X PATCH -f body="$(cat /tmp/pr-body.md)"
```

---

## Checklist Reference

From the PR template, these are the items we verify:

```markdown
## My PR created in accordance:
- [ ] no errors from eslint & prettier 
- [ ] components are nicely structured (component conventions)
- [ ] core functionality of my feature covered with unit tests
- [ ] changes are done in compliance with general conventions
- [ ] I did a sanity check over my own changes
- [ ] by checking this box I confirm I've clicked all the previous checkboxes truthfully
```

---

## Quick Commands

```bash
# Run all automated checks
npm run lint && npm run format:check && npm run type-check && npm run build-only:prod

# View PR details
gh pr view

# Get changed files
gh pr diff --name-only

# Get full diff
gh pr diff

# View PR in browser
gh pr view --web
```

---

## Error Handling

### No PR found

```markdown
No open PR found for branch `<branch-name>`.

Options:
1. Create a PR: `gh pr create`
2. Specify a PR number: "Review PR #123"
3. Push your branch first: `git push -u origin <branch-name>`
```

### Build failures

Collect all errors and format for handoff:

```markdown
## Build Failed

The following issues must be resolved before the PR can be reviewed:

**ESLint (5 errors):**
[list errors]

**TypeScript (2 errors):**
[list errors]

Run `npm run lint:fix` to auto-fix some issues.
```

---

## Integration with PLAN.md

If the repository has a `PLAN.md` file, update it with review status:

```markdown
## PR Review Status

- **PR:** #123
- **Reviewed:** 2026-01-16
- **Status:** Conditional Pass
- **Blocking:** Missing tests for useShipmentBulk
- **Next:** Add unit tests, then merge
```

---

## Related Documentation

- [Testing Strategy](../../../docs/testing-strategy.md) - Comprehensive guide for test coverage decisions

---

## Related Skills

- **vue-component** - Component conventions and script order
- **playwright-test** - Writing E2E tests
- **github-workflow** - Commit messages and PR workflow
- **api-integration** - API service patterns
