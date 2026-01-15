---
title: Viya Feature Ownership Matrix
version: 1.0
last_updated: 2026-01-13
status: draft
---

# Viya Feature Ownership Matrix

Every feature has exactly ONE owning domain. This prevents confusion about who decides, who builds, and who maintains.

## How to Read This Matrix

- **Owner**: The domain responsible for the feature (decisions, roadmap, quality)
- **Contributors**: Other domains that provide input or integrations
- **Status**: Current state of the feature

---

## Domain 1: Shipment

**Mission**: Enable users to define what needs to move, from buyer to seller.

| Feature | Description | Owner | Contributors | Status |
|---------|-------------|-------|--------------|--------|
| Order Import | Ingest sales orders from ERP/WMS | Shipment | Carrier Network (format specs) | Live |
| Shipment Creation | Create shipments from orders | Shipment | - | Live |
| Shipment Splitting | Split orders into multiple shipments | Shipment | - | Live |
| Shipment Consolidation | Combine orders into one shipment | Shipment | - | Live |
| Visual Flow Builder | Drag-and-drop shipping flow design | Shipment | - | Planned |
| Flow Templates | Pre-built templates for common scenarios | Shipment | - | Planned |
| Flow Simulation | Test flows before going live | Shipment | - | Planned |
| Receiver Requirements | Capture delivery preferences per receiver | Shipment | Visibility (notifications) | Partial |
| Shipping Rules Engine | Condition-based routing logic | Shipment | - | Live |
| Dangerous Goods Classification | DG handling requirements | Shipment | Consignment (documentation) | Live |

---

## Domain 2: Consignment

**Mission**: Execute carrier movements reliably with minimal manual steps.

| Feature | Description | Owner | Contributors | Status |
|---------|-------------|-------|--------------|--------|
| Carrier Selection | Choose carrier based on rules/cost/performance | Consignment | Carrier Network (rates), Analytics (performance) | Live |
| Carrier Booking | Book shipment with carrier | Consignment | Carrier Network (integrations) | Live |
| Multi-Leg Execution | Coordinate cross-dock, hub, multi-carrier flows | Consignment | - | Live |
| Label Generation | Create shipping labels | Consignment | Carrier Network (formats) | Live |
| Customs Documentation | Generate customs paperwork | Consignment | - | Live |
| Manifest Generation | Create carrier manifests | Consignment | - | Live |
| Bulk Processing | Process multiple shipments at once | Consignment | - | Live |
| Pickup Scheduling | Schedule carrier pickups | Consignment | Carrier Network (availability) | Partial |
| In-Transit Exception Handling | Resolve issues during transport | Consignment | Visibility (detection) | Live |
| Rerouting | Change carrier/route after booking | Consignment | Visibility (triggers) | Partial |
| Booking Confirmation | Confirm booking to internal users | Consignment | - | Live |

---

## Domain 3: Visibility

**Mission**: Provide real-time visibility and surface exceptions proactively.

| Feature | Description | Owner | Contributors | Status |
|---------|-------------|-------|--------------|--------|
| Real-Time Tracking | Show current shipment location/status | Visibility | Carrier Network (data feeds) | Live |
| Tracking Page | Customer-facing tracking portal | Visibility | - | Live |
| Exception Detection | Identify delays, issues, anomalies | Visibility | Carrier Network (status data) | Live |
| Exception Alerting | Notify users of problems | Visibility | - | Live |
| Exception Auto-Suggest | Suggest resolution actions | Visibility | Consignment (resolution) | Planned |
| Proactive Notifications | Alert before problems occur | Visibility | Analytics (predictions) | Planned |
| Delivery Confirmation | Capture POD and delivery status | Visibility | Carrier Network (POD data) | Live |
| Customer Notifications | Send updates to receivers | Visibility | - | Partial |
| Shipment Timeline | Visual history of shipment events | Visibility | - | Live |
| SLA Monitoring | Track against delivery commitments | Visibility | Analytics (reporting) | Partial |

---

## Domain 4: Analytics

**Mission**: Turn logistics data into actionable insights.

| Feature | Description | Owner | Contributors | Status |
|---------|-------------|-------|--------------|--------|
| Performance Dashboards | Overview of logistics KPIs | Analytics | All domains (data) | Live |
| Cost Analysis | Breakdown of logistics spend | Analytics | Carrier Network (rates) | Live |
| Carrier Scorecards | Performance metrics per carrier | Analytics | Visibility (delivery data) | Partial |
| Lane Analysis | Performance by origin-destination | Analytics | Visibility (data) | Partial |
| Freight Settlement | Match invoices to shipments | Analytics | Carrier Network (invoices) | Live |
| Invoice Dispute Management | Handle carrier billing issues | Analytics | Carrier Network (invoices) | Partial |
| Custom Reports | User-defined reporting | Analytics | - | Live |
| Report Scheduling | Automated report delivery | Analytics | - | Partial |
| AI Recommendations | ML-powered optimization suggestions | Analytics | All domains (data) | Planned |
| Cost Forecasting | Predict future logistics spend | Analytics | - | Planned |
| Benchmark Comparisons | Compare vs industry/network | Analytics | - | Planned |

