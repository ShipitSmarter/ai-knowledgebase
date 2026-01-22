---
topic: User Personas & Reporting Needs
date: 2026-01-21
project: viya-reporting
sources_count: 5
status: draft
tags: [reporting, tms, personas, user-needs, analytics]
---

# User Personas & Reporting Needs

## Summary

Understanding the reporting needs of different user personas is critical for designing an effective analytics and reporting system in Viya TMS. Each of the six defined personas has distinct reporting requirements driven by their roles, decision-making authority, and interaction frequency with the system.

The most intensive reporting needs come from **secondary personas** (Logistics Manager, Carrier/Rate Manager) who use reports for strategic decisions, while **primary personas** (Warehouse Worker/Manager, Customer Service/Sales) need operational views focused on real-time status and exceptions rather than traditional reports. **Enabler personas** (IT Admin) require technical monitoring and audit capabilities, and **external personas** (Receiver) need simplified self-service tracking with minimal complexity.

A key insight from TMS industry analysis is that reporting requirements map to the four key TMS processes identified by Wikipedia and Oracle: (1) planning and optimization, (2) execution, (3) transport follow-up/tracking, and (4) measurement/KPIs. Different personas engage primarily with different processes.

## Per-Persona Analysis

### 1. Warehouse Worker/Manager

**Type:** Primary | **Frequency:** Daily | **Reporting Interaction:** Low-Medium

#### Role Description

Responsible for physical execution of shipping operations - creating shipments, printing labels, and resolving pick/pack exceptions. High-volume, time-pressured role where efficiency directly impacts warehouse throughput.

#### Key Reports Needed

| Report Type | Purpose | Frequency | Priority |
|-------------|---------|-----------|----------|
| **Daily shipment volume** | End-of-day summary for handover/reporting | Daily | High |
| **Exception queue** | Real-time view of shipments requiring attention | Continuous | Critical |
| **Pickup schedule** | Carrier pickup times and preparation status | Daily | High |
| **Label reprint log** | Audit trail for label issues | As needed | Medium |
| **Shipments by priority** | Expedited vs. standard queue management | Continuous | High |

#### Interaction Style

- **Prefers dashboards over reports** - needs at-a-glance status, not detailed analysis
- **Real-time data** is essential - stale reports are useless for operational decisions
- **Exception-driven** - wants to see what needs attention, not what's working fine
- **Minimal clicks** - reports should be embedded in workflow, not separate destinations

#### Self-Service Requirements

- Low self-service needs for report creation
- Needs ability to filter/search shipments quickly
- Should see relevant data automatically without configuring reports
- Export to supervisor/manager occasionally (Excel)

---

### 2. Customer Service / Sales Rep

**Type:** Primary | **Frequency:** Daily | **Reporting Interaction:** Medium

#### Role Description

Primary contact point for shipment inquiries. Answers "where is my order" questions, proactively communicates delays, and resolves delivery exceptions. Critical for customer satisfaction.

#### Key Reports Needed

| Report Type | Purpose | Frequency | Priority |
|-------------|---------|-----------|----------|
| **Exception/delay dashboard** | Identify at-risk shipments before customers call | Continuous | Critical |
| **Shipment search** | Find any shipment quickly by various criteria | On-demand | Critical |
| **Customer shipment history** | View all shipments for a specific customer | On-demand | High |
| **Open ticket/inquiry status** | Track resolution of customer issues | Daily | High |
| **Delivery confirmation/POD** | Proof of delivery access for customer queries | On-demand | High |
| **Proactive alert summary** | Shipments flagged as potentially problematic | Morning | High |

#### Interaction Style

- **Search-first** - often starts with customer reference number, order ID, or tracking number
- **Single pane of glass** - needs all shipment info in one view without system switching
- **Proactive alerting** - wants to know about problems before customers do
- **Customer-centric grouping** - often needs to see all shipments for one customer

#### Self-Service Requirements

- Needs ability to customize which alerts/notifications they receive
- Should be able to create ad-hoc searches with multiple filters
- May need to export shipment history for customer requests
- Limited need for building custom reports

---

### 3. Logistics Manager

**Type:** Secondary | **Frequency:** Weekly/Monthly | **Reporting Interaction:** High

#### Role Description

Oversees logistics operations, makes strategic carrier and process decisions, reports performance to leadership. Uses analytics to identify optimization opportunities and drive continuous improvement.

