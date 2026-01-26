## Proposed Team Structure

Based on your target model (small teams: 1 PE + 0.5 Designer + 0.5 PM) and the Shipment/Consignment distinction, here's a clearer structure:

### Option A: Domain-Based Teams (Recommended)

```
┌─────────────────────────────────────────────────────────────────────┐
│                         PLATFORM TEAM                                │
│        Michael, Lennart, Jeffrey, Mila                              │
│        Focus: Infrastructure, DevEx, Code Quality, Shared Components│
└─────────────────────────────────────────────────────────────────────┘
                                  │
                    Supports all product teams
                                  │
     ┌────────────────┬───────────┴───────────┬────────────────┐
     ▼                ▼                       ▼                ▼
┌─────────┐    ┌─────────────┐    ┌──────────────────┐    ┌─────────┐
│SHIPMENT │    │ CONSIGNMENT │    │    INSIGHTS      │    │ CARRIER │
│ (Plan)  │    │  (Execute)  │    │(Track + Analyze) │    │NETWORK  │
└─────────┘    └─────────────┘    └──────────────────┘    └─────────┘
```

#### Team 1: Shipment (Planning Layer)

**Mission**: Enable users to define what needs to move from buyer to seller.

| Role             | Person                 | Allocation |
| ---------------- | ---------------------- | ---------- |
| Product Engineer | **Harris**             | 100%       |
| Designer         | **Dennis**             | 50%        |
| Product Manager  | **Roel**               | 50%        |
| Mentor/Support   | **Jeffrey** (Platform) | As needed  |

**Scope**:

- Sales order → shipment creation
- Shipment splitting/consolidation rules
- Customer/receiver requirements
- Shipment lifecycle management

**Why Harris**: New joiner can learn domain deeply with Roel's guidance. Jeffrey provides backend mentorship.

---

#### Team 2: Consignment (Execution Layer)

**Mission**: Execute the actual carrier movements with all integrations.

| Role             | Person     | Allocation |
| ---------------- | ---------- | ---------- |
| Product Engineer | **Fatjon** | 100%       |
| Designer         | **Robin**  | 50%        |
| Product Manager  | **Roel**   | 50%        |

**Scope**:

- Carrier selection & booking
- Multi-leg flow execution
- Documentation generation
- Carrier integrations (execution side)
- Exception handling during transport

**Why Fatjon**: Already deep in consignment domain. Robin worked on the ship/consign split.

---

#### Team 3: Insights (Visibility + Analytics)

**Mission**: Provide visibility into shipments/consignments and enable improvement.

| Role             | Person     | Allocation               |
| ---------------- | ---------- | ------------------------ |
| Product Engineer | **Sjoerd** | 100%                     |
| Product Engineer | **Bram**   | 50% (analytics/AI focus) |
| Designer         | **Dennis** | 50%                      |
| Product Manager  | **Wouter** | 50%                      |

**Scope**:

