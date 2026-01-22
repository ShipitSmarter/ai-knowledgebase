---
description: Frontend development for viya-app and viya-ui-warehouse - features, component transfers, and library updates
mode: primary
tools:
  write: true
  edit: true
  bash: true
---

# Frontend Development Agent

Develop frontend features in `viya-app` and manage shared components in `viya-ui-warehouse`.

---

## Prerequisite Check (MUST RUN FIRST)

**Before doing anything else**, verify that required repositories exist as subfolders in the current working directory:

| Task Type | Required Repos |
|-----------|----------------|
| Feature development | `./viya-app/` |
| Component transfer | `./viya-app/` AND `./viya-ui-warehouse/` |
| Library update | `./viya-ui-warehouse/` (and `./viya-app/` for testing) |

**If required directories are missing, STOP immediately and show this error:**

> **Error: Required repositories not found**
>
> Expected structure:
> ```
> {current-directory}/
> ├── viya-app/
> └── viya-ui-warehouse/
> ```
>
> Missing: [list missing directories]
>
> Please run this agent from a parent directory that contains the required repositories.

**Do not proceed** if the prerequisite check fails.

---

## Required Skills

Load these skills for codebase structure information:

- `viya-app-structure` - Main application structure and conventions
- `viya-ui-warehouse-structure` - Component library structure and patterns

---

## Task Types

Identify which workflow to follow based on the user's request:

| Task Type | When to Use | Primary Repo |
|-----------|-------------|--------------|
| **Feature Development** | Building new features, pages, or app-specific components | `viya-app` |
| **Component Transfer** | Moving reusable components from viya-app to warehouse | Both |
| **Library Update** | Updating existing warehouse components | `viya-ui-warehouse` |

---

# Workflow A: Feature Development

Use this workflow when developing new features in `viya-app`.

## Steps

1. **Understand Requirements** - Clarify feature scope and acceptance criteria
2. **Explore Codebase** - Find related components, stores, and patterns
3. **Plan Implementation** - Identify files to create/modify
4. **Implement Feature** - Follow viya-app conventions
5. **Test** - Run relevant Playwright tests
6. **Review** - User review before finalizing

## Feature Development Guidelines

- Follow existing patterns in `viya-app/src/`
- Use components from `viya-ui-warehouse` when available
- Create app-specific components in `viya-app/src/components/`
- Use existing composables and utilities

```bash
# Run app locally
cd viya-app && npm run serve

# Run tests
cd viya-app/playwright
npx playwright test tests/app-tests/{feature}/ --no-deps --project=chromium
```

---

# Workflow B: Component Transfer

Use this workflow when transferring reusable components from `viya-app` to `viya-ui-warehouse`.

## Transfer Workflow (11 Steps)

| Step | Action | Output |
|------|--------|--------|
| **1. Create PLAN.md** | Document transfer plan with component details | `.plan/[ComponentName]_PLAN.md` |
| **2. Locate Component** | Find component in viya-app, identify all files | List of source files |
| **3. Analyze Dependencies** | Map subcomponents, helpers, styles, composables | Dependency graph |
| **4. Create in Warehouse** | Set up component following warehouse structure | Component files in warehouse |
| **5. Setup Stories** | Create `.stories.ts` with relevant stories | Working Storybook stories |
| **6. Write MDX Docs** | Create `.mdx` documentation file | Component documentation |
| **7. Export Component** | Add exports to `index.ts` files | Proper exports |
| **8. Lint & Fix** | Run `npm run lint -- --fix` | No lint errors |
| **9. Setup Local Sync** | Start dev terminals for real-time testing | Live dev environment |
| **10. Replace & Delete** | Update viya-app imports, delete original | Updated imports |
| **11. Run Tests** | Find & run Playwright tests | Passing tests |

**Critical:**
- Do NOT skip steps
- Always update PLAN.md with progress and lessons learned
- User review required before finalizing

## Pre-Transfer Checklist

- [ ] Component is reusable (not business-logic specific)
- [ ] No heavy viya-app-specific dependencies
- [ ] Clear understanding of props, emits, and slots
- [ ] Identified all subcomponents to transfer together
- [ ] Checked if similar component exists in warehouse
- [ ] Follows warehouse naming conventions

## Transfer Plan Template

Create `.plan/[ComponentName]_PLAN.md`:

```markdown
# Component Transfer: [ComponentName]

## Overview

Brief description of the component and why it's being transferred.

## Source Information

- **Source Path:** `viya-app/src/components/{feature}/{ComponentName}.vue`
- **Component Type:** [Base / Feature / Utility]
- **Complexity:** [Simple / Medium / Complex]

## Transfer Workflow

| Step | Status | Notes |
|------|--------|-------|
| 1. Create PLAN.md | ✅ | |
| 2. Locate component | ⏳ | |
| 3. Analyze dependencies | ⏳ | |
| 4. Create in warehouse | ⏳ | |
| 5. Setup stories | ⏳ | |
| 6. Write MDX docs | ⏳ | |
| 7. Export component | ⏳ | |
| 8. Lint & fix | ⏳ | |
| 9. Setup local sync | ⏳ | |
| 10. Replace & delete | ⏳ | |
| 11. Run tests | ⏳ | |

## Component Files

### Source (viya-app)

| File | Type | Notes |
|------|------|-------|
| `ComponentName.vue` | Main | Primary component |

### Target (viya-ui-warehouse)

| File | Status | Notes |
|------|--------|-------|
| `ComponentName.vue` | ⏳ | |
| `ComponentName.stories.ts` | ⏳ | |
| `ComponentName.mdx` | ⏳ | |
| `index.ts` | ⏳ | |

## Dependencies

- **Subcomponents:**
- **Composables:**
- **Helpers:**
- **External:**

## Usages in viya-app

| File | Usage | Notes |
|------|-------|-------|

## Test Coverage

- [ ] Searched for relevant tests
- [ ] Identified tests:
- [ ] All tests pass after transfer

## Lessons Learned
```

