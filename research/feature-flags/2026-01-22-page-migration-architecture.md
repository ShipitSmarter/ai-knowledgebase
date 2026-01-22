---
topic: Page Migration Architecture with Feature Flags in Vue
date: 2026-01-22
project: feature-flags
sources_count: 7
status: reviewed
tags: [vue, vue-router, feature-flags, migration, strangler-fig, page-replacement]
---

# Page Migration Architecture with Feature Flags in Vue

## Summary

When replacing two Vue pages with a unified new page, you need a routing strategy that supports gradual migration while maintaining bookmarks, deep links, and user preferences. The recommended approach combines Vue Router's navigation guards with feature flags, using route aliases to preserve old URLs and a PageResolver wrapper component to abstract the old/new decision from route definitions.

The Strangler Fig pattern (Martin Fowler) provides the conceptual foundation: gradually route traffic from legacy to new components until the legacy can be removed. In Vue, this translates to building transitional architecture that allows both old and new pages to coexist, with feature flags controlling which version users see.

Key architectural insight: Keep routing simple by defining all routes statically, then use a wrapper component or navigation guard to resolve which implementation to render. This avoids complex conditional route registration and keeps the flag evaluation in one place.

## Key Findings

1. **Navigation guards over conditional routes**: Use `router.beforeEach()` with feature flag evaluation rather than dynamically adding/removing routes. This is simpler to reason about and avoids race conditions with flag loading.

2. **Route aliases preserve bookmarks**: Vue Router's `alias` feature keeps old URLs working without redirects. Users bookmarking `/page-a` or `/page-b` still reach the content via the new unified route.

3. **PageResolver wrapper pattern**: A single wrapper component that loads the correct implementation based on feature flag avoids code duplication in route definitions and centralizes the switching logic.

4. **Lazy loading both versions**: Use dynamic imports for both old and new page components to avoid bundling both when only one is used per user.

5. **Data layer abstraction**: Create a shared composable that abstracts data fetching differences, so both old and new pages can use the same data interface during transition.

6. **Settings migration requires explicit handling**: User preferences stored for old pages need migration logic - either on-read transformation or a one-time migration job.

7. **Transitional architecture is expected**: Building temporary code (redirects, wrappers, data adapters) that will be removed after migration is a feature, not technical debt - it reduces risk and enables gradual rollout.

## Detailed Analysis

### 1. Routing Strategies for Feature-Flagged Pages

There are three main approaches to structuring Vue routes during a page migration:

#### Approach A: Navigation Guard Redirect (Recommended)

Use static route definitions with a global navigation guard that evaluates the feature flag and redirects:

```typescript
// router/index.ts
import { createRouter, createWebHistory } from 'vue-router'
import { useFeatureFlags } from '@/composables/useFeatureFlags'

const routes = [
  // Old pages - keep for backwards compatibility
  {
    path: '/shipments',
    name: 'shipments-legacy',
    component: () => import('@/pages/ShipmentsPage.vue'),
    meta: { legacyPage: true, unifiedRoute: 'shipments-unified' }
  },
  {
    path: '/parcels', 
    name: 'parcels-legacy',
    component: () => import('@/pages/ParcelsPage.vue'),
    meta: { legacyPage: true, unifiedRoute: 'shipments-unified' }
  },
  // New unified page
  {
    path: '/logistics',
    name: 'shipments-unified',
    component: () => import('@/pages/LogisticsPage.vue'),
    alias: ['/shipments', '/parcels'], // Keep old URLs working
    meta: { newPage: true }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach(async (to, from) => {
  const { isEnabled } = useFeatureFlags()
  
  // If navigating to a legacy page and flag is enabled, redirect to new
  if (to.meta.legacyPage && await isEnabled('unified-logistics-page')) {
    return { name: to.meta.unifiedRoute, query: to.query, hash: to.hash }
  }
  
  // If navigating to new page and flag is disabled, redirect to legacy
  if (to.meta.newPage && !await isEnabled('unified-logistics-page')) {
    return { name: 'shipments-legacy', query: to.query, hash: to.hash }
  }
})
```

