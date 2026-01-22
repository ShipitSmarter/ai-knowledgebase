---
topic: Communication Patterns for Feature Flag Rollouts with Intercom
date: 2026-01-22
project: feature-flags
status: reviewed
sources_count: 6
tags: [intercom, posthog, feature-flags, beta-program, customer-communication, rollout]
---

# Communication Patterns for Feature Flag Rollouts with Intercom

## Summary

This document outlines practical communication strategies for announcing and managing feature flag rollouts using Intercom, specifically for opt-in beta programs managed with PostHog feature flags. The approach centers on syncing PostHog user properties to Intercom custom attributes, enabling targeted messaging based on feature flag state. Key channels include in-app banners for awareness, event-triggered messages for transactional updates, and Product Tours for onboarding users to new features.

Effective beta communication requires a multi-phase approach: pre-launch teaser, opt-in invitation, onboarding for beta users, feedback collection during the beta period, and deprecation notices as the old experience is retired. Intercom's audience filtering combined with PostHog's feature flag data creates powerful segmentation for showing the right message to the right users at the right time.

## Key Findings

1. **Sync PostHog properties to Intercom as custom data attributes** - This enables audience segmentation based on feature flag state (e.g., `betaNewPage: true`)
2. **Use banners for non-intrusive announcements** - Banners are ideal for feature announcements, beta invitations, and deprecation notices
3. **Event-based messaging for transactional updates** - Trigger messages when users opt-in, complete key actions, or need feedback requests
4. **Product Tours for onboarding** - Link banners to Product Tours to guide beta users through new features
5. **Track events in both systems** - Send `beta-opted-in`, `new-page-visited`, `feedback-submitted` events for targeting
6. **Use emoji reactions for quick NPS-style feedback** - Banners support emoji reactions for lightweight sentiment collection
7. **Schedule deprecation announcements** - Use Intercom's scheduling to phase out old page notices over time

## Detailed Analysis

### 1. PostHog to Intercom Data Sync

To segment Intercom messages based on feature flag state, you need to sync relevant PostHog person properties to Intercom as custom data attributes.

#### Implementation Pattern

```javascript
// When user opts into beta via PostHog
posthog.setPersonProperties({
  beta_new_page: true,
  beta_opted_in_at: new Date().toISOString()
});

// Sync to Intercom (same session)
Intercom('update', {
  beta_new_page: true,
  beta_opted_in_at: new Date().toISOString()
});
```

#### Recommended Custom Attributes for Intercom

| Attribute | Type | Purpose |
|-----------|------|---------|
| `beta_new_page` | Boolean | Feature flag state for new page |
| `beta_opted_in_at` | Date | When user joined beta |
| `feature_flag_variant` | String | A/B test variant if applicable |
| `old_page_usage_count` | Number | Track engagement with old page |
| `new_page_first_visit` | Date | Onboarding milestone tracking |

### 2. Message Types and When to Use Them

#### Banners (Primary Channel for Announcements)

Best for: Broad awareness, non-urgent announcements, feature invitations

**Beta Invitation Banner** (for users NOT in beta):
- **Audience**: `beta_new_page is false` OR `beta_new_page is unknown`
- **Style**: Floating, top position, dismissible
- **Action**: Link to opt-in page or trigger opt-in directly
- **Goal**: Track `beta_new_page is true`

**New Feature Onboarding Banner** (for users IN beta):
- **Audience**: `beta_new_page is true` AND `new_page_first_visit is unknown`
- **Style**: Inline, top position, non-dismissible until action
- **Action**: Launch Product Tour
- **Goal**: Track completion of product tour

**Deprecation Notice Banner** (for users NOT in beta):
- **Audience**: `beta_new_page is false`
- **Style**: Inline, warning color (yellow/orange)
- **Action**: Link to migration guide or opt-in
- **Scheduling**: Start 2 weeks before deprecation, increase urgency over time

#### Event-Based Messages (Transactional)