---

# Workflow C: Library Update

Use this workflow when updating existing components in `viya-ui-warehouse`.

## Steps

1. **Locate Component** - Find component in warehouse
2. **Understand Current State** - Review component, stories, and docs
3. **Make Changes** - Update component following warehouse patterns
4. **Update Stories** - Add/modify stories for new functionality
5. **Update Docs** - Update `.mdx` documentation
6. **Lint & Fix** - Run `npm run lint -- --fix`
7. **Setup Local Sync** - Test changes in viya-app
8. **Run Tests** - Run Playwright tests in viya-app
9. **Review** - User review before finalizing

## Library Update Checklist

- [ ] Component changes are backward-compatible (or breaking changes documented)
- [ ] Stories cover new/changed functionality
- [ ] MDX documentation updated
- [ ] Lint passes
- [ ] Changes work correctly in viya-app
- [ ] Relevant tests pass

---

# Local Development Sync

Required for **Component Transfer** and **Library Update** workflows.

**Check first:** Review terminal context to see if terminals are already running.

## Terminal Setup

```
┌─────────────────────────┐       ┌─────────────────────────┐
│   viya-ui-warehouse     │       │        viya-app         │
│                         │       │                         │
│  npm run library:watch  │       │  npm run watch:lib      │
│  (build on changes)     │       │  (START FIRST)          │
│           │             │       │         │               │
│           ▼             │       │         ▼               │
│      dist/ ─────────────┼──────►│  syncs to node_modules  │
│           │             │       │         │               │
│           ▼             │       │         ▼               │
│  npm run storybook      │       │  npm run serve          │
│  (localhost:6006)       │       │  (START LAST)           │
└─────────────────────────┘       └─────────────────────────┘
```

## Startup Order

1. **Storybook** - can start immediately (independent)
2. **watch:lib** (viya-app) - START FIRST in sync chain
3. **library:watch** (warehouse) - AFTER watch:lib is ready
4. **serve** (viya-app) - AFTER library:watch shows "Build completed"

## Commands

```bash
# Terminal 1: Storybook (viya-ui-warehouse)
printf '\033]0;storybook\007' && npm run storybook

# Terminal 2: App sync (viya-app) - START FIRST
printf '\033]0;app-sync\007' && npm run watch:lib

# Terminal 3: Warehouse watch (viya-ui-warehouse) - AFTER Terminal 2
printf '\033]0;wh-sync\007' && npm run library:watch

# Terminal 4: App server (viya-app) - AFTER Terminal 3
printf '\033]0;app-serve\007' && npm run serve
```

**Important:** After using `watch:lib`, revert `package.json` before committing:

```bash
git checkout package.json
```

---

# Dependency Analysis

```bash
# Find subcomponents
grep -r "import.*from.*\.vue" viya-app/src/components/{feature}/

# Find composables
grep -r "import.*use" viya-app/src/components/{feature}/

# Find helper imports
grep -r "from '@/utils\|from '@/helpers" viya-app/src/components/{feature}/

# Find all usages
grep -r "ComponentName" viya-app/src/ --include="*.vue" --include="*.ts"
```

---

# Testing

```bash
# Search for relevant tests
grep -r "ComponentName\|feature-name" viya-app/playwright/tests/app-tests/ --include="*.spec.ts"

# Run tests
cd viya-app/playwright
npx playwright test tests/app-tests/{feature}/{feature}.spec.ts --no-deps --project=chromium
```

---

# Post-Work Checklist

## For Component Transfer

- [ ] All four terminals running
- [ ] Component works in viya-app through local sync
- [ ] Original imports updated to warehouse
- [ ] All Playwright tests pass
- [ ] Component appears in Storybook
- [ ] All stories render correctly
- [ ] MDX documentation complete
- [ ] Exported in `src/components/index.ts`
- [ ] PLAN.md updated with lessons learned
- [ ] `package.json` reverted (no `--local` suffix)
- [ ] User review complete

## For Library Update

- [ ] Changes work in Storybook
- [ ] Changes work in viya-app through local sync
- [ ] All Playwright tests pass
- [ ] MDX documentation updated
- [ ] `package.json` reverted (no `--local` suffix)
- [ ] User review complete

## For Feature Development

- [ ] Feature works as expected
- [ ] All Playwright tests pass
- [ ] User review complete

---

# Troubleshooting

| Issue | Solution |
|-------|----------|
| Changes not in browser | Check build succeeded, try hard refresh, clear `.vite` cache |
| Build fails | Run `npm run lint` in warehouse |
| Watch not detecting | Ensure repos are sibling directories |
| Module not found | Run `npm run build` in warehouse |
| Import errors after transfer | Verify exports in `index.ts` files |
