---
topic: SMB vs Enterprise Reporting Requirements
date: 2026-01-21
project: viya-reporting
sources_count: 8
status: draft
tags: [reporting, tms, smb, enterprise, segmentation]
---

# SMB vs Enterprise Reporting Requirements in Shipper TMS

## Summary

The TMS market clearly segments into SMB, mid-market, and enterprise tiers, each with distinct reporting needs, deployment expectations, and pricing models. SMB shippers (typically <$5M annual freight spend) prioritize simplicity, quick deployment, and out-of-the-box reports that deliver immediate value without extensive configuration. Enterprise shippers (>$50M freight spend) require deep customization, multi-modal orchestration, advanced analytics (AI/ML), and extensive integration capabilities.

The mid-market segment ($5-50M freight spend)—Viya's target—represents the "sweet spot" where shippers outgrow basic tools but don't need enterprise complexity. These customers want the sophistication of enterprise features (carrier scorecards, exception management, trend analysis) with the simplicity and faster deployment of SMB solutions. Success in mid-market requires pre-built reports with configurable parameters, rather than blank-canvas report builders.

Key differentiator for mid-market: **self-service with guardrails**. Customers want to customize date ranges, filter by carrier, and export data—but they don't want to build reports from scratch. They need "opinionated defaults" with room to adjust.

## SMB Requirements

### Must-Haves (Table Stakes)
1. **Shipment Dashboard** - Real-time overview of active shipments with status (in-transit, delivered, exception)
2. **On-Time Delivery %** - Simple OTD metric visible at a glance
3. **Carrier Performance Summary** - Which carriers are performing well vs. poorly
4. **Cost per Shipment** - Basic spend visibility
5. **Exception Alerts** - Notification when something goes wrong
6. **Shipment History Export** - Ability to download data for external analysis

### Nice-to-Haves
- Scheduled email reports (weekly/monthly summaries)
- Mobile-friendly dashboards
- Simple trend charts (this month vs. last month)
- Customer-facing tracking links

### Characteristics
| Aspect | SMB Expectation |
|--------|-----------------|
| Deployment time | Days to 3 months |
| Configuration | Minimal; works out-of-box |
| Training | Self-service / online tutorials |
| Custom reports | Not expected; use Excel exports |
| Integrations | Limited (ERP optional) |
| Pricing model | Per-shipment or flat monthly fee ($1-4/shipment typical) |
| Support | Email/chat; no dedicated rep |

### What SMB Shippers DON'T Need
- Complex report builders
- Multi-modal orchestration
- AI/ML predictive analytics
- Sustainability/emissions reporting
- Custom branded portals
- Advanced API access

## Enterprise Requirements

### Advanced Features (Beyond Table Stakes)
1. **Custom Report Builder** - Drag-and-drop or SQL-based report creation
2. **AI/ML Analytics**:
   - Predictive ETA with machine learning
   - Exception prediction (identify at-risk shipments before they fail)
   - Capacity forecasting
   - Freight cost optimization recommendations
3. **Multi-Modal Visibility** - Ocean, air, rail, and OTR in single view
4. **Network Modeling** - What-if scenario analysis for network changes
5. **Sustainability Reporting** - Carbon footprint per shipment, Scope 3 emissions
6. **Control Tower / Command Center** - Real-time orchestration across facilities
7. **Customer-Facing Portals** - Branded tracking pages for B2B customers
8. **Advanced Carrier Analytics**:
   - Lane-level performance
   - Claims and damage tracking
   - Tender acceptance/rejection rates
   - Dwell time analysis
9. **Self-Service BI Integration** - Connect to Power BI, Tableau, Looker
10. **API Access** - Full data export for custom analytics

### Characteristics
| Aspect | Enterprise Expectation |
|--------|------------------------|
| Deployment time | 4-18 months |
| Configuration | Extensive; dedicated implementation team |
| Training | On-site training, certification programs |
| Custom reports | Fully customizable, unlimited |
| Integrations | Required (ERP, WMS, CRM, BI tools) |
| Pricing model | Licensed ($10K-$250K+/year) or enterprise SaaS |
| Support | Dedicated CSM, 24/7 support, SLAs |

## Mid-Market Sweet Spot (Viya's Target)

Mid-market shippers represent the growth opportunity: they've outgrown spreadsheets and basic tools, but are not ready for (or can't afford) enterprise solutions. Key characteristics:

### Profile
- **Freight spend**: $5-50M annually
- **Shipment volume**: 500-10,000 shipments/month
- **Team size**: 2-10 logistics staff
- **IT resources**: Limited; no dedicated TMS administrator
- **Decision drivers**: Price/value, ease of use, fast ROI

### What They Want

1. **Pre-Built Reports with Configurability**
   - Standard KPI dashboards that work on day one
   - Ability to filter by date range, carrier, customer, origin/destination
   - Drill-down capability (summary → detail)
   - Export to Excel for ad-hoc analysis

2. **Guided Analytics**
   - "What does this metric mean?" explanations
   - Suggested actions ("3 carriers underperforming—review contracts")
   - Benchmarks or targets to compare against

3. **Scheduled Reports**
   - Weekly/monthly automated email delivery
   - PDF or Excel attachments
   - Key stakeholders (ops manager, CFO) get regular updates

