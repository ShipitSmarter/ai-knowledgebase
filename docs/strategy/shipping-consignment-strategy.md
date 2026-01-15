---
title: Shipping / Consignment Strategy
product_team: Shipping / Consignment
owner: "[TODO: PM name]"
team_members: Sjoerd, Harris, Fatjon, Michael, Joel, Robin, Roel
version: 1.0
last_updated: 2026-01-13
status: draft
---

# Shipping / Consignment Strategy

## Product Vision

**A world where advanced logistics flows become reality for anyone without the hassle.**

Logistics professionals can design complex multi-leg, multi-carrier shipping flows visually, execute shipments in one click, and trust the system to handle exceptions automatically. What used to require deep expertise and hours of manual work becomes accessible, fast, and reliable.

**North Star Metric**: Time saved per user per week through automation

## Link to Company Strategy

| Company Choice | How We Contribute |
|----------------|-------------------|
| **Winning Aspiration**: €12M ARR, 10K professionals | Every hour saved per user per week scales across 10K professionals. Visual flow builder accelerates Enterprise/Mid-market adoption. |
| **Where to Play**: Enterprise (€10M+ spend), Mid-market, EU B2B shippers | We focus on multi-site, complex shipping scenarios that Enterprise and Mid-market need but struggle with. |
| **How to Win**: Automation without complexity, EU cross-border expertise | Visual flow builder makes complex simple. Pre-built EU templates encode cross-border expertise. |

## Target Users

### Primary Persona: Logistics Analyst

**Who they are**: Plans and optimizes shipping flows for the organization. Has moderate technical skills but is not IT. Responsible for carrier relationships and shipping efficiency.

**Pain points**:
1. "Complex multi-leg flows are error-prone" - Every cross-border shipment requires manual coordination, documentation, and carrier handoffs
2. "Changing carriers or adding new routes takes weeks" - IT involvement required for any flow changes
3. "When I leave, my knowledge leaves with me" - Shipping logic lives in my head, not the system

**Jobs to be done**:
- Design shipping flows that handle any scenario without IT help
- Onboard new carriers quickly without breaking existing flows
- Ensure consistent execution even when I'm not there

### Secondary Persona: Warehouse Operator

**Who they are**: Executes shipments day-to-day from the warehouse floor. Needs speed and simplicity. Doesn't want to make decisions - just wants to ship.

**Pain points**:
1. "Too many manual steps" - Every shipment requires clicks, copy-paste, carrier selection
2. "I don't know which carrier to choose" - Decision fatigue when rules aren't clear
3. "Exceptions ruin my day" - One failed pickup means firefighting instead of shipping

**Jobs to be done**:
- Ship packages as fast as possible with minimal decisions
- Know immediately when something goes wrong and what to do
- Get through my queue without stress

### Tertiary Persona: Logistics Manager

**Who they are**: Oversees shipping operations. Cares about cost, compliance, and customer experience. Needs visibility into what's happening and whether it's working.

**Pain points**:
1. "Knowledge walks out the door" - High turnover means constant retraining
2. "I can't optimize what I can't see" - No visibility into how flows perform
3. "Exceptions affect customer experience" - Failed shipments = unhappy receivers

**Jobs to be done**:
- Ensure consistent, compliant shipping across the team
- Reduce dependency on individual experts
- Know when to intervene before customers notice

## Strategic Bets

We are making **3 strategic bets** for the next 12 months:

### Bet 1: Visual Flow Builder

**What we believe**: If we enable logistics analysts to design multi-leg, cross-border flows visually (without IT involvement), then we will dramatically reduce implementation time and increase Enterprise/Mid-market win rates because complex shipping is our target customers' biggest pain point.

**Success metrics**:
- Flows created per customer: [Baseline TBD] → 5+ per Enterprise customer by Q4 2026
- Time to create a new flow: [Baseline TBD] → <30 minutes by Q3 2026
- % of flows created by non-IT users: → 80% by Q4 2026

**Key initiatives**:
1. Build drag-and-drop flow designer with condition logic (if/then)
2. Create pre-built templates for common EU cross-border scenarios
3. Develop testing/simulation mode before going live

**Risks & mitigations**:
- Risk: Too complex for target users → Mitigation: User testing with logistics analysts, not IT
- Risk: Edge cases break flows → Mitigation: Exception routing, not failure

### Bet 2: One-Click Shipping

**What we believe**: If we automate carrier selection, booking, and documentation so routine shipments require zero decisions, then we will save hours per user per week and make Viya indispensable for daily operations because operators want to ship, not configure.

**Success metrics**:
- Zero-touch shipment rate: [Baseline TBD] → 70% of shipments by Q4 2026
- Time per shipment (manual steps): [Baseline TBD] → <10 seconds for automated shipments
- User satisfaction (warehouse operators): NPS [Baseline TBD] → 50+ by Q4 2026

**Key initiatives**:
1. Smart carrier selection based on flow rules, cost, and performance
2. Auto-generation of all documentation (labels, customs, manifests)
3. Bulk processing for high-volume scenarios

**Risks & mitigations**:
- Risk: Automation makes mistakes → Mitigation: Confidence scoring, human review for low-confidence
- Risk: Users don't trust automation → Mitigation: Transparency into why system chose each carrier

