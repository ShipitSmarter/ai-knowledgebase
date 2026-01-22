---
topic: Rollout Strategies for Feature Flag Page Migration
date: 2026-01-22
project: feature-flags
sources_count: 7
status: reviewed
tags: [feature-flags, rollout, canary, percentage-rollout, ring-deployment, page-migration]
---

# Rollout Strategies for Feature Flag Page Migration

## Summary

Rollout strategies determine how and when users get access to new features behind feature flags. For page-level UI changes where two pages are being replaced by a unified page, the recommended approach combines **opt-in early access** with **phased percentage rollout**. This allows power users to adopt early while gradually exposing the broader user base.

The four main rollout strategies are: (1) percentage-based gradual rollout using consistent hashing for sticky user experience, (2) cohort/segment-based targeting by user properties, (3) canary releases to small validation groups first, and (4) ring-based deployment expanding outward from internal to production. For page migrations, a hybrid approach works best: start with internal testing, enable opt-in for early adopters, then gradually increase percentage while maintaining opt-out capability.

Key metrics that should gate progression between phases include error rates, page load times, task completion rates, and user satisfaction signals. Time between phases depends on traffic volume - you need statistically significant data, typically 24-72 hours per phase minimum.

## Key Findings

1. **Percentage rollout uses consistent hashing** - Users are assigned to cohorts using a hash of their user ID, ensuring the same user always sees the same version across sessions (stickiness). This prevents jarring experiences where features appear/disappear randomly.

2. **Canary releases validate before broad exposure** - Deploy to 1-5% of users first, validate key metrics, then expand. The "canary" group acts as early warning detection for issues before they affect the majority.

3. **Ring-based deployment expands outward** - Microsoft's model: Ring 0 (developers) → Ring 1 (team) → Ring 2 (internal org) → Ring 3 (early adopters) → Ring 4 (production). Each ring gates the next.

4. **Opt-in and percentage rollout can coexist** - Use OR logic: users get the feature if they explicitly opt-in OR fall within the percentage rollout. This enables power users to adopt early without waiting for their percentage cohort.

5. **Recommended rollout phases for page migration**: Internal (100%) → Beta opt-in → 10% → 25% → 50% → 100% with opt-out → Remove flag. Minimum 24-72 hours per phase depending on traffic.

6. **Gate progression on metrics, not time** - Don't advance to the next phase until: error rate < baseline + threshold, p95 latency stable, task completion rate maintained, no spike in support tickets.

7. **Always maintain rollback capability** - Feature flags enable instant rollback without deployment. Keep the old pages accessible until the flag is fully removed.

## Strategy Comparison

| Strategy | How It Works | Best For | Limitations |
|----------|--------------|----------|-------------|
| **Percentage Rollout** | Hash user ID to determine inclusion (0-100 scale). User at position 35 included when rollout >= 35%. | Gradual exposure to random subset | No targeting control |
| **Cohort/Segment** | Target by user properties (plan, region, email domain) | Specific audiences (premium users, beta testers) | Requires user properties |
| **Canary Release** | Small fixed group tests first | Validating risky changes | Limited sample size |
| **Ring-based** | Expanding circles from internal outward | Large organizations, infra changes | Complex coordination |
| **Opt-in/Opt-out** | User self-selects via UI toggle | User-facing UX changes | Adoption depends on awareness |

## Detailed Analysis

### Percentage-based Gradual Rollout

The most common strategy. Uses consistent hashing to assign users to a value between 0-100 based on their user ID. If the rollout percentage is set to 25%, all users with hash values 0-25 see the new feature.

**Advantages:**
- Stickiness: same user always gets same experience (until percentage changes)
- Simple to implement and understand
- Can ramp up/down quickly by changing percentage

**Implementation (PostHog):**
```javascript
// PostHog automatically handles percentage rollout with stickiness
if (posthog.isFeatureEnabled('new-unified-page')) {
  showNewPage()
} else {
  showLegacyPages()
}
```

