---
name: vue-component
description: Creating Vue 3 components following project conventions and script order. Use when building new components, refactoring existing ones, or reviewing component code for convention compliance.
license: MIT
metadata:
  author: shipitsmarter
  version: "1.1"
---

# Vue Component Skill

Guidelines for creating Vue 3 components in this project.

> **IMPORTANT:** All code must follow the **Frontend Guidelines** in `docs/frontend-guidelines/frontend-guidelines.md`. This is the authoritative source for code structure, naming conventions, and component organization.

---

## Quick Reference

### Common Commands
```bash
npm run type-check    # Type checking
npm run lint          # Linting
npm run lint:fix      # Auto-fix lint issues
npm run dev:docker:go # Run dev server
npm run test:unit     # Run unit tests
npm run test:unit -- --grep "MyComponent"  # Run specific test
```

### Key Paths
| Path | Purpose |
|------|----------|
| `src/views/{feature}/` | Feature page components |
| `src/components/{feature}/` | Reusable feature components |
| `src/components/utilities/` | Common utility components (BaseDialog, BaseCard, etc.) |
| `src/composables/` | Stateful reusable logic |
| `src/utils/` | Stateless pure functions |
| `src/services/` | API service classes |
| `src/store/` | Pinia stores |
| `src/types/` | TypeScript type definitions |

### Development Workflow (8 Steps)
1. **Understand** → 2. **PLAN.md** → 3. **Types** → 4. **Implementation** → 5. **Lint & Format** → 6. **Type Check** → 7. **Test Decision** → 8. **Unit/E2E Tests**

---

## Development Workflow (Detailed)

| Step | Action | Output |
|------|--------|--------|
| **1. Understand** | Read existing code, routes, services, types, API endpoints | Understanding of feature context |
| **2. Create PLAN.md** | Document implementation plan with steps, file changes, decisions | `PLAN.md` in feature directory |
| **3. Define Types** | Create/update TypeScript interfaces and types | Type definitions |
| **4. Implement** | Write Vue components, composables, services following code standards | Working feature code |
| **5. Lint & Format** | Run `npm run lint:fix` to auto-fix formatting issues | Clean, formatted code |
| **6. Type Check** | Run `npm run typecheck` and fix all errors | Zero type errors |
| **7. Test Decision** | Evaluate if E2E tests are needed (see Test Decision Framework) | Decision documented in PLAN.md |
| **8. Write Tests** | Write unit tests and/or E2E tests as appropriate | Test coverage |

**Critical:**
- Do NOT skip steps. Each step builds on the previous one.
- **Your PLAN.md and todo list MUST include ALL 8 steps**
- The exploration phase is essential for understanding patterns before writing any code
- Steps 5-6 are mandatory before any PR

---

## PLAN.md Template

Create a `PLAN.md` file in the feature directory to track progress and document decisions:

```markdown
# Feature: [Feature Name]

## Overview
Brief description of the feature and its purpose.

## Implementation Workflow

| Step | Status | Notes |
|------|--------|-------|
| 1. Understand existing code | ⏳ | |
| 2. Create PLAN.md | ✅ | |
| 3. Define types | ⏳ | |
| 4. Implement components | ⏳ | |
| 5. Lint & format | ⏳ | |
| 6. Type check | ⏳ | |
| 7. Test decision | ⏳ | |
| 8. Write tests | ⏳ | |

## Files to Modify/Create

| File | Action | Description |
|------|--------|-------------|
| `src/views/feature/FeaturePage.vue` | Create | Main feature page |
| `src/components/feature/FeatureCard.vue` | Create | Reusable card component |

## Test Decision

### E2E Test Evaluation
- [ ] Critical business workflow? 
- [ ] Crosses multiple pages/routes?
- [ ] Area has recurring bugs?
- [ ] Manual testing time-consuming?
- [ ] Can unit tests cover the logic adequately?

**Decision:** [Write E2E tests / Skip E2E, use unit tests]
**Justification:** [Reasoning]

## Lessons Learned
<!-- Update this section as you discover patterns, quirks, or useful information -->
```

---

## Component file structure

Components go in `src/components/<feature>/` organized by feature area.

