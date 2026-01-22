---
topic: Report Types & Frequency Matrix
date: 2026-01-21
project: viya-reporting
sources_count: 6
status: draft
tags: [reporting, tms, frequency, operational, strategic]
---

# Report Types & Frequency Matrix

## Summary

Transportation Management System (TMS) reports serve fundamentally different purposes depending on their audience and timing. Operational reports support daily execution decisions—shipment status, exception handling, pickup scheduling—and require near real-time or hourly updates. Strategic reports inform carrier negotiations, network optimization, and business planning, and are typically refreshed daily, weekly, or monthly. The distinction between these categories directly impacts technical implementation: operational dashboards need streaming data or frequent batch refreshes, while strategic analytics can use overnight batch aggregations.

Industry research from Oracle TMS, project44, Logistics Management, and Shipwell indicates that modern TMS platforms are converging on a common set of "table stakes" reports: real-time shipment tracking, on-time delivery rates, carrier scorecards, freight spend analysis, and exception management. The differentiation comes from AI-powered predictive features (ETA forecasting, exception prioritization) and emerging requirements like sustainability/emissions reporting. For a shipper TMS launch, the must-haves focus on visibility and exception management—users need to answer "where is my shipment?" and "what needs attention?" before they need deep strategic analytics.

The refresh frequency for each report type should align with user action cycles. A warehouse manager checking the operations dashboard every 10 minutes needs data refreshed at least every 5 minutes. A logistics manager reviewing carrier performance weekly doesn't need that data updated more than daily. Over-engineering refresh frequencies wastes infrastructure resources; under-engineering frustrates users with stale data. The matrix below provides specific recommendations based on industry practice and the Viya data model already documented.

## Report Categories

### 1. Real-Time Operational Reports

**Purpose**: Support immediate decisions in warehouse and operations environments.

**Audience**: Warehouse workers, warehouse managers, operations staff.

**Characteristics**:
- Exception-first design (show problems, hide successes)
- Action-oriented (click to resolve, tender, escalate)
- Simple metrics, minimal drill-down
- Mobile-friendly

**Examples**:
- Shipments pending confirmation
- Pickups scheduled today
- In-transit shipments with alerts
- Delivery exceptions requiring action

### 2. Daily Operational Reports

**Purpose**: Support planning and review of daily activities.

**Audience**: Logistics managers, customer service teams.

**Characteristics**:
- Summary of day's performance
- Comparison to yesterday/last week
- Carrier-level breakdown
- Exportable for stakeholder updates

**Examples**:
- Daily shipment volume summary
- On-time pickup rate (today)
- Carrier performance snapshot
- Service level attainment

### 3. Periodic Performance Reports

**Purpose**: Track trends and support tactical decisions.

**Audience**: Logistics managers, carrier managers.

**Characteristics**:
- Week-over-week or month-over-month trends
- Carrier and lane comparisons
- Cost analysis and benchmarking
- Supports carrier negotiations

**Examples**:
- Weekly on-time delivery trends
- Monthly carrier scorecard
- Lane cost analysis
- Service level compliance by carrier

### 4. Strategic Analytics Reports

**Purpose**: Inform business strategy and long-term planning.

**Audience**: Logistics directors, finance, executive leadership.

**Characteristics**:
- Quarterly or annual timeframes
- Multi-dimensional analysis
- What-if scenarios
- External benchmarking

**Examples**:
- Quarterly freight spend review
- Annual carrier performance assessment
- Network optimization analysis
- Sustainability/emissions report

### 5. Customer-Facing Reports

**Purpose**: Provide visibility to end customers and reduce support burden.

**Audience**: External receivers, customer service (on behalf of customers).

**Characteristics**:
- Simple, consumer-friendly language
- Tracking status and ETA
- Branded for shipper
- Self-service reduces WISMO tickets

**Examples**:
- Tracking page (real-time)
- Delivery notification emails
- Proof of delivery access

## Frequency Matrix

