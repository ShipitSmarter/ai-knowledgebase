---
topic: Feature Flag Categories & Lifecycle
date: 2026-01-22
project: feature-flags
status: reviewed
tags: [feature-flags, martin-fowler, lifecycle, taxonomy, release-toggles, cleanup]
---

# Feature Flag Categories & Lifecycle

## Summary

Martin Fowler's seminal article on Feature Toggles identifies four distinct categories based on two dimensions: **longevity** (how long the flag lives) and **dynamism** (how often the toggle decision changes). These categories are Release Toggles, Experiment Toggles, Ops Toggles, and Permissioning Toggles. Understanding which category a flag belongs to fundamentally affects implementation choices, configuration approach, and cleanup timing.

For a "page replacement with opt-in" scenario, the flag is primarily a **Release Toggle** that transitions through a **Permissioning Toggle** phase during beta. This hybrid lifecycle requires careful planning: start with developer-controlled static configuration, evolve to user-specific dynamic decisions during opt-in, then simplify back to static as you approach 100% rollout and cleanup.

## Key Findings

1. **Four flag categories exist** - Release, Experiment, Ops, Permissioning - each with distinct longevity and dynamism characteristics
2. **Categories affect implementation** - Long-lived flags need maintainable patterns (Strategy, dependency injection); short-lived flags can use simple conditionals
3. **"Page replacement with opt-in" is a hybrid** - Starts as Release Toggle, becomes Permissioning Toggle during beta, returns to Release Toggle before cleanup
4. **Cleanup timing varies by category** - Release: days to weeks; Experiment: hours to weeks; Ops: varies (some permanent); Permissioning: potentially years
5. **Flag lifecycle has five stages** - Define, Develop, Production, Cleanup, Archived
6. **Naming conventions signal intent** - Prefixes like `release-`, `exp-`, `ops-`, `perm-` help identify category and cleanup priority
7. **Technical debt accumulates** - Feature flags are inherently temporary technical debt that must be actively managed

## Detailed Analysis

### The Four Flag Categories (Fowler's Framework)

#### 1. Release Toggles

**Purpose:** Enable trunk-based development by allowing incomplete/untested code to ship as latent code.

**Characteristics:**
- Longevity: **Short** (days to weeks)
- Dynamism: **Static** (same decision for all users in a deployment)
- Configuration: Can be hardcoded, environment variables, or config files
- Who manages: Developers

**Lifecycle expectation:** Should not stick around longer than 1-2 weeks after code is feature-complete. Once validated in production, remove immediately.

**Example use cases:**
- Work-in-progress features merged to trunk
- Coordinating feature release with marketing campaign
- Separating deployment from release

**Implementation guidance:**
> "If we're adding a Release Toggle which will be removed in a few days time then we can probably get away with a Toggle Point which does a simple if/else check on a Toggle Router." - Fowler

#### 2. Experiment Toggles (A/B Testing)

**Purpose:** Multivariate or A/B testing to compare user behavior across different codepaths.

**Characteristics:**
- Longevity: **Medium** (hours to weeks - enough for statistical significance)
- Dynamism: **Highly dynamic** (per-request, user-based cohort assignment)
- Configuration: Cohort configuration (percentages, user grouping algorithm)
- Who manages: Product/Growth teams with developer support

**Lifecycle expectation:** Keep active only until statistically significant results are achieved. Longer experiments risk being invalidated by other system changes.

**Example use cases:**
- Testing purchase flow variations
- Call-to-action wording experiments
- Algorithm comparison (engagement, revenue metrics)

**Key distinction:** Unlike canary releases (random cohort), experiment toggles need **consistent cohorting** - the same user must always see the same variant.

#### 3. Ops Toggles (Operational/Circuit Breakers)

**Purpose:** Control operational aspects of system behavior, allowing quick degradation or feature disabling in production.

**Characteristics:**
- Longevity: **Varies** (short-lived for new features, permanent for kill switches)
- Dynamism: **Can change extremely quickly** (minutes, not deployments)
- Configuration: Must be re-configurable without deployment
- Who manages: Operations/SRE teams

**Lifecycle expectation:**
- **Short-term:** Remove once confidence in new feature's performance is established
- **Long-term kill switches:** May be permanent (e.g., disable recommendations under heavy load)

