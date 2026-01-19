---
name: codebase-navigation
description: Understanding viya-app project structure and where to find things. Use when exploring the codebase, finding files, or understanding how the app is organized.
license: MIT
metadata:
  author: shipitsmarter
  version: "1.0"
---

# Codebase Navigation Skill

Guide to understanding and navigating the viya-app project structure.

---

## Project overview

viya-app is a Vue 3 + TypeScript enterprise Transport Management Application providing:
- Shipment management
- Address books
- Pickup scheduling
- Rate management
- Workflow configuration

---

## Directory structure

```
viya-app/
├── src/                      # Application source code
│   ├── assets/               # Static assets (images, fonts, SCSS)
│   ├── components/           # Reusable Vue components by feature
│   ├── composables/          # Vue 3 composables (use* pattern)
│   ├── constants/            # Application-wide constants
│   ├── directives/           # Custom Vue directives
│   ├── generated/            # Auto-generated API types (DO NOT EDIT)
│   ├── injection-keys/       # Vue provide/inject keys
│   ├── json-forms/           # JSON Forms integration
│   ├── layout/               # Layout components
│   ├── plugins/              # Vue plugins
│   ├── router/               # Vue Router configuration
│   ├── services/             # API service layer
│   ├── store/                # Pinia stores
│   ├── test-utils/           # Test helper utilities
│   ├── types/                # Shared TypeScript types
│   ├── utils/                # Utility functions
│   └── views/                # Page-level components by feature
├── playwright/               # E2E tests (separate npm project)
├── agents/                   # AI agent documentation
│   ├── plans/                # Feature planning documents
│   └── skills/               # Skill definitions
└── docs/                     # Project documentation
```

---

## Finding components

### Reusable components: `src/components/`

Organized by feature area with 36+ directories:

```
src/components/
├── ui/                       # Base UI components (dialog, popover, table)
├── docs/                     # In-app documentation system
├── filters/                  # Filter components for list views
├── spotlight/                # Command palette / search
├── condition-builder-new/    # Condition/rule builder
├── shipment/                 # Shipment-specific components
└── ...
```

**Pattern:** `src/components/<feature>/<ComponentName>.vue`

### Page components: `src/views/`

Full pages organized by domain:

```
src/views/
├── shipment/                 # Shipment pages
│   ├── ShipmentOverviewPage.vue
│   ├── create/               # Shipment creation flow
│   └── details/              # Shipment detail views
├── pickup/                   # Pickup scheduling
├── address/                  # Address book
├── freight-settlement/       # Invoicing
├── configuration/            # Settings pages
└── ...
```

**Pattern:** `src/views/<domain>/<PageName>Page.vue`

---

## Finding services

### API services: `src/services/`

```
src/services/
├── clients/                  # Base API client setup
├── shipment-service.ts       # Shipment API calls
├── pickup-service.ts         # Pickup API calls
├── address-service.ts        # Address API calls
└── ...
```

**Pattern:** Services use generated types from `@/generated/`

```typescript
import { ShipmentService } from '@/services/shipment-service';
import type { Shipment } from '@/generated/shipping';
```

---

## Finding generated types

### Auto-generated from OpenAPI: `src/generated/`

```
src/generated/
├── shipping/                 # Shipment API types
├── rates/                    # Rates API types
├── address/                  # Address API types
├── pickup/                   # Pickup API types
└── ...
```

**Regenerate types:**
```bash
npm run generate-api
```

**Usage:**
```typescript
import type { Shipment, ShipmentStatus } from '@/generated/shipping';
import type { Rate, RateRequest } from '@/generated/rates';
```

---

## Finding stores

### Pinia stores: `src/store/`

```
src/store/
├── user.ts                   # User/auth state
├── carrier-profile.ts        # Carrier profile state
├── errors.ts                 # Error handling
└── ...
```

**Usage:**
```typescript
import { useUserStore } from '@/store/user';
import { useCarrierProfileStore } from '@/store/carrier-profile';
```

---

## Finding composables

### Vue composables: `src/composables/`

```
src/composables/
├── useAccess.ts              # Permission checking
├── useIntercom.ts            # Intercom integration
├── useSignedUrl.ts           # Signed URL handling
├── useFormDirtyCheck.ts      # Form dirty state
├── freight-settlement/       # Feature-specific composables
└── ...
```

