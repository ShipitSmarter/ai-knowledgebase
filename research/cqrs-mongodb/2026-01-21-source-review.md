---
topic: CQRS MongoDB Research - Source Review
date: 2026-01-21
project: cqrs-mongodb
status: complete
tags: [source-review, quality-assessment, bibliography]
---

# CQRS MongoDB Research - Source Review

## Overview

This document assesses the quality and reliability of sources used across the CQRS with MongoDB research project. Sources are categorized by type, authority, and key contributions.

## Source Categories

### Tier 1: Authoritative Primary Sources

These sources are definitive references from pattern creators, official documentation, or widely-recognized authorities.

| Source | Author/Org | Type | Used In | Assessment |
|--------|------------|------|---------|------------|
| [CQRS (bliki)](https://martinfowler.com/bliki/CQRS.html) | Martin Fowler | Foundational | Fundamentals | **Excellent**. Pattern co-creator's perspective. Strong cautions about overuse. |
| [CQRS Introduction](https://cqrs.wordpress.com/documents/cqrs-introduction/) | Greg Young | Foundational | Fundamentals | **Excellent**. Original pattern creator's documentation. Definitive source. |
| [Clarified CQRS](https://udidahan.com/2009/12/09/clarified-cqrs/) | Udi Dahan | Foundational | Fundamentals | **Excellent**. Deep architectural insights on collaboration/staleness as driving forces. |
| [Microsoft CQRS Pattern](https://learn.microsoft.com/azure/architecture/patterns/cqrs) | Microsoft | Official docs | Multiple | **Excellent**. Comprehensive, well-maintained, practical guidance. |
| [MongoDB Change Streams](https://www.mongodb.com/docs/manual/changeStreams/) | MongoDB | Official docs | Multiple | **Excellent**. Definitive reference for change stream mechanics. |
| [MongoDB Materialized Views](https://www.mongodb.com/docs/manual/core/materialized-views/) | MongoDB | Official docs | Multiple | **Excellent**. Official $merge/$out documentation. |
| [Jepsen Read Your Writes](https://jepsen.io/consistency/models/read-your-writes) | Jepsen (Kyle Kingsbury) | Academic | Eventual Consistency | **Excellent**. Formal consistency model definition. Trusted in distributed systems. |
| [NN/g Response Times](https://www.nngroup.com/articles/response-times-3-important-limits/) | Nielsen Norman Group | Research | Eventual Consistency | **Excellent**. Foundational UX research, though dated (1993 origin). |

### Tier 2: High-Quality Official Documentation

Official documentation from vendors or framework maintainers.

| Source | Author/Org | Type | Used In | Assessment |
|--------|------------|------|---------|------------|
| [Microsoft Simplified CQRS/DDD](https://learn.microsoft.com/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/apply-simplified-microservice-cqrs-ddd-patterns) | Microsoft | Official docs | Fundamentals, .NET | **Very Good**. Practical .NET implementation guidance. |
| [MongoDB $merge Documentation](https://www.mongodb.com/docs/manual/reference/operator/aggregation/merge/) | MongoDB | Official docs | Refresh, MV Patterns | **Very Good**. Complete reference for whenMatched options. |
| [MediatR Wiki](https://github.com/jbogard/MediatR/wiki) | Jimmy Bogard | Official docs | .NET Implementation | **Very Good**. Authoritative for MediatR patterns. |
| [MongoDB C# Driver Docs](https://www.mongodb.com/docs/drivers/csharp/current/) | MongoDB | Official docs | .NET Implementation | **Very Good**. Current driver documentation. |
| [FluentValidation Docs](https://docs.fluentvalidation.net/en/latest/aspnet.html) | Jeremy Skinner | Official docs | .NET Implementation | **Very Good**. Definitive for validation integration. |
| [TanStack Query Optimistic Updates](https://tanstack.com/query/latest/docs/framework/react/guides/optimistic-updates) | TanStack | Official docs | Eventual Consistency | **Very Good**. Practical optimistic UI patterns. |
| [MongoDB Causal Consistency](https://www.mongodb.com/docs/manual/core/causal-consistency-read-write-concerns/) | MongoDB | Official docs | Eventual Consistency | **Very Good**. Technical reference for consistency guarantees. |

### Tier 3: Vendor Blogs & Practitioner Content

High-quality content from vendors or recognized practitioners. May have marketing bias but technically sound.

| Source | Author/Org | Type | Used In | Assessment |
|--------|------------|------|---------|------------|
| [MongoDB Computed Pattern](https://www.mongodb.com/blog/post/building-with-patterns-the-computed-pattern) | MongoDB | Vendor blog | Read Models, Refresh | **Good**. Practical pattern with clear use cases. Vendor perspective. |
| [MongoDB Extended Reference Pattern](https://www.mongodb.com/blog/post/building-with-patterns-the-extended-reference-pattern) | MongoDB | Vendor blog | Read Models, MV Patterns | **Good**. Useful denormalization guidance. |
| [MongoDB Bucket Pattern](https://www.mongodb.com/blog/post/building-with-patterns-the-bucket-pattern) | MongoDB | Vendor blog | MV Patterns | **Good**. Time-series aggregation patterns. |
| [Kurrent CQRS Guide](https://www.kurrent.io/cqrs-pattern) | Kurrent (EventStore) | Vendor docs | Fundamentals | **Good**. Clarifies misconceptions. Note: EventStore vendor may favor event sourcing. |
| [Oskar Dudycz - Event Projections](https://event-driven.io/en/how_to_do_events_projections_with_entity_framework/) | Oskar Dudycz | Expert blog | Read Models | **Good**. Practical projection patterns from recognized ES expert. |
| [Milan Jovanovic - CQRS with MediatR](https://www.milanjovanovic.tech/blog/cqrs-pattern-with-mediatr) | Milan Jovanovic | Expert blog | .NET Implementation | **Good**. Clean Architecture perspective. Well-regarded .NET blogger. |
| [Change Streams Production Recommendations](https://www.mongodb.com/docs/manual/administration/change-streams-production-recommendations/) | MongoDB | Official docs | Refresh Strategies | **Good**. Operational guidance, performance constraints. |

### Tier 4: Community Content

Useful practitioner content with varying levels of rigor.

| Source | Author/Org | Type | Used In | Assessment |
|--------|------------|------|---------|------------|
| [Cursor Paging with EF Core](https://khalidabuhakmeh.com/cursor-paging-with-entity-framework-core-and-aspnet-core) | Khalid Abuhakmeh | Blog | Read Models | **Moderate**. 4x performance claim is specific to his benchmark. Conceptually sound. |
| [UX Planet Optimistic UIs](https://uxplanet.org/optimistic-1000-34d9eefe4c05) | UX Planet | Blog | Eventual Consistency | **Moderate**. Good examples, less rigorous than NN/g. |
| [Bits and Pieces Optimistic UI](https://blog.bitsrc.io/building-an-optimistic-user-interface-in-react-b943656e75e3) | Bits and Pieces | Blog | Eventual Consistency | **Moderate**. Implementation-focused, React-specific. |

## Source Quality Summary

### By Reliability

| Tier | Count | Description |
|------|-------|-------------|
| Tier 1 (Authoritative) | 8 | Pattern creators, official docs, academic |
| Tier 2 (Official Docs) | 7 | Vendor documentation, framework maintainers |
| Tier 3 (Vendor/Expert) | 7 | High-quality blogs with potential bias |
| Tier 4 (Community) | 3 | Practitioner content, varying rigor |

### By Source Type

| Type | Count | Notes |
|------|-------|-------|
| Official Documentation | 15 | MongoDB, Microsoft, Framework docs |
| Foundational/Academic | 4 | Fowler, Young, Dahan, Jepsen |
| Vendor Blogs | 5 | MongoDB Building with Patterns series |
| Expert Blogs | 4 | Recognized practitioners |
| Community Blogs | 3 | General developer content |

### By Topic Coverage

| Topic | Primary Sources | Total Sources |
|-------|-----------------|---------------|
| CQRS Fundamentals | 4 (Fowler, Young, Dahan, Microsoft) | 7 |
| MongoDB Platform | 3 (MongoDB official docs) | 7 |
| Read Models | 2 (Microsoft, MongoDB) | 9 |
| Write Models | 3 (Microsoft, MongoDB, Kurrent) | 9 |
| Eventual Consistency | 4 (NN/g, Jepsen, Microsoft, TanStack) | 12 |
| MV Design Patterns | 2 (MongoDB) | 8 |
| Refresh Strategies | 2 (MongoDB) | 8 |
| .NET Implementation | 3 (Microsoft, MediatR, FluentValidation) | 9 |

## Conflicting Information

### Minor Disagreements

1. **Whether CQRS requires Event Sourcing**
   - Fowler, Microsoft: Clearly separates CQRS from ES
   - Kurrent (EventStore vendor): Emphasizes ES benefits, may overstate coupling
   - **Resolution**: CQRS and ES are orthogonal; can use either independently

2. **Response time thresholds**
   - Nielsen (1993): 0.1s/1s/10s limits
   - Modern UX research: Context-dependent, may be more forgiving
   - **Resolution**: Use Nielsen as baseline, adjust for specific user expectations

3. **Optimistic UI error handling**
   - TanStack: Recommends rollback on error
   - UX Planet: Suggests silent retry for transient failures
   - **Resolution**: Both valid; use silent retry first, then rollback with message

### No Major Conflicts Found

The research sources generally agree on:
- Simplified CQRS as starting point
- Change streams for event propagation
- $merge for incremental updates
- Idempotent projection handlers
- Cursor pagination superiority

## Gaps in Available Sources

### Topics Needing More Research

1. **Multi-tenant CQRS at scale** - Limited guidance for SaaS scenarios with 1000s of tenants
2. **Change stream performance limits** - Benchmarks for high-volume scenarios are scarce
3. **MV migration strategies** - Schema evolution for production MVs
4. **Testing patterns** - Integration testing for change stream handlers

### Vendor Bias Considerations

- **MongoDB sources** may favor MongoDB-native solutions over external message brokers
- **Kurrent/EventStore sources** may favor event sourcing complexity
- **Microsoft sources** favor .NET ecosystem patterns

## Recommendations for Future Research

1. **Conduct internal benchmarks** for change stream performance with Viya data volumes
2. **Seek case studies** from similar TMS implementations
3. **Monitor MongoDB blog** for updated production recommendations
4. **Consider reaching out** to MongoDB consulting for multi-tenant guidance

## Complete Bibliography

### Primary Pattern Sources
1. Fowler, M. "CQRS" https://martinfowler.com/bliki/CQRS.html
2. Young, G. "CQRS Introduction" https://cqrs.wordpress.com/documents/cqrs-introduction/
3. Dahan, U. "Clarified CQRS" https://udidahan.com/2009/12/09/clarified-cqrs/

### Microsoft Documentation
4. Microsoft. "CQRS Pattern" https://learn.microsoft.com/azure/architecture/patterns/cqrs
5. Microsoft. "Simplified CQRS/DDD" https://learn.microsoft.com/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/apply-simplified-microservice-cqrs-ddd-patterns
6. Microsoft. "CQRS Microservice Reads" https://learn.microsoft.com/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/cqrs-microservice-reads
7. Microsoft. "DDD-Oriented Microservice" https://learn.microsoft.com/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/ddd-oriented-microservice
8. Microsoft. "eShop CQRS Approach" https://learn.microsoft.com/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/eshoponcontainers-cqrs-ddd-microservice
9. Microsoft. "Worker Services" https://learn.microsoft.com/dotnet/core/extensions/workers

### MongoDB Documentation
10. MongoDB. "Change Streams" https://www.mongodb.com/docs/manual/changeStreams/
11. MongoDB. "On-Demand Materialized Views" https://www.mongodb.com/docs/manual/core/materialized-views/
12. MongoDB. "$merge" https://www.mongodb.com/docs/manual/reference/operator/aggregation/merge/
13. MongoDB. "$out" https://www.mongodb.com/docs/manual/reference/operator/aggregation/out/
14. MongoDB. "Views" https://www.mongodb.com/docs/manual/core/views/
15. MongoDB. "Change Streams Production Recommendations" https://www.mongodb.com/docs/manual/administration/change-streams-production-recommendations/
16. MongoDB. "Causal Consistency" https://www.mongodb.com/docs/manual/core/causal-consistency-read-write-concerns/
17. MongoDB. "Indexes" https://www.mongodb.com/docs/manual/indexes/
18. MongoDB. "Compound Indexes" https://www.mongodb.com/docs/manual/core/indexes/index-types/index-compound/
19. MongoDB. "cursor.skip()" https://www.mongodb.com/docs/manual/reference/method/cursor.skip/
20. MongoDB. "Model One-to-Many" https://www.mongodb.com/docs/manual/tutorial/model-embedded-one-to-many-relationships-between-documents/
21. MongoDB. "Text Search" https://www.mongodb.com/docs/manual/text-search/
22. MongoDB. "C# Driver" https://www.mongodb.com/docs/drivers/csharp/current/
23. MongoDB. "Atlas Triggers" https://www.mongodb.com/docs/atlas/atlas-ui/triggers/

### MongoDB Blog (Building with Patterns)
24. MongoDB Blog. "Computed Pattern" https://www.mongodb.com/blog/post/building-with-patterns-the-computed-pattern
25. MongoDB Blog. "Extended Reference Pattern" https://www.mongodb.com/blog/post/building-with-patterns-the-extended-reference-pattern
26. MongoDB Blog. "Bucket Pattern" https://www.mongodb.com/blog/post/building-with-patterns-the-bucket-pattern

### Framework Documentation
27. MediatR Wiki. "Home" https://github.com/jbogard/MediatR/wiki
28. MediatR Wiki. "Behaviors" https://github.com/jbogard/MediatR/wiki/Behaviors
29. FluentValidation. "ASP.NET Integration" https://docs.fluentvalidation.net/en/latest/aspnet.html
30. TanStack. "Optimistic Updates" https://tanstack.com/query/latest/docs/framework/react/guides/optimistic-updates

### UX Research
31. Nielsen Norman Group. "Response Times" https://www.nngroup.com/articles/response-times-3-important-limits/
32. Nielsen Norman Group. "Progress Indicators" https://www.nngroup.com/articles/progress-indicators/
33. Nielsen Norman Group. "Visibility of System Status" https://www.nngroup.com/articles/visibility-system-status/

### Distributed Systems
34. Jepsen. "Read Your Writes" https://jepsen.io/consistency/models/read-your-writes

### Vendor/Expert Blogs
35. Kurrent. "CQRS Pattern" https://www.kurrent.io/cqrs-pattern
36. Kurrent. "Event Sourcing and CQRS" https://www.kurrent.io/blog/event-sourcing-and-cqrs
37. Dudycz, O. "Event Projections" https://event-driven.io/en/how_to_do_events_projections_with_entity_framework/
38. Dudycz, O. "Nested Object Projections" https://event-driven.io/en/how_to_create_projections_of_events_for_nested_object_structures/
39. Jovanovic, M. "CQRS with MediatR" https://www.milanjovanovic.tech/blog/cqrs-pattern-with-mediatr
40. Particular Software. "Messaging Concepts" https://docs.particular.net/nservicebus/concepts/
41. Fowler, M. "Reporting Database" https://martinfowler.com/bliki/ReportingDatabase.html

### Community Blogs
42. Abuhakmeh, K. "Cursor Paging with EF Core" https://khalidabuhakmeh.com/cursor-paging-with-entity-framework-core-and-aspnet-core
43. UX Planet. "Optimistic UIs" https://uxplanet.org/optimistic-1000-34d9eefe4c05
44. Bits and Pieces. "Optimistic UI in React" https://blog.bitsrc.io/building-an-optimistic-user-interface-in-react-b943656e75e3

### Internal References
45. Viya Reporting MV Strategy (../viya-reporting/2026-01-21-materialized-view-strategy.md)
46. Exploration Plan (./2026-01-21-exploration-plan.md)