```
src/components/
├── feature-name/
│   ├── index.ts           # Barrel export
│   ├── FeatureComponent.vue
│   ├── FeatureSubComponent.vue
│   └── feature-helpers.ts  # Helper functions (optional)
```

---

## Script order (MANDATORY)

All Vue components MUST follow this exact order in `<script setup>`:

```vue
<script setup lang="ts">
// 1. TYPES & INTERFACES (local to this component)
type MyType = { ... };
interface MyInterface { ... }

// 2. COMPOSABLES (external stateful hooks)
const route = useRoute();
const userStore = useUserStore();
const { width, height } = useWindowSize();

// 3. CONSTANTS (static values, never change)
const TABLE_OFFSET = 400;
const DEFAULT_PAGE_SIZE = 50;

// 4. SERVICES (API service instances)
const invoiceService = new InvoiceService();
const shipmentService = new ShipmentService();

// 5. PROPS & EMITS (component interface)
const props = defineProps<{ ... }>();
const emit = defineEmits<{ ... }>();

// 6. MODELS (two-way bindings)
const open = defineModel<boolean>('open', { required: true });

// 7. REFS & REACTIVES (local mutable state)
const loading = ref<boolean>(false);
const data = ref<MyType>();
const formState = reactive({ ... });

// 8. COMPUTED (derived state)
const isValid = computed(() => ...);
const filteredItems = computed(() => ...);

// 9. FUNCTIONS (methods, handlers, helpers)
const fetchData = async () => { ... };
const handleClick = () => { ... };
const formatValue = (val: number) => { ... };

// 10. WATCHERS (reactive side effects)
watch(() => props.id, fetchData, { immediate: true });
watch(data, (newVal) => { ... });

// 11. LIFECYCLE HOOKS (always LAST)
onMounted(() => { ... });
onBeforeUnmount(() => { ... });
</script>
```

**Why this order matters:**
- Dependencies flow top-to-bottom (composables before refs that use them)
- Lifecycle hooks are always last because they may depend on anything above
- Watchers come before lifecycle hooks but after functions they may call
- Makes code predictable and easier to navigate

---

## Import conventions

```typescript
// External packages first
import { SomeComponent } from '@shipitsmarter/viya-ui-warehouse';
import { computed, ref } from 'vue';
import { useRoute } from 'vue-router';

// Internal imports second (with @/ prefix)
import MyComponent from '@/components/my/MyComponent.vue';
import { SomeType } from '@/generated/shipping';
import { myService } from '@/services/my-service';
import { useMyStore } from '@/store/my-store';
```

**Rules:**
- Always use `@/` prefix (no relative paths like `../../`)
- Include `.vue` extension for Vue components
- Omit `.ts/.js` extension for TypeScript files
- Sort alphabetically within each group

---

## Props and emits

```typescript
// Props - always typed with interface
interface Props {
  shipmentId: string;
  readonly?: boolean;
  status?: 'pending' | 'active' | 'completed';
}

const props = withDefaults(defineProps<Props>(), {
  readonly: false,
  status: 'pending',
});

// Emits - always typed
interface Emits {
  (e: 'update', value: string): void;
  (e: 'close'): void;
}

const emit = defineEmits<Emits>();
```

---

## Template conventions

### Attribute order

Bound attributes (`:`) and event handlers (`@`) must come **before** directives:

```vue
<!-- Correct -->
<MyComponent :data="item" @click="handle" v-if="show" />

<!-- Wrong -->
<MyComponent v-if="show" :data="item" @click="handle" />
```

### Shorthands

Always use:
- `@` for `v-on` (events)
- `:` for `v-bind` (props)
- `#` for `v-slot` (slots)

### Props in templates

Avoid `props.` prefix in templates (except for `props.class`):

```vue
<!-- Correct -->
<template>
  <button :name="title" />
</template>

<!-- Avoid -->
<template>
  <button :name="props.title" />
</template>
```

### Method bindings

Don't use `()` for method bindings unless passing arguments:

```vue
<!-- Correct -->
<button @click="handleClick" />
<button @click="handleClick(id)" />

<!-- Wrong -->
<button @click="handleClick()" />
```

### v-for keys

Never use array index as `:key`:

```vue
<!-- Correct -->
<div v-for="item in items" :key="item.id" />

<!-- Wrong -->
<div v-for="(item, index) in items" :key="index" />
```