Best for: Confirmations, feedback requests, milestone celebrations

Track these events for targeting:
```javascript
// User opts into beta
Intercom('trackEvent', 'beta-opted-in', {
  feature: 'new-page',
  source: 'banner-click'
});

// User completes first action in new feature
Intercom('trackEvent', 'new-page-milestone', {
  milestone: 'first-shipment-created',
  time_to_milestone: 45 // minutes
});

// Feedback window (after 7 days of usage)
Intercom('trackEvent', 'beta-feedback-eligible', {
  feature: 'new-page',
  days_in_beta: 7
});
```

### 3. Message Templates

#### Beta Invitation Template

```
New [Feature Name] is here! Want to try it early?

We've redesigned [feature area] based on your feedback. Beta users 
get early access and help shape the final product.

[Try the Beta] → opens opt-in flow
```

**Intercom Configuration**:
- Type: Banner (floating)
- Action: Open URL (opt-in page) OR Launch Product Tour
- Dismiss on click: Yes
- Show avatar: No (for announcement feel)

#### Opt-In Confirmation Template

```
Welcome to the [Feature Name] beta!

You're now using the new experience. Here's what's different:
• [Key benefit 1]
• [Key benefit 2]
• [Key benefit 3]

Need help? Click the chat icon anytime.

[Take a Quick Tour] → launches Product Tour
```

**Trigger**: Event `beta-opted-in` where feature = 'new-page'

#### Feedback Request Template

```
How's the new [Feature Name] working for you?

You've been using it for [days] days. We'd love your feedback!

[Great] [Okay] [Needs work]
```

**Intercom Configuration**:
- Type: Banner with emoji reactions
- Trigger: Event `beta-feedback-eligible`
- Frequency: Once per user
- Dismiss on click: Yes

#### Deprecation Warning Templates

**Phase 1 (2 weeks out)**:
```
Heads up: The classic [Feature] view is retiring on [Date].

The new version has [key benefit]. Switch now to get familiar 
before the change.

[Switch to New Version]
```

**Phase 2 (1 week out)**:
```
One week left: Classic [Feature] retiring [Date]

All your data will automatically transfer. Switch now to avoid 
any workflow disruption.

[Switch Now] [Learn More]
```

**Phase 3 (Final days)**:
```
Action Required: Classic [Feature] ends [Date]

This is your last chance to switch voluntarily. After [Date], 
everyone moves to the new version.

[Switch Now]
```

### 4. Segmentation Strategies

#### Audience Rules for Different States

| User State | Intercom Filter | Message Type |
|------------|-----------------|--------------|
| Not aware of beta | `beta_new_page unknown` | Teaser banner |
| Aware but not opted in | `beta_new_page = false` | Invitation banner |
| Just opted in | `beta_new_page = true` AND `new_page_first_visit unknown` | Onboarding tour |
| Active beta user | `beta_new_page = true` AND `days_since_opt_in > 7` | Feedback request |
| Inactive beta user | `beta_new_page = true` AND `last_new_page_visit > 14 days` | Re-engagement |
| Heavy old page user | `beta_new_page = false` AND `old_page_usage_count > 50` | Targeted migration |

### 5. Feedback Collection Methods

#### In-Banner Reactions (Lightweight)

- Best for: Quick sentiment at scale
- Format: Emoji reactions (thumbs up/down or star rating)
- Use when: You want volume over depth
- Follow-up: Filter dissatisfied users for deeper outreach

#### Intercom Surveys (Detailed)

- Best for: Structured feedback on specific aspects
- Trigger: After milestone events or time-based
- Questions: Keep to 3-5 max
- Example questions:
  1. "How easy was it to [complete task] in the new version?" (1-5)
  2. "What's missing from the new [Feature]?" (free text)
  3. "Would you recommend the new [Feature] to a colleague?" (NPS)

#### In-Conversation Feedback (Qualitative)

