---
topic: Feature Flag Patterns & Rollout Strategies - Exploration Plan
date: 2026-01-22
project: feature-flags
sources_count: 6
status: planning
tags: [exploration, feature-flags, rollout, posthog, vue, intercom]
---

# Feature Flag Patterns & Rollout Strategies - Exploration Plan

## Context

You're using PostHog for feature flags, Vue for modals/switching UI, and Intercom for customer communication. The specific challenge is rolling out a new page that replaces two existing pages, with the ability for users to adopt early and revert if needed.

## Discovery Summary

Feature flags (also called feature toggles) are a powerful technique for decoupling code deployment from feature release. Martin Fowler's comprehensive guide categorizes toggles into four types: Release Toggles (short-lived, for CI/CD), Experiment Toggles (A/B testing), Ops Toggles (kill switches), and Permissioning Toggles (user-specific features). 

PostHog, Unleash, and LaunchDarkly all emphasize similar best practices: keep flags short-lived, clean up after rollout, use progressive/phased rollouts, and evaluate flags as close to the user as possible for performance. PostHog specifically offers "Early Access Feature Management" which enables user opt-in/opt-out flows - directly relevant to your use case.

The key architectural insight from Unleash's 11 principles is that feature flag systems should prioritize availability over consistency (CAP theorem), evaluate locally via SDK caching, and maintain unique flag names across the organization.

### Prior Knowledge Found
- Memory: No prior research on feature flags found
- Notion: Not searched (google-ai-search unavailable)

### Initial Sources Consulted

