---
topic: PostHog-Specific Implementation for Feature Flags
date: 2026-01-22
project: feature-flags
sources_count: 8
status: draft
tags: [posthog, feature-flags, vue, early-access, bootstrapping, cohorts]
---

# PostHog-Specific Implementation for Feature Flags

## Summary

PostHog provides a comprehensive feature flag system with a unique "Early Access Feature Management" capability that's directly relevant for page migration with user opt-in/opt-out. The JavaScript SDK (`posthog-js`) works well with Vue 3 via the Composition API pattern. Key APIs include `getEarlyAccessFeatures()` for fetching available betas and `updateEarlyAccessFeatureEnrollment()` for toggling user participation.

Bootstrapping flags is possible but requires server-side rendering to inject flag values into the page before client-side JavaScript loads - this prevents the "flicker" problem where users briefly see the wrong version. PostHog also supports cohorts for targeting specific user segments, percentage-based rollouts, and automatic analytics when flags are evaluated.

## Key Findings

1. **Early Access Management is purpose-built for opt-in betas** - PostHog automatically creates linked feature flags and provides APIs for user self-enrollment
2. **Vue 3 integration uses Composition API** - Create a `usePostHog` composable to access `posthog` instance throughout the app
3. **Bootstrapping requires SSR** - Must fetch flags server-side and inject into HTML to avoid flicker; not compatible with persistence flags
4. **Opt-in overrides release conditions** - User enrollment takes precedence over percentage rollouts, enabling both to coexist
5. **Cohorts enable targeted rollouts** - But dynamic cohorts with behavioral criteria cannot be used as feature flag targets (must duplicate to static)
6. **Automatic usage dashboards** - PostHog can create dashboards tracking flag evaluations when you create a flag

## Detailed Analysis

### Early Access Feature Management

Early Access Management allows users to opt in (and out) of betas and in-progress features. This is PostHog's recommended approach for public beta programs.

**Feature Stages:**
- **Concept**: Not yet available for testing - shows in "Coming Soon" tab, users can register interest
- **Beta**: Available for testing - users can opt in to try it out  
- **Alpha** / **General Availability**: More granular lifecycle management

**Key behaviors:**
- Feature flags are automatically created when an early access feature is created
- User opt-in/opt-out **overrides** any existing release conditions on the flag
- Only when a user has NOT explicitly opted in/out will release conditions be evaluated

```
┌─────────────────────────────────────────────────────────┐
│           FLAG EVALUATION PRIORITY                       │
├─────────────────────────────────────────────────────────┤
│ 1. User explicitly opted IN  → flag = true              │
│ 2. User explicitly opted OUT → flag = false             │
│ 3. No explicit choice        → evaluate release rules   │
│    (percentage, cohort, etc.)                           │
└─────────────────────────────────────────────────────────┘
```

### API Reference

#### getEarlyAccessFeatures

Fetches available early access features for the current user.

```typescript
posthog.getEarlyAccessFeatures(
  callback: (features: EarlyAccessFeature[]) => void,
  force_reload?: boolean,  // bypass cache, fetch from server
  stages?: string[]        // e.g., ['concept', 'beta']
)

interface EarlyAccessFeature {
  id: string
  name: string
  description: string
  documentationUrl?: string
  flagKey: string
  stage: 'concept' | 'beta' | 'alpha' | 'general-availability'
}
```

**Important**: Features are cached per browser load. Use `force_reload: true` to get the latest values (at cost of network request delay).

#### updateEarlyAccessFeatureEnrollment

Opts a user in or out of an early access feature.

```typescript
posthog.updateEarlyAccessFeatureEnrollment(
  flagKey: string,  // the feature flag key
  isEnrolled: boolean  // true = opt in, false = opt out
)
```

#### Other useful APIs

```typescript
// Check if flag is enabled for current user
posthog.isFeatureEnabled('flag-key')

// Get flag value (for multivariate flags)
posthog.getFeatureFlag('flag-key')

// Get flag payload (additional JSON data)
posthog.getFeatureFlagPayload('flag-key')

// React hook for active flags
import { useActiveFeatureFlags } from '@posthog/react'
const activeFlags = useActiveFeatureFlags() // string[]
```

### Vue 3 Integration

PostHog recommends the Composition API pattern for Vue 3:

```typescript
// src/composables/usePostHog.ts
import posthog from 'posthog-js'

export function usePostHog() {
  posthog.init('<ph_project_api_key>', {
    api_host: 'https://us.i.posthog.com',
    defaults: '2025-11-30',
    opt_in_site_apps: true  // enable early access modal site app
  })
  return { posthog }
}
```

```typescript
// src/router/index.ts
import { usePostHog } from '@/composables/usePostHog'

const router = createRouter({ ... })
const { posthog } = usePostHog()

export default router
```

**Using in components:**

```vue
<script setup>
import { usePostHog } from '@/composables/usePostHog'
import { ref, onMounted } from 'vue'

const { posthog } = usePostHog()
const isNewPageEnabled = ref(false)

onMounted(() => {
  isNewPageEnabled.value = posthog.isFeatureEnabled('new-unified-page')
})

const toggleBeta = (enable: boolean) => {
  posthog.updateEarlyAccessFeatureEnrollment('new-unified-page', enable)
  isNewPageEnabled.value = enable
}
</script>
```