**Example use cases:**
- Disable expensive-to-generate features during load spikes
- Gracefully degrade non-critical functionality
- Manual circuit breakers for known weak points

**Implementation note:** These flags require the most dynamic configuration - admin UI, distributed config systems (Consul, etcd), or feature flag services.

#### 4. Permissioning Toggles (Champagne Brunch)

**Purpose:** Change features/experience for specific user segments (premium users, beta testers, internal users).

**Characteristics:**
- Longevity: **Long** (potentially years for premium features)
- Dynamism: **Per-request** (user-specific decisions)
- Configuration: User/account attributes, group membership
- Who manages: Product teams, sometimes Customer Success

**Lifecycle expectation:** Premium feature flags may be permanent. Beta/"early access" flags should transition to full release.

**Example use cases:**
- Premium features for paying customers
- Alpha features for internal users only
- Beta features for opted-in users
- "Champagne Brunch" - internal team testing before release

**Fowler's term "Champagne Brunch":** Early opportunity to "drink your own champagne" - exposing features to internal or beta users before general availability.

### Mapping Dimensions to Implementation

Fowler identifies two critical dimensions that affect implementation:

```
                    DYNAMISM
                    
         Static                 Dynamic
         (per-deployment)       (per-request)
    ┌─────────────────────────────────────────┐
    │                    │                    │
S   │   RELEASE          │   EXPERIMENT       │
h   │   Simple if/else   │   Cohort logic     │
o   │   Config files     │   User hashing     │
r   │                    │                    │
t   ├─────────────────────────────────────────┤
    │                    │                    │
L   │   OPS              │   PERMISSIONING    │
O   │   Kill switches    │   User attributes  │
N   │   Admin UI         │   Group membership │
G   │                    │                    │
    └─────────────────────────────────────────┘
    
    LONGEVITY
```

**Implementation implications:**

| Dimension | Short-lived | Long-lived |
|-----------|-------------|------------|
| Code pattern | Simple if/else | Strategy pattern, DI |
| Testing | Test both paths | Essential to test both |
| Cleanup urgency | High | Lower, but still needed |

| Dimension | Static | Dynamic |
|-----------|--------|---------|
| Config source | Files, env vars | Database, distributed config |
| Toggle router | Simple lookup | Context-aware routing |
| Deployment | Reconfigure via deploy | Runtime changes |

### Categorizing "Page Replacement with Opt-in"

Your scenario: Replacing two pages with one unified page, allowing users to opt-in early and opt-out if needed.

**Analysis:**

This is a **hybrid flag** that transitions through categories:

| Phase | Category | Dynamism | Longevity |
|-------|----------|----------|-----------|
| Internal testing | Release Toggle | Static | Short |
| Opt-in beta | Permissioning Toggle | Per-user | Medium |
| Percentage rollout | Release Toggle | Per-user* | Short |
| Final migration | (flag removed) | N/A | N/A |

*Percentage rollout is technically per-user but with random assignment, not user attributes.

**Recommended classification:** Primary category is **Release Toggle** with a **Permissioning Toggle phase** for beta.

**Implementation implications:**
1. Start simple (Release Toggle pattern)
2. Add user-specific logic for opt-in phase
3. Use PostHog's Early Access Feature Management for the opt-in UI
4. Plan cleanup aggressively - don't let the "permissioning" phase extend indefinitely

### Flag Lifecycle Stages (Unleash Framework)

Unleash defines five lifecycle stages that apply across all categories:

1. **Define** - Flag created, no code written yet
2. **Develop** - Code in progress, not live, internal testing
3. **Production** - Deployed, gradually rolling out to users
4. **Cleanup** - Decision made (keep/discard), flag still active, code cleanup needed
5. **Archived** - Flag disabled, code removed

**Lifecycle bottleneck signals:**

| Stuck in... | Possible cause |
|-------------|----------------|
| Define | Unclear requirements, blocked dependencies |
| Develop | Testing delays, bugs, integration issues |
| Production | Missing success criteria, unclear ownership |
| Cleanup | Technical debt accumulation, no cleanup discipline |

### Cleanup Timing by Category