- Real-time tracking & visibility
- Exception detection & alerting
- Analytics & reporting dashboards
- Performance insights & recommendations
- Freight settlement / cost analysis (Bram's AI/data skills)

**Why this combo**: Sjoerd knows tracking, Bram brings data/AI for analytics & rates. Wouter's vision focus fits cross-cutting insights. Merging Visibility + Freight Settlement reduces overlap.

---

#### Team 4: Carrier Network

**Mission**: Build and maintain the carrier ecosystem.

| Role             | Person     | Allocation |
| ---------------- | ---------- | ---------- |
| Product Engineer | **Nick**   | 100%       |
| Designer         | **Robin**  | 50%        |
| Product Manager  | **Wouter** | 50%        |

**Scope**:

- Carrier portal & onboarding
- Carrier integrations (setup/maintenance)
- Rate management & contracts
- Carrier performance data
- Invoice routing

**Why Nick**: Needs focus - this gives him clear ownership. Carrier network is foundational for other teams.

---

### Shared Resources

| Person            | Primary Team        | Shared With | Notes                                          |
| ----------------- | ------------------- | ----------- | ---------------------------------------------- |
| **Joel**          | CSM / Process       | All teams   | PostHog setup, release process, visual support |
| **Dennis**        | Shipment + Insights | All teams   | Most experienced, covers complex design needs  |
| **Platform Team** | Platform            | All teams   | Jeffrey supports Shipment team on backend      |

---

## Team Boundaries (Reducing Overlap)

| Question                                         | Answer                                                                                                |
| ------------------------------------------------ | ----------------------------------------------------------------------------------------------------- |
| "Where does Shipment end and Consignment begin?" | Shipment = what/where. Consignment = how/carrier. The handoff is when a shipment is ready to execute. |
| "Who owns exception handling?"                   | **Detection**: Insights team. **Resolution during transport**: Consignment team.                      |
| "Who owns carrier integrations?"                 | **Setup/onboarding**: Carrier Network. **Execution/booking**: Consignment.                            |
| "Who owns rates?"                                | **Rate contracts/management**: Carrier Network. **Rate analytics/optimization**: Insights (Bram).     |
| "Who owns automation?"                           | Each team owns automation within their domain. No single "automation team".                           |

---

## Comparison: Current vs Proposed

| Current Team               | Problem                          | Proposed Team(s)                                                       | Resolution                                  |
| -------------------------- | -------------------------------- | ---------------------------------------------------------------------- | ------------------------------------------- |
| Shipping / Consignment     | Blurred boundary                 | **Shipment** + **Consignment**                                         | Clear split: Plan vs Execute                |
| Visibility / Tracking      | Overlaps with exception handling | **Insights**                                                           | Owns detection; Consignment owns resolution |
| Freight Settlement / Rates | Isolated, needs carrier data     | Merged into **Insights** (analytics) + **Carrier Network** (contracts) | Bram's skills used for optimization         |
| Carrier Portal             | Everyone needs carriers          | **Carrier Network**                                                    | Single owner for carrier ecosystem          |

---

## Capacity Overview

| Team            | PE Capacity             | Designer     | PM           | Total FTE |
| --------------- | ----------------------- | ------------ | ------------ | --------- |
| Platform        | 4.0                     | -            | -            | 4.0       |
| Shipment        | 1.0 (Harris)            | 0.5 (Dennis) | 0.5 (Roel)   | 2.0       |
| Consignment     | 1.0 (Fatjon)            | 0.5 (Robin)  | 0.5 (Roel)   | 2.0       |
| Insights        | 1.5 (Sjoerd + Bram 50%) | 0.5 (Dennis) | 0.5 (Wouter) | 2.5       |
| Carrier Network | 1.0 (Nick)              | 0.5 (Robin)  | 0.5 (Wouter) | 2.0       |
| CSM Support     | -                       | Joel         | -            | 1.0       |
| **Total**       | **8.5**                 | **2.0**      | **2.0**      | **13.5**  |

---

## Mentorship & Growth Paths

| Person     | Current Level   | Growth Path                                    | Mentor                               |
| ---------- | --------------- | ---------------------------------------------- | ------------------------------------ |
| **Harris** | Junior PE       | Learn Shipment domain deeply, grow to Medior   | Jeffrey (technical), Roel (domain)   |
| **Nick**   | Medior PE       | Own Carrier Network end-to-end, grow to Senior | Wouter (product thinking)            |
| **Fatjon** | Medior PE       | Deepen Consignment expertise, grow to Senior   | Jeffrey (technical)                  |
| **Bram**   | Medior PE       | Become AI/Data specialist for product          | Wouter (vision), Lennart (technical) |
| **Robin**  | Junior Designer | Learn full UX process, work with Dennis        | Dennis                               |

---

## Open Questions

- [ ] Does merging Freight Settlement into Insights make sense, or should rates stay separate?
- [ ] Is Harris ready to anchor the Shipment team, or should he shadow Fatjon first?
- [ ] How do we handle Jeffrey's split between Platform and Shipment mentorship?
- [ ] Should Joel be 100% CSM support or partially allocated to a product team?
- [ ] What's the right cadence for cross-team syncs to maintain alignment?

---

## Next Steps

1. **Review this proposal** with leadership team
2. **Get feedback from team members** on proposed assignments
3. **Define team charters** for each of the 4 product teams
4. **Create product strategies** for each team (using /product-strategy skill)
5. **Set up team rituals** (standups, retrospectives, cross-team syncs)

---

## Appendix: Full Team Directory

| Name    | Role               | Team                          | Skills                 | Notes                             |
| ------- | ------------------ | ----------------------------- | ---------------------- | --------------------------------- |
| Michael | Senior Backend     | Platform                      | C#, Kubernetes         |                                   |
| Lennart | Senior Backend/SRE | Platform                      | C#, DevOps, Kubernetes |                                   |
| Jeffrey | Senior Backend     | Platform                      | C#, Shipping domain    | Longest serving, mentors Shipment |
| Mila    | Senior Frontend    | Platform                      | Vue, Storybook, Vitest |                                   |
| Sjoerd  | Senior PE          | Insights                      | Full-stack, Tracking   | Most versatile PE                 |
| Fatjon  | Medior PE          | Consignment                   | C#, Vue                | Deep consignment knowledge        |
| Nick    | Medior PE          | Carrier Network               | C#, Vue                | Needs focus, gets ownership       |
| Bram    | Medior PE          | Insights                      | Data, AI, Analytics    | Unique skillset                   |
| Harris  | PE                 | Shipment                      | C#                     | New joiner, learning              |
| Roel    | PM                 | Shipment + Consignment        | Domain expertise       | Detail-focused                    |
| Wouter  | PM                 | Insights + Carrier Network    | Vision, Data, Strategy | Vision-focused                    |
| Dennis  | Senior UX          | Shipment + Insights           | Frontend, Prototyping  | Knows all domains                 |
| Robin   | UX                 | Consignment + Carrier Network | UX Design              | Learning domain                   |
| Joel    | Visual PM          | CSM Support                   | Visual design, Process | Hybrid role                       |
