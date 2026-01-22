# CQRS with MongoDB Materialized Views

Research project exploring CQRS patterns using MongoDB materialized views for TMS applications at ShipitSmarter/Viya. This synthesis combines findings from 8 subtopic research documents with 69 unique sources consulted.

## Executive Summary

CQRS (Command Query Responsibility Segregation) with MongoDB materialized views provides a pragmatic architecture for TMS applications that need both **reporting analytics** and **fast application queries** (list views, dashboards, lookups). The key insight from this research is that **CQRS is a spectrum**—most applications should use "Simplified CQRS" (Level 1: same database, logical code separation) rather than jumping to separate databases or event sourcing.

For Viya TMS, the recommended approach is:

1. **Use MediatR** for command/query separation in C#/.NET
2. **MongoDB change streams** for event-driven MV synchronization (no external message broker needed)
3. **Purpose-built materialized views** for list views, lookups, and dashboards
4. **Optimistic UI** with read-your-own-writes guarantees for user experience
5. **Hybrid refresh strategy** - event-driven for critical MVs, scheduled batch for reports

This architecture provides 80% of CQRS benefits with 20% of the complexity of full event sourcing.

## Key Insights

### High Confidence (Multiple Sources Agree)

| Finding | Confidence | Sources |
|---------|------------|---------|
| CQRS doesn't require separate databases | Very High | Microsoft, Fowler, Young, Dahan |
| MediatR is de facto standard for CQRS in .NET | Very High | Microsoft docs, community adoption |
| Cursor pagination is 4x faster than offset for large datasets | High | MongoDB docs, performance benchmarks |
| Change streams provide ordered, resumable event delivery | High | MongoDB official docs |
| `$merge` enables incremental MV updates; `$out` replaces entire collection | High | MongoDB official docs |
| Design read models per query, not per entity | High | Microsoft, event sourcing experts |

### Medium Confidence (Limited Sources or Vendor-Specific)

| Finding | Confidence | Notes |
|---------|------------|-------|
| Change streams can replace message brokers for CQRS sync | Medium | True within MongoDB, not for external systems |
| ESR (Equality-Sort-Range) index order is optimal | Medium | MongoDB vendor guidance, widely accepted |
| Event-driven + scheduled hybrid is optimal refresh strategy | Medium | Practitioner consensus, limited academic research |
| 0.1s/1s/10s response time limits apply to all applications | Medium | Nielsen research is dated (1993), still widely cited |

### Open Questions (Needs Validation)

- [ ] Change stream performance at scale (1000s of writes/second)
- [ ] Practical limit on concurrent change stream cursors
- [ ] Multi-tenant sharding implications for MVs
- [ ] Oplog retention requirements for extended downtime recovery

## Cross-Topic Findings

### Confirmed Patterns (Multiple Documents Agree)

1. **Simplified CQRS is the right starting point**
   - Fundamentals, MongoDB Platform, and .NET Implementation all recommend same-database CQRS
   - Separate databases only justified for extreme scale or technology mismatch

2. **Change streams are MongoDB's CQRS event bus**
   - MongoDB Platform, Write Model, Refresh Strategies all emphasize change streams
   - Resume tokens enable exactly-once processing semantics
   - No external message broker needed for within-MongoDB sync

3. **Idempotent projections are essential**
   - Write Model, Refresh Strategies, .NET Implementation all stress idempotency
   - Use upsert operations with deterministic keys
   - Store processed event IDs or use version fields

4. **Optimistic UI + RYW is the UX pattern**
   - Eventual Consistency research provides strong UX foundation
   - MongoDB causal sessions provide RYW guarantees
   - Combine with client-side caching for best experience

### Tensions/Trade-offs Identified

| Tension | Option A | Option B | Recommendation |
|---------|----------|----------|----------------|
| Freshness vs Load | Event-driven (real-time) | Scheduled (batch) | Hybrid based on MV criticality |
| Fat vs Lean events | Include all denormalized data | Include only IDs, lookup at projection | Lean + lookup for most cases |
| Read model per query vs shared | Multiple specialized MVs | Fewer general-purpose MVs | Per-query for critical paths |
| Validation: write model vs read model | Always query write model | Query read model for speed | Read model OK with compensating transactions |

### Emergent Patterns for TMS

1. **4-tier MV architecture**
   - **Real-time**: Operations dashboard (5-min refresh, single-doc pattern)
   - **Near-real-time**: List views (change stream driven)
   - **Deferred**: Lookups/dropdowns (15-min scheduled)
   - **Batch**: Reports (hourly/daily)

2. **Composite `_id` pattern**
   - Include `organizationId` in MV `_id` for multi-tenant
   - Enables efficient per-tenant queries and data isolation
   - Example: `{ _id: { organizationId: "org-123", shipmentId: "shp-456" } }`

3. **Hierarchical projection**
   - Embed parent summary in child MV (consignment knows shipment status)
   - Embed child summary in parent MV (shipment knows consignment count)
   - Accept eventual consistency for display fields

