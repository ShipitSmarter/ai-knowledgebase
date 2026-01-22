---
topic: Monitoring & Rollback Strategies for Feature Flag Rollouts
date: 2026-01-22
project: feature-flags
sources_count: 10
status: reviewed
tags: [feature-flags, monitoring, rollback, posthog, canary-release, incident-management]
---

# Monitoring & Rollback Strategies for Feature Flag Rollouts

## Summary

Effective monitoring and rollback strategies are critical for safe feature flag rollouts. The key insight from industry practice is that feature flags should serve as "kill switches" - enabling instant rollback within seconds, not hours. PostHog provides three primary tools for rollout monitoring: real-time analytics dashboards, session replay for debugging, and feature flag filtering in all reports.

The monitoring approach should focus on three metric categories: (1) technical health (error rates, latency, crashes), (2) user behavior (engagement, conversion rates, drop-off points), and (3) business outcomes (revenue, support tickets). Rollback decisions should be tied to predefined thresholds (SLOs) - for example, "roll back if error rate exceeds 2x baseline" or "roll back if conversion drops >10%." This removes subjective judgment from high-pressure situations.

Data consistency during rollback is the most complex challenge. The safest approach is to design the new feature to be additive - never delete or modify data in ways that can't be reversed. If the new page creates data structures that don't exist in the old system, implement a backward-compatible API layer or accept that some users may need manual data migration.

## Key Findings

1. **Instant rollback is the #1 safety net**: Feature flags enable disabling a feature in <1 minute vs. hours for code deployment rollback. PostHog flags update within 30 seconds for client-side evaluation.

2. **Monitor the delta, not absolutes**: Compare metrics between flag-on and flag-off cohorts rather than tracking absolute numbers. A 5% error rate might be normal for your system, but a 2x increase vs. control group signals a problem.

3. **Session replay is your debugging superpower**: PostHog's session replay can be filtered by feature flag state, allowing you to watch exactly what users experienced when something went wrong.

4. **Define rollback criteria BEFORE rollout**: Document specific thresholds that trigger rollback (e.g., error rate >2%, latency >500ms p95). This removes ambiguity during incidents.

5. **"Bake time" prevents premature rollout expansion**: Microsoft recommends 24 hours minimum at each rollout stage before expanding to the next tier. Some issues only manifest under sustained load or specific usage patterns.

6. **Tiered rollouts follow the "blast radius" principle**: Start with users who have highest tolerance for issues (internal team, beta users) before expanding to general population. Facebook uses multiple canary tiers before full deployment.

7. **Data rollback is harder than code rollback**: Plan for data consistency early. Use additive-only changes, or maintain backward-compatible APIs during the rollout period.

## Detailed Analysis

### Metrics to Monitor During Rollout

Based on PostHog documentation and safe deployment practices from Microsoft, monitor these three categories:

#### Technical Health Metrics

| Metric | What to Watch | PostHog Implementation |
|--------|---------------|----------------------|
| Error rates | JavaScript exceptions, API failures | Track `$exception` events, filter by feature flag |
| Latency | Page load time, API response time | Use `$performance` autocapture or custom events |
| Crash-free rate | Browser crashes, unresponsive UI | Session replay shows browser state at crash |
| API error codes | 4xx/5xx responses from backend | Custom events with response codes |

#### User Behavior Metrics

| Metric | What to Watch | PostHog Implementation |
|--------|---------------|----------------------|
| Engagement | Time on page, interactions | Trends insight, compare flag-on vs flag-off |
| Conversion rates | Key actions completed | Funnels with breakdown by flag variant |
| Drop-off points | Where users abandon flows | Funnel analysis + session replay |
| Rage clicks | Signs of user frustration | Automatic detection in session replay |
| Feature adoption | New features actually being used | Track custom events for new functionality |

#### Business Outcome Metrics

| Metric | What to Watch | PostHog Implementation |
|--------|---------------|----------------------|
| Support ticket volume | Increase after rollout | Track via Intercom webhook or custom events |
| Revenue impact | Conversion to paid, upsells | Track with revenue events, breakdown by flag |
| User retention | Return visits after exposure | Retention insight, cohort by flag exposure date |

### PostHog Dashboard Setup for Rollout Monitoring

Create a dedicated "Rollout Monitoring" dashboard with these insights:

```
Dashboard: [Feature Name] Rollout Monitoring
├── Rollout Progress (Text card)
│   - Current phase: 10% → 25% → 50% → 100%
│   - Current percentage: X%
│   - Days at current tier: N
│
├── Error Rate Comparison (Trends)
│   - Filter: event = "$exception"
│   - Breakdown: feature flag variant
│   - Compare: flag-on vs flag-off
│
├── Page Load Performance (Trends)
│   - Filter: event = "$pageview", URL = new page
│   - Display: p50, p95, p99 load times
│
├── Key Conversion Funnel (Funnel)
│   - Steps: Page view → Key action → Completion
│   - Breakdown: feature flag variant
│
├── Session Replay Quick Access (Text card)
│   - Link to: Sessions filtered by flag + error events
│   - Link to: Sessions with rage clicks on new page
│
└── Daily Active Users (Trends)
    - Filter: unique users with flag-on
    - Compare: previous period
```

