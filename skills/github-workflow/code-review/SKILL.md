---
name: code-review
description: Senior frontend code review for Vue/TypeScript. Use when reviewing PRs, checking code quality, or validating against project conventions.
license: MIT
metadata:
  author: shipitsmarter
  version: "1.0"
---

# Code Review Skill

Senior frontend tech lead code review for Vue 3 / TypeScript projects. Clear, concise, actionable feedback.

---

## Trigger

Use this skill when:
- Reviewing a PR or code changes
- Checking code quality before committing
- Validating component structure against conventions
- Deciding if tests are needed

For **full PR workflow** (checklist verification, release notes, GitHub updates), use the **pr-review** skill instead.

---

## Review Principles

### Be Direct
Lead with the verdict, explain why, suggest how to fix.

### Be Proportional
- **Blocking issues**: Must fix before merge
- **Suggestions**: Nice to have, not required
- **Nits**: One line max, or skip entirely

### Be Helpful
Don't just criticize - show the correct pattern.

---

## Review Process

### Step 1: Understand the Feature

Before looking at code:
- Read PR description completely
- Understand what user problem this solves
- Map out the expected user flows
- Ask: "How will this feature actually be used?"

### Step 2: Run Automated Checks

```bash
npm run lint && npm run type-check
```

Any errors here are **blocking issues**. Report them first.

### Step 3: Trace the Critical Paths

For each main user action the PR enables:
- Trace the code path from trigger to completion
- Identify where errors can occur
- Verify error handling exists at each point
- Ask: "What happens when X fails?"

### Step 4: Check Component Structure

For each changed `.vue` file, verify script order:

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

**Common violations:**
- Lifecycle hooks before functions
- Watchers before functions
- Refs defined before composables

### Step 5: Check Conventions

| Convention | Correct | Wrong |
|------------|---------|-------|
| Imports | `@/components/X.vue` | `../../components/X` |
| Types | `unknown` + type guard | `any` |
| Templates | `@click="fn"` | `@click="fn()"` |
| v-for keys | `:key="item.id"` | `:key="index"` |
| Styling | Tailwind classes | `<style>` blocks |
| Functions | Arrow functions | `function` declarations |

### Step 6: Check for Debug Code

```bash
# Console statements (remove before merge)
rg "console\.(log|warn|debug)" --type vue --type ts

# Debugger statements
rg "debugger" --type vue --type ts
```

**Exceptions:**
- `console.error` in error handlers is OK
- `TODO(VIYA-123)` with ticket reference is OK

### Step 7: Evaluate Test Coverage

Use the Test Decision Framework below.

---

## Before Commenting on Any Issue

**STOP.** For each potential issue, complete this checklist before writing it up:

### 1. Trace the Execution Path

Don't assume. Actually follow the code:
- What calls this function/triggers this watcher?
- Under what conditions does each branch execute?
- What are the actual values at runtime, not what they "look like"?

### 2. Understand Intent

- What problem is the author solving?
- Is there a simpler way to achieve the same goal?
- Does this code actually achieve that goal?

### 3. Validate with a Concrete Scenario

Mental unit test:
- Walk through a real user action step by step
- "User opens page X, what happens?"
- "User clicks Y, what happens if API fails?"

### 4. Question Your Assumption

Before writing the comment:
- "Am I pattern-matching or did I actually verify this?"
- "What if I'm wrong? What would that look like?"
- "Is there context I'm missing about how this is used?"

---

## Common Review Traps to Avoid

| Trap | Example | What to Do Instead |
|------|---------|-------------------|
| Pattern matching | "watch + onMounted = duplicate" | Trace actual execution flow |
| Assuming behavior | "immediate: true fires with same values" | Check Vue docs / verify |
| Surface-level reading | "No try/catch = missing error handling" | Check if caller handles it |
| Reviewing in isolation | "This watcher handles route changes" | Ask: does this route change ever happen in practice? |
| Breadth over depth | Finding 15 shallow issues | Deeply understand 5 real issues |

---

## Self-Verification Protocol

Before finalizing any **blocking issue**:

1. **Re-read the code** with fresh eyes after writing your comment
2. **Argue against yourself** - How would the author defend this code?
3. **Prove the bug** - Can you describe the exact conditions under which it manifests?
4. **Severity check** - Is this actually blocking, or pedantic?

**If you cannot clearly explain:**
- The exact conditions under which the bug manifests
- What the user would experience
- Why the fix is correct

**Then you don't have a blocking issue.** Downgrade to suggestion or investigate further.

---

## Depth Over Breadth

It's better to deeply understand 5 issues than to superficially flag 15.

For complex logic (composables, watchers, lifecycle, async flows):
- Spend 2-3x longer analyzing before commenting
- If you can't explain the exact execution flow, you don't understand it yet
- Write out the execution trace mentally or on paper if needed

---

## Test Decision Framework

```
Is this a critical business workflow? (payments, shipments, rates)
  YES -> E2E test required

Does the feature cross multiple pages/routes?
  YES -> E2E test required

Is this a new composable or utility function?
  YES -> Unit test required

Is this a bug fix?
  YES -> Test that reproduces the bug

Is this pure refactoring?
  YES -> Existing tests should pass, no new tests

Is this a simple UI/styling change?
  YES -> No tests required
```

### Test Locations

| Code | Location | Example |
|------|----------|---------|
| Component | `src/components/{feature}/__tests__/` | `Button.spec.ts` |
| Composable | `src/composables/__tests__/` | `useFilter.spec.ts` |
| Utility | `src/utils/__tests__/` | `format.spec.ts` |
| E2E | `playwright/tests/app-tests/{feature}/` | `shipment.spec.ts` |

---

## Review Output Format

```markdown
## Review Summary

**Verdict**: [APPROVE / CHANGES REQUESTED / NEEDS DISCUSSION]

### Blocking Issues
- [Issue 1 with file:line]
- [Issue 2 with file:line]
- Or: None

### Suggestions
- [Optional improvement]

### Good Patterns
[One line noting what was done well, or omit]
```

---

## Common Issue Templates

### Script Order Violation

```markdown
**Script order** `ComponentName.vue:89`

Watchers appear before functions. Move to correct position.

Order: Types -> Composables -> Constants -> Services -> Props -> Models -> Refs -> Computed -> Functions -> **Watchers** -> Lifecycle
```

### Missing Type

```markdown
**Add typing** `useData.ts:45`

```typescript
// Before
const data: any = await response.json();

// After  
const data: ShipmentResponse = await response.json();
```
```

### Missing Tests

```markdown
**Missing tests** `useShipmentBulk.ts`

New composable with business logic needs unit tests.

Create: `src/composables/__tests__/useShipmentBulk.spec.ts`
```

### Debug Code

```markdown
**Remove console.log** `ShipmentPage.vue:123`
```

---

## Quick Commands

```bash
# Full check
npm run lint && npm run type-check && npm run build-only:prod

# Changed files only
git diff --name-only origin/main...HEAD | grep -E '\.(vue|ts)$'

# Run specific test
npm run test:unit -- --grep "ComponentName"
```

---

## When to Escalate

Request discussion (not just changes) when:
- Architecture changes affect multiple features
- New patterns that could set precedent
- Security or performance concerns
- Breaking changes to shared components

---

## Related Skills

| Skill | When to Use |
|-------|-------------|
| **pr-review** | Full PR workflow with checklist and release notes |
| **vue-component** | Detailed component conventions |
| **unit-testing** | Vitest patterns and mocking |
| **playwright-test** | E2E test structure |