### Bootstrapping (Avoiding Flicker)

**The problem**: On first page load, `isFeatureEnabled()` returns `undefined` until flags are fetched from PostHog's servers. This causes "flicker" where users briefly see the wrong version.

**The solution**: Bootstrap flags by fetching them server-side and injecting into the HTML.

```typescript
// Server-side (e.g., Express/Nuxt server middleware)
import { PostHog } from 'posthog-node'

const client = new PostHog(
  process.env.POSTHOG_KEY,
  { 
    host: process.env.POSTHOG_HOST,
    personalApiKey: process.env.POSTHOG_PERSONAL_API_KEY
  }
)

// Get user's distinct ID from cookie/session
const distinctId = getUserDistinctId(req)

// Fetch all flags for this user
const flags = await client.getAllFlags(distinctId)

// Inject into HTML
const scriptTag = `<script>
  window.__FLAG_DATA__ = ${JSON.stringify(flags)};
  window.__PH_DISTINCT_ID__ = ${JSON.stringify(distinctId)};
</script>`
```

```typescript
// Client-side initialization
import posthog from 'posthog-js'

posthog.init('<ph_project_api_key>', {
  api_host: 'https://us.i.posthog.com',
  bootstrap: {
    distinctID: window.__PH_DISTINCT_ID__,
    featureFlags: window.__FLAG_DATA__,
  }
})
```

**Limitations:**
- Requires server-side rendering capability
- Not compatible with "persist feature flags across authentication" option
- Requires a PostHog Personal API Key (with "Local feature flag evaluation" scope)

### Release Conditions for Phased Rollout

Feature flags support multiple condition sets evaluated top-to-bottom:

```
┌─────────────────────────────────────────────────────────┐
│              RELEASE CONDITION EVALUATION               │
├─────────────────────────────────────────────────────────┤
│ Condition Set 1: Internal team                          │
│   - email contains "@yourcompany.com"                   │
│   - rollout: 100%                                       │
│   → If MATCHES, return flag value                       │
├─────────────────────────────────────────────────────────┤
│ Condition Set 2: Beta testers cohort                    │
│   - person is in cohort "beta-testers"                  │
│   - rollout: 100%                                       │
│   → If MATCHES, return flag value                       │
├─────────────────────────────────────────────────────────┤
│ Condition Set 3: Gradual rollout                        │
│   - all users                                           │
│   - rollout: 25%                                        │
│   → If MATCHES, return flag value                       │
├─────────────────────────────────────────────────────────┤
│ No match → return false/undefined                       │
└─────────────────────────────────────────────────────────┘
```

**Available targeting options:**
- Percentage rollout (all flags)
- Geographic location (if GeoIP enabled)
- Person properties (if capturing identified events)
- Cohorts (if capturing identified events)
- Group properties (if group analytics enabled)

### Cohorts for User Targeting

Cohorts are lists of users with something in common. Use them to target specific user segments for feature flags.

**Creating cohorts:**
1. From insights - click data point → "Save as cohort"
2. From Cohorts page - define criteria

**Types:**
- **Static cohorts**: Fixed list, doesn't change (upload CSV or duplicate dynamic)
- **Dynamic cohorts**: Auto-updated based on criteria (events, properties, lifecycle)

**Limitation for feature flags:**
> Dynamic cohorts with behavioral or lifecycle criteria CANNOT be used as feature flag targets. Must duplicate to static cohort first.

Only dynamic cohorts with **person property criteria** can be used directly.

### Tracking Adoption Metrics

PostHog automatically tracks feature flag evaluations. When creating a flag, enable "Create usage dashboard" to get:

- Call volume trends (how often flag is evaluated)
- Variant distribution (for multivariate flags)
- Who has the flag enabled

**Custom tracking for opt-in:**

```typescript
// Track when user opts into beta
posthog.capture('beta_opted_in', { 
  feature: 'new-unified-page',
  source: 'settings_modal'  // or 'intercom_banner', etc.
})

// Track when user opts out
posthog.capture('beta_opted_out', {
  feature: 'new-unified-page',
  reason: userSelectedReason  // optional feedback
})
```

**Calculating conversion rates:**

Create a funnel insight:
1. Step 1: `beta_opted_in` where feature = 'new-unified-page'
2. Step 2: Key action in new page (e.g., completed task, saved form)

This shows what percentage of beta opt-ins actually use the new feature.

### Site App: Early Access Modal

PostHog provides a pre-built modal for user opt-in. To use:

1. Enable `opt_in_site_apps: true` in PostHog init config
2. Enable the "Early Access Features App" in PostHog (Pipeline → Browse Apps)
3. Set a selector (e.g., `#beta-button`) or enable "Show features button on page"
4. Add a trigger element: `<button id="beta-button">Beta Features</button>`

The modal shows:
- **Previews** tab: Beta features user can opt into
- **Coming soon** tab: Concept features user can register interest in