| Source | Type | Key Insight |
|--------|------|-------------|
| [Martin Fowler - Feature Toggles](https://martinfowler.com/articles/feature-toggles.html) | Authoritative article | Four toggle categories, implementation patterns, de-coupling decision points |
| [PostHog - Best Practices](https://posthog.com/docs/feature-flags/best-practices) | Official docs | Naming conventions, progressive rollout, flag cleanup |
| [PostHog - Phased Rollout](https://posthog.com/tutorials/phased-rollout) | Tutorial | Step-by-step rollout process using cohorts |
| [PostHog - Canary Release](https://posthog.com/tutorials/canary-release) | Tutorial | Monitoring and rollback strategies |
| [PostHog - Early Access Management](https://posthog.com/docs/feature-flags/early-access-feature-management) | Official docs | User opt-in/opt-out for betas - directly relevant |
| [Unleash - 11 Principles](https://docs.getunleash.io/topics/feature-flags/feature-flag-best-practices) | Best practices | Architectural principles for scale |

## Proposed Subtopics

### 1. Feature Flag Categories & Lifecycle
**Why:** Understanding the different types of flags (release, experiment, ops, permission) helps choose the right approach for your page migration scenario.
**Questions to answer:**
- Which category does a "page replacement with opt-in/opt-out" fit into?
- What's the expected lifecycle for this type of flag?
- How to handle the transition from beta to general availability?

### 2. Rollout Strategies (Percentage, Cohort, Canary)
**Why:** You need to decide how to progressively expose users to the new page - by percentage, by user segment, or by explicit opt-in.
**Questions to answer:**
- What's the difference between percentage rollout, cohort-based, and canary releases?
- Which strategy works best for page-level changes?
- How to combine multiple strategies (e.g., opt-in for early adopters + percentage for others)?

### 3. User Opt-in/Opt-out Patterns (Your Specific Use Case)
**Why:** This is the core of your requirement - allowing users to try the new page and revert if needed.
**Questions to answer:**
- How to implement opt-in UI in Vue?
- How to persist opt-in state (PostHog vs local storage vs database)?
- How to handle opt-out and ensure users can always revert?
- What UX patterns work best for "try new experience" features?

### 4. PostHog-Specific Implementation
**Why:** You're already using PostHog - need to know the specific APIs and patterns.
**Questions to answer:**
- How does Early Access Feature Management work in PostHog?
- How to use `getEarlyAccessFeatures` and `updateEarlyAccessFeatureEnrollment`?
- How to bootstrap flags for immediate availability?
- How to track adoption metrics in PostHog?

### 5. Communication Patterns (Intercom Integration)
**Why:** You want to use Intercom to inform customers about the new page.
**Questions to answer:**
- When and how to announce new features via Intercom?
- How to segment Intercom messages based on feature flag state?
- How to collect feedback from users trying the new page?

### 6. Page Migration Architecture
**Why:** Replacing two pages with one is a significant architectural change that needs careful planning.
**Questions to answer:**
- How to structure Vue routing with feature flags?
- How to handle edge cases (bookmarks, deep links to old pages)?
- How to migrate user settings/preferences between old and new pages?

### 7. Monitoring & Rollback Strategies
**Why:** You need to detect problems quickly and be able to roll back if the new page causes issues.
**Questions to answer:**
- What metrics to monitor during rollout?
- How to implement instant rollback?
- How to use session recordings to debug issues?

### 8. Flag Cleanup & Technical Debt
**Why:** Feature flags add complexity - need a plan to remove them once rollout is complete.
**Questions to answer:**
- When to remove the flag (timeline)?
- How to clean up code paths?
- How to communicate the final cutover to users?

## Flagged Uncertainties

- [ ] PostHog Early Access Management only works with JavaScript Web SDK - need to verify Vue compatibility
- [ ] Sources disagree on whether opt-in state should be persisted in feature flag system vs application database
- [ ] Limited information on combining opt-in with percentage rollout (can both coexist?)
- [ ] Intercom integration patterns with PostHog are not well-documented

## Recommended Research Order

1. **User Opt-in/Opt-out Patterns** - Foundation for your specific use case
2. **PostHog-Specific Implementation** - Technical details you need immediately
3. **Rollout Strategies** - Broader context for your phased approach
4. **Page Migration Architecture** - Vue-specific implementation patterns
5. **Monitoring & Rollback** - Critical for production safety
6. **Communication Patterns** - Intercom integration
7. **Feature Flag Categories** - Theoretical foundation
8. **Flag Cleanup** - Post-launch planning

## Recommended Approach for Your Use Case

Based on discovery, here's a preliminary recommendation for your "replace two pages with one" scenario:

```
┌─────────────────────────────────────────────────────────────────┐
│                    ROLLOUT PHASES                                │
├─────────────────────────────────────────────────────────────────┤
│ Phase 1: Internal Team (flag: is-new-unified-page-enabled)      │
│   - Test with internal users                                     │
│   - Fix bugs, polish UX                                          │
├─────────────────────────────────────────────────────────────────┤
│ Phase 2: Opt-in Beta (Early Access Feature)                      │
│   - Users can opt-in via UI toggle                               │
│   - Intercom banner: "Try our new unified page"                  │
│   - Users can opt-out at any time                                │
├─────────────────────────────────────────────────────────────────┤
│ Phase 3: Gradual Percentage Rollout                              │
│   - 10% → 25% → 50% → 100%                                      │
│   - Users still have opt-out option                              │
│   - Monitor metrics between old/new                              │
├─────────────────────────────────────────────────────────────────┤
│ Phase 4: Default New, Opt-out for Old                            │
│   - New page is default                                          │
│   - Legacy users can still access old pages                      │
│   - Intercom: "Old pages will be removed on [date]"             │
├─────────────────────────────────────────────────────────────────┤
│ Phase 5: Full Migration                                          │
│   - Remove old pages                                             │
│   - Remove feature flag                                          │
│   - Redirect old URLs to new page                                │
└─────────────────────────────────────────────────────────────────┘
```

## Next Steps

Awaiting your approval to proceed with subtopic research. You can:
- Approve all subtopics
- Remove subtopics you don't need
- Add subtopics you want explored
- Reorder priority
- Ask for more discovery on specific areas