#### Key Reports Needed

| Report Type | Purpose | Frequency | Priority |
|-------------|---------|-----------|----------|
| **Executive KPI dashboard** | Overview of logistics performance | Weekly | Critical |
| **On-time delivery trends** | Track OTIF over time, by carrier, by lane | Weekly | Critical |
| **Cost per shipment analysis** | Cost trends, breakdown by carrier/mode/region | Monthly | Critical |
| **Carrier performance scorecard** | Compare carriers objectively | Monthly | Critical |
| **Exception pattern analysis** | Identify systemic issues | Weekly | High |
| **Volume forecasting** | Plan capacity and resources | Monthly | High |
| **Sustainability/CO2 report** | Carbon footprint tracking | Monthly | Medium |
| **Customer SLA compliance** | Meet delivery promises | Weekly | High |
| **Cost savings attribution** | Prove ROI of logistics improvements | Quarterly | High |

#### Industry Standard KPIs (from Wikipedia/Oracle TMS)

- % On-Time Pickup/Delivery Performance
- Cost per metric (mile, kg, pallet, cube)
- Productivity in monetary terms (cost per unit weight)
- Productivity in operational terms (shipping units per order)
- Service quality metrics

#### Interaction Style

- **Dashboard-first** - visual KPIs at a glance
- **Drill-down capability** - from summary to detail
- **Trend visualization** - needs to show improvement over time for leadership
- **Actionable insights** - wants recommendations, not just data
- **Easy export** - for presentations to leadership

#### Self-Service Requirements

- **High self-service needs** - this persona spends significant time creating reports
- Needs to build custom reports without IT involvement
- Requires scheduled report delivery (weekly, monthly)
- Export to Excel and PowerPoint for further analysis
- Integration with BI tools (PowerBI, Tableau) is valuable

---

### 4. Carrier/Rate Manager

**Type:** Secondary | **Frequency:** Weekly/Monthly | **Reporting Interaction:** High

#### Role Description

Maintains carrier relationships, manages rate cards, evaluates carrier performance. Ensures right carriers are available at competitive rates. May be combined with Logistics Manager in smaller organizations.

#### Key Reports Needed

| Report Type | Purpose | Frequency | Priority |
|-------------|---------|-----------|----------|
| **Carrier performance scorecard** | Evaluate carriers objectively | Weekly/Monthly | Critical |
| **Rate card accuracy audit** | Compare invoiced vs. contracted rates | Monthly | Critical |
| **Spend by carrier/lane** | Understand carrier utilization | Monthly | High |
| **Contract expiration tracker** | Avoid missing renewal deadlines | Weekly | High |
| **Rate variance analysis** | Identify rate errors and trends | Monthly | High |
| **Carrier comparison (lanes)** | Compare performance on specific lanes | On-demand | High |
| **Invoice discrepancy report** | Support freight audit process | Weekly | High |
| **New carrier evaluation** | Assess potential new carriers | As needed | Medium |

#### Interaction Style

- **Comparative analysis** - often needs side-by-side carrier comparisons
- **Historical trending** - rate and performance changes over time
- **Lane-level detail** - performance varies significantly by origin-destination
- **Financial focus** - cost and savings are primary metrics

#### Self-Service Requirements

- Needs to create custom carrier comparisons
- Requires export for carrier negotiations
- May need to share reports with carriers
- Scenario modeling for rate changes

---

### 5. IT/Integrations Admin

**Type:** Enabler | **Frequency:** Setup + Occasional | **Reporting Interaction:** Low-Medium

#### Role Description

Connects Viya to other business systems, configures automation, maintains technical health. The "enabler" who makes the system work for all other personas.

#### Key Reports Needed

| Report Type | Purpose | Frequency | Priority |
|-------------|---------|-----------|----------|
| **Integration health dashboard** | Monitor API/EDI connection status | Daily/Continuous | Critical |
| **Error log summary** | Identify and resolve integration issues | Daily | Critical |
| **API usage/performance** | Track response times, throughput | Weekly | High |
| **User access audit** | Security and compliance | Monthly | High |
| **Data quality report** | Identify missing/invalid data | Weekly | Medium |
| **Automation rule performance** | Track which automations are firing | Weekly | Medium |
| **System capacity metrics** | Monitor for scaling needs | Monthly | Medium |

#### Interaction Style