| Report Type | Refresh Frequency | Rationale | Technical Implementation |
|-------------|-------------------|-----------|-------------------------|
| **Real-Time Operations Dashboard** | 1-5 minutes | Operations staff check frequently; exceptions need immediate visibility | Lightweight aggregation or change streams; cache layer |
| **Shipment Tracking (Individual)** | Real-time | Customers expect immediate status updates | Direct query with carrier event joins; cache TTL ~30 seconds |
| **Exception/Alert List** | 1-5 minutes | At-risk shipments require timely action | Event-driven update on status changes; push notifications |
| **Daily Shipment Summary** | Hourly during business hours | Supports intra-day decisions; overnight batch for history | Scheduled aggregation job; hourly incremental updates |
| **Carrier Performance (Daily)** | End of day (once daily) | Used for next-day planning; doesn't change intra-day | Nightly batch aggregation; run after cutoff time |
| **On-Time Delivery Rate** | Daily | Requires delivery confirmation; calculated after fact | Nightly calculation against delivery events |
| **Weekly Carrier Scorecard** | Weekly (Monday morning) | Reviewed in weekly logistics meetings | Scheduled job; email distribution |
| **Lane Cost Analysis** | Weekly or Monthly | Supports rate negotiations; stable data set preferred | Monthly batch aggregation |
| **Freight Spend Summary** | Monthly | Aligns with financial reporting cycles | Monthly batch; reconciled with invoices |
| **Carrier Quarterly Review** | Quarterly | Formal vendor review cycles | Manual trigger or quarterly schedule |
| **Sustainability/Emissions Report** | Monthly or Quarterly | Regulatory reporting; annual targets | Monthly aggregation; emissions calculation |

## Must-Have vs Nice-to-Have Prioritization

### Must-Have for Launch (P0)

These reports are essential for a functional shipper TMS. Without them, users cannot operate effectively.

| Report | Why Must-Have | Viya Data Readiness |
|--------|---------------|---------------------|
| **Shipment Status Dashboard** | Core "where is my shipment?" use case | Ready - shipments.Data.Status |
| **Exception/Alert View** | Users need to know what needs attention | Ready - can derive from status + time windows |
| **Daily Volume Summary** | Basic operational awareness | Ready - count by CreatedOn |
| **Carrier Performance Snapshot** | Carrier issues affect all operations | Ready - aggregate by CarrierReference |
| **Pickup Schedule View** | Warehouse needs to know what's being collected | Partial - pickup_requests exists |

### Important for Adoption (P1)

These reports significantly improve user productivity and are expected by experienced TMS users.

| Report | Why Important | Viya Data Readiness |
|--------|---------------|---------------------|
| **On-Time Delivery Report** | Primary KPI for logistics; carrier accountability | Partial - needs delivery timestamp from carrier events |
| **Tracking Page (Customer-Facing)** | Reduces WISMO support volume by 65% (AfterShip data) | Ready - can build from shipment + events |
| **Weekly Carrier Scorecard** | Supports carrier management conversations | Partial - needs OTD calculation |
| **Transit Time Analysis** | Identifies slow lanes/carriers | Partial - needs delivery timestamps |
| **Geographic Distribution** | Shows where volume flows | Ready - addresses data exists |

### Nice-to-Have (P2)

These reports add value but are not blocking for launch.

| Report | Why Deferred | Dependency |
|--------|--------------|------------|
| **Freight Spend Analysis** | Rate data often incomplete early on | Rate population in production |
| **Lane Cost Comparison** | Meaningful only with cost data | Rate + volume data |
| **Carrier Benchmark** | Requires baseline period | 3+ months historical data |
| **Emissions/Sustainability** | Emerging requirement; not yet mandated for most | Emissions methodology + carrier factors |
| **Predictive ETA** | Requires ML investment | ML pipeline + historical transit data |

### Future/Advanced (P3)

| Report | Complexity | Prerequisites |
|--------|------------|---------------|
| **AI Exception Prioritization** | Needs classification model | Exception categorization; ML |
| **Network Optimization** | Complex modeling | Scenario simulation capability |
| **Rate Benchmarking** | Needs market data | External rate intelligence feed |
| **Natural Language Queries** | GenAI integration | LLM integration; semantic layer |