---

## Defensive rendering

Use `v-if` generously to prevent broken components:

```vue
<template>
  <div v-if="data">
    <h1>{{ data.title }}</h1>
    <p v-if="data.description">{{ data.description }}</p>
    <UserInfo v-if="data.user" :user="data.user" />
  </div>
  <LoadingSpinner v-else />
</template>
```

---

## Helper files

Extract reusable logic to co-located `-helpers.ts` files:

```typescript
// feature-helpers.ts
export const formatPrice = (value: number): string => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
  }).format(value);
};

export const COLUMN_DEFINITIONS = [
  { key: 'name', label: 'Name', sortable: true },
  { key: 'status', label: 'Status', sortable: false },
] as const;
```

Keep components focused on reactive state and template rendering.

---

## Naming conventions

| Type | Convention | Example |
|------|------------|---------|
| Components | PascalCase | `ShipmentList.vue` |
| Props/variables | camelCase | `shipmentId` |
| Events/emits | kebab-case | `update-status` |
| Directories | kebab-case | `shipment-list/` |
| Helper files | kebab-case | `shipment-helpers.ts` |
| Types/interfaces | PascalCase | `ShipmentData` |

---

## Barrel exports (index.ts)

Every component directory should have an `index.ts`:

```typescript
// src/components/feature-name/index.ts
export { default as FeatureComponent } from './FeatureComponent.vue';
export { default as FeatureSubComponent } from './FeatureSubComponent.vue';
export * from './feature-helpers';
```

---

## Styling with Tailwind CSS

**Always use Tailwind CSS classes instead of `<style>` blocks:**

```vue
<!-- Correct: Use Tailwind classes -->
<input class="text-sm font-medium text-white placeholder:text-white/70" />

<!-- Avoid: Scoped CSS -->
<style scoped>
input {
  font-size: 0.875rem;
  color: white;
}
</style>
```

**For deep styling of library components, use Tailwind's arbitrary variants:**

```vue
<!-- Correct: Deep styling with Tailwind arbitrary variants -->
<InputComponent class="[&_input]:text-white [&_input::placeholder]:text-white/70" />

<!-- Avoid: Scoped CSS with :deep() -->
<style scoped>
.my-input :deep(input) { color: white; }
</style>
```

**Exceptions where CSS may be needed:**
- Complex animations that can't be expressed in Tailwind
- CSS variables for theming (rare)
- Third-party library overrides that don't work with classes

---

## UI Library components

**Before creating a new component**, check if it already exists in the shared UI warehouse:

- **Storybook**: https://storybook.viyatest.it/ - Browse all available components with examples
- **Package**: `@shipitsmarter/viya-ui-warehouse`

Import from the shared UI warehouse:

```typescript
import {
  ButtonComponent,
  InputComponent,
  DialogComponent,
  PopoverComponent,
  TableComponent,
  SelectComponent,
} from '@shipitsmarter/viya-ui-warehouse';
```

For local development with warehouse changes, see `docs/local-warehouse-testing.md`.

---

## Component checklist

Before submitting:
- [ ] Script follows the mandatory order
- [ ] All props and emits are typed
- [ ] Uses `@/` absolute imports
- [ ] Template uses v-if for defensive rendering
- [ ] No `any` types
- [ ] Uses Tailwind classes (no `<style>` blocks unless necessary)
- [ ] Checked Storybook for existing UI components
- [ ] Helper functions extracted to `-helpers.ts`
- [ ] Barrel export in `index.ts`
- [ ] Unit test in `__tests__/` directory

---

## Related Skills

| Skill | When to Use |
|-------|-------------|
| **api-integration** | Using services in components |
| **pr-review** | Component structure verification during review |
| **playwright-test** | Adding data-testid for E2E testing |

---

## Test Decision Framework

**Not every feature needs E2E tests.** Use this decision tree:

```
Should I write an E2E test?
│
├─ Is this a critical business workflow? (shipments, rates, bookings)
│   └─ YES → Write E2E test
│
├─ Does the feature cross multiple pages/routes?
│   └─ YES → Write E2E test
│
├─ Has this area had recurring bugs?
│   └─ YES → Write E2E test
│
├─ Is manual testing time-consuming or error-prone?
│   └─ YES → Write E2E test
│
├─ Can unit/component tests adequately cover the logic?
│   └─ YES → Skip E2E, use unit tests
│
├─ Is the feature stable and rarely changes?
│   └─ YES → Skip E2E
│
└─ Default → Skip E2E (start with unit tests)
```

