---
topic: Shipper TMS Reporting - Exploration Plan
date: 2026-01-21
project: viya-reporting
sources_count: 12
status: planning
tags: [exploration, tms, reporting, analytics, shipper]
---

# Shipper TMS Reporting - Exploration Plan

## Discovery Summary

This exploration examines reporting capabilities for a shipper-focused Transportation Management System (TMS). The discovery phase revealed a mature market with clear "table stakes" features that all TMS vendors offer, plus emerging differentiators around AI/ML, sustainability, and self-service analytics.

The existing research in this project (`2026-01-20-reporting-materialized-views.md`) provides excellent technical foundation—database schema, existing MVs, competitor feature analysis, and KPI mapping. This exploration builds on that to cover strategic and user-facing aspects of TMS reporting.

Key themes emerging from discovery:
1. **User personas have distinct reporting needs** - Logistics managers need strategic analytics, operations staff need real-time dashboards, customers need tracking visibility
2. **Report frequency matters** - From real-time alerts to quarterly strategic reviews
3. **SMB vs Enterprise divide** - Smaller shippers need simplicity and out-of-the-box reports; enterprises need customization
4. **Customer portals are expected** - Branded tracking pages reduce support load by 65% (WISMO tickets)
5. **Sustainability reporting is emerging** - Carbon/emissions tracking becoming table stakes

### Prior Knowledge Found

**Memory:** TMS persona framework exists (6 personas defined for Viya TMS) - this maps directly to reporting user needs.

**Existing Research:**
- `2026-01-20-reporting-materialized-views.md` - Comprehensive technical analysis of Viya database schema, proposed MVs, competitor feature comparison
- `tms-competitors/2026-01-20-transporeon-competitor-analysis.md` - Competitor deep-dive

### Initial Sources Consulted

| Source | Type | Key Insight |
|--------|------|-------------|
| Oracle TMS | Official docs | ML-based ETA prediction, network modeling, 18-year Gartner Leader |
| Blue Yonder | Official docs | AI-driven optimization, 40% service level improvements cited |
| project44 | Official docs | MO AI Assistant for natural language queries, 600+ exception categories |
| DAT Resources | Industry | Freight rate benchmarking, market intelligence |
| AfterShip | Vendor | Customer portals reduce WISMO by 65%, 3.2x tracking page views |
| Logistics Management | Publication | TMS 2026 trends - AI/ML, SMB market maturation |

## Proposed Subtopics

### 1. Report Types & Frequency Matrix
**Why:** Foundation for prioritizing what to build first. Different reports serve different purposes at different cadences.
**Questions to answer:**
- What are the "must-have" reports for shipper TMS launch?
- What's the optimal refresh frequency for each report type?
- How do daily operational reports differ from monthly strategic reports?
- Which reports need real-time data vs batch aggregation?

### 2. User Personas & Their Reporting Needs
**Why:** Viya has 6 defined personas - understanding their specific analytics needs ensures we build the right features for the right users.
**Questions to answer:**
- What reports does a Warehouse Manager need vs a Logistics Manager?
- What's the Customer Service team's view into shipment data?
- How do external receivers (end customers) access tracking information?
- What self-service capabilities does each persona need?

### 3. Dashboard UX Patterns
**Why:** Competitive TMS products have established UI patterns (exception-first, map views, trend charts). Understanding these helps design effective dashboards.
**Questions to answer:**
- What visualization types are standard in TMS dashboards?
- How do leading products organize information hierarchy?
- What interaction patterns work best (drill-down, filters, exports)?
- How do mobile/responsive needs affect design?

### 4. Customer-Facing Portals & Branded Tracking
**Why:** Customer portals are increasingly expected. They reduce support load and improve customer experience.
**Questions to answer:**
- What features do shippers provide their end customers?
- How do branded tracking pages work?
- What self-service capabilities should customers have?
- How do notifications (email/SMS) integrate with portals?

### 5. KPI Definitions & Calculations
**Why:** Industry-standard KPIs must be calculated consistently. This subtopic standardizes definitions.
**Questions to answer:**
- How is On-Time Delivery (OTD/OTIF) precisely calculated?
- What's the standard for transit time measurement?
- How do you calculate cost-per-shipment when data is incomplete?
- What carrier performance metrics matter most?

### 6. SMB vs Enterprise Requirements
**Why:** Viya serves mid-market shippers. Understanding where SMB needs differ from enterprise helps prioritize appropriately.
**Questions to answer:**
- What out-of-the-box reports are essential for SMB?
- What customization is acceptable vs overwhelming?
- How do deployment/onboarding expectations differ?
- What features can be deferred for enterprise tier?

### 7. Self-Service BI & Analytics Extensibility
**Why:** Modern TMS platforms offer self-service analytics. Understanding options helps plan architecture.
**Questions to answer:**
- Should reports be embedded or linked to external BI tools?
- What export formats do users expect?
- How do AI assistants/natural language queries work?
- What API access should be provided for custom analytics?

### 8. Sustainability & Emissions Reporting
**Why:** Carbon footprint reporting is becoming standard. Early adopters gain competitive advantage.
**Questions to answer:**
- How do competitors calculate emissions per shipment?
- What standards exist (GHG Protocol, Scope 3)?
- What data is required to estimate carbon footprint?
- How sophisticated should v1 sustainability features be?

## Flagged Uncertainties

- [ ] **OTIF calculation varies** - Different vendors define "on-time" differently (by hour, by day, by window)
- [ ] **SMB boundaries unclear** - Where exactly does "mid-market" end and "enterprise" begin for TMS?
- [ ] **AI/ML capabilities overstated** - Marketing claims vs actual user value hard to verify
- [ ] **Emissions methodology** - Multiple competing standards; accuracy of estimates questioned
- [ ] **Customer portal scope** - How much is shipper-facing vs truly customer-facing may blur

## Recommended Research Order

1. **Report Types & Frequency Matrix** - Foundation for prioritization
2. **User Personas & Reporting Needs** - Leverages existing persona work
3. **KPI Definitions & Calculations** - Technical precision needed early
4. **Dashboard UX Patterns** - Informs design decisions
5. **Customer-Facing Portals** - Distinct enough to research separately
6. **SMB vs Enterprise Requirements** - Helps scope features
7. **Self-Service BI** - Architecture implications
8. **Sustainability Reporting** - Emerging/differentiator, can come later

## Next Steps

Awaiting user approval to proceed with subtopic research.

**Options:**
- Approve all 8 subtopics → Full research
- Select subset → Focused research
- Add/modify subtopics → Adjusted scope
- Request more discovery → Deeper exploration of specific areas