## Technical Implementation Notes

### Real-Time vs Batch Processing

| Pattern | Use When | Viya Approach |
|---------|----------|---------------|
| **Change Streams** | Single-shipment tracking; exception detection | MongoDB change streams on shipments/events |
| **Scheduled Aggregation** | Daily/weekly rollups; historical analysis | Background jobs writing to `mv_*` collections |
| **Materialized Views** | Repeated queries on same data shape | Pre-computed aggregations (already exists in Viya) |
| **Cache Layer** | High-read, low-write dashboards | Redis/in-memory cache with TTL |

### Recommended MV Refresh Schedule

Based on the frequency matrix:

| Materialized View | Refresh Schedule | Implementation |
|-------------------|------------------|----------------|
| `mv_operations_current` | Every 5 minutes | Scheduled job |
| `mv_shipments_daily` | Hourly (business hours); nightly full | Incremental + full batch |
| `mv_carrier_performance` | Nightly (after EOD cutoff) | Full aggregation |
| `mv_shipment_events` | On event | Change stream trigger |
| `mv_lanes_summary` | Weekly | Scheduled batch |

### Data Freshness Expectations by Persona

| Persona | Primary Reports | Acceptable Latency |
|---------|-----------------|-------------------|
| Warehouse Worker | Operations dashboard, pickup list | < 5 minutes |
| Warehouse Manager | Operations dashboard, exceptions | < 5 minutes |
| Customer Service | Tracking lookup, exceptions | < 1 minute (individual) |
| Logistics Manager | Daily summary, carrier performance | < 1 hour |
| Carrier Manager | Carrier scorecard, lane analysis | < 24 hours |
| Executive/Finance | Spend reports, strategic metrics | < 24 hours |

## Sources

| # | Source | Type | Key Contribution |
|---|--------|------|------------------|
| 1 | Oracle TMS Documentation | Vendor | Gartner Leader 18x; ML-based ETA; Transportation Intelligence dashboards; refresh patterns for operational vs strategic |
| 2 | Logistics Management "TMS 2026: 9 Trends" (Jan 2026) | Industry Publication | Current TMS market trends; AI/GenAI adoption; user expectation changes; dashboard integration patterns |
| 3 | Shipwell "What is a TMS?" | Vendor | Core TMS functions (planning, executing, optimizing); KPI examples (OTP/OTD); SMB user expectations |
| 4 | Viya existing research (2026-01-20-reporting-materialized-views.md) | Internal | Viya schema analysis; existing MVs; competitor reporting analysis; table stakes vs differentiators |
| 5 | AfterShip / project44 marketing | Vendor | Customer portal reduces WISMO by 65%; 600+ exception categories; 90-day trend patterns |
| 6 | Gartner TMS definition | Analyst | TMS scope: "planning and execution of physical movement of goods across supply chain" |

## Questions for Further Research

- [ ] What is the optimal polling interval for carrier tracking API updates? (Affects exception detection latency)
- [ ] How do competitors handle missing rate data in early deployments? (Grace period? Estimates?)
- [ ] What emissions calculation methodology is most accepted? (GHG Protocol Scope 3? GLEC Framework?)
- [ ] How frequently do enterprise customers export data vs consume via dashboards?
- [ ] What alert/notification preferences do different personas have? (Email, in-app, SMS?)

---

## Appendix: Report Type Decision Tree

When determining how to categorize a new report request:

```
Is it about a single shipment or small set?
├─ YES → Real-time query (no MV needed)
└─ NO → Does the user need it within minutes?
         ├─ YES → Real-time operational (5-min refresh)
         └─ NO → Does it support today's decisions?
                  ├─ YES → Daily operational (hourly refresh)
                  └─ NO → Does it compare weeks/months?
                           ├─ YES → Periodic performance (daily refresh)
                           └─ NO → Strategic analytics (weekly/monthly batch)
```
