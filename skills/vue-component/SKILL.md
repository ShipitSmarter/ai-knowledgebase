---
name: vue-component
description: Creating Vue 3 components following project conventions and script order. Use when building new components, refactoring existing ones, or reviewing component code for convention compliance.
license: MIT
metadata:
  author: shipitsmarter
  version: "1.0"
---

# Vue Component Skill

Guidelines for creating Vue 3 components in this project.

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
