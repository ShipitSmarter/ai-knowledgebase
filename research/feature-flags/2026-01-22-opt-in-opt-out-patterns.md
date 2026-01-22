---
topic: User Opt-in/Opt-out Patterns for Feature Flag Page Migration
date: 2026-01-22
project: feature-flags
sources_count: 6
status: reviewed
tags: [feature-flags, opt-in, opt-out, posthog, vue, ux-patterns, beta-program]
---

# User Opt-in/Opt-out Patterns for Page Migration

## Summary

When replacing existing pages with a new unified page, users need control over when they adopt the change. PostHog's Early Access Feature Management provides built-in opt-in/opt-out infrastructure that stores state in the feature flag system (not application database). The UX should use **non-modal, non-intrusive patterns** - banners or settings page toggles rather than popups. Key principle from NN/g: progressive disclosure works best when users can easily understand how to progress between states and can always revert.

For your Vue + PostHog + Intercom stack, the recommended approach is: (1) create an Early Access Feature in PostHog, (2) add a dismissible banner or settings toggle in Vue, (3) use Intercom for announcement only (not for opt-in mechanism), and (4) ensure opt-out is always accessible and instant.

## Key Findings

### 1. PostHog Early Access Feature Management is Purpose-Built for This

PostHog provides dedicated "Early Access Feature Management" that handles opt-in/opt-out automatically:

**How it works:**
- Create a feature in PostHog's Early Access Management tab
- PostHog auto-creates a linked feature flag
- User opt-in/opt-out is an **overriding condition** - it bypasses any percentage rollout rules
- State is stored per-user in PostHog (no need for app database)

**Key APIs (JavaScript):**
```javascript
// Get available beta features
posthog.getEarlyAccessFeatures((features) => {
  // features: array of { flagKey, name, description, stage }
}, force_reload)

// Opt user in or out
posthog.updateEarlyAccessFeatureEnrollment(flagKey, true)  // opt-in
posthog.updateEarlyAccessFeatureEnrollment(flagKey, false) // opt-out

// Check if flag is enabled (after opt-in)
const isEnabled = posthog.isFeatureEnabled('new-unified-page')
```

**Vue integration:**
```vue
<script setup>
import { usePostHog, useActiveFeatureFlags } from 'posthog-js/vue'
import { ref, watchEffect } from 'vue'

const posthog = usePostHog()
const activeFlags = useActiveFeatureFlags()
const isNewPageEnabled = ref(false)

watchEffect(() => {
  isNewPageEnabled.value = activeFlags.value?.includes('new-unified-page')
})

function toggleNewPage() {
  posthog.updateEarlyAccessFeatureEnrollment(
    'new-unified-page', 
    !isNewPageEnabled.value
  )
}
</script>
```

### 2. UX Patterns: Banners Beat Modals for Opt-in

**Avoid modals for opt-in prompts.** NN/g research strongly warns against:
- Modals interrupt workflow and require immediate attention
- Users develop "banner blindness" to aggressive popups
- Multiple overlays (cookie consent + beta prompt) cause frustration

**Recommended patterns:**

| Pattern | Best For | Pros | Cons |
|---------|----------|------|------|
| **Inline banner** | First announcement | Non-intrusive, dismissible | Can be ignored |
| **Settings page toggle** | Ongoing control | Persistent, discoverable | Users must find it |
| **Page header badge** | Contextual awareness | Shows current state | Takes screen space |
| **Intercom message** | Initial awareness | Reaches inactive users | One-time only |

**Banner implementation (recommended):**
```vue
<template>
  <div v-if="showBetaBanner" class="beta-banner">
    <span>Try our new unified page experience</span>
    <button @click="optIn">Try it now</button>
    <button @click="dismissBanner">Not now</button>
  </div>
</template>
```

**Wording that works:**
- "Try the new [Feature Name]" (action-oriented)
- "You can switch back anytime" (reduces anxiety)
- "Preview our new experience" (sets expectations)