**Pros**: Simple, all routes defined statically, flag evaluated once per navigation  
**Cons**: Slight delay on first navigation while flag loads

#### Approach B: Dynamic Route Registration

Add/remove routes based on feature flag state:

```typescript
// router/featureFlagRoutes.ts
export function setupFeatureFlaggedRoutes(router: Router, flags: FeatureFlags) {
  if (flags.isEnabled('unified-logistics-page')) {
    router.addRoute({
      path: '/logistics',
      name: 'logistics',
      component: () => import('@/pages/LogisticsPage.vue'),
      alias: ['/shipments', '/parcels']
    })
    // Remove legacy routes
    router.removeRoute('shipments-legacy')
    router.removeRoute('parcels-legacy')
  }
}
```

**Pros**: Clean route table, no runtime redirects  
**Cons**: Complex, race conditions if flags load async, harder to debug

#### Approach C: Wrapper Component Pattern (Best for Complex Cases)

Define a single route with a wrapper that resolves the component:

```typescript
// router/index.ts
{
  path: '/logistics',
  name: 'logistics',
  component: () => import('@/pages/LogisticsPageResolver.vue'),
  alias: ['/shipments', '/parcels'],
  props: route => ({ 
    originalPath: route.path,
    params: route.params,
    query: route.query 
  })
}
```

```vue
<!-- pages/LogisticsPageResolver.vue -->
<script setup lang="ts">
import { computed, defineAsyncComponent } from 'vue'
import { useFeatureFlag } from '@/composables/useFeatureFlag'

const props = defineProps<{
  originalPath: string
  params: Record<string, string>
  query: Record<string, string>
}>()

const { isEnabled, isLoading } = useFeatureFlag('unified-logistics-page')

// Determine which legacy page this would have been
const legacyComponent = computed(() => {
  if (props.originalPath.startsWith('/shipments')) {
    return defineAsyncComponent(() => import('./ShipmentsPage.vue'))
  }
  return defineAsyncComponent(() => import('./ParcelsPage.vue'))
})

const newComponent = defineAsyncComponent(() => import('./LogisticsPage.vue'))

const activeComponent = computed(() => 
  isEnabled.value ? newComponent : legacyComponent.value
)
</script>

<template>
  <Suspense>
    <component :is="activeComponent" v-bind="props" />
    <template #fallback>
      <LoadingSpinner />
    </template>
  </Suspense>
</template>
```

**Pros**: Most flexible, handles async flag loading gracefully, single source of truth  
**Cons**: Extra wrapper component, slightly more complex

### 2. Handling Bookmarks and Deep Links

Vue Router aliases are the key to preserving old URLs:

```typescript
{
  path: '/logistics',
  component: LogisticsPage,
  alias: ['/shipments', '/parcels', '/shipments/:id', '/parcels/:id']
}
```

With aliases:
- URL stays as-is in browser (no redirect flash)
- Bookmarks continue working
- `router.currentRoute.path` shows the actual URL the user visited
- Use `route.matched[0].path` to get the canonical path

For deep links with parameters:

```typescript
{
  path: '/logistics/:type/:id',
  component: LogisticsPage,
  alias: ['/shipments/:id', '/parcels/:id'],
  props: route => ({
    // Normalize params from different URL structures
    type: route.params.type || (route.path.includes('shipments') ? 'shipment' : 'parcel'),
    id: route.params.id
  })
}
```

### 3. Migrating User Settings and Preferences

User preferences from old pages need explicit migration. Three strategies:

#### Strategy A: On-Read Transformation (Recommended)

Transform legacy settings when reading, store in new format when writing:

```typescript
// composables/useUserPreferences.ts
interface LegacyShipmentPrefs {
  sortColumn: string
  sortDirection: 'asc' | 'desc'
  pageSize: number
}

interface UnifiedLogisticsPrefs {
  defaultView: 'list' | 'grid'
  sorting: { field: string; order: 'asc' | 'desc' }
  pagination: { size: number }
  columns: string[]
}

export function useLogisticsPreferences() {
  const { get, set } = useUserSettings()
  
  const preferences = computed<UnifiedLogisticsPrefs>(() => {
    // Try new format first
    const newPrefs = get<UnifiedLogisticsPrefs>('logistics.preferences')
    if (newPrefs) return newPrefs
    
    // Fall back to legacy migration
    const shipmentPrefs = get<LegacyShipmentPrefs>('shipments.preferences')
    const parcelPrefs = get<LegacyShipmentPrefs>('parcels.preferences')
    
    return migrateLegacyPrefs(shipmentPrefs, parcelPrefs)
  })
  
  function savePreferences(prefs: UnifiedLogisticsPrefs) {
    // Always save in new format
    set('logistics.preferences', prefs)
  }
  
  return { preferences, savePreferences }
}

function migrateLegacyPrefs(
  shipment?: LegacyShipmentPrefs, 
  parcel?: LegacyShipmentPrefs
): UnifiedLogisticsPrefs {
  const source = shipment || parcel || {}
  return {
    defaultView: 'list',
    sorting: { 
      field: source.sortColumn || 'createdAt', 
      order: source.sortDirection || 'desc' 
    },
    pagination: { size: source.pageSize || 25 },
    columns: ['id', 'status', 'destination', 'createdAt']
  }
}
```

#### Strategy B: Database Migration Job

For server-stored preferences, run a one-time migration:

```typescript
// One-time migration script
async function migrateUserPreferences() {
  const users = await db.users.find({ 'preferences.shipments': { $exists: true } })
  
  for (const user of users) {
    const unified = migrateLegacyPrefs(
      user.preferences.shipments,
      user.preferences.parcels
    )
    await db.users.updateOne(
      { _id: user._id },
      { 
        $set: { 'preferences.logistics': unified },
        $unset: { 'preferences.shipments': '', 'preferences.parcels': '' }
      }
    )
  }
}
```

#### Strategy C: Dual-Write During Transition

Write to both old and new format during transition period:

```typescript
function savePreferences(prefs: UnifiedLogisticsPrefs) {
  // New format
  set('logistics.preferences', prefs)
  
  // Legacy format for users who might switch back
  if (featureFlags.isEnabled('unified-logistics-page-opt-out-allowed')) {
    set('shipments.preferences', convertToLegacy(prefs, 'shipment'))
    set('parcels.preferences', convertToLegacy(prefs, 'parcel'))
  }
}
```

### 4. Avoiding Code Duplication

The key to avoiding duplication is extracting shared logic into composables:

```typescript
// composables/useLogisticsData.ts
export function useLogisticsData(type: Ref<'shipment' | 'parcel' | 'all'>) {
  const { data, isLoading, error, refetch } = useQuery({
    queryKey: ['logistics', type],
    queryFn: () => fetchLogistics(type.value)
  })
  
  // Shared filtering, sorting, pagination logic
  const filters = ref<LogisticsFilters>({})
  const sorting = ref<SortConfig>({ field: 'createdAt', order: 'desc' })
  
  const filteredData = computed(() => 
    applyFilters(data.value, filters.value)
  )
  
  return { data: filteredData, isLoading, error, filters, sorting, refetch }
}
```

Both old and new pages can use this:

```vue
<!-- Old ShipmentsPage.vue -->
<script setup>
const { data, isLoading } = useLogisticsData(ref('shipment'))
</script>

<!-- New LogisticsPage.vue -->
<script setup>
const typeFilter = ref<'shipment' | 'parcel' | 'all'>('all')
const { data, isLoading } = useLogisticsData(typeFilter)
</script>
```

### 5. Data Fetching Differences

When old and new pages have different API requirements, create an adapter layer:

```typescript
// api/logistics.ts
interface LogisticsItem {
  id: string
  type: 'shipment' | 'parcel'
  status: string
  // ... normalized fields
}

// Adapter that works with both old and new APIs
export async function fetchLogistics(
  type: 'shipment' | 'parcel' | 'all'
): Promise<LogisticsItem[]> {
  if (type === 'all') {
    // New unified API
    return api.get('/api/v2/logistics')
  }
  
  // Legacy APIs with transformation
  const endpoint = type === 'shipment' ? '/api/shipments' : '/api/parcels'
  const data = await api.get(endpoint)
  
  return data.map(item => normalizeToLogisticsItem(item, type))
}

function normalizeToLogisticsItem(raw: any, type: string): LogisticsItem {
  return {
    id: raw.id,
    type: type as 'shipment' | 'parcel',
    status: raw.status || raw.shipmentStatus || raw.parcelStatus,
    // ... map other fields
  }
}
```

### 6. Lazy Loading Both Versions

Always lazy-load both old and new components to avoid bundling unused code:

```typescript
// Never do this - bundles both
import OldPage from './OldPage.vue'
import NewPage from './NewPage.vue'

// Do this instead
const OldPage = defineAsyncComponent(() => import('./OldPage.vue'))
const NewPage = defineAsyncComponent(() => import('./NewPage.vue'))

// Or in router
{
  path: '/page',
  component: () => featureFlags.isEnabled('new-page') 
    ? import('./NewPage.vue') 
    : import('./OldPage.vue')
}
```

With Vite, you can group related chunks:

```typescript
// vite.config.ts
export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          'logistics-legacy': ['./src/pages/ShipmentsPage.vue', './src/pages/ParcelsPage.vue'],
          'logistics-new': ['./src/pages/LogisticsPage.vue']
        }
      }
    }
  }
})
```

### 7. Transition Period Timeline

Based on the Strangler Fig pattern, plan these phases:

```
Phase 1: Shadow Mode (1-2 weeks)
├── New page exists but hidden behind flag
├── Only internal team has access
└── Validate functionality, fix bugs

Phase 2: Opt-in Beta (2-4 weeks)  
├── Users can opt-in via settings or banner
├── Easy opt-out always available
├── Collect feedback, iterate
└── Monitor error rates, performance

Phase 3: Gradual Rollout (2-4 weeks)
├── 10% → 25% → 50% → 100% of users
├── Opt-out still available
├── Old URLs redirect to new page
└── Monitor business metrics

Phase 4: Default New (2-4 weeks)
├── New page is default for everyone
├── Legacy pages still accessible via explicit toggle
├── Announce deprecation timeline
└── Help stragglers migrate

Phase 5: Cleanup (1-2 weeks)
├── Remove legacy pages
├── Remove feature flag code
├── Remove transitional components
└── Old URLs permanently redirect
```

## Sources

| Source | URL | Key Contribution |
|--------|-----|------------------|
| Vue Router - Navigation Guards | https://router.vuejs.org/guide/advanced/navigation-guards.html | beforeEach pattern, guard flow, async guards |
| Vue Router - Redirect and Alias | https://router.vuejs.org/guide/essentials/redirect-and-alias.html | Alias syntax for URL preservation |
| Vue Router - Dynamic Routing | https://router.vuejs.org/guide/advanced/dynamic-routing.html | addRoute/removeRoute patterns |
| Vue Router - Route Meta Fields | https://router.vuejs.org/guide/advanced/meta.html | Typing meta, accessing in guards |
| Vue Router - Lazy Loading | https://router.vuejs.org/guide/advanced/lazy-loading.html | Dynamic imports, chunk grouping |
| Martin Fowler - Strangler Fig | https://martinfowler.com/bliki/StranglerFigApplication.html | Gradual replacement philosophy |
| Fowler et al - Transitional Architecture | https://martinfowler.com/articles/patterns-legacy-displacement/transitional-architecture.html | Building disposable integration code |

## Questions for Further Research

- [ ] How to handle analytics tracking during transition (track separately or unified)?
- [ ] Best practices for A/B testing page variants vs feature flag rollout
- [ ] How to handle SEO implications of route aliases vs redirects
- [ ] Server-side rendering considerations for feature-flagged pages
- [ ] Testing strategies for pages with multiple implementation versions