| Category | Expected Lifetime | Cleanup Trigger |
|----------|-------------------|-----------------|
| Release | 1-2 weeks post-completion | Feature validated in production |
| Experiment | Until statistical significance | Results analyzed, decision made |
| Ops (short) | Weeks | Performance confidence established |
| Ops (kill switch) | Permanent | Never (but review periodically) |
| Permissioning (beta) | Weeks to months | Full rollout decision |
| Permissioning (premium) | Years | Business model change |

**For page replacement:** Target 4-8 weeks total lifecycle:
- Week 1-2: Internal testing
- Week 2-4: Opt-in beta
- Week 4-6: Percentage rollout (10% → 50% → 100%)
- Week 6-8: Cleanup phase
- Week 8: Flag archived, old code removed

### Naming Conventions for Flag Categories

Fowler doesn't prescribe naming, but Unleash and industry practice suggest:

**Prefix patterns:**
```
release-unified-planning-page     # Release toggle
exp-new-checkout-flow             # Experiment toggle
ops-disable-recommendations       # Ops toggle
perm-premium-analytics            # Permissioning toggle
beta-unified-planning-page        # Permissioning (early access variant)
```

**Include metadata in structured config:**
```yaml
unified-planning-page:
  category: release
  owner: planning-team
  created: 2026-01-22
  expected-cleanup: 2026-03-01
  description: "Replace shipment/planning pages with unified view"
```

**Benefits of categorized naming:**
1. Grep for `release-*` to find cleanup candidates
2. Audit `perm-*` flags for access control review
3. Alert on `exp-*` flags exceeding expected duration
4. Distinguish `ops-*` flags that need operational runbooks

### Handling Flags That Span Categories

Some flags legitimately span categories. Your page replacement is an example.

**Approaches:**

1. **Single flag, changing interpretation**
   - Start as release toggle
   - Configuration evolves (add user targeting for beta)
   - Simplify back for final rollout
   - Pros: Single flag to track
   - Cons: Configuration complexity

2. **Multiple flags for each phase**
   ```
   release-unified-page-dev       # Internal testing (static)
   beta-unified-page-opt-in       # User opt-in (per-user)
   release-unified-page-rollout   # Percentage rollout (% based)
   ```
   - Pros: Clear separation, easier cleanup
   - Cons: More flags to manage, coordination overhead

3. **Flag with multiple activation strategies** (PostHog/Unleash approach)
   - Single flag with layered rules:
     1. Internal team = always on
     2. Opted-in users = on
     3. Percentage rollout = X%
   - Pros: Best of both worlds
   - Cons: More complex configuration

**Recommendation for page replacement:** Use approach #3 (single flag, multiple strategies) with PostHog's Early Access Feature Management for the opt-in phase.

### Technical Debt Implications

> "Feature flags are a form of technical debt." - Unleash

**Why flags create debt:**
- Multiple code paths to maintain
- Testing complexity (2^n combinations)
- Stale flags can cause bugs or security issues
- Context loss as time passes or personnel changes

**Debt mitigation strategies:**
1. **Set expiration dates** at flag creation
2. **Assign owners** responsible for cleanup
3. **Track lifecycle stages** with tooling
4. **Sprint tasks** for flag removal (treat like any tech debt)
5. **Archive, don't delete** - maintain audit trail

**Long-lived flags (Ops, Permissioning) need extra care:**
- Document thoroughly
- Include in operational runbooks
- Review periodically (quarterly?)
- Test both paths in CI/CD

## Sources

| Source | Type | Key Contribution |
|--------|------|------------------|
| [Martin Fowler - Feature Toggles](https://martinfowler.com/articles/feature-toggles.html) | Authoritative article | Four-category framework, implementation patterns, longevity/dynamism dimensions |
| [Unleash - 11 Principles](https://docs.getunleash.io/topics/feature-flags/feature-flag-best-practices) | Best practices | Make flags short-lived, avoid config misuse, naming uniqueness |
| [Unleash - Feature Flags at Scale](https://docs.getunleash.io/guides/best-practices-using-feature-flags-at-scale) | Best practices | Lifecycle stages, technical debt management, cleanup discipline |

## Questions for Further Research

- [ ] How does PostHog's Early Access Feature Management interact with percentage rollouts?
- [ ] What's the best way to transition a flag from opt-in to percentage rollout in PostHog?
- [ ] How to handle users who opted-in during beta when moving to general availability?
- [ ] Should opt-in state be stored in PostHog properties or application database?