**Wording to avoid:**
- "Beta" alone (unclear what's beta)
- "New!" without context
- Anything that sounds permanent

### 3. Persistence: Feature Flag System vs App Database

**Use PostHog for persistence** (recommended for your case):

| Aspect | PostHog Early Access | App Database |
|--------|---------------------|--------------|
| Setup effort | Minimal (built-in) | Custom schema + API |
| Cross-device sync | Automatic (user ID) | You build it |
| Analytics | Built-in | Manual tracking |
| Override logic | Automatic | You implement |
| Cleanup | Delete feature | Migrations |

**When to use app database instead:**
- Opt-in has business logic (e.g., paid feature)
- Need audit trail for compliance
- Opt-in affects other systems

**PostHog stores opt-in as person property:**
```
$feature_enrollment/new-unified-page: true/false
```

### 4. Opt-out Must Be Instant and Always Accessible

**Critical principle:** Users must be able to revert immediately without:
- Contacting support
- Waiting for changes to take effect
- Losing their work/data

**Implementation checklist:**
- [ ] Add "Switch back to classic" link on new page
- [ ] Show toggle in user settings/preferences
- [ ] Opt-out takes effect on next page load (or immediately with router)
- [ ] No confirmation modal for opt-out (reduce friction)
- [ ] Consider showing brief toast: "Switched back. You can try the new version anytime."

**Vue router integration:**
```javascript
// In router guard or page component
const posthog = usePostHog()

// Redirect based on feature flag
router.beforeEach((to, from, next) => {
  const useNewPage = posthog.isFeatureEnabled('new-unified-page')
  
  if (to.path === '/old-page-1' || to.path === '/old-page-2') {
    if (useNewPage) {
      next('/new-unified-page')
    } else {
      next()
    }
  } else {
    next()
  }
})
```

### 5. Transition Period: Both Experiences Available

During rollout, maintain both old and new pages:

**URL strategy:**
```
/shipments (old page 1) → keep working
/tracking (old page 2)  → keep working  
/logistics (new unified) → new page

# After full rollout:
/shipments → redirect to /logistics
/tracking  → redirect to /logistics
```

**Feature flag stages in PostHog:**
1. **Concept** - Coming soon, users can register interest
2. **Beta** - Available for opt-in testing
3. **General Availability** - Default on, opt-out available
4. **Retired** - Old pages removed

**Handle bookmarks/deep links:**
```javascript
// Preserve query params when redirecting
if (useNewPage && to.path === '/old-shipments') {
  next({ 
    path: '/logistics',
    query: { ...to.query, tab: 'shipments' }
  })
}
```

### 6. Toggle UI Placement and Wording

**Best placements (in order of preference):**

1. **Contextual on the page itself** - "Try new version" link in page header
2. **User settings/preferences** - Dedicated "Beta Features" section  
3. **Account dropdown** - "Try new features" option
4. **Dismissible banner** - Top of page on first visit only

**PostHog's built-in site app (optional):**
PostHog offers a pre-built modal for beta opt-in:
```javascript
// In PostHog init
posthog.init('key', {
  opt_in_site_apps: true
})
```
Then enable "Early Access Features App" in PostHog pipeline. Creates a modal triggered by any element with your chosen selector (e.g., `#beta-button`).

**Custom toggle component:**
```vue
<template>
  <div class="beta-toggle">
    <label>
      <input 
        type="checkbox" 
        :checked="isNewPageEnabled" 
        @change="toggleNewPage"
      />
      Use new unified logistics page
    </label>
    <span class="beta-badge">Beta</span>
    <button @click="showInfo" class="info-btn">Learn more</button>
  </div>
</template>
```

## Practical Implementation Guide

### Step 1: Create Early Access Feature in PostHog

1. Go to PostHog → Early Access Management
2. Click "New public beta"
3. Name: "Unified Logistics Page" 
4. Description: "New combined view for shipments and tracking"
5. Stage: "Beta"
6. Save and Release

This auto-creates feature flag `unified-logistics-page`.

### Step 2: Add Vue Banner Component

```vue
<!-- BetaFeatureBanner.vue -->
<script setup>
import { ref, onMounted } from 'vue'
import { usePostHog } from 'posthog-js/vue'

const props = defineProps({
  featureKey: String,
  title: String,
  description: String
})

const posthog = usePostHog()
const dismissed = ref(false)
const isOptedIn = ref(false)

onMounted(() => {
  // Check localStorage for dismissal
  dismissed.value = localStorage.getItem(`beta-banner-${props.featureKey}-dismissed`) === 'true'
  isOptedIn.value = posthog.isFeatureEnabled(props.featureKey)
})

function optIn() {
  posthog.updateEarlyAccessFeatureEnrollment(props.featureKey, true)
  // Navigate to new page
  window.location.href = '/logistics'
}

function dismiss() {
  localStorage.setItem(`beta-banner-${props.featureKey}-dismissed`, 'true')
  dismissed.value = true
}
</script>

<template>
  <div v-if="!dismissed && !isOptedIn" class="beta-banner">
    <div class="banner-content">
      <strong>{{ title }}</strong>
      <span>{{ description }}</span>
    </div>
    <div class="banner-actions">
      <button @click="optIn" class="btn-primary">Try it now</button>
      <button @click="dismiss" class="btn-link">Not now</button>
    </div>
  </div>
</template>
```

### Step 3: Add Settings Page Toggle

```vue
<!-- In user settings/preferences page -->
<section class="beta-features">
  <h3>Beta Features</h3>
  <p>Try new features before they're released to everyone.</p>
  
  <div class="feature-toggle">
    <div>
      <strong>New Unified Logistics Page</strong>
      <p>Combined view for shipments and tracking in one place.</p>
    </div>
    <Toggle 
      :modelValue="isUnifiedPageEnabled" 
      @update:modelValue="toggleUnifiedPage"
    />
  </div>
</section>
```

### Step 4: Add Opt-out on New Page

```vue
<!-- On the new unified page -->
<header class="page-header">
  <h1>Logistics</h1>
  <span class="beta-badge">Beta</span>
  <button @click="optOut" class="switch-back-link">
    Switch back to classic view
  </button>
</header>
```

### Step 5: Intercom Announcement (One-time)

Use Intercom for awareness, not for the opt-in mechanism:

```javascript
// When announcing the beta (e.g., in a release)
Intercom('showNewMessage', 
  "We're testing a new unified logistics page! " +
  "Go to Settings > Beta Features to try it out."
)
```

Or use Intercom's Product Tours to guide users to the settings.

## Sources

| Source | URL | Key Contribution |
|--------|-----|------------------|
| PostHog Early Access Docs | https://posthog.com/docs/feature-flags/early-access-feature-management | Core API and architecture for opt-in/opt-out |
| PostHog Beta Program Tutorial | https://posthog.com/tutorials/public-beta-program | Complete implementation example |
| PostHog Feature Flag Best Practices | https://posthog.com/docs/feature-flags/best-practices | Naming, cleanup, flag persistence |
| NN/g Progressive Disclosure | https://www.nngroup.com/articles/progressive-disclosure/ | UX principles for feature adoption |
| NN/g Modal Dialogs | https://www.nngroup.com/articles/modal-nonmodal-dialog/ | When to use/avoid modals |
| NN/g Overlay Overload | https://www.nngroup.com/articles/overlay-overload/ | Why popups hurt UX |

## Questions for Further Research

- [ ] How to handle users who opted-in but the feature is later removed from beta?
- [ ] Best practices for A/B testing during opt-in period (comparing opt-in users vs control)?
- [ ] How to sync opt-in state with Intercom for targeted messaging?
- [ ] What metrics best indicate readiness for full rollout?
