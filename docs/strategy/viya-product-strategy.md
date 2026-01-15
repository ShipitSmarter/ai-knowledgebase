---
title: Viya Product Strategy
version: 1.0
last_updated: 2026-01-13
status: draft
owner: Product Leadership
---

# Viya Product Strategy

## Our Mission

**Awesome Logistics. Made Simple.**

We believe logistics is not just a necessary evil — it can be a competitive advantage. We help B2B partners automate the repetitive, simplify the complex, and unlock creativity. That's when logistics becomes magical.

## Winning Aspiration (2025-2030)

> Achieve **€12M ARR** in Europe while improving the daily work lives of **10,000 European logistics professionals** — by delivering an awesome logistics platform.

**Dual focus:**
- Business growth: €12M ARR
- Social impact: 10,000 logistics professionals working better

---

## Strategic Context

### Where We Play

| Dimension | Focus | Avoid |
|-----------|-------|-------|
| **Customer size** | Enterprise (€10M+ transport spend, MRR €25k+), Mid-market (50+ logistics employees, MRR €7k+) | Micro/small companies (MRR <€7k) |
| **Transport mode** | Road and Express | Air, Ocean (except via 4PL partners) |
| **Geography** | European corridors, HQ in Benelux | Non-EU markets |
| **Cargo type** | General cargo, medium-high shipment value | Food, bulk goods |
| **Industries** | Manufacturing, spare-parts, life sciences | Commoditized retail logistics |

### How We Win

| Differentiator | What It Means |
|----------------|---------------|
| **Human-centred design** | Intuitive, visual, enjoyable to use — not enterprise software that feels like a chore |
| **Automation without complexity** | Frees teams for creative, value-added work — not more configuration |
| **European cross-border expertise** | Multi-leg, multi-carrier, customs-aware — not single-market thinking |
| **Speed to value** | Lighter, faster implementation than legacy TMS — weeks, not months |

---

## The Logistics Lifecycle

Viya covers the complete logistics lifecycle for our customers. This lifecycle is the foundation of our product architecture.

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                        THE LOGISTICS LIFECYCLE                                │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐                  │
│   │  PLAN   │───▶│ EXECUTE │───▶│  TRACK  │───▶│ IMPROVE │                  │
│   └─────────┘    └─────────┘    └─────────┘    └─────────┘                  │
│        │              │              │              │                        │
│   What needs     How it        Where is it     How do we                    │
│   to move?       moves         now?            get better?                  │
│                                                                              │
│   Shipment       Consignment   Visibility      Analytics &                  │
│   (sales order)  (carrier)     (tracking)      Optimization                 │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
              ┌────────────────────────────────┐
              │       CARRIER NETWORK          │
              │    (foundation for all)        │
              └────────────────────────────────┘
