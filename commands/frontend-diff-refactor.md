---
description: Diff branch to main and refactor changed Vue/TypeScript files to match frontend coding standards (Vue repos only)
---

# Frontend Diff Refactor

Apply coding standards, comment guidelines, and best practices to all changed files in the current branch compared to `main`.

## Required Skill

**Load the `viya-app-coding-standards` skill before proceeding.** This skill contains all coding standards for TypeScript, Vue components, and Playwright tests.

## Prerequisite Check

**This command is only for Vue.js frontend repositories.**

Before executing, verify this is a Vue frontend codebase by checking for:
- `src/` directory with `.vue` files
- `package.json` with `vue` as a dependency
- Typical Vue project structure (`src/components/`, `src/views/`, etc.)

**If this is NOT a Vue frontend repository:**
> This command is only available for Vue frontend repositories. The coding standards and refactoring rules are specific to Vue 3 with TypeScript and Composition API.
>
> For other codebases, please use a different refactoring approach appropriate to your tech stack.

**Do not proceed** with any analysis or changes if the prerequisite check fails.

## Workflow

1. **Load the skill** - Load `viya-app-coding-standards` for reference
2. **Get the diff** - List all changed files between current branch and `main`
3. **Analyze each file** - Check for violations against the coding standards
4. **Apply fixes** - Refactor code to comply with standards
5. **Verify** - Run `npm run lint` and `npm run type-check` to ensure no regressions

---

## Vue Component Architecture Review

For each **new or modified Vue component**, evaluate refactoring opportunities:

### 1. Helper Function Extraction

**Question:** Are there significant sections of helper functions that could be in separate `-helpers.ts` files?

**Look for:**
- Pure utility functions (formatting, calculations, transformations)
- Static configuration objects (maps, column definitions, filter configs)
- Functions that don't depend on component reactive state
- 3+ related helper functions in `<script setup>`

**Action:**
- **Obvious** (5+ pure functions, clearly reusable): Extract immediately to co-located `feature-helpers.ts`
- **Less obvious**: Document proposal and ask user

### 2. Thin Wrapper Components

**Question:** Is this component an unnecessary thin wrapper that adds no value?

**Signs of thin wrappers:**
- Only passes props through to a child component
- No additional logic, computed properties, or template structure
- Used in only 1-2 places

**Action:**
- **Obvious** (pure pass-through, single usage): Remove wrapper, use child directly
- **Less obvious** (some logic but minimal): Document proposal and ask user

### 3. Redundant Custom Components

**Question:** Does this component reinvent functionality already available in existing components?

**Search locations (in order):**
1. `@shipitsmarter/viya-ui-warehouse` package
2. `src/components/` (shared application components)
3. `src/components/ui/` (shadcn-based primitives)
4. `src/views/{feature}/components/` (feature-specific components)

---

## Checklist

For each changed file, verify:

- [ ] No redundant comments that restate code
- [ ] Complex logic extracted to well-named functions
- [ ] Watch/effect comments explain *why* they're needed (if non-obvious)
- [ ] Script sections in correct order (per skill)
- [ ] Composable files named `use*.ts`
- [ ] No magic numbers - use named constants
- [ ] Absolute imports only
- [ ] Props simplified where appropriate
- [ ] Using library components where available

**For new/modified Vue components:**
- [ ] No significant helper functions that should be extracted
- [ ] No thin wrapper components that add no value
- [ ] No custom implementations of existing library components

---

## Verification Commands

```bash
npm run lint        # Check for lint errors
npm run type-check  # Check for TypeScript errors
```

Both must pass with no new errors introduced by your changes.
