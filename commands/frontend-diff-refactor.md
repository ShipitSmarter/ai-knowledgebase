---
description: Diff branch to main and refactor changed Vue/TypeScript files to match frontend coding standards (Vue repos only)
---

# Frontend Diff Refactor

Apply coding standards, comment guidelines, and best practices to all changed files in the current branch compared to `main`.

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

1. **Get the diff** - List all changed files between current branch and `main`
2. **Analyze each file** - Check for violations of the rules below
3. **Apply fixes** - Refactor code to comply with standards
4. **Verify** - Run `npm run lint` and `npm run type-check` to ensure no regressions

---

## Comment Guidelines

### When Comments ARE Appropriate
- Non-obvious workarounds (browser quirks, timing issues, API limitations)
- Explaining *why* something is done when not self-evident
- Backend format/protocol explanations
- Watch/effect dependencies that aren't obvious from context

### When to AVOID Comments
- Restating what the code already says (e.g., `// Find the index` before `.findIndex()`)
- TSDoc for simple/obvious functions - clear naming is preferred
- Step-by-step explanations that should be extracted to helper functions

### Prefer Self-Documenting Code
- Use descriptive variable/function names that explain *what* and *why*
- Extract complex logic (5-10+ lines) into well-named helper functions
- Comments should only explain *non-obvious* behavior

**Examples:**
```ts
// Bad: comment restates the code
// Find the row index by matching the label
const index = data.value.findIndex((row) => row.label === highlightLabel);

// Good: self-explanatory variable name
const matchingRowIndex = data.value.findIndex((row) => row.label === highlightLabel);

// Bad: long inline comment
// Only update if the data has changed (compare by reference count and first item)
if (filtered.length !== data.value.length || ...) { ... }

// Good: extract to self-documenting function
const hasDataChanged = (filtered: Item[]): boolean =>
  filtered.length !== data.value.length || ...;
if (hasDataChanged(filtered)) { ... }

// Good: comment explains non-obvious behavior
// Watch needed: initialTab prop changes after mount when deep-linking from stepper
watch(() => props.initialTab, ...);
```

---

## Vue Component Script Order

All `<script setup>` sections MUST follow this order:

```vue
<script setup lang="ts">
// 1. TYPES & INTERFACES
type MyType = { ... };
interface MyInterface { ... }

// 2. COMPOSABLES
const route = useRoute();
const store = useMyStore();

// 3. CONSTANTS
const TABLE_OFFSET = 400;

// 4. SERVICES
const myService = new MyService();

// 5. PROPS & EMITS
const props = defineProps<{ ... }>();
const emit = defineEmits<{ ... }>();

// 6. MODELS
const open = defineModel<boolean>('open');

// 7. REFS & REACTIVES
const loading = ref<boolean>(false);

// 8. COMPUTED
const isValid = computed(() => ...);

// 9. FUNCTIONS
const handleClick = () => { ... };

// 10. WATCHERS
watch(() => props.id, fetchData);

// 11. LIFECYCLE HOOKS (always LAST)
onMounted(() => { ... });
</script>
```

---

## Code Standards

### Naming Conventions
| Type | Convention | Example |
|------|------------|---------|
| Components | `PascalCase` | `UserProfile.vue` |
| Composables | `camelCase` with `use` prefix | `useTableHighlight.ts` |
| Stores | `camelCase` with `use` prefix | `useRatesStore.ts` |
| Utilities | `kebab-case` | `rates-helpers.ts` |
| Types/Interfaces | `PascalCase` | `RatesData` |
| Variables/Functions | `camelCase` | `calculateTotal` |
| Constants | `SCREAMING_SNAKE_CASE` | `MAX_ITEMS` |
| CSS classes | `kebab-case` | `user-profile` |
| Directories | `kebab-case` | `user-profile/` |

### Import Rules
- Always use absolute imports with `@/` prefix
- Never use relative imports (`../`, `./`)
- Vue files include `.vue` extension
- TypeScript files do NOT include `.ts` extension

```ts
// Correct
import MyComponent from '@/components/MyComponent.vue';
import { myHelper } from '@/utils/helpers';

// Wrong
import { something } from '../utils/helpers';
import { myHelper } from '@/utils/helpers.ts';
```

### Template Rules
- Use shorthand syntax: `@` for `v-on`, `:` for `v-bind`, `#` for `v-slot`
- Don't use `props.` prefix in template (except `props.class`)
- Don't use `()` for event handlers without arguments: `@click="save"` not `@click="save()"`
- Never use array index as `:key` in `v-for` loops

### No Magic Numbers
```ts
// Bad
if (step.value === 2) { ... }

// Good
const PRICES_STEP_INDEX = 2;
if (step.value === PRICES_STEP_INDEX) { ... }
```

### Props Simplification
```ts
// Verbose
interface Props {
  source: PriceDetailsSource;
}
defineProps<Props>();

// Concise (when simple)
defineProps<{ source: PriceDetailsSource }>();
```

### Use Library Components
- Prefer `ButtonComponent` from warehouse over raw `<button>`
- Use established UI components for consistency

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
- [ ] Script sections in correct order
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