### E2E Test Priority

| Priority | What to Test | Examples |
|----------|--------------|----------|
| **Critical** | Core business workflows | Shipment creation, rate calculation |
| **Important** | Complex integrations, bug-prone areas | FTP connections, zone calculations |
| **Standard** | Standard CRUD with complex state | Contract management |
| **Low** | Simple CRUD, read-only views | Settings pages, reports |

When E2E tests are needed, use the **playwright-test** skill for guidance.

---

## Lessons Learned

### Focus Retention in Table Cells

When creating editable table cells with TanStack Table:
- **Problem**: Vue re-renders can cause input focus loss during typing
- **Solution**: Create a stable component with local state that syncs to table only on blur
- **Pattern**: Use a `focusTracker` module-level singleton to track active cell and cursor position
- **Key insight**: Extract complex cell components to separate `.vue` files, don't use `defineComponent` inline

### Component Extraction

When moving inline components to separate files:
- Create the `.vue` file using Composition API
- If the component needs module-level state (like `focusTracker`), put it in a separate `.ts` file
- Use absolute imports in the new file
- Test thoroughly after extraction - import resolution issues can crash the app

### Extracting Complex Dialog Logic

When a page component grows large due to dialog functionality:
- **Extract the dialog** to its own component (e.g., `ImportContractDialog.vue`)
- **Extract reusable UI patterns** (e.g., `FileUploadWithDragDrop.vue`, `DragDropZone.vue`)
- **Pass dependencies as props** (e.g., `existingReferences` for validation) rather than importing services
- **Emit events** for parent actions (e.g., `@imported` to trigger data refresh)
- **Reset state on dialog close** using a watcher on the `open` model

### Drag-and-Drop File Upload Pattern

For file upload with drag-and-drop support:
- Create a `DragDropZone` component handling drag events and format validation
- The zone emits `drop` (with FileList) and `formatError` events
- Wrap it in a `FileUploadWithDragDrop` component that:
  - Shows drop zone OR selected file info (never both)
  - Processes file content via FileReader
  - Emits `fileSelected` with content and File object
  - Exposes `clearSelectedFile()` for parent reset

### UI Component Availability

Not all expected components/icons exist in the warehouse library:
- **Dialogs**: Use `BaseDialog` from `@/components/utilities/BaseDialog.vue`, NOT `DialogComponent` from warehouse
- **Icons**: Check available icons - e.g., `PhFileJson` doesn't exist, use `PhFileText` instead
- **When in doubt**: Search codebase for existing usage patterns

### Vuelidate in Dialogs

When using Vuelidate for validation inside dialogs:
- Reset validation state when dialog closes: `v$.value.$reset()`
- Use `computed` for validation object to make it reactive
- Combine `required` with custom validators using `helpers.withMessage()`

### Finding API Endpoints

To find which endpoint is called for a feature:
1. Find the store that manages the data (e.g., `useCarrierSelectStore`)
2. Look at the actions that fetch data (e.g., `getRates`)
3. Trace to the service method (e.g., `shipmentService.getShipmentOptionsWithQuery`)
4. Find the actual endpoint in the service (e.g., `POST /shipping/v4/shipments/options`)

### Attribute Ordering in Templates

ESLint enforces specific attribute ordering in Vue templates:
1. `TWO_WAY_BINDING` (v-model)
2. `DEFINITION`
3. `LIST_RENDERING` (v-for)
4. `CONDITIONALS` (v-if, v-show)
5. `RENDER_MODIFIERS`
6. `GLOBAL`
7. `UNIQUE`, `SLOT`
8. `OTHER_DIRECTIVES`
9. `EVENTS` (@click, etc.)
10. `CONTENT`
11. `OTHER_ATTR` (:prop bindings)

### Refactoring Large Files

When refactoring large files into multiple smaller files:
- **First verify existing tests pass** before making changes
- Make incremental changes and test after each
- If import resolution fails, revert and try a simpler approach
- Not every file needs to be split - readability > modularity