---

## Domain 5: Carrier Network

**Mission**: Build and maintain the carrier ecosystem.

| Feature | Description | Owner | Contributors | Status |
|---------|-------------|-------|--------------|--------|
| Carrier Onboarding | Add new carriers to platform | Carrier Network | - | Live |
| Carrier Portal | Self-service portal for carriers | Carrier Network | Consignment (shipment data) | Partial |
| Carrier Integrations (API) | Real-time API connections | Carrier Network | - | Live |
| Carrier Integrations (EDI) | EDI-based connections | Carrier Network | - | Live |
| Carrier Integrations (Manual) | Email/portal fallback | Carrier Network | - | Live |
| Rate Management | Store and manage carrier rates | Carrier Network | Analytics (optimization) | Live |
| Contract Management | Track carrier agreements | Carrier Network | - | Partial |
| Carrier Credentials | Manage API keys, accounts | Carrier Network | - | Live |
| Invoice Routing | Route carrier invoices for processing | Carrier Network | Analytics (settlement) | Live |
| Carrier Performance Data | Collect delivery/quality metrics | Carrier Network | Visibility (tracking data) | Live |
| Carrier Availability | Track carrier capacity/cutoffs | Carrier Network | Consignment (selection) | Planned |

---

## Platform (Cross-Cutting)

These are infrastructure capabilities owned by the Platform team, not a product domain.

| Capability | Description | Owner | Used By |
|------------|-------------|-------|---------|
| Authentication & SSO | User login, identity | Platform | All |
| Authorization & Roles | Permissions, access control | Platform | All |
| Audit Logging | Track user actions | Platform | All |
| API Gateway | External API access | Platform | All |
| Webhooks | Event notifications to external systems | Platform | All |
| File Storage | Document/label storage | Platform | Consignment, Visibility |
| Search Infrastructure | Global search | Platform | All |
| Notification Engine | Email, SMS, push delivery | Platform | Visibility, Consignment |
| Background Jobs | Async processing | Platform | All |
| Data Pipeline | Analytics data flow | Platform | Analytics |

---

## Boundary Decisions

When ownership is unclear, use these principles:

| Situation | Decision Rule |
|-----------|---------------|
| Feature spans two domains | Owner = domain closest to the user outcome |
| Data needed by multiple domains | Owner = domain that creates the data |
| Integration with external system | Owner = domain that uses the integration most |
| New feature request | Owner = domain aligned with primary persona |

### Worked Examples

| Feature | Seems Like | Actually Owned By | Rationale |
|---------|------------|-------------------|-----------|
| Carrier rate optimization | Analytics or Carrier Network? | **Analytics** | Outcome is insight/recommendation, not rate storage |
| Exception notification | Visibility or Consignment? | **Visibility** | Detection and alerting is Visibility's job; resolution is Consignment's |
| Tracking data from carrier | Carrier Network or Visibility? | **Carrier Network** collects, **Visibility** displays | Carrier Network owns the integration, Visibility owns the UX |
| Bulk label printing | Consignment or Shipment? | **Consignment** | Labels are part of execution, not planning |

---

## Handoff Points

Clear handoffs between domains reduce confusion.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           HANDOFF POINTS                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  SHIPMENT ───────────────────▶ CONSIGNMENT                                  │
│  "Shipment is ready to execute"                                             │
│   Shipment marked as 'ready', all data complete                             │
│                                                                             │
│  CONSIGNMENT ────────────────▶ VISIBILITY                                   │
│  "Carrier has accepted the shipment"                                        │
│   Booking confirmed, tracking begins                                        │
│                                                                             │
│  VISIBILITY ─────────────────▶ CONSIGNMENT                                  │
│  "Exception detected that needs action"                                     │
│   Alert with context, Consignment resolves                                  │
│                                                                             │
│  VISIBILITY ─────────────────▶ ANALYTICS                                    │
│  "Shipment delivered (or failed)"                                           │
│   Final status, ready for reporting                                         │
│                                                                             │
│  CARRIER NETWORK ────────────▶ ALL DOMAINS                                  │
│  "Carrier is active and ready"                                              │
│   Integration live, rates loaded, credentials working                       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Feature Requests: Routing Guide

When a new feature request comes in, route it to the right domain:

| Request Contains | Route To |
|------------------|----------|
| "order", "split", "consolidate", "flow", "rule" | Shipment |
| "book", "label", "manifest", "pickup", "ship" | Consignment |
| "track", "status", "exception", "alert", "notify" | Visibility |
| "report", "dashboard", "cost", "invoice", "performance" | Analytics |
| "carrier", "rate", "integration", "onboard" | Carrier Network |

---

## Open Questions

- [ ] Should "Customer Notifications" move from Visibility to a shared capability?
- [ ] Where does "Returns/Reverse Logistics" live? (New domain or Consignment extension?)
- [ ] Is "Rate Shopping" owned by Consignment (selection) or Carrier Network (rates)?
- [ ] Should "Freight Settlement" be its own domain given complexity?

---

## Changelog

| Date | Version | Author | Changes |
|------|---------|--------|---------|
| 2026-01-13 | 1.0 | AI-assisted | Initial matrix created |
