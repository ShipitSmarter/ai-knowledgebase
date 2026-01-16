---
title: Warehouse Worker/Manager Persona
type: primary
frequency: daily
status: draft
---

# Warehouse Worker/Manager

## Overview

The Warehouse Worker/Manager is responsible for the physical execution of shipping operations. They create shipments, print labels, and resolve exceptions that occur during the pick/pack process. This is a high-volume, time-pressured role where efficiency directly impacts the warehouse's throughput and customer satisfaction.

## Demographics

| Attribute              | Typical Profile                                                              |
| ---------------------- | ---------------------------------------------------------------------------- |
| **Job Titles**         | Shipping Clerk, Warehouse Associate, Shipping Manager, Logistics Coordinator |
| **Company Size**       | 50-500 employees (mid-market), 500+ (enterprise)                             |
| **Industry**           | Manufacturing, Spare Parts, Life Sciences, Distribution                      |
| **Location**           | Warehouse floor or shipping office                                           |
| **Tech Comfort**       | Moderate - uses operational software daily                                   |
| **Decision Authority** | Tactical (shipment level), limited strategic input                           |

## Goals & Motivations

### Primary Goals

1. **Process shipments quickly** - Get orders out the door on time
2. **Minimize errors** - Correct labels, right carriers, accurate documentation
3. **Handle exceptions efficiently** - Resolve pick/pack issues without delays
4. **End the day on time** - Complete workload within shift hours

### Underlying Motivations

- Job security through performance
- Pride in efficient operations
- Avoiding customer complaints that reflect poorly on the team
- Work-life balance (finishing on time)

## Pain Points & Frustrations

### Current Challenges

1. **Repetitive data entry** - Entering the same information multiple times across systems
2. **Carrier selection complexity** - Too many options, unclear which is best
3. **Exception overload** - Too many alerts, hard to prioritize what matters
4. **System switching** - Jumping between ERP, WMS, TMS, and carrier portals
5. **Label printing issues** - Wrong labels, printer problems, format inconsistencies
6. **Rush orders** - Last-minute requests disrupting planned workflow

### Emotional State

- Stressed during peak shipping times
- Frustrated by repetitive tasks
- Overwhelmed by exceptions
- Satisfied when shipments flow smoothly

## Jobs-to-be-Done

### Core Jobs

| Job                                 | Frequency    | Success Metric                      |
| ----------------------------------- | ------------ | ----------------------------------- |
| Create shipment from sales order    | 50-200/day   | Time per shipment, error rate       |
| Select appropriate carrier/service  | Per shipment | Cost optimization, delivery success |
| Print shipping labels and documents | Per shipment | Accuracy, first-time print success  |
| Handle pick/pack exceptions         | 5-20/day     | Resolution time, escalation rate    |
| Consolidate multi-item orders       | As needed    | Package efficiency                  |

### Related Jobs

| Job                                 | Frequency  | Notes                                |
| ----------------------------------- | ---------- | ------------------------------------ |
| Track shipment status               | Occasional | Typically handed to Customer Service |
| Report daily shipping volumes       | Daily      | For management visibility            |
| Coordinate with carriers for pickup | Daily      | Scheduling and preparation           |

## Workflow & Touchpoints

### Typical Day

```
06:00 - Shift start, review pending orders
06:30 - Begin processing orders by priority (expedited first)
08:00 - First carrier pickup window
10:00 - Handle exceptions from overnight
12:00 - Lunch break
13:00 - Afternoon order processing
15:00 - Final carrier pickup preparation
16:00 - End of day reporting
```

### System Touchpoints

1. **ERP/WMS** - Source of sales orders and inventory
2. **TMS (Viya)** - Carrier selection, shipment creation, label printing
3. **Carrier Portals** - Occasionally for special requirements
4. **Email/Chat** - Exception communication

### Key Viya Features Used

- Shipment creation
- Label printing
- Carrier selection/rating
- Exception management
- Bulk processing

## Persona Scenario

> **Maria, Shipping Manager at MedTech GmbH**
>
> Maria manages a team of 5 shipping clerks at a medical device manufacturer. They process 150-200 shipments daily, ranging from small spare parts to large equipment. Her biggest challenge is handling urgent orders for hospital equipment repairs while maintaining efficient flow for regular orders.
>
> "I need a system that tells me what's urgent and gets the routine stuff out of my way. Right now, everything looks the same priority and I'm constantly switching between screens to figure out what needs attention."

## Design Implications

### UI/UX Priorities

1. **Speed over features** - Minimize clicks for common tasks
2. **Clear prioritization** - Visual hierarchy for urgent vs routine
3. **Bulk operations** - Handle multiple shipments efficiently
4. **Error prevention** - Validations before costly mistakes
5. **Keyboard navigation** - Power users prefer keyboard to mouse

### Feature Priorities

1. One-click shipment creation from sales order
2. Smart carrier recommendation (default with override)
3. Exception dashboard with priority sorting
4. Batch printing and processing
5. Quick search and filter

### Metrics to Track

- Time from order to shipment created
- Error rate (wrong carrier, label issues)
- Exception resolution time
- Shipments per hour per user

## Relationship to Other Personas

| Persona                    | Relationship                                                    |
| -------------------------- | --------------------------------------------------------------- |
| **Customer Service/Sales** | Hands off shipments after creation; receives tracking inquiries |
| **Logistics Manager**      | Reports to; provides data for optimization                      |
| **Carrier/Rate Manager**   | Uses rates and rules they configure                             |
| **IT/Integrations Admin**  | Relies on integrations they set up                              |
| **Receiver**               | End customer of their work                                      |

## Competitive Context

From competitor analysis:

- **Cargoson** emphasizes ease of use for this persona
- **Sendcloud** targets e-commerce but similar workflow needs
- **Enterprise TMS** (SAP, Oracle) often too complex for this user

Viya differentiator: "Simplicity & joy" design principle directly addresses this persona's need for intuitive, fast tools.