### Custom Beta Opt-in Page (Vue Implementation)

For full control, build a custom page:

```vue
<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import { usePostHog } from '@/composables/usePostHog'

const { posthog } = usePostHog()

const activeBetas = ref([])
const inactiveBetas = ref([])
const comingSoon = ref([])

onMounted(() => {
  loadFeatures()
})

function loadFeatures() {
  posthog.getEarlyAccessFeatures((features) => {
    const betas = features.filter(f => f.stage === 'beta')
    const concepts = features.filter(f => f.stage === 'concept')
    
    comingSoon.value = concepts
    
    // Check which betas are active for this user
    const activeFlags = [] // get from posthog if available
    activeBetas.value = betas.filter(b => posthog.isFeatureEnabled(b.flagKey))
    inactiveBetas.value = betas.filter(b => !posthog.isFeatureEnabled(b.flagKey))
  }, true, ['concept', 'beta'])
}

function toggleBeta(flagKey: string) {
  const isActive = activeBetas.value.some(b => b.flagKey === flagKey)
  posthog.updateEarlyAccessFeatureEnrollment(flagKey, !isActive)
  
  // Optimistic UI update
  if (isActive) {
    const beta = activeBetas.value.find(b => b.flagKey === flagKey)
    activeBetas.value = activeBetas.value.filter(b => b.flagKey !== flagKey)
    inactiveBetas.value = [...inactiveBetas.value, beta]
  } else {
    const beta = inactiveBetas.value.find(b => b.flagKey === flagKey)
    inactiveBetas.value = inactiveBetas.value.filter(b => b.flagKey !== flagKey)
    activeBetas.value = [...activeBetas.value, beta]
  }
}

function registerInterest(flagKey: string) {
  posthog.updateEarlyAccessFeatureEnrollment(flagKey, true)
  // Update UI to show registered
}
</script>

<template>
  <div class="beta-features">
    <h1>Beta Features</h1>
    
    <section>
      <h2>Available to Try</h2>
      <div v-for="beta in inactiveBetas" :key="beta.id">
        <h3>{{ beta.name }}</h3>
        <p>{{ beta.description }}</p>
        <button @click="toggleBeta(beta.flagKey)">Enable</button>
      </div>
    </section>
    
    <section>
      <h2>Currently Enabled</h2>
      <div v-for="beta in activeBetas" :key="beta.id">
        <h3>{{ beta.name }}</h3>
        <p>{{ beta.description }}</p>
        <button @click="toggleBeta(beta.flagKey)">Disable</button>
      </div>
    </section>
    
    <section>
      <h2>Coming Soon</h2>
      <div v-for="feature in comingSoon" :key="feature.id">
        <h3>{{ feature.name }}</h3>
        <p>{{ feature.description }}</p>
        <button @click="registerInterest(feature.flagKey)">
          Notify Me
        </button>
      </div>
    </section>
  </div>
</template>
```

## Sources

| Source | Type | Key Contribution |
|--------|------|-----------------|
| [PostHog Early Access Feature Management](https://posthog.com/docs/feature-flags/early-access-feature-management) | Official docs | Core APIs, feature stages, opt-in override behavior |
| [PostHog JavaScript Web SDK](https://posthog.com/docs/libraries/js) | Official docs | Installation, initialization options |
| [PostHog Vue.js Integration](https://posthog.com/docs/libraries/vue-js) | Official docs | Composition API pattern, Vue 3 setup |
| [Bootstrap Feature Flags in React](https://posthog.com/tutorials/bootstrap-feature-flags-react) | Tutorial | SSR bootstrapping pattern (applicable to Vue) |
| [Creating Feature Flags](https://posthog.com/docs/feature-flags/creating-feature-flags) | Official docs | Release conditions, rollout percentages, evaluation |
| [Public Beta Program Tutorial](https://posthog.com/tutorials/public-beta-program) | Tutorial | Complete Next.js implementation example |
| [Cohorts Documentation](https://posthog.com/docs/data/cohorts) | Official docs | Static vs dynamic, feature flag limitations |
| [PostHog Feature Flags Overview](https://posthog.com/docs/feature-flags) | Official docs | Best practices, canary releases, API guides |

## Questions for Further Research

- [ ] How to handle Intercom integration for announcing beta features to specific user segments?
- [ ] What's the recommended approach for cleaning up feature flags after full migration?
- [ ] How to handle deep links/bookmarks to old pages during migration?
- [ ] Can PostHog track engagement differences between old and new page versions automatically?
- [ ] How does Nuxt 3/Vue SSR specifically handle PostHog bootstrapping?

## Implementation Checklist

- [ ] Create Early Access Feature in PostHog with linked flag
- [ ] Set up Vue composable for PostHog
- [ ] Implement feature check in routing/component logic
- [ ] Build beta opt-in UI (modal or dedicated page)
- [ ] Add custom tracking events for opt-in/opt-out
- [ ] Create adoption funnel in PostHog insights
- [ ] Consider bootstrapping if flicker is unacceptable
- [ ] Plan release condition phases (internal → beta → percentage → GA)
