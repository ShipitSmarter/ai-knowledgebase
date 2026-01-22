---
topic: CQRS with MongoDB Materialized Views - Exploration Plan
date: 2026-01-21
project: cqrs-mongodb
sources_count: 8
status: planning
tags: [exploration, cqrs, mongodb, materialized-views, event-sourcing]
---

# CQRS with MongoDB Materialized Views - Exploration Plan

## Discovery Summary

CQRS (Command Query Responsibility Segregation) is a software architectural pattern that separates read and write operations into distinct models, each optimized for its specific purpose. The pattern extends CQS (Command Query Separation) from method-level to architectural-level concerns. When combined with MongoDB's on-demand materialized views and change streams, CQRS enables powerful patterns for both **reporting analytics** and **application-embedded read models**.

Key insight from discovery: CQRS doesn't mandate separate databases—it can start with logical separation in code (same database, different models) and evolve to physical separation as needed. MongoDB's change streams provide the event propagation mechanism needed to synchronize write models with read models without requiring a separate message broker.

The context for this research is **Viya TMS**, where we've already designed 4 materialized views for reporting. The goal is to expand the MV approach to serve application-embedded queries (list views, lookups, dashboards) using CQRS principles—avoiding constant ad-hoc collection queries while maintaining data freshness.

### Prior Knowledge Found

**Memory:** No prior CQRS research found. Related: MV strategy for Viya reporting (4 dimensional MVs designed).

**Existing Research:** `research/viya-reporting/2026-01-21-materialized-view-strategy.md` covers reporting-focused MVs but doesn't address application-embedded CQRS patterns.

### Initial Sources Consulted