**Pattern:** `use<Name>.ts` with camelCase

---

## Finding utilities

### Utility functions: `src/utils/`

```
src/utils/
├── datetime.ts               # Date/time formatting
├── pipe.ts                   # Functional utilities
├── unit.ts                   # Unit conversions
└── ...
```

**Pattern:** Pure functions, no Vue reactivity

---

## Finding routes

### Router configuration: `src/router/`

```
src/router/
├── index.ts                  # Main router setup
├── routes.ts                 # Route constants (ROUTES object)
├── shipment.ts               # Shipment routes
├── pickup.ts                 # Pickup routes
└── ...
```

**Route constants:**
```typescript
import { ROUTES } from '@/router/routes';

router.push({ name: ROUTES.SHIPMENT_DETAIL.name, params: { id } });
```

---

## Finding tests

### Unit tests: `__tests__/` directories

Tests live alongside their code:

```
src/components/feature/
├── FeatureComponent.vue
└── __tests__/
    ├── FeatureComponent.spec.ts
    └── __mocks__/
        └── feature-data-mock.ts
```

### E2E tests: `playwright/`

Separate npm project:

```
playwright/
├── tests/                    # Test files
├── fixtures/                 # Test fixtures
├── helpers/                  # Test helpers
└── playwright.config.ts
```

**Run E2E tests:**
```bash
npm run playwright           # From root
cd playwright && npx playwright test  # Direct
```

---

## Quick reference: Where to find things

| Looking for... | Location |
|----------------|----------|
| Reusable component | `src/components/<feature>/` |
| Full page | `src/views/<domain>/` |
| API service | `src/services/` |
| API types | `src/generated/<api>/` |
| Global state | `src/store/` |
| Composable | `src/composables/` |
| Utility function | `src/utils/` |
| Route config | `src/router/` |
| Unit test | `src/<path>/__tests__/` |
| E2E test | `playwright/tests/` |
| UI library components | `@shipitsmarter/viya-ui-warehouse` |
| Storybook | https://storybook.viyatest.it/ |

---

## Common search patterns

### Find component by name

```bash
# Find a component file
npx glob "src/**/*ShipmentList*.vue"

# Find where a component is used
npx grep "ShipmentList" --include "*.vue"
```

### Find API type usage

```bash
# Find all files using a generated type
npx grep "from '@/generated/shipping'" --include "*.ts"
```

### Find store usage

```bash
# Find where a store is used
npx grep "useUserStore" --include "*.vue"
```

### Find route definitions

```bash
# Find route configuration
npx grep "SHIPMENT_DETAIL" --include "*.ts"
```

---

## Key files to know

| File | Purpose |
|------|---------|
| `src/main.ts` | App entry point, plugin setup |
| `src/App.vue` | Root component |
| `src/router/routes.ts` | All route name constants |
| `src/services/clients/index.ts` | API client configuration |
| `vite.config.ts` | Build configuration |
| `tsconfig.json` | TypeScript configuration |
| `.github/copilot-instructions.md` | Coding conventions |

---

## Import aliases

The project uses path aliases configured in `tsconfig.json`:

| Alias | Resolves to |
|-------|-------------|
| `@/` | `src/` |

**Always use `@/` prefix:**
```typescript
// ✅ Correct
import { useUserStore } from '@/store/user';

// ❌ Wrong - no relative paths
import { useUserStore } from '../../store/user';
```

---

## Feature development workflow

When adding a new feature:

1. **Plan** - Create plan document in `agents/plans/`
2. **Types** - Check/generate types in `src/generated/`
3. **Service** - Add API service in `src/services/`
4. **Store** - Add store if needed in `src/store/`
5. **Components** - Create components in `src/components/<feature>/`
6. **View** - Create page in `src/views/<domain>/`
7. **Route** - Add route in `src/router/<domain>.ts`
8. **Tests** - Add unit tests in `__tests__/`, E2E in `playwright/`

---

## Related skills

| Skill | When to Use |
|-------|-------------|
| **vue-component** | Creating new components |
| **api-integration** | Working with services and API types |
| **unit-testing** | Writing tests |
| **playwright-test** | Writing E2E tests |
