---
title: IT/Integrations Admin Persona
type: enabler
frequency: setup-occasional
status: draft
---

# IT/Integrations Admin

## Overview

The IT/Integrations Admin connects Viya to other business systems (ERP, WMS, carrier APIs), configures automation rules, and maintains the technical health of the logistics technology stack. They are the "enabler" who makes the system work for all other personas. In smaller companies, this role may be handled by a Logistics Manager with technical aptitude.

## Demographics

| Attribute | Typical Profile |
|-----------|-----------------|
| **Job Titles** | IT Administrator, Integration Specialist, Business Analyst, System Administrator |
| **Company Size** | 100+ employees (dedicated role), smaller companies combine with operations |
| **Industry** | Manufacturing, Spare Parts, Life Sciences, Distribution |
| **Location** | Office or remote |
| **Tech Comfort** | Very high - technical background |
| **Decision Authority** | Technical decisions, vendor evaluation input |

## Goals & Motivations

### Primary Goals
1. **Reliable integrations** - Systems communicate without errors
2. **Fast onboarding** - Get new capabilities live quickly
3. **Self-service for business users** - Reduce IT support tickets
4. **Security and compliance** - Protect data, meet requirements

### Underlying Motivations
- Professional pride in well-architected integrations
- Reducing support burden (fewer tickets)
- Learning new technologies
- Recognition for successful implementations

## Pain Points & Frustrations

### Current Challenges
1. **Integration complexity** - Each carrier and system is different
2. **Documentation gaps** - Incomplete API docs, unclear requirements
3. **Testing difficulty** - Hard to test without affecting production
4. **Support dependency** - Waiting on vendor support for issues
5. **Change management** - Carrier API changes break integrations
6. **Resource constraints** - Too many projects, not enough time

### Emotional State
- Frustrated by undocumented APIs and integration quirks
- Stressed by production integration failures
- Satisfied when integrations "just work"
- Proud of elegant automation solutions

## Jobs-to-be-Done

### Core Jobs
| Job | Frequency | Success Metric |
|-----|-----------|----------------|
| Set up new carrier integrations | As needed | Time to go-live |
| Connect ERP/WMS systems | One-time + maintenance | Data accuracy, reliability |
| Configure automation rules | Ongoing | Automation coverage |
| Troubleshoot integration issues | As needed | Resolution time |
| Manage user access and security | Ongoing | Compliance, zero breaches |

### Related Jobs
| Job | Frequency | Notes |
|-----|-----------|-------|
| Evaluate new vendors | As needed | Technical due diligence |
| Document integrations | Ongoing | Knowledge management |
| Train users | As needed | New feature rollouts |

## Workflow & Touchpoints

### Typical Work Pattern

```
Initial Setup Phase (Weeks):
- Discovery: understand data flows and requirements
- Configuration: set up integrations and mappings
- Testing: validate in sandbox environment
- Go-live: deploy and monitor
- Handover: document and train users

Maintenance Phase (Ongoing):
- Monitor integration health
- Respond to error alerts
- Apply updates when needed
- Handle support requests
```

### System Touchpoints
1. **TMS (Viya)** - Integration configuration, automation setup, admin console
2. **ERP** - Order and master data source
3. **WMS** - Inventory and fulfillment integration
4. **Carrier APIs** - Direct carrier connectivity
5. **Monitoring Tools** - Integration health, error tracking

### Key Viya Features Used
- Integration configuration
- API documentation
- Automation rule builder
- Admin console
- Error logs and monitoring
- User management

## Persona Scenario

> **Stefan, IT Manager at LogisticsPlus**
>
> Stefan manages IT for a mid-market distributor with limited resources (2-person IT team). He's responsible for integrating Viya with their SAP Business One ERP and 8 carriers. His biggest challenge is that each carrier has different API requirements, and documentation is often incomplete or outdated.
>
> "I need integrations that just work. I don't want to spend hours debugging why carrier X suddenly stopped working. And I need good documentation - not just API specs, but examples of common setups and troubleshooting guides. When something breaks at 6 AM, I need to fix it fast."

## Design Implications

### UI/UX Priorities
1. **Clear configuration UI** - Visual integration builder
2. **Comprehensive documentation** - Examples, troubleshooting
3. **Testing capabilities** - Sandbox environments, test modes
4. **Error visibility** - Clear error messages, logs
5. **Self-service** - Minimize vendor dependency

### Feature Priorities
1. Low-code/no-code integration setup
2. Comprehensive API documentation
3. Integration health monitoring
4. Sandbox/test environment
5. Error alerting and diagnostics

### Metrics to Track
- Integration uptime
- Time to set up new integration
- Error resolution time
- Support ticket volume

## Relationship to Other Personas

| Persona | Relationship |
|---------|--------------|
| **Warehouse Worker/Manager** | Enables their systems to work |
| **Customer Service/Sales** | Enables tracking data flow |
| **Logistics Manager** | Enables analytics data quality |
| **Carrier/Rate Manager** | Enables carrier connectivity |
| **Receiver** | Indirect - enables tracking portal |

## Competitive Context

From competitor analysis:
- **Transporeon** emphasizes extensive carrier network (pre-built integrations)
- **Sendcloud** highlights easy e-commerce platform integrations
- **Enterprise TMS** (SAP, Oracle) require significant IT investment

Viya differentiator: "Faster setup and integration" and "Lighter, faster, easier to implement" positions against complex enterprise solutions. Self-service configuration reduces IT dependency.