**Recommended progression for page migration:**
- 5% - initial validation, catch obvious bugs
- 10% - broader validation, monitor metrics
- 25% - significant exposure, A/B compare metrics
- 50% - majority exposure, final validation
- 100% - full rollout, keep opt-out available

### Cohort/Segment-based Targeting

Target specific user segments based on properties like subscription plan, company, region, or behavior. Useful when you want specific audiences to get features first.

**Use cases:**
- Premium customers get features first
- Users who requested the feature via feedback
- Specific companies/organizations
- Geographic regions (time zone testing)

**Implementation (PostHog):**
```javascript
// Create cohort in PostHog UI based on properties
// Then use as release condition for feature flag
posthog.capture('$pageview', {
  $set: {
    plan: 'enterprise',
    requested_new_ui: true
  }
})
```

### Canary Release

Deploy to a small, fixed group (1-5%) to validate changes before broader exposure. The "canary" group serves as early warning - if they experience issues, you catch it before affecting the majority.

**Canary release steps (from PostHog):**
1. Just yourself - personal validation
2. Internal team - `email contains @mycompany.com`
3. Beta users/orgs - specific email domains or org IDs
4. Expanded beta - percentage of general users
5. Full release - 100%, then remove flag

**Key insight:** Canary is about validation, not gradual adoption. You're looking for problems, not measuring adoption metrics.

### Ring-based Deployment

Microsoft's approach for large-scale rollouts. Features expand through concentric rings, each gating the next:

```
Ring 0: Developers/Feature Team
   ↓
Ring 1: Adjacent Teams
   ↓
Ring 2: Internal Organization
   ↓
Ring 3: External Early Adopters
   ↓
Ring 4: Production (Full)
```

**Best suited for:**
- Infrastructure changes
- Breaking API changes
- Large organizations with multiple teams
- Changes requiring cross-team validation

**For page migrations:** Simplified rings work well:
- Ring 0: Development team
- Ring 1: All internal employees
- Ring 2: Opt-in beta users
- Ring 3: Gradual percentage rollout

### Combining Opt-in with Percentage Rollout

For page-level UI changes, the best approach combines user opt-in with percentage rollout. This satisfies both:
- Power users who want to try new things immediately
- Regular users who should be gradually introduced

**Implementation pattern:**
```javascript
// Pseudo-code for combined approach
function shouldShowNewPage(user) {
  // Check explicit opt-in first
  if (user.hasOptedInToNewPage) {
    return true
  }
  
  // Check explicit opt-out
  if (user.hasOptedOutOfNewPage) {
    return false
  }
  
  // Fall back to percentage rollout
  return posthog.isFeatureEnabled('new-unified-page')
}
```

**In PostHog:** Create two feature flags:
1. `new-unified-page-beta` - enabled for users who opt in
2. `new-unified-page-rollout` - percentage-based rollout

Check beta flag first, then rollout flag. This gives opt-in users immediate access regardless of percentage.

## Rollout Phase Recommendations

### Phase Timeline for Page Migration

| Phase | Audience | Duration | Exit Criteria |
|-------|----------|----------|---------------|
| **Internal** | Dev team + QA | 1-3 days | All acceptance tests pass, no blocking bugs |
| **Beta Opt-in** | Self-selected users | 1-2 weeks | Positive feedback, < 5% opt-out after trying |
| **5%** | Random subset | 24-48 hours | Error rate stable, no metric degradation |
| **25%** | Random subset | 48-72 hours | Compare metrics old vs new statistically |
| **50%** | Random subset | 48-72 hours | Final metric validation |
| **100%** | All users | 1-2 weeks | No support tickets, remove flag |

### How Long to Stay at Each Percentage

