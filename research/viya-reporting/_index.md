# Viya Reporting Research

Research on reporting capabilities, materialized views, and analytics for Viya TMS.

## Executive Summary

This research project comprehensively analyzed reporting requirements for a shipper-focused TMS, covering 8 subtopics from technical KPI definitions to strategic feature prioritization. The key insight for Viya's mid-market positioning: **"self-service with guardrails"** - customers want pre-built reports with configurability, not blank-canvas report builders. Time-to-first-value under 1 week is critical for mid-market adoption.

### Top Findings

1. **Control tower pattern dominates UX** - KPI tiles at top, map center, exception list driving action reflects the logistics workflow: assess health -> identify problems -> drill into specifics

2. **Exception-first design is universal** - Leading TMS products (project44, FourKites) surface at-risk shipments immediately; healthy shipments fade to background

3. **No universal KPI standards exist** - OTD/OTIF definitions vary significantly; consistency matters more than specific definition. Document and apply uniformly.

4. **Customer portals reduce support by 65%** - Branded tracking pages get 3.2x more views and dramatically reduce WISMO tickets

5. **GLEC Framework (ISO 14083) is THE sustainability standard** - Tier 2 calculations (modeled with actual distance) most practical for TMS v1

6. **Mid-market sweet spot**: Pre-built reports with filters/exports, not report builders. Time-to-value < 1 week critical.

7. **AI/NL analytics becoming table stakes** - But actual mid-market adoption unclear; marketing may exceed reality

### Confidence Assessment

| Finding | Confidence | Evidence |
|---------|------------|----------|
| Control tower UX pattern | High | Multiple vendors, consistent pattern |
| Customer portal ROI (65% WISMO reduction) | Medium | Single source (AfterShip) |
| GLEC/ISO 14083 as standard | High | Industry convergence, ISO formalization |
| Mid-market time-to-value requirement | Medium | Vendor claims, logical but unvalidated |
| AI/ML feature value | Low | Marketing claims, no adoption data |

## Research Documents

### Exploration & Synthesis

| Date | Document | Status | Content |
|------|----------|--------|---------|
| 2026-01-21 | [Exploration Plan](./2026-01-21-exploration-plan.md) | complete | Discovery findings, subtopic identification |
| 2026-01-21 | [Source Review](./2026-01-21-source-review.md) | complete | Cross-source validation, quality assessment |

### Subtopic Research

| Date | Topic | Status | Key Contribution |
|------|-------|--------|------------------|
| 2026-01-21 | [Report Types & Frequency](./2026-01-21-report-types-frequency.md) | draft | 5 report categories, frequency matrix, P0/P1/P2 prioritization |
| 2026-01-21 | [User Personas & Reporting](./2026-01-21-personas-reporting-needs.md) | draft | Per-persona analysis, access control matrix |
| 2026-01-21 | [Dashboard UX Patterns](./2026-01-21-dashboard-ux-patterns.md) | draft | Control tower layout, visualization types, mobile patterns |
| 2026-01-21 | [Customer-Facing Portals](./2026-01-21-customer-facing-portals.md) | draft | Branded tracking, notifications, self-service |
| 2026-01-21 | [KPI Definitions](./2026-01-21-kpi-definitions.md) | draft | OTD/OTIF formulas, carrier scorecard, missing data handling |
| 2026-01-21 | [SMB vs Enterprise](./2026-01-21-smb-vs-enterprise.md) | draft | Feature tiering, deployment expectations |
| 2026-01-21 | [Self-Service BI](./2026-01-21-self-service-bi.md) | draft | Embedded vs external, AI analytics, data architecture |
| 2026-01-21 | [Sustainability Reporting](./2026-01-21-sustainability-reporting.md) | draft | GLEC/ISO 14083, calculation tiers, v1 recommendations |

### Technical Foundation

