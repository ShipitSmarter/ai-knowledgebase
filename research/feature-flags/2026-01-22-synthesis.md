---
topic: Feature Flags & Rollout Strategies - Synthesis
date: 2026-01-22
project: feature-flags
status: final
sources_count: 35
tags: [synthesis, feature-flags, rollout, posthog, vue, intercom, page-migration]
---

# Feature Flags & Rollout Strategies - Synthesis

## Executive Summary

This synthesis consolidates research across 8 subtopics to provide a complete implementation guide for rolling out a new unified page that replaces two existing pages, with user opt-in/opt-out capabilities using PostHog, Vue, and Intercom.

**The Core Architecture:**
```
┌─────────────────────────────────────────────────────────────────────┐
│                    RECOMMENDED IMPLEMENTATION                        │
├─────────────────────────────────────────────────────────────────────┤
│  PostHog Early Access Feature Management                             │
│  └─ Handles opt-in/opt-out state (overrides percentage rollout)     │
│                                                                      │
│  Vue Router Navigation Guards                                        │
│  └─ Redirects based on feature flag + PageResolver wrapper          │
│                                                                      │
│  Intercom Custom Attributes                                          │
│  └─ Synced from PostHog for targeted messaging                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Key Insight:** PostHog's opt-in/opt-out **overrides** percentage rollout rules. This means you can run both strategies simultaneously:
- Power users opt-in immediately
- Regular users gradually rolled in via percentage
- Anyone can opt-out at any time

---

## 1. The Rollout Strategy

### Recommended 5-Phase Approach

| Phase | Duration | Audience | Key Actions |
|-------|----------|----------|-------------|
| **1. Internal** | 1-3 days | Team only | QA, fix bugs, set up monitoring |
| **2. Beta Opt-in** | 1-2 weeks | Self-selected users | Launch Early Access, Intercom banner |
| **3. Gradual Rollout** | 2-4 weeks | 5% → 25% → 50% → 100% | Monitor metrics, keep opt-out |
| **4. Default New** | 2-4 weeks | Everyone (opt-out available) | Deprecation notices |
| **5. Cleanup** | 1-2 weeks | Everyone | Remove flag, redirect URLs |

### Progression Gates

**Never advance to the next phase unless:**
- Error rate: < baseline + 1%
- P95 latency: < baseline + 10%  
- Task completion: > baseline - 5%
- Opt-out rate: < 10% of users who tried it
- Minimum 24-72 hours at current phase

---

## 2. PostHog Implementation

### Setting Up Early Access Feature

1. **Create the feature** in PostHog → Early Access Management
   - Name: "Unified Logistics Page"
   - Stage: "Beta"
   - PostHog auto-creates linked feature flag

2. **Key APIs in Vue:**

```vue
<script setup>
import posthog from 'posthog-js'
import { ref, onMounted } from 'vue'

const isNewPageEnabled = ref(false)

onMounted(() => {
  isNewPageEnabled.value = posthog.isFeatureEnabled('unified-logistics-page')
})

// User opts in
function optIn() {
  posthog.updateEarlyAccessFeatureEnrollment('unified-logistics-page', true)
  isNewPageEnabled.value = true
}

// User opts out  
function optOut() {
  posthog.updateEarlyAccessFeatureEnrollment('unified-logistics-page', false)
  isNewPageEnabled.value = false
}
</script>
```

### Flag Evaluation Priority

```
1. User explicitly opted IN  → flag = true  (ignores percentage)
2. User explicitly opted OUT → flag = false (ignores percentage)
3. No explicit choice        → evaluate release conditions (percentage, cohort)
```

### Avoiding Flicker (Bootstrapping)

For SSR apps, fetch flags server-side and inject:

```javascript
// Server-side
const flags = await posthogNode.getAllFlags(distinctId)

// Inject into HTML
const bootstrap = { distinctID, featureFlags: flags }

