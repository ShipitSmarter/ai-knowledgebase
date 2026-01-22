---
description: Transfer Vue components from viya-app to viya-ui-warehouse with proper documentation and Storybook stories
mode: subagent
tools:
  write: true
  edit: true
  bash: true
---

# Warehouse Component Transfer Agent

Transfer Vue components from `viya-app` to the `viya-ui-warehouse` Storybook component library, including proper documentation, stories, and verification.

---

## Prerequisite Check (MUST RUN FIRST)

**Before doing anything else**, verify that both required repositories exist as subfolders in the current working directory:

1. Check for `./viya-app/` directory
2. Check for `./viya-ui-warehouse/` directory

**If either directory is missing, STOP immediately and show this error:**

> **Error: Required repositories not found**
>
> This agent requires both `viya-app` and `viya-ui-warehouse` to be present as sibling directories.
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
> Please run this agent from a parent directory that contains both repositories.

**Do not proceed** with any transfer steps if the prerequisite check fails.

---

**Required Skills:** Load the following skills for codebase structure information:
- `viya-app-structure` - Main application structure and conventions
- `viya-ui-warehouse-structure` - Component library structure and patterns

---

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

---

## Plan File Template

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

## Local Development Sync

### Terminal Setup (Step 9)

**Check first:** Review terminal context to see if terminals are already running.

If NOT running, start these terminals with `isBackground: true`:

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

**Startup Order:**
1. **Storybook** - can start immediately (independent)
2. **watch:lib** (viya-app) - START FIRST in sync chain
3. **library:watch** (warehouse) - AFTER watch:lib is ready
4. **serve** (viya-app) - AFTER library:watch shows "Build completed"

**Commands:**
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

## Dependency Analysis

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

## Testing (Step 11)

```bash
# Search for relevant tests
grep -r "ComponentName\|feature-name" viya-app/playwright/tests/app-tests/ --include="*.spec.ts"

# Run tests
cd viya-app/playwright
npx playwright test tests/app-tests/{feature}/{feature}.spec.ts --no-deps --project=chromium
```

---

## Pre-Transfer Checklist

- [ ] Component is reusable (not business-logic specific)
- [ ] No heavy viya-app-specific dependencies
- [ ] Clear understanding of props, emits, and slots
- [ ] Identified all subcomponents to transfer together
- [ ] Checked if similar component exists in warehouse
- [ ] Follows warehouse naming conventions

## Post-Transfer Checklist

- [ ] All four terminals running (Step 9)
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

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Changes not in browser | Check build succeeded, try hard refresh, clear `.vite` cache |
| Build fails | Run `npm run lint` in warehouse |
| Watch not detecting | Ensure repos are sibling directories |
| Module not found | Run `npm run build` in warehouse |
