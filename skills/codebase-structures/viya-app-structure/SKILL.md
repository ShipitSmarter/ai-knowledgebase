---
name: viya-app-structure
description: Understanding the viya-app frontend codebase structure, key paths, and development patterns. Use when working with the main Vue.js application.
license: MIT
metadata:
  author: shipitsmarter
  version: "1.0"
---

# Viya App Structure

The `viya-app` repository is the main Vue.js frontend application for the Viya TMS platform.

---

## Key Paths

| Path | Purpose |
|------|---------|
| `src/views/{feature}/` | Feature page components |
| `src/components/{feature}/` | Reusable feature components |
| `src/components/utilities/` | Common utility components (BaseDialog, BaseCard, etc.) |
| `src/components/upload-download/` | File upload/download components |
| `src/components/drag-drop/` | Drag-and-drop components |
| `src/composables/` | Stateful reusable logic (use*.ts) |
| `src/utils/` | Stateless pure functions |
| `src/services/` | API service classes |
| `src/store/` | Pinia stores |
| `src/types/` | TypeScript type definitions |
| `src/generated/` | Auto-generated API types |
| `playwright/tests/app-tests/` | E2E Playwright tests |
| `docs/` | Project documentation |

---

## Common Commands

```bash
# Type checking
npm run type-check

# Linting & formatting
npm run lint
npm run lint:fix

# Run dev server
npm run dev:docker:go

# Run unit tests
npm run test:unit
npm run test:unit -- --grep "MyComponent"

# Run Playwright tests
cd playwright
npx playwright test tests/app-tests/{feature}/{feature}.spec.ts --no-deps --project=chromium
```

---

## Component Structure

Components in viya-app follow the Vue 3 Composition API with `<script setup>`:

```
src/components/{feature}/
├── index.ts              # Barrel export
├── FeatureComponent.vue  # Main component
├── FeatureSubComponent.vue
└── feature-helpers.ts    # Helper functions (optional)
```

---

## Import Conventions

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

---

## Local Warehouse Development

When testing warehouse changes locally in viya-app:

```bash
# In viya-app - watches warehouse dist folder and syncs to node_modules
npm run watch:lib

# In viya-ui-warehouse - builds on changes
npm run library:watch
```

**Important:** After running `watch:lib`, your `package.json` will have `--local` suffix. Revert before committing:
```bash
git checkout package.json
```

See `docs/local-warehouse-testing.md` for full setup guide.

---

## UI Component Sources

When looking for UI components, check these locations in order:

1. `@shipitsmarter/viya-ui-warehouse` - Shared component library
2. `src/components/utilities/` - App-specific utilities (BaseDialog, etc.)
3. `src/components/ui/` - shadcn-based primitives
4. `src/components/{feature}/` - Feature-specific components

**Note:** Use `BaseDialog` from `@/components/utilities/BaseDialog.vue`, NOT `DialogComponent` from warehouse.

---

## Related Skills

| Skill | When to Use |
|-------|-------------|
| **vue-component** | Creating/modifying Vue components |
| **viya-ui-warehouse-structure** | Working with the shared component library |
| **playwright-test** | Writing E2E tests |
| **api-integration** | Working with API services |