- Best for: Understanding edge cases and power user needs
- Method: Proactive outreach to high-engagement beta users
- Approach: Personal message from product team, not automated

### 6. Communication Cadence

#### Pre-Launch Phase (2 weeks before beta)
| Day | Action | Channel |
|-----|--------|---------|
| -14 | Internal announcement to team | Email/Slack |
| -7 | Teaser for power users | Targeted banner |
| -3 | Documentation and help articles ready | Help center |
| -1 | Final testing of all Intercom messages | Test banner |

#### Beta Launch Phase (Day 0-7)
| Day | Action | Channel |
|-----|--------|---------|
| 0 | Beta invitation banner goes live | Banner (all users) |
| 0 | Welcome message triggers on opt-in | Event message |
| 1 | Product Tour available | Tour via banner |
| 3 | Check-in message for early adopters | Event message |
| 7 | First feedback request | Banner with reactions |

#### Beta Active Phase (Week 2-4)
| Day | Action | Channel |
|-----|--------|---------|
| 14 | Feature update announcement | Banner (beta users) |
| 14 | Re-engagement for inactive beta users | Targeted message |
| 21 | Detailed survey to engaged users | Intercom Survey |
| 28 | "Thank you" message, announce GA timeline | Banner |

#### Deprecation Phase (4 weeks before end)
| Week | Action | Channel |
|------|--------|---------|
| -4 | First deprecation notice | Banner (non-beta) |
| -2 | Increased urgency message | Banner (non-beta) |
| -1 | Final warning | Persistent banner |
| 0 | Forced migration, confirmation message | Event message |

### 7. Technical Implementation Notes

#### Keeping PostHog and Intercom in Sync

Option A: Client-side dual-write (simple)
```javascript
function optIntoBeta() {
  // PostHog
  posthog.setPersonProperties({ beta_new_page: true });
  
  // Intercom
  Intercom('update', { beta_new_page: true });
  
  // Track event for messaging
  Intercom('trackEvent', 'beta-opted-in', { feature: 'new-page' });
}
```

Option B: Server-side sync via webhooks (robust)
- PostHog webhook on person property change
- Backend updates Intercom via REST API
- Ensures consistency even if user closes browser

#### Event Naming Conventions

Recommended pattern: `{action}-{subject}`
- `beta-opted-in`
- `beta-opted-out`
- `new-page-visited`
- `new-page-milestone-reached`
- `feedback-submitted`
- `tour-completed`
- `tour-dismissed`

## Sources

| Source | URL | Key Contribution |
|--------|-----|------------------|
| Intercom Help - Custom Data Attributes | https://www.intercom.com/help/en/articles/213-customize-intercom-to-be-about-your-users | User segmentation with custom attributes |
| Intercom Help - Event Tracking | https://www.intercom.com/help/en/articles/175-set-up-event-tracking-in-intercom | JavaScript API for event tracking |
| Intercom Help - Event-Based Messages | https://www.intercom.com/help/en/articles/5180516-send-repeatable-messages-based-on-events-you-track-in-intercom | Triggering messages on events |
| Intercom Help - Banner Messages | https://www.intercom.com/help/en/articles/4557393-how-to-create-a-banner-message | Banner configuration and best practices |
| Intercom Help - Banner Best Practices | https://www.intercom.com/help/en/articles/4557552-banner-message-best-practices-example-uses | Feature announcement templates |
| PostHog Docs - Person Properties | https://posthog.com/docs/product-analytics/person-properties | Setting and syncing user properties |

## Questions for Further Research

- [ ] Is there a native PostHog-Intercom integration, or is manual sync required?
- [ ] Can Intercom surveys be triggered by PostHog events directly?
- [ ] What's the latency between setting a custom attribute and it being available for filtering?
- [ ] How do Product Tours interact with feature flags (show different tours to different variants)?
- [ ] What are rate limits on Intercom event tracking that might affect high-traffic rollouts?