## Recommendations for Viya TMS

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Viya TMS                              │
│  ┌──────────────────┐         ┌──────────────────┐          │
│  │   Command Side   │         │   Query Side     │          │
│  │   (MediatR)      │         │   (MediatR)      │          │
│  │   - Validators   │         │   - DTOs         │          │
│  │   - Handlers     │         │   - Handlers     │          │
│  └────────┬─────────┘         └────────┬─────────┘          │
│           │                            │                     │
│           ▼                            ▼                     │
│  ┌──────────────────┐         ┌──────────────────┐          │
│  │ Source Collections│────────▶│ Materialized     │          │
│  │ (shipments, etc.) │ Change  │ Views (mv_*)     │          │
│  └──────────────────┘ Streams └──────────────────┘          │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              BackgroundService                        │   │
│  │   ShipmentChangeStreamService (MV updates)           │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Recommended MVs for Application Queries

| MV Name | Purpose | Refresh | Key Fields |
|---------|---------|---------|------------|
| `mv_shipment_list` | Shipment list view | Change stream | reference, status, customer, carrier, origin, destination |
| `mv_consignment_list` | Consignment list with shipment context | Change stream | reference, tracking, shipment.reference, carrier |
| `mv_customer_lookup` | Customer autocomplete | 15-min scheduled | label, code, searchText |
| `mv_carrier_lookup` | Carrier dropdown | 15-min scheduled | label, code, services |
| `mv_dashboard_counters` | Operations dashboard | 5-min scheduled | single doc per org with nested counts |

### Implementation Priorities

1. **Phase 1: Foundation**
   - Add MediatR to Viya
   - Refactor one bounded context to commands/queries
   - Create `mv_shipment_list` with change stream handler

2. **Phase 2: Expand**
   - Add lookup MVs for dropdowns
   - Implement dashboard counters MV
   - Add validation behaviors to pipeline

3. **Phase 3: Optimize**
   - Add cursor-based pagination
   - Implement optimistic UI patterns
   - Monitor and tune refresh strategies

## Documents

| Document | Date | Status | Description |
|----------|------|--------|-------------|
| [Exploration Plan](./2026-01-21-exploration-plan.md) | 2026-01-21 | complete | Subtopic discovery and research questions |
| [CQRS Fundamentals](./2026-01-21-cqrs-fundamentals.md) | 2026-01-21 | reviewed | CQRS spectrum (4 levels), simplified CQRS |
| [MongoDB CQRS Platform](./2026-01-21-mongodb-cqrs-platform.md) | 2026-01-21 | reviewed | Change streams, $merge/$out, consistency |
| [Application Read Models](./2026-01-21-application-read-models.md) | 2026-01-21 | reviewed | List views, lookups, dashboards, pagination |
| [Write Model & Commands](./2026-01-21-write-model-commands.md) | 2026-01-21 | reviewed | Command patterns, propagation strategies |
| [Eventual Consistency](./2026-01-21-eventual-consistency.md) | 2026-01-21 | reviewed | Staleness management, optimistic UI, RYW |
| [MV Design Patterns](./2026-01-21-mv-design-patterns.md) | 2026-01-21 | reviewed | Practical schemas for TMS screens |
| [Refresh Strategies](./2026-01-21-refresh-strategies.md) | 2026-01-21 | reviewed | Event-driven vs batch, performance |
| [CQRS in .NET](./2026-01-21-cqrs-dotnet-mongodb.md) | 2026-01-21 | reviewed | MediatR, BackgroundService, implementation |
| [Source Review](./2026-01-21-source-review.md) | 2026-01-21 | complete | Source quality and reliability assessment |

## Related Research

- [Viya Reporting MV Strategy](../viya-reporting/2026-01-21-materialized-view-strategy.md) - Reporting-focused MVs (4 MVs for analytics)
- [Viya Reporting Index](../viya-reporting/_index.md) - Reporting research summary

## Key Concepts Glossary

| Term | Definition |
|------|------------|
| **CQRS** | Command Query Responsibility Segregation - separating read and write models |
| **Simplified CQRS** | Level 1 CQRS with same database, logical code separation |
| **Materialized View (MV)** | Pre-computed query results stored as a collection |
| **Change Stream** | MongoDB real-time data change notifications |
| **Resume Token** | Checkpoint for resuming change stream from specific position |
| **Read Model** | Denormalized data structure optimized for specific queries |
| **Projection** | Process of transforming events/changes into read model updates |
| **Optimistic UI** | Showing expected result before server confirmation |
| **Read-Your-Own-Writes (RYW)** | Guarantee that user sees their own changes immediately |
| **ESR Rule** | Index field ordering: Equality, Sort, Range |

## Statistics

- **Documents**: 9 research documents + 1 synthesis
- **Sources Consulted**: 69 unique sources across all documents
- **Primary Sources**: MongoDB official docs, Microsoft Learn, Martin Fowler, Greg Young
- **Research Period**: 2026-01-21
- **Status**: Synthesis complete