**Dashboard filters to add:**
- Feature flag = your rollout flag
- Person properties for segmentation (plan, role, etc.)
- Date range (since rollout started)

**Auto-refresh:** Enable auto-refresh (every 5-15 minutes) if displaying on a team monitor during active rollout.

### Using Session Replay for Debugging

PostHog session replay is invaluable for understanding WHY metrics changed, not just WHAT changed.

#### Filtering Replays by Feature Flag

1. Go to Session Recordings
2. Click "Filter" → "Show advanced filters"
3. Add filter: "Feature flag called" = your flag name
4. Add filter: "Feature flag response" = variant you want to inspect
5. Optionally add: "Events" = "$exception" to see error sessions

#### Debugging Workflow

When an issue is detected:

1. **Identify the problem** in analytics (error spike, conversion drop)
2. **Filter replays** by:
   - Feature flag = new variant
   - Event = the problematic event (error, drop-off page)
   - Time range = when issue started
3. **Watch 3-5 sessions** to understand the pattern
4. **Look for:**
   - UI elements not rendering correctly
   - User confusion (hovering, rage clicks)
   - Error messages displayed
   - Network failures in the timeline
5. **Use the event timeline** to jump directly to problematic moments
6. **Check console logs** (if enabled) for JavaScript errors

#### Session Replay Privacy Considerations

For sensitive pages, configure recording privacy:
- Mask inputs by default (`maskAllInputs: true`)
- Block specific elements (`blockClass: 'sensitive-data'`)
- Disable recording on certain pages if needed

### Rollback Implementation

#### Option 1: Disable Flag (Fastest - Recommended for Emergencies)

**PostHog UI:**
1. Go to Feature Flags
2. Find your rollout flag
3. Toggle "Enabled" to OFF

**Result:** All users immediately see old experience (within ~30 seconds for client-side flags)

**Pros:** Instant, no code deployment needed
**Cons:** Affects ALL users, including those who opted in

#### Option 2: Reduce Percentage to 0%

1. Go to Feature Flags
2. Edit rollout percentage: set to 0%
3. Save

**Result:** No new users get the flag, existing sessions may still have cached flag value until refresh

**Pros:** Can preserve opt-in users if implemented separately
**Cons:** Slightly slower than full disable

#### Option 3: Code-Level Fallback (For Graceful Degradation)

```javascript
// Vue component example
const useNewPage = computed(() => {
  try {
    return posthog.isFeatureEnabled('new-unified-page')
  } catch (error) {
    // If PostHog fails, default to old experience
    console.error('Feature flag evaluation failed:', error)
    return false
  }
})
```

**Pros:** Handles PostHog outages gracefully
**Cons:** Requires code deployment to change fallback behavior

#### Option 4: Emergency Kill Switch (Pre-planned)

Create a separate "ops toggle" flag that overrides the rollout:

```javascript
// Check kill switch first
if (posthog.isFeatureEnabled('kill-switch-new-page')) {
  return false // Force old experience
}
// Then check rollout flag
return posthog.isFeatureEnabled('new-unified-page')
```

**Pros:** Preserves rollout state while disabling feature
**Cons:** Extra complexity, two flags to manage

### Rollback Decision Criteria

Define these BEFORE starting rollout:

| Metric | Green | Yellow (Investigate) | Red (Roll Back) |
|--------|-------|---------------------|-----------------|
| Error rate | < 1% | 1-2% | > 2% or >2x baseline |
| P95 latency | < 300ms | 300-500ms | > 500ms |
| Conversion rate | > baseline | -5% to -10% | < -10% vs baseline |
| Support tickets | Normal | 1.5x increase | 2x+ increase |
| Rage clicks | < 5% sessions | 5-10% sessions | > 10% sessions |

#### Escalation Process

1. **Yellow metrics:** Investigate within 4 hours, pause rollout expansion
2. **Red metrics:** Immediate rollback (< 15 minutes decision)
3. **Multiple yellows:** Treat as red

### Handling Data Created During Rollout

This is the most complex aspect of rollback. Strategies depend on your data model:

#### Scenario A: New Page Uses Same Data Model

**Situation:** New page displays/edits the same entities as old pages
**Rollback impact:** Minimal - data is compatible
**Action:** No special handling needed

#### Scenario B: New Page Adds Fields to Existing Entities

**Situation:** New page adds `preferences.newPageSetting = true` to user records
**Rollback impact:** Old pages ignore new fields, data is safe
**Action:** Document that orphaned fields will be cleaned up after final migration