### Bet 3: Exception Auto-Resolution

**What we believe**: If the system detects issues and suggests/executes fixes before users notice, then we will prevent the cascade of firefighting that ruins operators' days and damages customer experience because exceptions are the #1 source of stress and receiver complaints.

**Success metrics**:
- Exceptions auto-resolved: [Baseline TBD] → 40% of exceptions by Q4 2026
- Time to resolve remaining exceptions: [Baseline TBD] → <5 minutes by Q4 2026
- Exception-related customer complaints: [Baseline TBD] → 50% reduction by Q4 2026

**Key initiatives**:
1. Proactive exception detection (carrier delays, address issues, capacity)
2. Auto-suggest alternative carriers/routes when issues detected
3. One-click exception resolution with pre-approved actions

**Risks & mitigations**:
- Risk: Auto-resolution causes worse outcomes → Mitigation: Start with suggestions, graduate to auto-execute
- Risk: Depends on good carrier data → Mitigation: Leverage Visibility/Tracking team's data

## How We Win

| Differentiator | How It Delights Users | Why It's Hard to Copy |
|----------------|----------------------|----------------------|
| **UX simplicity for complexity** | Logistics analysts design flows without IT | Years of UX refinement, deep domain expertise embedded in product |
| **Domain knowledge baked in** | Pre-built templates for EU cross-border scenarios | Templates learned from customer data across our network |
| **Implementation speed** | Go live in weeks, not months | Opinionated defaults + visual configuration reduces customization |

## What We're NOT Doing

We are explicitly deprioritizing:

| Not Doing | Rationale |
|-----------|-----------|
| **Custom SMB solutions** | Company strategy focuses on Enterprise/Mid-market (MRR 7k+). SMB customization dilutes product focus. |
| **Mobile-first UX** | Our users (analysts, operators at desks) work on desktop. Mobile is nice-to-have, not strategic. |
| **Fleet/own transport management** | We focus on carrier network, not owned assets. Fleet management is a different product. |

**How we say no**: "We're focused on making third-party carrier shipping world-class. For fleet management, we recommend integrating with [partner] and using Viya for the carrier portion of your network."

## Dependencies & Capabilities

### Capabilities We Need

| Capability | Current State | Gap | Plan to Close |
|------------|--------------|-----|---------------|
| Visual workflow engine | Basic | Full drag-and-drop with conditions | Build Q1-Q2 2026 |
| EU carrier integrations | Strong in Benelux | Gaps in DE, FR, Southern EU | Carrier Portal team dependency |
| Exception detection | Reactive | Proactive/predictive | Collaborate with Visibility team |

### Cross-Team Dependencies

| Dependency | Team | What We Need | Timeline |
|------------|------|--------------|----------|
| Real-time carrier status | Visibility/Tracking | Exception data feed for auto-resolution | Q2 2026 |
| Carrier onboarding | Carrier Portal | Faster carrier activation for new flows | Q2 2026 |
| Rate optimization | Freight Settlement | Cost data for smart carrier selection | Q3 2026 |

## Key Metrics

| Metric | Current | Target | Rationale |
|--------|---------|--------|-----------|
| **Time saved per user/week** | [TODO] | 5+ hours | North star - directly contributes to "10K professionals impacted" |
| **Zero-touch shipment rate** | [TODO] | 70% | Measures automation success |
| **Flow creation time** | [TODO] | <30 min | Measures visual builder usability |
| **Exception auto-resolution rate** | [TODO] | 40% | Measures proactive value |
| **Enterprise/Mid-market win rate** | [TODO] | +20% | Business impact of strategy |

## Review Cadence

- **Weekly**: Bet progress, blockers, key metrics
- **Monthly**: Customer feedback synthesis, competitive moves, metric trends
- **Quarterly**: Full strategy review with leadership, adjust bets if needed

---

## Appendix

### Competitive Landscape

| Competitor | Positioning | Our Differentiation |
|------------|-------------|---------------------|
| **CargoWise** | Comprehensive, complex, expensive | We're simpler, faster to implement, focused on EU |
| **Transporeon** | Strong carrier network | We're more user-friendly, visual flow builder |
| **Shippo/EasyPost** | Simple, API-first | We handle complex multi-leg; they're single-carrier |
| **In-house solutions** | Fully custom | We're faster to deploy, include EU carrier integrations |

### Customer Evidence

[TODO: Add quotes from customer interviews that validate pain points and bets]

Example format:
> "We spend 2 hours per day just selecting carriers and generating paperwork. If that was automated, my team could focus on exceptions." — Logistics Manager, [Customer]

### Open Questions

- [ ] What baseline metrics exist for time saved, zero-touch rate, etc.?
- [ ] Which 3 EU carriers are highest priority for expansion beyond Benelux?
- [ ] How do we measure "knowledge captured in system" vs "knowledge in people's heads"?
- [ ] What's the appetite for auto-resolution vs suggestion-only for exceptions?
- [ ] Should templates be shared across customers or remain private?

---

## Changelog

| Date | Version | Author | Changes |
|------|---------|--------|---------|
| 2026-01-13 | 1.0 | [AI-assisted] | Initial draft created |