| Source | Type | Key Insight |
|--------|------|-------------|
| [Microsoft CQRS Pattern](https://learn.microsoft.com/azure/architecture/patterns/cqrs) | Official docs | Comprehensive pattern definition; separate models for read/write; can share database or use separate stores |
| [MongoDB On-Demand Materialized Views](https://www.mongodb.com/docs/manual/core/materialized-views/) | Official docs | Use `$merge`/`$out` to persist aggregation results; can create indexes on MVs |
| [MongoDB Change Streams](https://www.mongodb.com/docs/manual/changeStreams/) | Official docs | Real-time data change notifications; can trigger MV updates; supports filtering |
| [MongoDB Computed Pattern](https://www.mongodb.com/blog/post/building-with-patterns-the-computed-pattern) | Vendor blog | Pre-compute expensive calculations; useful for read-heavy workloads |
| [Kurrent CQRS Guide](https://www.kurrent.io/cqrs-pattern) | Vendor docs | CQRS misconceptions; doesn't require separate DBs or message queues; pairs well with Event Sourcing |
| [Microsoft Simplified CQRS/DDD](https://learn.microsoft.com/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/apply-simplified-microservice-cqrs-ddd-patterns) | Official docs | Practical .NET implementation; single database with logical separation; ViewModels for read side |

## Proposed Subtopics

### 1. CQRS Fundamentals & Spectrum of Implementation
**Why:** Establish clear understanding of CQRS levels—from logical code separation to full event-sourced systems—to choose appropriate level for Viya.
**Questions to answer:**
- What are the different levels of CQRS implementation (same DB, separate DBs, event sourcing)?
- When is each level appropriate? What are the trade-offs?
- How does "simplified CQRS" work in practice (Microsoft's approach)?

### 2. MongoDB as a CQRS Platform
**Why:** Understand MongoDB-specific capabilities and patterns for implementing CQRS.
**Questions to answer:**
- How do change streams enable CQRS synchronization without message brokers?
- What are the patterns for using `$merge`/`$out` to maintain read models?
- How do MongoDB views vs materialized views fit into CQRS architecture?
- What are the consistency guarantees and latency characteristics?

### 3. Application-Embedded Read Models (Non-Reporting)
**Why:** Core goal—identify what MVs should be created for application UI (list views, dropdowns, dashboards) vs ad-hoc queries.
**Questions to answer:**
- What query patterns benefit from pre-computed read models?
- How to design MVs for list views with filtering, sorting, pagination?
- When should the application query source collections directly vs read models?
- How to handle entity lookups (single record retrieval) in CQRS?

### 4. Write Model & Command Handling Patterns
**Why:** CQRS includes the write side—understand command patterns that trigger read model updates.
**Questions to answer:**
- How should commands be structured in a MongoDB CQRS system?
- What triggers MV updates: change streams, post-command hooks, or scheduled jobs?
- How to ensure write model changes propagate to read models reliably?
- How to handle command validation that needs to query data?

### 5. Eventual Consistency & Staleness Management
**Why:** Separate read/write models introduce consistency delays—need strategies to manage user expectations.
**Questions to answer:**
- What latency is acceptable for different use cases (ops dashboard vs list views)?
- How do users handle "just created but not yet visible" scenarios?
- What patterns exist for read-your-own-writes in CQRS?
- How to communicate data freshness to users?

### 6. MV Design Patterns for Common Application Queries
**Why:** Practical guidance on designing MVs for typical TMS application screens.
**Questions to answer:**
- What MV schema works for shipment list views with multi-field filters?
- How to design customer/carrier lookup MVs for autocomplete/dropdowns?
- What aggregations support dashboard widgets (counts, totals, charts)?
- How to handle hierarchical data (shipments → consignments → handling units)?

### 7. Refresh Strategies & Performance
**Why:** Balance data freshness against system load and complexity.
**Questions to answer:**
- When to use event-driven (change streams) vs scheduled (batch) refresh?
- How to implement incremental updates efficiently?
- What are the performance implications of many MVs?
- How to monitor and troubleshoot MV refresh issues?

### 8. CQRS in C#/.NET with MongoDB
**Why:** Viya uses C#/.NET—need implementation-specific guidance.
**Questions to answer:**
- How to structure commands/queries in C# (MediatR pattern)?
- How to implement MongoDB change stream handlers in .NET?
- What libraries/patterns exist for CQRS with MongoDB in .NET?
- How does this integrate with existing Viya architecture?

## Flagged Uncertainties

- [ ] **Change stream reliability** - What happens when change stream handler is down? How to ensure no events are lost?
- [ ] **MV count limits** - Is there a practical limit to how many MVs a MongoDB deployment can support?
- [ ] **Write-heavy scenarios** - Most CQRS advice assumes read-heavy; what about TMS operations with high write throughput?
- [ ] **Multi-tenant considerations** - How does CQRS/MV design change for multi-tenant SaaS (organization-scoped data)?
- [ ] **Event Sourcing necessity** - Sources differ on whether Event Sourcing is required for "real" CQRS benefits

## Recommended Research Order

1. **CQRS Fundamentals** - Foundation for understanding all other subtopics
2. **MongoDB as CQRS Platform** - MongoDB-specific capabilities we can leverage
3. **Application-Embedded Read Models** - Core goal of this research
4. **MV Design Patterns** - Practical schemas for Viya use cases
5. **Eventual Consistency** - Important UX consideration
6. **Write Model & Commands** - Complete the picture
7. **Refresh Strategies** - Operational concerns
8. **CQRS in C#/.NET** - Implementation specifics

## Use Case Categories to Track

As research progresses, findings should be categorized by:

### Reporting Use Cases (Already covered in viya-reporting)
- Daily volume summaries
- Carrier performance scorecards
- Geographic distribution reports
- Transit time analysis

### Application-Embedded Use Cases (Focus of this research)
- **List Views**: Shipment list, consignment list, customer list
- **Lookups/Dropdowns**: Carrier selector, customer autocomplete, address lookup
- **Dashboards**: Operations dashboard, today's pickups, exception alerts
- **Entity Detail**: Single shipment view, consignment detail
- **Search**: Full-text search, filtered search results

## Next Steps

Awaiting user approval to proceed with subtopic research.

**Options:**
1. Approve all 8 subtopics → Proceed with parallel research
2. Remove/add subtopics based on priority
3. Reorder to focus on specific areas first
4. Request more discovery on specific topics
