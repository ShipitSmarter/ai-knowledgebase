# Persona-Based Team Structure Prompt

Use this prompt to continue developing the 5+1 team structure based on Viya's user personas.

## Context

We have defined 6 user personas for Viya TMS:

| Persona | Type | Description |
|---------|------|-------------|
| Warehouse Worker/Manager | Primary | Daily shipment creation, labels, exceptions |
| Customer Service/Sales | Primary | "Where is my order", delay handling |
| Logistics Manager | Secondary | KPIs, analytics, optimization |
| Carrier/Rate Manager | Secondary | Rates, carrier performance |
| IT/Integrations Admin | Enabler | System setup, integrations |
| Receiver | External | End customer receiving goods |

Detailed persona profiles are in `knowledgebase/personas/`.

## Current Team Resources

From `knowledgebase/team-structure-matrix.md`:

- **5 Product Engineers**: Sjoerd (Senior), Fatjon (Medior), Nick (Medior), Bram (Medior, AI/data), Harris (Junior)
- **4 Platform Engineers**: Michael, Lennart, Jeffrey, Mila (separate team, no PE allocation)
- **3 Product Managers**: Roel, Wouter, Joey (starting February)
- **3 Designers**: Dennis (Senior), Robin, Joel (Visual/Process)

**Constraint**: Maximum 5 PE-focused teams + Platform as enabling team (6th)

## Proposed Team Structure (Draft)

Based on earlier discussion, here's the working proposal to refine:

| # | Team Name | Primary Persona(s) | Domain | Notes |
|---|-----------|---------------------|--------|-------|
| 1 | **Shipping** | Warehouse Worker/Manager | Shipment creation, labels, automation | High volume, core execution |
| 2 | **Visibility** | Customer Service/Sales + Receiver | Tracking, exceptions, portal | Customer-facing focus |
| 3 | **Insights** | Logistics Manager | Analytics, dashboards, KPIs | Data-heavy, AI potential |
| 4 | **Carrier** | Carrier/Rate Manager | Rates, performance, settlement | Lower frequency |
| 5 | **TBD** | ? | ? | 5th PE team |
| 6 | **Platform** | IT/Integrations Admin | Integrations, automation engine, DX | Enabling team (no PE) |

## Tasks to Complete

1. **Validate team boundaries** - Are the 4 teams above correctly scoped?
2. **Define 5th team** - What should team 5 own?
3. **Assign people to teams** - Match PEs, PMs, designers to teams
4. **Define team charters** - Mission, metrics, ownership boundaries
5. **Identify cross-team dependencies** - Where will coordination be needed?

## Questions to Explore

1. Should Shipping and Consignment be separate teams or combined?
2. Is there enough work for a dedicated Carrier team, or should it combine with Insights?
3. What owns the automation/workflow engine - Shipping or Platform?
4. How do we handle features that span multiple personas?
5. Should the Receiver-focused tracking portal be part of Visibility or separate?

## Research Context

See `research/product-strategy/2026-01-16-team-organization-personas.md` for:
- Team Topologies model (stream-aligned teams)
- SVPG empowered teams guidance
- Pros/cons of persona-based organization

## Strategic Alignment

From `knowledgebase/Strategy 2025-2030.md`:

| Strategic Priority | Potential Team Owner |
|-------------------|---------------------|
| Automate repetitive transport workflows | Shipping + Platform |
| Simplify shipment visibility and tracking | Visibility |
| Optimise carrier selection and transport spend | Carrier + Insights |
| Clarify with powerful analytics | Insights |

## How to Use This Prompt

Copy this prompt into a new conversation to continue the team structure work. Reference:
- `knowledgebase/personas/` for persona details
- `knowledgebase/team-structure-matrix.md` for current team composition
- `research/product-strategy/2026-01-16-team-organization-personas.md` for research
- `research/company-context/2026-01-13-competitor-analysis.md` for competitive context

Start with: "I want to continue developing the team structure based on personas. Let's work on [specific task]."