// Client-side init
posthog.init(key, { bootstrap })
```

---

## 3. Vue Routing Architecture

### Recommended: Navigation Guard + Route Aliases

```typescript
// router/index.ts
const routes = [
  // Keep old routes for backwards compatibility
  {
    path: '/shipments',
    name: 'shipments-legacy',
    component: () => import('@/pages/ShipmentsPage.vue'),
    meta: { legacyPage: true }
  },
  {
    path: '/parcels',
    name: 'parcels-legacy', 
    component: () => import('@/pages/ParcelsPage.vue'),
    meta: { legacyPage: true }
  },
  // New unified page with aliases
  {
    path: '/logistics',
    name: 'logistics',
    component: () => import('@/pages/LogisticsPage.vue'),
    alias: ['/shipments', '/parcels'], // Preserves bookmarks!
    meta: { newPage: true }
  }
]

router.beforeEach(async (to) => {
  const useNewPage = posthog.isFeatureEnabled('unified-logistics-page')
  
  // Redirect legacy → new if flag enabled
  if (to.meta.legacyPage && useNewPage) {
    return { name: 'logistics', query: to.query }
  }
  
  // Redirect new → legacy if flag disabled
  if (to.meta.newPage && !useNewPage) {
    return { name: 'shipments-legacy', query: to.query }
  }
})
```

### Why Route Aliases?

- **Bookmarks work**: `/shipments` bookmark still works after migration
- **No flash redirect**: URL stays the same in browser
- **Deep links preserved**: Query params carry over

---

## 4. Opt-in/Opt-out UX Patterns

### What Works

| Pattern | Use For | Example |
|---------|---------|---------|
| **Dismissible banner** | Initial awareness | "Try our new unified page" at top of old pages |
| **Settings toggle** | Persistent control | "Beta Features" section in user preferences |
| **Page header link** | Easy reversion | "Switch back to classic" on new page |

### What to Avoid

- **Modal popups** for opt-in (interrupts workflow)
- **Confirmation dialogs** for opt-out (adds friction)
- **Hidden opt-out** (users must always be able to revert)

### Sample Banner Component

```vue
<template>
  <div v-if="!dismissed && !isOptedIn" class="beta-banner">
    <span>Try our new unified logistics page</span>
    <button @click="optIn">Try it now</button>
    <button @click="dismiss">Not now</button>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import posthog from 'posthog-js'

const dismissed = ref(localStorage.getItem('beta-banner-dismissed') === 'true')
const isOptedIn = ref(posthog.isFeatureEnabled('unified-logistics-page'))

function optIn() {
  posthog.updateEarlyAccessFeatureEnrollment('unified-logistics-page', true)
  window.location.href = '/logistics'
}

