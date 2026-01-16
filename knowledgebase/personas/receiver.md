---
title: Receiver Persona
type: external
frequency: per-shipment
status: draft
---

# Receiver (End Customer)

## Overview

The Receiver is the ultimate customer - the person or company receiving the shipped goods. While not a direct Viya user in most cases, the Receiver's experience significantly impacts customer satisfaction and the shipper's reputation. Viya serves Receivers primarily through self-service tracking portals and proactive communication.

## Demographics

| Attribute | Typical Profile |
|-----------|-----------------|
| **Role** | Customer of Viya's customers |
| **Types** | B2B: Receiving dock, maintenance, operations; B2C: End consumer |
| **Industry** | Varies (customers of manufacturers, distributors, etc.) |
| **Location** | Receiving location (warehouse, office, home) |
| **Tech Comfort** | Varies widely |
| **Decision Authority** | None in Viya - consumer of information |

## Goals & Motivations

### Primary Goals
1. **Know when delivery arrives** - Plan for receiving
2. **Track shipment status** - Self-service answers
3. **Get proactive updates** - Know about delays before asking
4. **Resolve issues quickly** - If problems occur

### Underlying Motivations
- Reduce uncertainty and planning stress
- Avoid wasted time waiting for deliveries
- Get issues resolved without long hold times
- Feel valued as a customer

## Pain Points & Frustrations

### Current Challenges
1. **No visibility** - "When will it arrive?" is a mystery
2. **Must contact shipper** - No self-service tracking option
3. **Inconsistent updates** - Different experience per carrier
4. **Last-minute delays** - Find out about problems too late
5. **Difficult returns/claims** - Complex processes when issues occur
6. **Impersonal communication** - Generic carrier notifications

### Emotional State
- Anxious about unknown delivery times
- Frustrated by lack of information
- Relieved when tracking is clear
- Delighted by proactive communication

## Jobs-to-be-Done

### Core Jobs
| Job | Frequency | Success Metric |
|-----|-----------|----------------|
| Check delivery status | Per shipment | Self-service success rate |
| Plan for receiving | Per shipment | Accuracy of ETA |
| Get notified of changes | As needed | Proactive vs reactive |
| Report delivery issues | As needed | Resolution time |

### Related Jobs
| Job | Frequency | Notes |
|-----|-----------|-------|
| Initiate returns | Occasionally | May involve separate process |
| Provide delivery feedback | Occasionally | Rating, reviews |
| Coordinate special requirements | As needed | Time windows, appointments |

## Workflow & Touchpoints

### Typical Experience

```
Order Placed
    │
    ▼
Shipment Confirmation ──► Receives tracking link
    │
    ▼
In Transit ──────────────► Checks tracking status (self-service)
    │
    ▼
[Delay Occurs] ──────────► Receives proactive notification
    │
    ▼
Out for Delivery ────────► Knows to expect delivery
    │
    ▼
Delivered ───────────────► Confirmation, POD available
```

### Touchpoints with Viya (Indirect)
1. **Tracking Portal** - Customer-branded tracking page
2. **Email Notifications** - Status updates, delay alerts
3. **SMS Updates** - Time-sensitive notifications
4. **POD Access** - Proof of delivery documents

### Key Viya Features Used (via Shipper)
- Customer-facing tracking portal
- Automated email/SMS notifications
- Proof of delivery
- Delay detection and alerting
- Branded communication templates

## Persona Scenario

> **B2B Example: Henrik, Maintenance Technician at Factory**
>
> Henrik needs a spare part to repair critical equipment. Production is down until the part arrives. He was given a tracking number but the carrier's tracking page shows "In Transit" with no ETA. He has to call the supplier multiple times to get updates, wasting time and increasing frustration.
>
> "I just need to know when it's arriving so I can be at the dock. Right now I'm checking my email every 10 minutes and calling the supplier twice a day."

> **B2B Example: Sophie, Receiving Manager at Distribution Center**
>
> Sophie manages inbound receiving at a busy DC. She needs to plan dock door assignments and labor. Without accurate ETAs, she often has trucks waiting or dock doors sitting empty. Proactive delay notifications would help her adjust plans.
>
> "If I knew yesterday that this shipment would be 4 hours late, I could have rescheduled the dock appointment. Instead, I have a truck waiting and another one with no door."

## Design Implications

### UI/UX Priorities
1. **Simple, clear tracking** - Status at a glance
2. **Mobile-first** - Often checked on phone
3. **Branded experience** - Feels like shipper's service
4. **Proactive notifications** - Push, don't require pull
5. **Accessibility** - Works for all users

### Feature Priorities
1. Customer-facing tracking portal
2. Configurable notification preferences
3. Accurate ETA predictions
4. Proactive delay detection
5. Easy escalation to shipper

### Metrics to Track
- Tracking portal usage rate
- Self-service vs contact ratio
- Notification delivery rate
- Customer satisfaction (from shipper feedback)

## Relationship to Other Personas

| Persona | Relationship |
|---------|--------------|
| **Warehouse Worker/Manager** | Source of shipment |
| **Customer Service/Sales** | Primary contact for issues |
| **Logistics Manager** | Indirect - SLAs affect experience |
| **Carrier/Rate Manager** | Indirect - carrier performance matters |
| **IT/Integrations Admin** | Enables tracking data flow |

## Competitive Context

From competitor analysis:
- **Sendcloud** excels at branded tracking pages for e-commerce
- **project44** strong on carrier tracking aggregation
- **Cargoson** offers real-time tracking

Viya differentiator: "Improving visibility and tracking for customer and receiver" is a core strategic priority. Customer Journey exception handling is a key differentiator - catching and communicating issues before they impact the receiver.

## Value to Shipper

While Receivers don't pay for Viya, their experience drives:
- **Customer satisfaction** - Happy receivers = repeat business
- **Reduced support costs** - Self-service tracking reduces calls
- **Competitive advantage** - Better experience than competitors
- **Exception handling** - Proactive communication reduces complaints
- **Brand perception** - Smooth logistics = professional company
