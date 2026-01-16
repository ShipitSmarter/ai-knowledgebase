---
title: Carrier/Rate Manager Persona
type: secondary
frequency: weekly-monthly
status: draft
---

# Carrier/Rate Manager

## Overview

The Carrier/Rate Manager maintains carrier relationships, manages rate cards, and evaluates carrier performance. They ensure the right carriers are available at competitive rates and work with logistics managers on carrier strategy. This is a specialized role that may be combined with Logistics Manager in smaller organizations.

## Demographics

| Attribute | Typical Profile |
|-----------|-----------------|
| **Job Titles** | Carrier Manager, Rate Analyst, Procurement Manager, Transport Coordinator |
| **Company Size** | Usually 200+ employees (role often combined in smaller companies) |
| **Industry** | Manufacturing, Spare Parts, Life Sciences, Distribution |
| **Location** | Office environment |
| **Tech Comfort** | Moderate to high - comfortable with complex rate structures |
| **Decision Authority** | Tactical (rate decisions), strategic input on carrier mix |

## Goals & Motivations

### Primary Goals
1. **Optimize transport costs** - Negotiate best rates without sacrificing service
2. **Maintain carrier relationships** - Strong partnerships for priority treatment
3. **Ensure carrier availability** - Right options for all shipment types
4. **Monitor carrier performance** - Identify underperformers, reward top performers

### Underlying Motivations
- Recognition for cost savings
- Strong vendor relationships (professional network)
- Avoiding carrier failures that impact customers
- Strategic influence on logistics decisions

## Pain Points & Frustrations

### Current Challenges
1. **Manual rate management** - Excel spreadsheets, version control issues
2. **Rate complexity** - Fuel surcharges, accessorials, zone-based pricing
3. **Performance data gaps** - Hard to objectively compare carriers
4. **Contract expiration tracking** - Missing renewal deadlines
5. **Rate audit difficulty** - Ensuring invoiced rates match contracted rates
6. **Carrier communication overhead** - Emails, calls, portals for each carrier

### Emotional State
- Frustrated by rate complexity and manual processes
- Anxious about missing cost savings opportunities
- Satisfied when negotiations yield measurable savings
- Proud of strong carrier partnerships

## Jobs-to-be-Done

### Core Jobs
| Job | Frequency | Success Metric |
|-----|-----------|----------------|
| Maintain rate cards | Monthly/Quarterly | Accuracy, coverage |
| Negotiate carrier contracts | Quarterly/Annually | Savings achieved |
| Monitor carrier performance | Weekly/Monthly | Performance visibility |
| Evaluate new carriers | As needed | Fit assessment accuracy |
| Audit carrier invoices | Monthly | Discrepancy rate |

### Related Jobs
| Job | Frequency | Notes |
|-----|-----------|-------|
| Resolve carrier disputes | As needed | Invoice or service issues |
| Support RFP/tender process | Annually | Major carrier reviews |
| Communicate rate changes | As needed | To operations team |

## Workflow & Touchpoints

### Typical Week

```
Monday    - Review carrier performance metrics
Tuesday   - Rate card updates, new contract entry
Wednesday - Carrier meetings, relationship management
Thursday  - Invoice audit, dispute resolution
Friday    - Reporting, planning for next period
```

### System Touchpoints
1. **TMS (Viya)** - Rate management, carrier performance, freight audit
2. **Carrier Portals** - Rate quotes, contract management
3. **Excel** - Rate modeling, scenario analysis
4. **Finance/AP System** - Invoice reconciliation
5. **Email** - Carrier communication

### Key Viya Features Used
- Rate card management
- Carrier performance dashboards
- Freight settlement/audit
- Contract management
- Rate comparison tools

## Persona Scenario

> **Linda, Carrier Manager at TechParts Distribution**
>
> Linda manages relationships with 15 carriers across road and express. She negotiates annual contracts and maintains rate cards for all lanes. Her biggest challenge is keeping rate cards accurate - fuel surcharges change monthly, and she often finds out about rate increases after shipments have been processed at old rates.
>
> "I need a single place to manage all my rates and see which carriers are actually delivering on their promises. Right now, I have 15 different Excel files and I spend half my time just keeping them updated. And I only find out about carrier problems when Customer Service escalates."

## Design Implications

### UI/UX Priorities
1. **Centralized rate management** - One place for all carrier rates
2. **Performance visibility** - Easy carrier comparison
3. **Change tracking** - History of rate modifications
4. **Alert on anomalies** - Catch rate errors before they compound
5. **Integration with carrier systems** - Reduce manual entry

### Feature Priorities
1. Comprehensive rate card management
2. Carrier performance scorecards
3. Contract expiration tracking and alerts
4. Invoice audit and discrepancy detection
5. Rate comparison and scenario modeling

### Metrics to Track
- Rate accuracy (invoiced vs contracted)
- Cost savings from negotiations
- Carrier performance trends
- Time spent on rate maintenance

## Relationship to Other Personas

| Persona | Relationship |
|---------|--------------|
| **Warehouse Worker/Manager** | Provides rates for carrier selection |
| **Customer Service/Sales** | Receives escalations on carrier issues |
| **Logistics Manager** | Works together on carrier strategy |
| **IT/Integrations Admin** | Requests carrier integrations |
| **Receiver** | Indirect - carrier performance affects delivery |

## Competitive Context

From competitor analysis:
- **Transporeon** has strong freight marketplace and carrier network
- **project44** offers carrier network connectivity
- **Cargoson** provides basic rate comparison

Viya differentiator: European cross-border expertise with multi-carrier, multi-modal support. Freight settlement module directly serves this persona.