function dismiss() {
  localStorage.setItem('beta-banner-dismissed', 'true')
  dismissed.value = true
}
</script>
```

---

## 5. Intercom Communication

### Sync Strategy

Sync PostHog state to Intercom custom attributes:

```javascript
function optIntoBeta() {
  // PostHog
  posthog.updateEarlyAccessFeatureEnrollment('unified-logistics-page', true)
  posthog.setPersonProperties({ beta_new_page: true })
  
  // Intercom
  Intercom('update', { beta_new_page: true })
  Intercom('trackEvent', 'beta-opted-in', { feature: 'unified-page' })
}
```

### Message Timeline

| Phase | Audience | Message Type |
|-------|----------|--------------|
| Beta launch | `beta_new_page` is unknown | "Try our new page" banner |
| Just opted in | `beta-opted-in` event | Welcome + Product Tour |
| After 7 days | `beta_new_page = true` | Feedback request |
| 2 weeks before sunset | `beta_new_page = false` | "Classic retiring soon" |
| 1 week before | `beta_new_page = false` | Urgent migration notice |
| Final days | `beta_new_page = false` | "Action required" |

---

## 6. Monitoring & Rollback

### Dashboard Setup

Create a "Rollout Monitoring" dashboard in PostHog:

1. **Error Rate Comparison** - Trends, breakdown by flag variant
2. **Page Load Performance** - P50, P95, P99
3. **Conversion Funnel** - Key actions, breakdown by variant
4. **Session Replays** - Link to flag=ON + error events

### Rollback Decision Matrix

| Metric | Green | Yellow | Red (Roll Back) |
|--------|-------|--------|-----------------|
| Error rate | < 1% | 1-2% | > 2% or 2x baseline |
| P95 latency | < 300ms | 300-500ms | > 500ms |
| Conversion | > baseline | -5% to -10% | < -10% |
| Support tickets | Normal | 1.5x | 2x+ |

### Instant Rollback

```
PostHog → Feature Flags → [your flag] → Toggle OFF
```

Takes effect in ~30 seconds. No deployment needed.

---

## 7. Flag Cleanup

### When to Remove (1-4 weeks after 100% rollout)

**Readiness signals:**
- [ ] Metrics stable for 2+ weeks
- [ ] No support tickets related to new page
- [ ] Product sign-off received
- [ ] Old page analytics show zero traffic

### Cleanup Steps

1. **Remove flag checks** from code (keep only new page path)
2. **Delete old page components**
3. **Set up 301 redirects** for old URLs
4. **Archive flag** in PostHog (don't delete - audit trail)
5. **Remove Intercom segments** for old page users

### URL Redirect Strategy

```typescript
// After cleanup - permanent redirects
const routes = [
  {
    path: '/shipments',
    redirect: '/logistics'
  },
  {
    path: '/parcels', 
    redirect: '/logistics'
  },
  {
    path: '/logistics',
    component: LogisticsPage
  }
]
```

---

## 8. High-Confidence Findings

These findings are supported by multiple authoritative sources:

| Finding | Confidence | Sources |
|---------|------------|---------|
| Opt-in overrides percentage rollout | High | PostHog docs, confirmed behavior |
| Use banners not modals for opt-in | High | NN/g research, PostHog tutorials |
| Feature flags enable <1 min rollback | High | All vendors agree |
| Consistent hashing ensures sticky experience | High | PostHog, Unleash, LaunchDarkly |
| Clean up flags within 1-4 weeks | High | Unleash, Martin Fowler |
| Use route aliases to preserve bookmarks | High | Vue Router docs |
| Monitor delta between cohorts, not absolutes | High | Microsoft, PostHog |

---

## 9. Open Questions & Gaps

These areas need further investigation or custom implementation:

| Question | Status |
|----------|--------|
| Native PostHog-Intercom integration | None found - manual sync required |
| Automated rollback on metric thresholds | Not built into PostHog - custom needed |
| SSR/Nuxt-specific bootstrapping | React examples available, Vue needs adaptation |
| SEO implications of route aliases | Likely fine, but not explicitly documented |
| A/B testing during opt-in period | Possible but complex (self-selection bias) |

---

## 10. Implementation Checklist

### Week 1: Setup

- [ ] Create feature flag `unified-logistics-page` in PostHog
- [ ] Create Early Access Feature linked to flag
- [ ] Set up Vue Router with navigation guards
- [ ] Build PageResolver wrapper component
- [ ] Create beta opt-in banner component
- [ ] Add "Switch back to classic" link on new page
- [ ] Create PostHog dashboard for monitoring

### Week 2: Internal Testing

- [ ] Enable flag for team emails (`@yourcompany.com`)
- [ ] QA all flows on new page
- [ ] Test opt-in/opt-out cycle
- [ ] Verify bookmarks and deep links work
- [ ] Test data migration between old and new pages

### Week 3-4: Beta Launch

- [ ] Enable Early Access opt-in
- [ ] Launch Intercom banner for beta invitation
- [ ] Set up Intercom-PostHog sync
- [ ] Monitor dashboard daily
- [ ] Review session replays weekly
- [ ] Collect feedback via Intercom

### Week 5-8: Gradual Rollout

- [ ] Expand to 5%, wait 48 hours
- [ ] Expand to 25%, wait 48 hours
- [ ] Expand to 50%, wait 72 hours
- [ ] Expand to 100%, keep opt-out available
- [ ] Send deprecation notices via Intercom

### Week 9-10: Cleanup

- [ ] Remove old page components
- [ ] Remove feature flag code
- [ ] Set up permanent redirects
- [ ] Archive flag in PostHog
- [ ] Update documentation

---

## Source Summary

| Category | Count | Key Sources |
|----------|-------|-------------|
| PostHog Documentation | 12 | Feature flags, Early Access, Session Replay |
| Authoritative Articles | 3 | Martin Fowler (Feature Toggles, Strangler Fig) |
| Vendor Best Practices | 8 | Unleash, Microsoft Safe Deployment |
| Vue Ecosystem | 5 | Vue Router, Composition API patterns |
| UX Research | 4 | NN/g (progressive disclosure, modals) |
| Intercom Documentation | 6 | Banners, Events, Custom Attributes |

---

*Research completed: 2026-01-22*  
*Documents: 9 files in research/feature-flags/*
