---
project: feature-flags
description: Research on feature flag patterns, rollout strategies, and implementation for page migrations
date: 2026-01-22
status: complete
---

# Feature Flags Research

Research on feature flag patterns, rollout strategies, and user opt-in/opt-out mechanisms for controlled feature releases.

## Executive Summary

This research explores best practices for feature flags, with specific focus on a page migration scenario where two existing pages are replaced with a new unified page. Users should be able to opt-in early to try the new experience and opt-out to revert if needed.

**Key Architectural Decision**: Use PostHog's Early Access Feature Management for opt-in/opt-out, combined with percentage-based rollout. User opt-in **overrides** percentage targeting, allowing both strategies to coexist.

**Recommended Rollout Phases**:
1. Internal team testing (flag enabled for team only)
2. Beta opt-in via UI toggle (Early Access Feature)
3. Gradual rollout: 5% → 25% → 50% → 100%
4. Default to new page, opt-out for old pages
5. Remove old pages, remove flag, set up redirects

## Research Documents

| Date | Topic | Status | Key Contribution |
|------|-------|--------|------------------|
| 2026-01-22 | [Exploration Plan](./2026-01-22-exploration-plan.md) | Complete | Initial discovery, subtopic identification |
| 2026-01-22 | [Opt-in/Opt-out Patterns](./2026-01-22-opt-in-opt-out-patterns.md) | Complete | UX patterns, banner vs modal, opt-out accessibility |
| 2026-01-22 | [PostHog Implementation](./2026-01-22-posthog-implementation.md) | Complete | Early Access Management APIs, Vue integration, bootstrapping |
| 2026-01-22 | [Rollout Strategies](./2026-01-22-rollout-strategies.md) | Complete | Percentage, cohort, canary, ring-based approaches |
| 2026-01-22 | [Page Migration Architecture](./2026-01-22-page-migration-architecture.md) | Complete | Vue routing patterns, URL handling, data migration |
| 2026-01-22 | [Monitoring & Rollback](./2026-01-22-monitoring-rollback.md) | Complete | Metrics, dashboards, instant rollback, session replay |
| 2026-01-22 | [Communication Patterns](./2026-01-22-communication-patterns.md) | Complete | Intercom integration, announcement timing, feedback collection |
| 2026-01-22 | [Flag Categories](./2026-01-22-flag-categories.md) | Complete | Martin Fowler's taxonomy, lifecycle management |
| 2026-01-22 | [Flag Cleanup](./2026-01-22-flag-cleanup.md) | Complete | Code cleanup, URL redirects, technical debt |

## Context

This research supports a specific use case: replacing two existing pages with a new unified page, where users can:
- Opt-in early to try the new page
- Opt-out to revert to the old pages if needed
- Have control during the transition period

## Tech Stack

- **Feature Flags**: PostHog
- **Frontend**: Vue.js
- **Customer Communication**: Intercom

## Key Insights

### High Confidence (Multiple Sources)

1. **PostHog Early Access Management** provides built-in opt-in/opt-out infrastructure - user choice overrides percentage rollout rules
2. **Non-modal UI patterns** (banners, settings toggles) work better than popups for opt-in (NN/g research)
3. **Instant rollback** is the #1 safety net - feature flags enable <1 minute rollback vs hours for deployment
4. **Session replay filtered by flag state** is the debugging superpower for understanding metric changes
5. **Consistent hashing** (MurmurHash of user ID) ensures sticky experience in percentage rollouts
6. **Route aliases** in Vue Router preserve bookmarks without redirects during migration
7. **Clean up flags 1-4 weeks** after 100% rollout - longer creates technical debt

### Medium Confidence (Limited Sources)

1. Opt-in and percentage rollout coexist using OR logic
2. Ring-based deployment (Microsoft pattern) is effective for large organizations
3. Intercom sync requires manual implementation (no native PostHog integration)

### Needs Verification

1. PostHog Early Access behavior when user opts in during beta but feature moves to GA
2. Optimal "bake time" at each rollout tier (sources vary from 24 hours to 1 week)
3. SSR bootstrapping patterns for Nuxt/Vue specifically

## Implementation Checklist

### Phase 1: Setup
- [ ] Create feature flag: `is-new-unified-page-enabled`
- [ ] Configure Early Access Feature in PostHog
- [ ] Set up Vue Router with navigation guards
- [ ] Create PageResolver wrapper component

### Phase 2: Internal Testing
- [ ] Set release condition to internal team emails
- [ ] Test both old and new page flows
- [ ] Set up monitoring dashboard in PostHog

### Phase 3: Beta Launch
- [ ] Enable Early Access opt-in UI
- [ ] Create Intercom banner for beta invitation
- [ ] Set up feedback collection (Intercom + in-app survey)
- [ ] Sync PostHog opt-in state to Intercom attributes

### Phase 4: Gradual Rollout
- [ ] Expand to 5%, monitor for 24-72 hours
- [ ] Check metrics: error rate, latency, task completion
- [ ] Expand to 25% → 50% → 100%
- [ ] Keep opt-out option available

### Phase 5: Full Migration
- [ ] Set new page as default
- [ ] Announce deprecation timeline via Intercom
- [ ] Remove old pages
- [ ] Set up 301 redirects for old URLs
- [ ] Remove feature flag code
- [ ] Archive flag in PostHog

## Open Questions

- [ ] How to handle users who opted into beta when transitioning to GA?
- [ ] Intercom-PostHog sync: client-side dual-write or server-side webhook?
- [ ] SEO implications of route aliases vs 301 redirects?
- [ ] Automated rollback based on metrics (not built into PostHog)?

## Sources

Primary sources consulted:
- Martin Fowler: Feature Toggles article (martinfowler.com)
- PostHog: Feature Flags & Early Access Management documentation
- Unleash: 11 Principles for Feature Flag Systems
- Microsoft: Safe Deployment Practices (Azure DevOps)
- NN/g: UX patterns for progressive disclosure
