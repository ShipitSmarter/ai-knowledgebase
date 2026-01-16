---
title: Customer Service / Sales Rep Persona
type: primary
frequency: daily
status: draft
---

# Customer Service / Sales Rep

## Overview

The Customer Service/Sales Rep is the primary contact point for shipment inquiries from customers and internal stakeholders. They answer "where is my order" questions, proactively communicate delays, and resolve delivery exceptions. This persona is critical for customer satisfaction and retention.

## Demographics

| Attribute | Typical Profile |
|-----------|-----------------|
| **Job Titles** | Customer Service Rep, Inside Sales, Account Manager, Order Desk |
| **Company Size** | 50-500 employees (mid-market), 500+ (enterprise) |
| **Industry** | Manufacturing, Spare Parts, Life Sciences, Distribution |
| **Location** | Office environment (often remote/hybrid) |
| **Tech Comfort** | High - multiple systems simultaneously |
| **Decision Authority** | Limited - follows policies, escalates exceptions |

## Goals & Motivations

### Primary Goals
1. **Answer customer inquiries quickly** - Reduce call/email handling time
2. **Proactively communicate issues** - Catch problems before customers call
3. **Resolve delivery exceptions** - Reroute, reschedule, find solutions
4. **Maintain customer satisfaction** - Build loyalty through service

### Underlying Motivations
- Positive customer interactions (job satisfaction)
- Meeting service level targets
- Avoiding escalations to management
- Building long-term customer relationships

## Pain Points & Frustrations

### Current Challenges
1. **Information scattered across systems** - Must check ERP, TMS, carrier portals
2. **No proactive alerts** - Finds out about delays after customer calls
3. **Carrier tracking inconsistency** - Different formats, update frequencies
4. **Manual status communication** - Copying/pasting tracking info
5. **Exception resolution complexity** - Unclear what options are available
6. **Customer frustration spillover** - Takes heat for shipping issues they can't control

### Emotional State
- Anxious about customer calls regarding delayed shipments
- Frustrated by having to search multiple systems
- Relieved when tracking is clear and accurate
- Proud when resolving issues proactively

## Jobs-to-be-Done

### Core Jobs
| Job | Frequency | Success Metric |
|-----|-----------|----------------|
| Answer "where is my order" | 20-50/day | Response time, accuracy |
| Identify delayed shipments proactively | Continuous | Delays caught before customer contact |
| Communicate delivery updates | As needed | Customer satisfaction, NPS |
| Resolve delivery exceptions | 5-15/day | Resolution rate, escalation rate |
| Update customer on resolution | Per exception | Communication clarity |

### Related Jobs
| Job | Frequency | Notes |
|-----|-----------|-------|
| Process returns/claims | Weekly | Often handled by separate team |
| Escalate to carrier | As needed | For serious delivery failures |
| Coordinate with warehouse | As needed | For re-shipments |

## Workflow & Touchpoints

### Typical Day

```
08:00 - Check exception dashboard, identify at-risk shipments
08:30 - Proactive outreach for known delays
09:00 - Begin handling incoming inquiries (phone, email, chat)
12:00 - Lunch break
13:00 - Afternoon inquiry handling
15:00 - Follow up on open exceptions
16:30 - Handover notes for next shift
```

### System Touchpoints
1. **TMS (Viya)** - Primary tracking and exception view
2. **CRM** - Customer history and communication log
3. **Carrier Portals** - Detailed tracking when needed
4. **Email/Phone** - Customer communication
5. **ERP** - Order and invoice information

### Key Viya Features Used
- Tracking and visibility dashboard
- Exception alerts and management
- Customer communication tools
- Shipment history search
- Proof of delivery access

## Persona Scenario

> **Thomas, Customer Service Lead at SparePartsPro**
>
> Thomas leads a team of 8 customer service reps handling inquiries for a spare parts distributor. They receive 200+ "where is my order" calls daily, with peaks during product launches. His biggest frustration is finding out about delays from angry customers instead of getting proactive alerts.
>
> "I want to call the customer before they call me. If I know a shipment is delayed, I can apologize and offer solutions. But right now, I'm always reacting instead of being proactive. That makes me look bad and makes the customer angrier."

## Design Implications

### UI/UX Priorities
1. **Single pane of glass** - All shipment info in one view
2. **Proactive alerting** - Surface problems before customers notice
3. **Quick search** - Find any shipment in seconds
4. **Exception prioritization** - Focus on high-impact issues first
5. **Communication tools** - Easy customer notification

### Feature Priorities
1. Exception dashboard with smart prioritization
2. Proactive delay detection and alerting
3. One-click customer notification
4. Unified tracking across all carriers
5. Customer-facing tracking portal (self-service)

### Metrics to Track
- Average response time to inquiries
- % of delays caught proactively
- Customer satisfaction (NPS/CSAT)
- Exception resolution time
- Self-service tracking usage

## Relationship to Other Personas

| Persona | Relationship |
|---------|--------------|
| **Warehouse Worker/Manager** | Receives shipment info after creation |
| **Logistics Manager** | Reports exception patterns for improvement |
| **Carrier/Rate Manager** | Escalates carrier performance issues |
| **IT/Integrations Admin** | Relies on tracking data quality |
| **Receiver** | Primary contact for delivery issues |

## Competitive Context

From competitor analysis:
- **project44** excels at visibility for this persona
- **Sendcloud** offers branded tracking pages
- **Enterprise TMS** often lacks customer-facing tools

Viya differentiator: "Highlight what matters" principle directly addresses exception overload; integrated tracking portal serves both this persona and Receiver.
