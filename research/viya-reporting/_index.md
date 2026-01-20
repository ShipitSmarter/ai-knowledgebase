# Viya Reporting Research

Research on reporting capabilities, materialized views, and analytics for Viya TMS.

## Documents

| Date | Document | Status |
|------|----------|--------|
| 2026-01-20 | [TMS Reporting Analysis & Materialized Views](./2026-01-20-reporting-materialized-views.md) | draft |

## Key Findings

- **Existing MVs**: Some materialized views already exist (`mv_consignments_flat`, `analytics_*`)
- **Core entities**: shipments, consignments, carrier_tracking_events, handling_units
- **Key dimensions**: carrier, status, time (day/week/month), geography (origin/dest country)
- **Priority KPIs**: on-time delivery, shipment volume, carrier performance, cost per shipment

## Competitor Analysis Summary

**Table stakes** (all major TMS offer):
- Real-time shipment tracking dashboard
- On-time delivery % reporting
- Carrier performance scorecards
- Freight spend analysis
- Exception management

**Differentiators** (competitive advantages):
- Sustainability/carbon reporting (emerging standard)
- Predictive ETA with ML
- Customer-facing branded portals
- 90-day trend visualizations
- AI-powered exception handling

**Key vendors researched**: Oracle TMS, project44, Flexport, Blue Yonder, e2open, Descartes, SAP TM, Transporeon, Shipwell