| Date | Document | Status | Content |
|------|----------|--------|---------|
| 2026-01-21 | [Materialized View Strategy](./2026-01-21-materialized-view-strategy.md) | draft | **Final MV architecture**: 4 dimensional MVs serving 15+ reports |
| 2026-01-20 | [Materialized Views Analysis](./2026-01-20-reporting-materialized-views.md) | draft | Viya schema, existing MVs, proposed aggregations, competitor features |

## Cross-Topic Findings

### Confirmed Findings (Multiple Sources)

1. **Reports should be exception-first** - Confirmed across UX patterns, personas, and competitor analysis. Operations staff need "what needs attention" not "everything is fine."

2. **Frequency aligns with user action cycles** - Report Types research + Persona research both confirm: warehouse (5-min), logistics manager (daily), strategic (weekly/monthly).

3. **Customer tracking reduces support load** - Both Customer Portals research (65% WISMO reduction) and Persona research (Customer Service needs) confirm value.

4. **Mid-market wants guardrails, not freedom** - SMB vs Enterprise research + Self-Service BI research both show mid-market prefers configured options over blank canvas.

5. **Sustainability is emerging standard, not yet mandatory** - Both Sustainability research and SMB vs Enterprise confirm: nice-to-have for mid-market, becoming table stakes for enterprise.

### Areas of Disagreement

| Topic | Conflict | Resolution |
|-------|----------|------------|
| OTD/OTIF definition | Multiple valid approaches (day, hour, window) | Choose one, document clearly, apply consistently |
| SMB/Mid-market boundary | Sources vary: $1M-$10M freight spend | Define for Viya context; $5-50M seems reasonable mid-market |
| AI/ML value | Marketing claims high, adoption data absent | Treat as P3 feature; validate with customer research before investing |
| Exception categories | project44 claims 600+; seems excessive | Start with 20-50 categories, expand based on usage |

### Emerging Patterns

1. **Convergence on control tower** - All major vendors moving toward unified command center view
2. **AI assistants for analytics** - Natural language queries emerging but accuracy for logistics domain unproven
3. **Data lakehouse architecture** - Hybrid operational + analytical data layer becoming preferred pattern
4. **Real-time expectations increasing** - 5-minute latency acceptable for operations; sub-minute for customer tracking

## Open Questions

- [ ] What specific KPIs does Viya leadership prioritize?
- [ ] How do current customers use reporting today? (customer interviews needed)
- [ ] What BI tools do target customers already use?
- [ ] What are specific regulatory deadlines driving sustainability urgency?
- [ ] How should multi-organization hierarchies affect report visibility?
- [ ] What accessibility requirements apply to logistics dashboards?

## Recommendations

### Phase 1 - MVP (Launch)

| Feature | Priority | Rationale |
|---------|----------|-----------|
| Shipment Status Dashboard | P0 | Core "where is my shipment" use case |
| Exception/Alert View | P0 | Users must know what needs attention |
| Daily Volume Summary | P0 | Basic operational awareness |
| Carrier Performance Snapshot | P0 | Carrier issues affect all operations |
| Shareable Tracking Links | P1 | Reduces WISMO, improves customer experience |

### Phase 2 - Enhancement

| Feature | Priority | Rationale |
|---------|----------|-----------|
| On-Time Delivery Reports | P1 | Primary KPI, requires delivery timestamps |
| Weekly Carrier Scorecard | P1 | Supports carrier management |
| Scheduled Email Reports | P1 | Mid-market expects automated delivery |
| Basic Carbon Estimates | P2 | Emerging differentiator |

### Phase 3 - Advanced

| Feature | Priority | Rationale |
|---------|----------|-----------|
| BI Tool Integration | P2 | Enterprise requirement |
| Branded Customer Portal | P2 | Beyond basic tracking links |
| AI/ML Predictions | P3 | Validate value before investing |
| Custom Report Builder | P3 | Enterprise-only need |

---

*Research conducted: January 20-21, 2026*
*Total sources consulted: 50+*
*Methodology: Deep Research skill with parallel subtopic agents*