**Factors determining duration:**
1. **Traffic volume** - Need enough users to be statistically significant
2. **Metric stability** - Metrics should stabilize before advancing
3. **Support ticket volume** - Watch for spike in complaints
4. **Session recording review** - Sample recordings for UX issues

**Rule of thumb:** Minimum 24 hours at each phase. For lower traffic apps, 72+ hours. Never advance phases back-to-back without metric review.

### Metrics That Should Gate Progression

| Metric Category | What to Measure | Threshold |
|-----------------|-----------------|-----------|
| **Reliability** | Error rate, exceptions | < baseline + 1% |
| **Performance** | P50/P95 page load time | < baseline + 10% |
| **Functionality** | Task completion rate | > baseline - 5% |
| **User satisfaction** | Opt-out rate, time on page | Monitor trend |
| **Business** | Conversion rate, actions completed | > baseline - 2% |

**Red flags that should pause rollout:**
- Error rate increases by > 2%
- P95 latency doubles
- Support tickets mention the new feature
- Opt-out rate > 10% of users who tried it

## Best Strategy for Page-Level UI Changes

For replacing two pages with a unified page, use this hybrid approach:

```
┌────────────────────────────────────────────────────────────────┐
│                 RECOMMENDED ROLLOUT PATTERN                     │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. INTERNAL TESTING (Ring 0-1)                                │
│     Flag: enabled for @company.com emails                      │
│     Duration: Until QA sign-off                                │
│                                                                 │
│  2. BETA OPT-IN                                                │
│     Enable Early Access Management in PostHog                   │
│     Add "Try New Page" toggle in UI                            │
│     Announce via Intercom banner                                │
│     Duration: 1-2 weeks to gather feedback                      │
│                                                                 │
│  3. GRADUAL PERCENTAGE (with opt-out)                          │
│     5% → 25% → 50% → 100%                                      │
│     Users can still opt-out even if in percentage               │
│     Duration: 1-2 weeks total                                   │
│                                                                 │
│  4. DEFAULT NEW, SUNSET OLD                                     │
│     New page default for everyone                               │
│     Old pages still accessible via "Use Classic" link           │
│     Announce sunset date via Intercom                           │
│     Duration: 2-4 weeks                                         │
│                                                                 │
│  5. REMOVE FLAG                                                 │
│     Delete old page code                                        │
│     Remove feature flag                                         │
│     Redirect old URLs to new page                               │
│                                                                 │
└────────────────────────────────────────────────────────────────┘
```

## Sources

| Source | URL | Key Contribution |
|--------|-----|------------------|
| Martin Fowler | https://martinfowler.com/articles/feature-toggles.html | Feature toggle categories, canary releasing pattern, toggle lifecycle management |
| PostHog - Phased Rollout | https://posthog.com/tutorials/phased-rollout | Step-by-step rollout process, cohort creation, percentage configuration |
| PostHog - Canary Release | https://posthog.com/tutorials/canary-release | Canary validation steps, monitoring with session recordings, funnel analysis |
| Unleash - Best Practices | https://docs.getunleash.io/topics/feature-flags/feature-flag-best-practices | 11 principles for feature flags, consistent user experience, stickiness via hashing |
| Unleash - Activation Strategies | https://docs.getunleash.io/reference/activation-strategies | Rollout percentage mechanics, targeting constraints, multiple strategy combination |
| Unleash - Canary Deployment | https://www.getunleash.io/blog/canary-deployment-what-is-it | Canary implementation with feature flags, gradual rollout UI examples |
| Microsoft Azure DevOps | https://learn.microsoft.com/en-us/azure/devops/pipelines/release/ | Ring-based deployment model, multi-stage release pipelines |

## Questions for Further Research

- [ ] How does PostHog's Early Access Management interact with percentage rollout flags?
- [ ] What's the best way to persist opt-in state: PostHog person property vs application database?
- [ ] How to handle users who clear cookies mid-rollout (lose stickiness)?
- [ ] What Intercom integration patterns work for feature flag-based announcements?
