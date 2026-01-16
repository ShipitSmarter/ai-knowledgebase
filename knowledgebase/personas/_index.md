---
title: Viya TMS User Personas
date: 2026-01-16
status: draft
---

# Viya TMS User Personas

## Overview

This document defines the user personas for Viya TMS. These personas represent the distinct user groups we design for and are the foundation for team organization, feature prioritization, and product strategy.

Personas are categorized by their **frequency of interaction** and **strategic importance**:

| Category | Description | Design Priority |
|----------|-------------|-----------------|
| **Primary** | Daily users, high interaction frequency | Highest - optimize for speed and efficiency |
| **Secondary** | Weekly/monthly users, strategic decisions | High - optimize for insights and control |
| **Enabler** | Setup and maintenance, occasional use | Medium - optimize for self-service and reliability |
| **External** | Non-users who receive value from the system | Medium - optimize for simplicity and delight |

## Persona Summary

| # | Persona | Type | Frequency | Core Job-to-be-Done |
|---|---------|------|-----------|---------------------|
| 1 | [Warehouse Worker/Manager](./warehouse-worker-manager.md) | Primary | Daily | Create shipments, print labels, resolve exceptions |
| 2 | [Customer Service/Sales](./customer-service-sales.md) | Primary | Daily | Answer "where is my order", handle delays |
| 3 | [Logistics Manager](./logistics-manager.md) | Secondary | Weekly | Monitor KPIs, optimize costs, report to leadership |
| 4 | [Carrier/Rate Manager](./carrier-rate-manager.md) | Secondary | Weekly/Monthly | Manage rates, evaluate carrier performance |
| 5 | [IT/Integrations Admin](./it-integrations-admin.md) | Enabler | Setup + occasional | Connect systems, configure automation |
| 6 | [Receiver](./receiver.md) | External | Per shipment | Know when delivery arrives, self-service |

## Persona Relationship Map

```
                    ┌─────────────────┐
                    │    RECEIVER     │
                    │   (External)    │
                    └────────▲────────┘
                             │
                             │ tracking info, delivery
                             │
    ┌────────────────────────┼────────────────────────┐
    │                        │                        │
    │    ┌───────────────────┴───────────────────┐    │
    │    │        CUSTOMER SERVICE/SALES         │    │
    │    │             (Primary)                 │    │
    │    └───────────────────┬───────────────────┘    │
    │                        │                        │
    │                        │ status, exceptions     │
    │                        │                        │
    │    ┌───────────────────┴───────────────────┐    │
    │    │       WAREHOUSE WORKER/MANAGER        │    │
    │    │             (Primary)                 │    │
    │    └───────────────────┬───────────────────┘    │
    │                        │                        │
    │          ┌─────────────┼─────────────┐          │
    │          │             │             │          │
    │          ▼             ▼             ▼          │
    │  ┌───────────┐  ┌───────────┐  ┌───────────┐    │
    │  │ LOGISTICS │  │ CARRIER/  │  │ IT/INTEG  │    │
    │  │  MANAGER  │  │   RATE    │  │   ADMIN   │    │
    │  │(Secondary)│  │ MANAGER   │  │ (Enabler) │    │
    │  │           │  │(Secondary)│  │           │    │
    │  └───────────┘  └───────────┘  └───────────┘    │
    │                                                  │
    └──────────────────────────────────────────────────┘
                    SHIPPER ORGANIZATION
```

## Strategic Alignment

Each persona maps to strategic priorities from the [Strategy 2025-2030](./Strategy%202025-2030.md):

| Strategic Priority | Primary Personas | Product Focus |
|-------------------|------------------|---------------|
| **Automate repetitive transport workflows** | Warehouse Worker/Manager, IT Admin | Shipment automation, integration |
| **Simplify shipment visibility and tracking** | Customer Service/Sales, Receiver | Tracking portal, exception alerts |
| **Optimise carrier selection and transport spend** | Carrier/Rate Manager, Logistics Manager | Rates, analytics |
| **Clarify with powerful analytics** | Logistics Manager | Dashboards, KPIs, reporting |

## Pain Point Matrix

Cross-referencing common pain points across personas:

| Pain Point | Warehouse | CS/Sales | Logistics Mgr | Carrier Mgr | IT Admin |
|------------|:---------:|:--------:|:-------------:|:-----------:|:--------:|
| Repetitive manual work | ●●● | ● | ●● | ●●● | ● |
| Exception overload | ●●● | ●●● | ● | ● | - |
| Data quality issues | ● | ● | ●●● | ●● | ●● |
| Carrier performance visibility | - | ● | ●● | ●●● | - |
| Integration complexity | - | - | - | ● | ●●● |
| Lack of proactive alerts | ● | ●●● | ● | ● | ● |

Legend: ●●● = Major pain, ●● = Moderate, ● = Minor, - = Not applicable

## Design Principles by Persona

| Persona | Key Design Principle |
|---------|---------------------|
| Warehouse Worker/Manager | **Speed over features** - minimize clicks, keyboard-first |
| Customer Service/Sales | **Proactive, not reactive** - surface problems before customers |
| Logistics Manager | **Insights, not just data** - actionable recommendations |
| Carrier/Rate Manager | **Single source of truth** - centralized rate management |
| IT/Integrations Admin | **Self-service** - minimize vendor dependency |
| Receiver | **Simple and branded** - feels like shipper's service |

## Competitive Differentiation by Persona

| Persona | Competitor Strength | Viya Opportunity |
|---------|---------------------|------------------|
| Warehouse Worker/Manager | Cargoson: ease of use, low price | Match ease of use, differentiate on power |
| Customer Service/Sales | project44: visibility platform | Integrated execution + visibility |
| Logistics Manager | Blue Yonder: advanced analytics | Right-sized analytics for mid-market |
| Carrier/Rate Manager | Transporeon: massive carrier network | European expertise, simpler setup |
| IT/Integrations Admin | Enterprise: deep ERP integration | Faster, lighter implementation |
| Receiver | Sendcloud: branded tracking | B2B-appropriate tracking experience |

## Using These Personas

### For Product Teams
1. Reference personas when defining user stories
2. Validate features against persona goals and pain points
3. Prioritize based on persona type (Primary > Secondary > Enabler > External)
4. Test with real users matching persona profiles

### For Design
1. Design flows optimized for each persona's frequency
2. Apply persona-specific design principles
3. Consider persona relationships in navigation and information architecture

### For Engineering
1. Understand who will use what you build
2. Consider performance requirements (Primary personas need speed)
3. Understand integration persona's needs for APIs and configuration

### For Sales/Marketing
1. Use personas in sales conversations
2. Create persona-specific messaging and case studies
3. Identify which personas are buyers vs users

## Change Log

| Date | Change | Author |
|------|--------|--------|
| 2026-01-16 | Initial persona framework created | AI (with Wouter) |

## Related Documents

- [Team Structure Matrix](./team-structure-matrix.md)
- [Strategy 2025-2030](./Strategy%202025-2030.md)
- [Mission & Vision](./Mission%20&%20Vision.md)
- [Competitor Analysis](../research/company-context/2026-01-13-competitor-analysis.md)