4. **Exception-First Design**
   - Dashboard highlights problems, not just data
   - "5 shipments at risk today" vs. "1,247 shipments in transit"
   - One-click drill-down to problematic shipments

5. **Customer Tracking (Basic)**
   - Shareable tracking links for end customers
   - Reduces "Where is my order?" support tickets
   - No complex portal customization needed

### What They DON'T Need (Yet)
- Full AI/ML prediction suites
- Multi-modal orchestration (most are road-focused)
- Complex network modeling
- Sustainability reporting (nice-to-have, not must-have)
- Custom branded portals (basic tracking links sufficient)

## Feature Tiering Recommendations

| Feature | Basic (SMB) | Standard (Mid-Market) | Premium (Enterprise) |
|---------|-------------|----------------------|---------------------|
| **Shipment Dashboard** | Real-time status | + Trend charts | + Control tower view |
| **OTD Reporting** | Single metric | + By carrier/lane/customer | + Predictive at-risk |
| **Carrier Scorecards** | Basic ranking | + Detailed KPIs | + Tender/claims analysis |
| **Cost Analysis** | Total spend | + Per shipment/lane | + Optimization suggestions |
| **Exception Management** | Alerts | + 50 exception types | + 600+ exception categories [UNCERTAIN] |
| **Customer Visibility** | Tracking links | + Notification emails | + Branded portal |
| **Export/Integration** | Excel download | + Scheduled email reports | + BI tool integration, API |
| **Emissions Tracking** | Not included | Basic carbon estimate | Full Scope 3 reporting |
| **AI/ML Analytics** | Not included | Not included | Full suite |
| **Custom Reports** | Not included | Template customization | Full report builder |

### Recommended Viya Approach

**Phase 1 (MVP)**: Standard tier features
- Pre-built dashboards covering key personas (Logistics Manager, Customer Service)
- 10-15 standard reports with filter/export capability
- Basic exception alerting
- Shareable tracking links

**Phase 2 (Enhancement)**: Premium features selectively added
- Scheduled email reports
- More exception categories
- Carrier scorecard deep-dives
- Basic carbon estimates

**Phase 3 (Enterprise)**: Full premium tier
- BI integration
- Custom report builder
- Advanced analytics
- Branded customer portals

## Deployment Expectations by Segment

| Segment | Time to Value | Implementation Approach | Training Model |
|---------|---------------|------------------------|----------------|
| **SMB** | Days-2 weeks | Self-service onboarding | Video tutorials, knowledge base |
| **Mid-Market** | 2-8 weeks | Guided implementation with CSM | 2-4 hours webinar training |
| **Enterprise** | 3-12+ months | Dedicated project team | On-site training, certification |

### Mid-Market Onboarding Expectations
1. **Week 1**: Account setup, carrier connections, first shipments flowing
2. **Week 2-3**: Historical data import, baseline reports available
3. **Week 4-6**: Team training, dashboard customization
4. **Week 6-8**: Full operational use, first performance reviews

Key insight: Mid-market customers will abandon complex onboarding. **Time-to-first-value must be under 1 week.**

## Sources

| Source | URL | Key Contribution |
|--------|-----|------------------|
| Oracle TMS | https://www.oracle.com/scm/logistics/transportation-management/ | Enterprise TMS capabilities, ML-based ETA, network modeling features |
| Blue Yonder TMS | https://www.blueyonder.com/solutions/transportation-management | Enterprise feature set, AI-driven optimization, 40% service improvement claims |
| e2open Logistics | https://www.e2open.com/logistics/transportation-management/ | Multi-modal visibility, control tower capabilities |
| project44 Blog | https://www.project44.com/blog | Decision intelligence, AI agents, exception management categories |
| Descartes 3G TMS | https://go3g.com/ | Mid-market focus, ERP integrations, quick deployment messaging |
| Viya Reporting Index | Internal | Existing competitor analysis, table stakes vs differentiators |
| Viya Exploration Plan | Internal | Persona framework, reporting frequency context |
| Industry knowledge | Multiple sources | Pricing benchmarks, deployment timelines |

## Flagged Items

### [UNCERTAIN] Areas
- **Exception categories**: project44 claims 600+ exception types; actual utility for mid-market unclear
- **AI/ML value**: Marketing claims vs. actual user value difficult to verify without case studies
- **Emissions accuracy**: Carbon estimates vary significantly by methodology; may not be reliable enough for mid-market

### [CONFLICTING] Information
- **Deployment timelines**: Sources vary widely (Oracle: 4-5 months minimum for enterprise; 3G: "get started in days"). Likely depends heavily on scope and integration complexity.
- **SMB definition**: Some sources define SMB as <$1M freight spend, others <$10M. Mid-market boundaries similarly fuzzy.

## Questions for Further Research

- [ ] What specific KPIs do Logistics Managers check daily vs. weekly vs. monthly?
- [ ] What report formats (PDF, Excel, interactive dashboard) do different personas prefer?
- [ ] How do competitors handle the "good enough" threshold for SMB to mid-market upsell?
- [ ] What's the actual adoption rate of AI/ML features in mid-market accounts?
- [ ] How do shippers currently measure carrier performance without a TMS?
