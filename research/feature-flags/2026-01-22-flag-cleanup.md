---
topic: Feature Flag Cleanup & Technical Debt
date: 2026-01-22
project: feature-flags
sources_count: 7
status: reviewed
tags: [feature-flags, technical-debt, cleanup, migration, url-redirects, code-cleanup]
---

# Feature Flag Cleanup & Technical Debt

## Summary

Feature flags are powerful but create technical debt if not actively managed. The core principle: **treat feature flags as temporary by default**. Martin Fowler notes that most flags should be "short-lived" and removed within days to weeks of full rollout. Unleash recommends setting expiration dates at flag creation and tracking cleanup as explicit sprint tasks.

The cleanup process involves three phases: (1) identifying readiness signals (100% rollout, stable metrics, no user complaints), (2) safely removing code paths (using abstraction layers and testing both paths), and (3) handling URL redirects with HTTP 301 permanent redirects for SEO preservation. Communication is critical - announce final cutover dates via in-app notifications 2-4 weeks in advance.

For page migrations specifically, the recommended timeline is: 2 weeks at 100% rollout as a "burn-in" period, then schedule flag removal in the next sprint while maintaining URL redirects indefinitely. Tools like Unleash's lifecycle tracking, PostHog's flag cleanup reminders, and static analysis (grep/AST tools) help detect stale flags automatically.

## Key Findings

1. **Readiness signals for flag removal**: Flag has been at 100% rollout for 1-2 weeks, no regressions or user complaints, metrics are stable compared to baseline, and the feature is considered "done" by product owner.

2. **Code cleanup best practices**: Use abstraction layers/wrappers so flag checks are centralized, evaluate flags once at the highest level and pass results down, test both code paths before removal, and remove the conditional logic + old code path + flag definition together.

3. **Recommended timeline**: From full rollout to flag removal should be 1-4 weeks maximum for release toggles. Longer for ops toggles (kill switches) which may be permanent.

4. **URL redirect strategy**: Use HTTP 301 (permanent redirect) for old page URLs to new page URL. Maintain redirects indefinitely for SEO and bookmark preservation. Never remove redirects unless analytics show zero traffic.

5. **Communication pattern**: Announce cutover date 2-4 weeks in advance via in-app banners or Intercom. Send reminder 1 week before. Document the migration in a changelog or release notes.

6. **Stale flag detection tools**: Unleash provides lifecycle stages and "potentially stale" markers. PostHog recommends cleaning up after rollout. Static analysis tools (grep, AST parsers) can find flag references. Some teams integrate flag cleanup checks into CI/CD pipelines.

7. **Technical debt risk**: Stale flags introduce security vulnerabilities, unexpected behavior, and cognitive load. Knight Capital's $440M loss is often cited as a cautionary tale of stale flag configuration.

## Detailed Analysis

### When to Remove a Feature Flag

A feature flag is ready for removal when all of these conditions are met:

| Signal | Description |
|--------|-------------|
| Full rollout achieved | Flag is at 100% for all user segments |
| Burn-in period complete | 1-2 weeks of stable operation at full rollout |
| Metrics are stable | Error rates, performance, user engagement match or exceed baseline |
| No active issues | No open bugs or user complaints related to the feature |
| Product sign-off | Product owner confirms feature is complete and successful |
| Old code path unused | Analytics confirm no users are hitting the old code path |

**Martin Fowler's guidance**: "Release Toggles should generally not stick around much longer than a week or two."

**Unleash's guidance**: "Once a rollout is complete, you should remove the feature flag from your code and archive it. Remove any old code paths that the new functionality replaces."

### How to Clean Up Flag Code Paths Safely

#### Step 1: Centralize Flag Checks (Prevention)

The best cleanup is one that's easy. Structure your code so flags are evaluated in one place:

```typescript
// GOOD: Centralized flag evaluation
function createFeatureDecisions(features) {
  return {
    shouldUseNewPage() {
      return features.isEnabled("new-unified-page");
    }
  };
}

// Use in component
if (featureDecisions.shouldUseNewPage()) {
  return <NewPage />;
} else {
  return <OldPage />;
}
```

```typescript
// BAD: Scattered flag checks
// page1.vue
if (posthog.isFeatureEnabled('new-unified-page')) { ... }

// page2.vue  
if (posthog.isFeatureEnabled('new-unified-page')) { ... }

// api.ts
if (posthog.isFeatureEnabled('new-unified-page')) { ... }
```