#### Scenario C: New Page Creates New Entities

**Situation:** New page creates `UnifiedView` records that replace old `ViewA` + `ViewB` records
**Rollback impact:** After rollback, users have `UnifiedView` data that old pages can't read
**Best practices:**
1. **Don't delete old data** during rollout - keep both representations
2. **Implement sync logic** that keeps old and new data in sync during rollout
3. **Accept some data loss** if the new feature was experimental (document this clearly)
4. **Manual migration path** for affected users if critical data is involved

#### Scenario D: Destructive Migration

**Situation:** New page fundamentally restructures data, old format is lost
**Rollback impact:** Cannot roll back without data loss
**Best practices:**
- **Avoid this pattern** if possible
- If unavoidable, create database backups before rollout
- Implement point-in-time recovery capability
- Document the "point of no return" clearly

### Communicating Rollback to Users

#### Immediate (Technical Issue)

If rolling back due to bugs/crashes:

**In-app notification (Vue toast/modal):**
> "We've temporarily reverted to the previous version while we fix an issue. Your data is safe. We'll notify you when the new experience is available again."

**Intercom message (to affected users):**
> "You may have noticed we rolled back a recent update. We identified [brief, non-technical description] and are working on a fix. Expected timeline: [X days]. We appreciate your patience."

#### Planned (Metrics Didn't Meet Goals)

If rolling back because adoption/metrics were poor:

**No immediate communication needed** - users return to familiar experience
**Post-rollback retrospective:**
- Survey users who tried the new experience
- Analyze session recordings for UX issues
- Plan iteration before next rollout attempt

### Monitoring Checklist for Rollout Day

```markdown
## Pre-Rollout (1 day before)
- [ ] Dashboard created with baseline metrics (7-day average)
- [ ] Rollback criteria documented and shared with team
- [ ] Session replay verified working on new page
- [ ] Error alerting configured (Slack/email for anomalies)
- [ ] Database backup created (if applicable)
- [ ] Team notified of rollout schedule

## Rollout Start
- [ ] Enable flag for first tier (internal users)
- [ ] Verify flag is working (test user sees new experience)
- [ ] Monitor dashboard for first 30 minutes
- [ ] Check session replay for any obvious issues

## First 24 Hours ("Bake Time")
- [ ] Review metrics every 4 hours
- [ ] Watch 5-10 session replays
- [ ] Check support queue for related tickets
- [ ] Document any issues found

## Expansion Decision
- [ ] All green metrics? → Proceed to next tier
- [ ] Any yellow metrics? → Investigate, delay expansion
- [ ] Any red metrics? → Execute rollback, post-mortem

## Post-Rollback (if needed)
- [ ] Verify users are seeing old experience
- [ ] Send communication to affected users
- [ ] Create incident report
- [ ] Schedule post-mortem meeting
```

## Sources

| Source | URL | Key Contribution |
|--------|-----|------------------|
| PostHog - Feature Flag Best Practices | https://posthog.com/docs/feature-flags/best-practices | Phased rollout patterns, fallback to working code |
| PostHog - Session Replay Filtering | https://posthog.com/tutorials/filter-session-recordings | Filter by feature flags, events, and user friction |
| PostHog - Phased Rollout Tutorial | https://posthog.com/tutorials/phased-rollout | Step-by-step rollout with flags and cohorts |
| PostHog - Feature Flag Troubleshooting | https://posthog.com/docs/feature-flags/common-questions | Rollout percentage behavior, evaluation consistency |
| PostHog - Dashboards Documentation | https://posthog.com/docs/product-analytics/dashboards | Dashboard creation, filters, auto-refresh |
| Martin Fowler - Canary Release | https://martinfowler.com/bliki/CanaryRelease.html | Tiered rollout, bake time, monitoring patterns |
| Microsoft - Safe Deployment Practices | https://learn.microsoft.com/en-us/devops/operate/safe-deployment-practices | Tier model, error budgets, hotfix processes |
| Firebase - Remote Config Rollouts | https://firebase.google.com/docs/remote-config/rollouts | Crashlytics integration, staged rollout monitoring |
| Atlassian - SLOs and Error Budgets | https://www.atlassian.com/incident-management/kpis/sla-vs-slo-vs-sli | Defining rollback thresholds, incident response |
| IMVU - Cluster Immune System | https://martinfowler.com/bliki/CanaryRelease.html (referenced) | Automated rollback on statistical regression |

## Questions for Further Research

- [ ] How to implement automated rollback based on metric thresholds (cluster immune system)?
- [ ] What's the optimal "bake time" for different types of features (UI changes vs. data processing)?
- [ ] How to A/B test the new page while also allowing opt-in? (Can both coexist in PostHog?)
- [ ] Integration between PostHog error tracking and alerting systems (PagerDuty, Opsgenie)?