```

### Lifecycle Stages Explained

| Stage | Question | Viya Domain | Primary User | Key Outcome |
|-------|----------|-------------|--------------|-------------|
| **Plan** | What needs to move from buyer to seller? | Shipment | Logistics Analyst | Sales order → shipping plan |
| **Execute** | How does it actually move? | Consignment | Warehouse Operator | Carrier booked, goods moving |
| **Track** | Where is it now? Is there a problem? | Visibility | Operations Manager | Real-time status, exception alerts |
| **Improve** | How do we get better over time? | Analytics | Logistics Manager | Insights, cost optimization |

**Carrier Network** underpins all stages — the ecosystem of carriers, rates, and integrations that make everything work.

---

## Product Domains

Based on the lifecycle, Viya has **5 product domains**. Each domain is a complete product area with its own mission, users, and metrics.

### Domain 1: Shipment

**Mission**: Enable users to define what needs to move, from buyer to seller, with complex rules encoded visually.

**Lifecycle stage**: PLAN

**What it covers**:
- Sales order → shipment creation
- Shipment splitting/consolidation rules
- Customer/receiver requirements
- Visual flow builder for shipping logic
- Shipment templates for common scenarios

**Primary persona**: Logistics Analyst
- Designs shipping flows
- Doesn't want IT involvement
- Needs to capture knowledge in system, not in head

**Key jobs to be done**:
1. Turn a sales order into a shipping plan without manual intervention
2. Design complex multi-leg flows visually
3. Encode shipping logic so it survives employee turnover

**Success metrics**:
| Metric | Why It Matters |
|--------|----------------|
| Flows created per customer | Adoption of visual builder |
| Time to create a new flow | Usability of design tools |
| % zero-touch order-to-shipment | Automation effectiveness |

**Strategic bet**: Visual Flow Builder — if logistics analysts can design flows without IT, we win Enterprise deals faster.

---

### Domain 2: Consignment

**Mission**: Execute carrier movements reliably with minimal manual steps.

**Lifecycle stage**: EXECUTE

**What it covers**:
- Carrier selection & booking
- Multi-leg flow execution (cross-dock, hub, etc.)
- Documentation generation (labels, customs, manifests)
- Pickup/delivery coordination
- Exception handling during transport

**Primary persona**: Warehouse Operator
- Ships packages all day
- Wants speed and simplicity
- Doesn't want to make decisions — just ship

**Key jobs to be done**:
1. Ship packages as fast as possible with minimal clicks
2. Know immediately when something goes wrong
3. Get through my queue without stress

**Success metrics**:
| Metric | Why It Matters |
|--------|----------------|
| Zero-touch shipment rate | Automation effectiveness |
| Seconds per shipment (manual steps) | Operator efficiency |
| On-time carrier booking rate | Execution reliability |

**Strategic bet**: One-Click Shipping — routine shipments require zero decisions, making Viya indispensable.

---

### Domain 3: Visibility

**Mission**: Provide real-time visibility into all shipments and surface exceptions before they become problems.

**Lifecycle stage**: TRACK

**What it covers**:
- Real-time tracking & status updates
- Proactive exception detection
- Exception alerting & escalation
- Delivery confirmation & POD
- Customer/receiver notifications

**Primary persona**: Operations Manager
- Monitors daily operations
- Firefights exceptions
- Cares about customer experience

**Key jobs to be done**:
1. Know where every shipment is without asking
2. See problems before customers complain
3. Take action on exceptions quickly

**Success metrics**:
| Metric | Why It Matters |
|--------|----------------|
| Tracking data coverage | Visibility completeness |
| Mean time to exception detection | Proactive capability |
| Customer complaint rate (shipment-related) | Customer experience |

**Strategic bet**: Exception Auto-Resolution — detect issues and suggest/execute fixes before users notice.

---

### Domain 4: Analytics

**Mission**: Turn logistics data into actionable insights that drive continuous improvement.

**Lifecycle stage**: IMPROVE

**What it covers**:
- Performance dashboards & reporting
- Cost analysis & optimization
- Carrier performance scoring
- Freight settlement & invoice matching
- AI-powered recommendations

**Primary persona**: Logistics Manager
- Oversees shipping operations
- Cares about cost, compliance, customer experience
- Needs visibility into what's working

**Key jobs to be done**:
1. Understand total logistics cost and drivers
2. Know which carriers perform and which don't
3. Find optimization opportunities I didn't know existed

**Success metrics**:
| Metric | Why It Matters |
|--------|----------------|
| Active dashboard users | Analytics adoption |
| Cost per shipment trend | Business value delivered |
| Carrier performance data completeness | Recommendation quality |

**Strategic bet**: AI-Powered Insights — use network data to recommend optimizations customers can't see themselves.

---

### Domain 5: Carrier Network

**Mission**: Build and maintain the carrier ecosystem that powers all logistics operations.

**Lifecycle stage**: FOUNDATION (enables all stages)

**What it covers**:
- Carrier onboarding & portal
- Carrier integrations (EDI, API, manual)
- Rate management & contracts
- Carrier performance data collection
- Invoice routing

**Primary persona**: Carrier Partner + Logistics Analyst
- Carrier: Wants easy access to shipments, status updates, documents
- Analyst: Wants to add new carriers quickly without IT

**Key jobs to be done**:
1. Onboard a new carrier in days, not weeks
2. Maintain consistent data quality across all carriers
3. Give carriers a portal they actually want to use

**Success metrics**:
| Metric | Why It Matters |
|--------|----------------|
| Carrier onboarding time | Network expansion speed |
| API integration coverage | Data quality |
| Carrier portal active users | Ecosystem health |

**Strategic bet**: Self-Service Carrier Onboarding — carriers onboard themselves, reducing our implementation burden.

---

## Cross-Domain Boundaries

Clear boundaries prevent overlap and ownership confusion.

| Question | Answer | Owning Domain |
|----------|--------|---------------|
| Where does Shipment end and Consignment begin? | Shipment = what/where. Consignment = how/carrier. Handoff: when shipment is ready to execute. | Shipment → Consignment |
| Who owns exception detection vs resolution? | Detection: Visibility. Resolution during transport: Consignment. | Visibility → Consignment |
| Who owns carrier integrations? | Setup/onboarding: Carrier Network. Execution/booking: Consignment. | Carrier Network → Consignment |
| Who owns rates? | Rate contracts/management: Carrier Network. Rate analytics/optimization: Analytics. | Carrier Network + Analytics |
| Who owns automation/workflows? | Each domain owns automation within their scope. No single "automation domain." | All domains |
| Who owns customer notifications? | In-transit notifications: Visibility. Booking confirmations: Consignment. | Visibility + Consignment |

---

## Unified Strategic Bets

Across all domains, we are making **5 strategic bets** for 2026:

| # | Bet | Domain | Hypothesis |
|---|-----|--------|------------|
| 1 | **Visual Flow Builder** | Shipment | If logistics analysts can design flows without IT, we win Enterprise faster |
| 2 | **One-Click Shipping** | Consignment | If routine shipments need zero decisions, we become indispensable |
| 3 | **Proactive Exceptions** | Visibility | If we detect and resolve issues before users notice, we prevent firefighting |
| 4 | **AI Insights** | Analytics | If we surface optimization opportunities from network data, we prove ongoing ROI |
| 5 | **Self-Service Carriers** | Carrier Network | If carriers onboard themselves, we scale the network without linear cost |

---

## Who We Build For

### ICP (Ideal Customer Profile)

**Mid-market to Enterprise B2B shippers in Europe**
- 50+ logistics employees OR €10M+ transport spend
- Multi-site or cross-border complexity
- General cargo (manufacturing, spare-parts, life sciences)
- Value customer experience and receiver satisfaction
- Frustrated with legacy TMS complexity or manual processes

### Primary Personas (by domain)

| Domain | Primary Persona | Secondary Persona |
|--------|-----------------|-------------------|
| Shipment | Logistics Analyst | IT Integration Specialist |
| Consignment | Warehouse Operator | Logistics Analyst |
| Visibility | Operations Manager | Customer Service Rep |
| Analytics | Logistics Manager | Finance Controller |
| Carrier Network | Logistics Analyst | Carrier Operations Manager |

### Persona Maturity Strategy

Following PostHog's principle: **start with ONE persona per domain until product-market fit**.

1. **Shipment**: Start with Logistics Analyst (flow designer)
2. **Consignment**: Start with Warehouse Operator (daily shipper)
3. **Visibility**: Start with Operations Manager (exception handler)
4. **Analytics**: Start with Logistics Manager (decision maker)
5. **Carrier Network**: Start with Logistics Analyst (carrier relationship owner)

Only expand to secondary personas when primary persona churn is low and satisfaction is high.

---

## How We're Different (DHM Model)

| Aspect | Our Approach | Competitor Approach |
|--------|--------------|---------------------|
| **Delight** | Visual, intuitive UX that operators enjoy using | Enterprise software that feels like a chore |
| **Hard-to-copy** | EU cross-border templates learned from customer network data | Generic global features |
| **Margin-enhancing** | Fast implementation (weeks, not months), minimal services | Heavy implementation, professional services dependency |

---

## What We're NOT Doing

| Not Doing | Rationale | How We Say No |
|-----------|-----------|---------------|
| **SMB/Micro customers** | <€7k MRR dilutes focus, different needs | "Our platform is designed for mid-market and enterprise. For smaller volumes, we recommend [partner]." |
| **Fleet/own transport management** | Different product, different market | "We focus on third-party carrier networks. For fleet management, consider integrating with [partner]." |
| **Air/Ocean (direct)** | Outside EU road/express core | "We support air/ocean through our 4PL integrations with [partners]." |
| **Mobile-first UX** | Desktop is where our users work | "Mobile access is available but desktop is our primary experience." |
| **Food/bulk/cold chain** | Specialized requirements outside core | "Our platform is optimized for general cargo. For temperature-controlled logistics, consider [partner]." |

---

## Secret Master Plan

1. **Ship every tool logistics teams need** — covering Plan → Execute → Track → Improve
2. **Use that to speed up the logistics cycle** — automation at every stage
3. **Eventually, automate the entire flow** — AI handles routine logistics, humans handle exceptions and strategy

**Long-term vision**: Logistics teams spend their time on creative problem-solving and strategic decisions, not repetitive tasks. Viya handles everything else.

---

## Next Steps

1. **Create Feature Ownership Matrix** — map every feature to exactly one owning domain
2. **Define team assignments** — assign small teams to each domain
3. **Write domain strategies** — detailed strategy for each product domain
4. **Set baselines** — measure current state for all key metrics
5. **Prioritize Q1 initiatives** — pick first bets to validate

---

## Appendix: Domain-to-Team Mapping (Proposed)

Based on `docs/strategy/team-structure-matrix.md`:

| Domain | Proposed Team | Product Engineer | Designer | PM |
|--------|---------------|------------------|----------|-----|
| Shipment | Shipment | Harris | Dennis (50%) | Roel (50%) |
| Consignment | Consignment | Fatjon | Robin (50%) | Roel (50%) |
| Visibility + Analytics | Insights | Sjoerd + Bram (50%) | Dennis (50%) | Wouter (50%) |
| Carrier Network | Carrier Network | Nick | Robin (50%) | Wouter (50%) |

Platform team (Michael, Lennart, Jeffrey, Mila) supports all domains.

---

## Changelog

| Date | Version | Author | Changes |
|------|---------|--------|---------|
| 2026-01-13 | 1.0 | AI-assisted | Initial unified strategy created |