- **Technical/diagnostic** - needs detailed error information
- **Alerting-first** - wants to be notified of issues, not pull reports
- **Audit trail** - needs complete history for troubleshooting
- **Drillable** - from summary to individual transaction

#### Self-Service Requirements

- Needs access to technical logs and diagnostics
- Requires ability to configure alerts and thresholds
- Export for incident reports and vendor communication
- Limited need for ad-hoc report building

---

### 6. Receiver (End Customer)

**Type:** External | **Frequency:** Per Shipment | **Reporting Interaction:** Minimal

#### Role Description

The ultimate customer receiving shipped goods. Not a direct Viya user but experiences the system through tracking portals and notifications. Their experience significantly impacts customer satisfaction.

#### Key Reports/Information Needed

| Information Type | Purpose | Access Method | Priority |
|------------------|---------|---------------|----------|
| **Shipment status** | Know where package is | Self-service portal | Critical |
| **Estimated arrival time** | Plan for receiving | Self-service portal | Critical |
| **Delay notifications** | Know about problems proactively | Push (email/SMS) | Critical |
| **Proof of delivery** | Confirm delivery occurred | Self-service portal | High |
| **Delivery history** | View past deliveries (B2B) | Self-service portal | Medium |

#### Interaction Style

- **Mobile-first** - often checked on phone
- **Simple and clear** - status at a glance, no complexity
- **Branded experience** - should feel like shipper's service, not carrier's
- **Proactive notifications** - push updates, don't require pull
- **Multi-language** - international receivers need local language

#### Self-Service Requirements

- **100% self-service** - should never need to call for basic tracking
- No report building capabilities
- Preferences for notification channels (email, SMS)
- Ability to leave delivery instructions (advanced)
- [UNCERTAIN] Whether receivers need historical shipment reports depends on B2B vs B2C context

---

## Access Control Considerations

### Role-Based Access Matrix

| Report Category | Warehouse | CS/Sales | Logistics Mgr | Carrier Mgr | IT Admin | Receiver |
|----------------|:---------:|:--------:|:-------------:|:-----------:|:--------:|:--------:|
| **Operational dashboards** | Full | Full | Full | View | View | - |
| **Exception management** | Full | Full | Full | View | View | - |
| **Customer shipment search** | Limited | Full | Full | View | View | Own only |
| **KPI/Analytics dashboards** | - | View | Full | Full | View | - |
| **Carrier performance** | - | View | Full | Full | View | - |
| **Cost/financial reports** | - | - | Full | Full | - | - |
| **Rate management** | - | - | View | Full | - | - |
| **System/integration health** | - | - | View | View | Full | - |
| **User audit logs** | - | - | View | - | Full | - |

### Data Sensitivity Levels

1. **Public** - Tracking status (can share with receivers)
2. **Internal** - Operational data (all internal users)
3. **Restricted** - Cost/financial data (managers only)
4. **Confidential** - Rate cards, contracts (carrier manager + leadership)
5. **System** - Security logs, PII audit (IT admin only)

### Multi-Tenancy Considerations

- Users should only see shipments for their organization
- Parent organizations may need visibility into subsidiary shipments
- Receivers should only see shipments addressed to them
- [UNCERTAIN] Whether cross-organization benchmarking reports are appropriate

---

## Sources

| # | Source | Type | Key Contribution |
|---|--------|------|------------------|
| 1 | Viya Persona Files (knowledgebase/personas/) | Internal | Detailed persona definitions, goals, pain points |
| 2 | Wikipedia - Transportation Management System | Reference | TMS functionality framework (planning, execution, follow-up, measurement) |
| 3 | Oracle Transportation Management | Vendor | Industry-leading TMS capabilities, reporting features, KPI standards |
| 4 | Viya Reporting Research (_index.md, existing docs) | Internal | Existing MV structure, competitor analysis, priority KPIs |
| 5 | Gartner Magic Quadrant for TMS (via Oracle) | Analyst | Market leadership validation, key TMS capabilities |

---

## Questions for Further Research

- [ ] What specific KPIs does Viya's leadership want to track? (need stakeholder input)
- [ ] How do current customers use reporting today? (customer interviews)
- [ ] What BI tools do target customers already use? (market research)
- [ ] Should Viya offer embedded analytics or focus on data export to external tools?
- [ ] What sustainability/carbon reporting requirements exist in European markets?
- [ ] How should multi-organization hierarchies affect report visibility?
- [ ] What regulatory/compliance reports are required for European transport?