#### Step 2: Find All Flag References

Before removal, locate every reference to the flag:

```bash
# Simple grep search
grep -r "new-unified-page" --include="*.vue" --include="*.ts"

# Or use your IDE's "Find in Files" feature
```

For large codebases, consider AST-based tools that can detect:
- Direct flag checks: `isFeatureEnabled('flag-name')`
- Flag name constants: `const FLAG_NAME = 'flag-name'`
- Conditional imports based on flags

#### Step 3: Remove Code in Order

1. **Remove the conditional logic** - Delete the if/else and keep only the new code path
2. **Remove the old code path** - Delete the old component/function entirely
3. **Remove the flag definition** - Delete from your centralized flag constants
4. **Remove wrapper methods** - Delete helper functions like `shouldUseNewPage()`
5. **Update tests** - Remove tests that verify old behavior, keep tests for new behavior
6. **Archive the flag** - Mark as archived in PostHog/Unleash (don't delete - keep audit trail)

#### Step 4: Test After Removal

Run your test suite to ensure:
- New code path works without the flag check
- No references to the flag remain
- No dead code is left behind

### Testing That Cleanup Doesn't Break Anything

| Test Type | What to Verify |
|-----------|----------------|
| Unit tests | New code path works without flag evaluation |
| Integration tests | Full user flow works end-to-end |
| Smoke tests | Critical paths still function in staging |
| Visual regression | UI renders correctly without old styles/components |

**Key insight from Unleash**: "A feature isn't 'done' until its associated feature flag has been removed from the code and archived."

### Timeline from Full Rollout to Flag Removal

```
Day 0: Flag reaches 100% rollout
         ↓
Days 1-14: Burn-in period
  - Monitor metrics daily
  - Address any issues that arise
  - Confirm with product owner that feature is successful
         ↓
Day 14: Schedule cleanup task
  - Create ticket/task for flag removal
  - Assign to original developer (context is fresh)
         ↓
Days 14-21: Code cleanup
  - Remove flag from codebase
  - Deploy cleanup changes
  - Archive flag in PostHog
         ↓
Day 21+: URL redirects remain
  - Keep 301 redirects indefinitely
  - Monitor redirect traffic quarterly
```

**For page migrations specifically**: The timeline may extend to 4 weeks if the change is significant, to ensure enough user feedback.

### URL Redirect Strategy for Page Migrations

When replacing old pages with a new page, implement permanent redirects:

#### HTTP 301 Redirects

Use HTTP 301 (Moved Permanently) to:
- Preserve SEO rankings (search engines transfer link equity)
- Support user bookmarks
- Maintain external links from documentation, emails, etc.

```typescript
// Vue Router example
const routes = [
  // New unified page
  { 
    path: '/shipments/overview', 
    component: NewUnifiedPage 
  },
  
  // Redirects from old pages
  { 
    path: '/shipments/list', 
    redirect: '/shipments/overview' 
  },
  { 
    path: '/shipments/dashboard', 
    redirect: '/shipments/overview' 
  },
]
```

```nginx
# Nginx example
location /old-page {
    return 301 /new-page;
}
```

#### Server-side vs Client-side Redirects

| Type | Pros | Cons |
|------|------|------|
| Server-side (301) | SEO-friendly, instant redirect | Requires server config |
| Vue Router redirect | Easy to implement | Client must load JS first |
| Meta refresh | Works without JS | Poor UX, not SEO-friendly |

**Recommendation**: Use server-side 301 redirects where possible. Fall back to Vue Router redirects for SPA-only routes.

#### How Long to Keep Redirects

- **Minimum**: 6 months (allows search engines to update indexes)
- **Recommended**: Indefinitely (storage cost is negligible)
- **Review quarterly**: Check analytics for redirect traffic; if still getting hits, keep them

### Communicating Final Cutover to Users

#### Timeline for Communication

| When | Action | Channel |
|------|--------|---------|
| T-4 weeks | Announce deprecation of old pages | Blog post, changelog |
| T-2 weeks | In-app banner on old pages | Toast/banner component |
| T-1 week | Direct notification to heavy users | Intercom message |
| T-1 day | Final reminder | In-app notification |
| T-0 | Cutover complete | Remove old pages, activate redirects |
| T+1 day | Confirmation | Email to stakeholders |

#### Sample In-App Banner

```vue
<template>
  <div v-if="showDeprecationBanner" class="deprecation-banner">
    <p>
      This page is being replaced by our new unified view.
      <router-link to="/new-page">Try it now</router-link> or 
      it will become the default on {{ cutoverDate }}.
    </p>
    <button @click="dismissBanner">Dismiss</button>
  </div>
</template>
```

#### Sample Intercom Message

```
Subject: Your [Page Name] is getting an upgrade

Hi {{ first_name }},

We're consolidating [Old Page 1] and [Old Page 2] into a single, 
more powerful [New Page Name].

What's changing:
- Both pages will redirect to the new unified view
- All your data and settings are preserved
- The new page includes [benefit 1], [benefit 2]

Timeline:
- Now: You can opt-in to try the new page
- [Date]: The new page becomes the default
- Old URLs will automatically redirect

Questions? Reply to this message or contact support.
```

### Documenting the Migration

Create a migration document in your team wiki or changelog:

```markdown
## Migration: Unified Shipments Page

**Date**: 2026-01-22
**Flag**: `new-unified-shipments-page`
**Status**: Completed

### What Changed
- Merged /shipments/list and /shipments/dashboard into /shipments/overview
- Added filtering, sorting, and bulk actions from both pages
- Improved performance by 40%

### Redirects
- /shipments/list → /shipments/overview (301)
- /shipments/dashboard → /shipments/overview (301)

### Breaking Changes
- Deep links to specific filters on old pages no longer work
- Browser history may show old URLs

### Rollback Plan (expired)
- Revert commit [hash]
- Re-enable feature flag
- Contact [owner] for questions
```

### Tools for Detecting Stale Flags

| Tool | Capability |
|------|------------|
| **Unleash Lifecycle** | Tracks flag stages (initial, pre-live, live, completed), marks flags as "potentially stale" automatically |
| **PostHog** | Shows last evaluation time, recommends cleanup for fully rolled out flags |
| **Static analysis** | Grep, ESLint rules, or custom scripts to find flag references |
| **CI/CD integration** | Fail builds if code references archived flags |
| **IDE plugins** | Highlight stale flag usage in editor |

#### Example: ESLint Rule for Stale Flags

```javascript
// .eslintrc.js
module.exports = {
  rules: {
    'no-restricted-syntax': [
      'error',
      {
        selector: `CallExpression[callee.property.name='isFeatureEnabled'][arguments.0.value='archived-flag-name']`,
        message: 'This flag has been archived. Remove this code path.'
      }
    ]
  }
};
```

#### Example: CI Check for Archived Flags

```yaml
# .github/workflows/check-flags.yml
- name: Check for archived flags
  run: |
    ARCHIVED_FLAGS="old-flag-1 old-flag-2 old-flag-3"
    for flag in $ARCHIVED_FLAGS; do
      if grep -r "$flag" src/; then
        echo "Error: Found reference to archived flag: $flag"
        exit 1
      fi
    done
```

## Sources

| Source | URL | Key Contribution |
|--------|-----|------------------|
| Martin Fowler | https://martinfowler.com/articles/feature-toggles.html | Foundational article on toggle categories and lifecycle |
| Unleash Best Practices | https://docs.getunleash.io/topics/feature-flags/feature-flag-best-practices | 11 principles including short-lived flags and cleanup |
| Unleash Technical Debt | https://docs.getunleash.io/concepts/technical-debt | Stale flag detection and lifecycle management |
| Unleash Code Management | https://docs.getunleash.io/guides/manage-feature-flags-in-code | Code patterns, abstraction layers, cleanup workflow |
| PostHog Best Practices | https://posthog.com/docs/feature-flags/best-practices | Cleanup recommendations, naming conventions |
| MDN HTTP Redirects | https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Redirections | HTTP 301/302 redirect best practices |
| Prior research | research/feature-flags/2026-01-22-exploration-plan.md | Rollout phases and overall migration strategy |

## Questions for Further Research

- [ ] How to automate flag cleanup PRs (e.g., Unleash AI cleanup feature)?
- [ ] What metrics specifically indicate a page migration is safe to finalize?
- [ ] How do other teams handle "sunset period" where both old and new coexist?
- [ ] Are there Vue-specific patterns for feature flag cleanup in composables?
- [ ] How to handle database migrations that depend on feature flags?
