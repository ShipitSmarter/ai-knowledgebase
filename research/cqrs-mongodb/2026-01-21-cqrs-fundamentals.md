---
topic: CQRS Fundamentals & Spectrum of Implementation
date: 2026-01-21
project: cqrs-mongodb
sources_count: 7
status: reviewed
tags: [cqrs, architecture, patterns, event-sourcing, ddd]
---

# CQRS Fundamentals & Spectrum of Implementation

## Summary

Command Query Responsibility Segregation (CQRS) is an architectural pattern that separates read and write operations into distinct models. Originating from Bertrand Meyer's Command Query Separation (CQS) principle at the method level, Greg Young extended it to an architectural pattern in 2010. The critical insight is that **CQRS exists on a spectrum**—from simple logical separation within the same database to full event-sourced systems with separate data stores. Most applications benefit from "simplified CQRS" (Level 1), while only highly collaborative or high-scale domains justify the complexity of separate databases (Level 2) or event sourcing (Level 3).

Martin Fowler's key warning resonates throughout the literature: "CQRS is a significant mental leap... you should be very cautious about using CQRS. Many information systems fit well with the notion of an information base that is updated in the same way that it's read." The pattern adds value primarily in **collaborative environments** where multiple actors modify shared data, not as a general-purpose architecture. For a TMS application like Viya, simplified CQRS with MongoDB materialized views likely represents the sweet spot—gaining read optimization benefits without event sourcing complexity.

## Key Findings

1. **CQRS is NOT about separate databases** — The fundamental misconception is that CQRS requires separate read/write databases. It's about separating the *responsibilities* in code; physical separation is optional and often unnecessary.

2. **The pattern exists on a spectrum with 4 distinct levels** — From traditional CRUD (Level 0) through logical separation (Level 1), separate data stores (Level 2), to full Event Sourcing (Level 3). Most applications should stop at Level 1.

3. **"Simplified CQRS" is the recommended starting point** — Microsoft explicitly advocates starting with the same database, different code models. The eShopOnContainers reference app uses a single database with logical separation as its CQRS example.

4. **CQRS should only apply to specific bounded contexts** — Not system-wide. As Fowler states: "CQRS should only be used on specific portions of a system (a BoundedContext in DDD lingo) and not the system as a whole."

5. **Event Sourcing is orthogonal to CQRS** — They pair well but are independent patterns. You can have CQRS without ES, and ES without CQRS. The conflation of these patterns is a major source of confusion.

6. **The driving forces are collaboration and staleness** — Udi Dahan identifies these as the key reasons to use CQRS: multiple actors modifying shared data, and the inherent staleness of data in any distributed system.

7. **Most systems don't need CQRS** — Fowler's experience: "so far the majority of cases I've run into have not been so good, with CQRS seen as a significant force for getting a software system into serious difficulties."

## The CQRS Implementation Spectrum

### Level 0: Traditional CRUD (No CQRS)

**Description:** Single model for both reads and writes. Same objects, same database, same code paths.

```
┌─────────────────────────────────────┐
│           Application               │
│  ┌─────────────────────────────┐   │
│  │      Single Model           │   │
│  │  (Reads AND Writes)         │   │
│  └─────────────────────────────┘   │
│               │                     │
│               ▼                     │
│        ┌──────────┐                │
│        │ Database │                │
│        └──────────┘                │
└─────────────────────────────────────┘
```

**When appropriate:**
- Simple CRUD applications
- Single-user systems
- Data doesn't have complex business rules
- Read and write patterns are similar

**Trade-offs:**
- ✅ Simplest to understand and maintain
- ✅ No synchronization concerns
- ✅ Single source of truth
- ❌ Can't optimize reads/writes independently
- ❌ Domain model polluted with query concerns

### Level 1: Logical Separation (Simplified CQRS)

**Description:** Same database, but separate code paths for commands and queries. Different object models optimized for each purpose.

```
┌─────────────────────────────────────────────┐
│              Application                     │
│  ┌──────────────┐    ┌──────────────┐       │
│  │ Command Side │    │  Query Side  │       │
│  │ (Domain Model)│   │ (ViewModels) │       │
│  └──────┬───────┘    └──────┬───────┘       │
│         │                    │               │
│         └────────┬───────────┘               │
│                  ▼                           │
│           ┌──────────┐                       │
│           │ Database │                       │
│           └──────────┘                       │
└─────────────────────────────────────────────┘
```

**How it works (Microsoft's approach):**
- **Write side:** Rich domain model with business logic, validation, aggregates
- **Read side:** "Thin Read Layer" that queries directly and maps to ViewModels/DTOs
- Same database tables, but queries bypass domain model entirely

**From Microsoft's eShopOnContainers:**
> "This approach keeps the queries independent from restrictions and constraints coming from DDD patterns that only make sense for transactions and updates."

**When appropriate:**
- Need to optimize query patterns
- Domain model is complex but read patterns are simple
- Want cleaner separation without infrastructure complexity
- Starting point before considering further separation

**Trade-offs:**
- ✅ Simple infrastructure (one database)
- ✅ No synchronization/consistency concerns
- ✅ Easy to understand data flow
- ✅ Can optimize read queries independently (indexes, views)
- ❌ Both models share same database resources
- ❌ Can't scale reads/writes independently

### Level 2: Separate Data Stores

**Description:** Different databases for reads and writes. Write model publishes events to sync read model.

```
┌────────────────────────────────────────────────────────────┐
│                      Application                            │
│  ┌──────────────┐              ┌──────────────┐            │
│  │ Command Side │              │  Query Side  │            │
│  │              │   Events     │              │            │
│  └──────┬───────┘ ──────────►  └──────┬───────┘            │
│         │                              │                    │
│         ▼                              ▼                    │
│  ┌─────────────┐              ┌─────────────────┐          │
│  │Write Database│             │Read Database    │          │
│  │ (Normalized) │             │ (Denormalized)  │          │
│  └─────────────┘              └─────────────────┘          │
└────────────────────────────────────────────────────────────┘
```

**How synchronization works:**
1. Command processor modifies write database
2. Publishes domain event (e.g., `CustomerPreferredStatusChanged`)
3. Event handler updates read database asynchronously
4. Queries serve from optimized read database

**When appropriate:**
- Significant disparity between read/write loads
- Need different storage technologies (e.g., relational writes, document reads)
- Extreme scalability requirements
- Reports/analytics need isolation from transactional workload

**Trade-offs:**
- ✅ Independent scaling of read/write infrastructure
- ✅ Optimal storage technology per use case
- ✅ Read queries don't impact write performance
- ❌ Eventual consistency complexity
- ❌ Event handling infrastructure required
- ❌ Debugging across systems is harder
- ❌ More operational complexity

### Level 3: Event Sourcing

**Description:** Write model stores events as source of truth. Current state is derived from event replay. Read models are projections from event stream.

```
┌─────────────────────────────────────────────────────────────────┐
│                        Application                               │
│  ┌──────────────┐                    ┌──────────────┐           │
│  │ Command Side │                    │  Query Side  │           │
│  │              │      Events        │  (Projections)│          │
│  └──────┬───────┘  ───────────────►  └──────┬───────┘           │
│         │                                     │                  │
│         ▼                                     ▼                  │
│  ┌─────────────────┐              ┌───────────────────┐         │
│  │  Event Store    │              │ Read Model DB(s)  │         │
│  │ (Append-only)   │              │ (Materialized     │         │
│  │                 │              │  Projections)     │         │
│  └─────────────────┘              └───────────────────┘         │
└─────────────────────────────────────────────────────────────────┘
```

**Key characteristics:**
- Events are immutable facts ("CustomerMovedToAddress", "OrderPlaced")
- Current state = replay all events for an entity
- Read models are rebuilt by replaying events
- Full audit trail built-in

**When appropriate:**
- Audit requirements are paramount (finance, healthcare, legal)
- Need to answer "what was the state at time X?"
- Complex event-driven business processes
- Need to introduce new read models retroactively

**Trade-offs:**
- ✅ Complete audit trail
- ✅ Temporal queries (state at any point in time)
- ✅ Can rebuild read models from scratch
- ✅ Natural fit for event-driven architectures
- ❌ Significant mental model shift
- ❌ Event versioning complexity
- ❌ Snapshotting needed for performance with long event streams
- ❌ Hardest to implement correctly

## Microsoft's "Simplified CQRS" in Practice

Microsoft's official guidance explicitly recommends starting simple:

> "This guide uses the simplest CQRS approach, which consists of just separating the queries from the commands."

### Implementation Pattern

**Command Side (Domain Model):**
```csharp
public class Order
{
    public void MarkAsShipped()
    {
        if (Status != OrderStatus.Confirmed)
            throw new InvalidOperationException("Cannot ship unconfirmed order");
        
        Status = OrderStatus.Shipped;
        ShippedDate = DateTime.UtcNow;
        AddDomainEvent(new OrderShippedDomainEvent(this));
    }
}
```

**Query Side (Direct Database Access):**
```csharp
public class OrderQueries : IOrderQueries
{
    public async Task<OrderViewModel> GetOrderAsync(int id)
    {
        // Direct database query, bypassing domain model
        return await _context.Orders
            .Where(o => o.Id == id)
            .Select(o => new OrderViewModel
            {
                Id = o.Id,
                Status = o.Status.ToString(),
                Total = o.OrderItems.Sum(i => i.Price)
            })
            .FirstOrDefaultAsync();
    }
}
```

### Key Benefits of This Approach

1. **No ORM impedance mismatch for queries** — Query side can use raw SQL, Dapper, or optimized LINQ without going through domain objects

2. **Domain model stays focused** — No getters needed just for display, no query methods polluting repositories

3. **ViewModels match UI needs exactly** — Avoid over-fetching or N+1 queries

4. **Same transactional consistency** — Since both use same database, no eventual consistency handling needed

## Common CQRS Misconceptions (Clarified)

### Misconception 1: "CQRS requires separate databases"

**Reality:** CQRS is about code separation, not physical separation. Greg Young's original definition:

> "The fundamental difference is that in CQRS *objects* are split into two objects, one containing the Commands one containing the Queries."

Note: "objects" refers to handlers/code, not storage.

### Misconception 2: "CQRS requires Event Sourcing"

**Reality:** They are orthogonal patterns that work well together but are independent:
- CQRS without ES: Simplified CQRS with same DB, different models
- ES without CQRS: Event-sourced writes with same model for reads
- Both together: Full CQRS/ES as described in Level 3

### Misconception 3: "CQRS creates eventual consistency problems"

**Reality:** Only Level 2+ introduces eventual consistency. Level 1 (simplified CQRS) has the same consistency as traditional CRUD. Even with separate databases, the latency is often milliseconds—within tolerance for most business requirements.

### Misconception 4: "CQRS always needs message queues"

**Reality:** Message queues are optional infrastructure for Level 2+. Level 1 needs no messaging at all. Even at Level 2, you might use database change detection (MongoDB Change Streams, SQL Server CDC) instead of explicit message queues.

### Misconception 5: "CQRS should be applied system-wide"

**Reality:** Fowler emphasizes this is dangerous:

> "In particular CQRS should only be used on specific portions of a system (a BoundedContext in DDD lingo) and not the system as a whole. In this way of thinking, each Bounded Context needs its own decisions on how it should be modeled."

## When to Use Each Level

| Criteria | Level 0 (CRUD) | Level 1 (Simplified) | Level 2 (Separate DBs) | Level 3 (Event Sourcing) |
|----------|---------------|----------------------|------------------------|--------------------------|
| **Complexity** | Low | Low-Medium | High | Very High |
| **Read/Write ratio** | Balanced | Read-heavy | Very read-heavy | Any |
| **Scalability need** | Low | Medium | High | High |
| **Audit requirements** | None | None | None | Critical |
| **Team expertise** | Any | Basic DDD | Distributed systems | Event-driven + DDD |
| **Typical use case** | Simple CRUD apps | Business apps with complex domains | High-traffic public APIs | Financial, compliance systems |

## Decision Framework for TMS (Viya)

For a Transportation Management System:

**Arguments for Level 1 (Simplified CQRS):**
- Multiple users collaborating on shipments ✓
- Complex domain logic for rate calculation, routing ✓
- Read-heavy (dashboards, list views, reports) ✓
- Same database simplifies operations ✓
- MongoDB materialized views can serve as "read models" ✓

**Arguments against Level 2+:**
- No extreme scale requirements (not millions of concurrent users)
- Eventual consistency adds complexity for operations staff
- Team would need to learn new patterns
- Event versioning adds long-term maintenance burden

**Recommendation:** Start with Level 1 simplified CQRS. Use MongoDB materialized views as optimized read models. This provides 80% of the benefit with 20% of the complexity.

## Sources

| Source | Author/Org | Key Contribution |
|--------|------------|------------------|
| [CQRS](https://martinfowler.com/bliki/CQRS.html) | Martin Fowler | Pattern definition, strong cautions about overuse |
| [CQRS Pattern](https://learn.microsoft.com/en-us/azure/architecture/patterns/cqrs) | Microsoft | Comprehensive pattern documentation with diagrams |
| [CQRS Introduction](https://cqrs.wordpress.com/documents/cqrs-introduction/) | Greg Young | Original pattern creator's documentation |
| [Clarified CQRS](https://udidahan.com/2009/12/09/clarified-cqrs/) | Udi Dahan | Deep dive on collaboration/staleness as driving forces |
| [Simplified CQRS/DDD](https://learn.microsoft.com/en-us/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/apply-simplified-microservice-cqrs-ddd-patterns) | Microsoft | Practical .NET implementation guidance |
| [CQRS Pattern Guide](https://www.kurrent.io/cqrs-pattern) | Kurrent (EventStore) | Misconceptions clarified, CQS vs CQRS explained |
| [Event Sourcing and CQRS](https://www.kurrent.io/blog/event-sourcing-and-cqrs) | Kurrent | Relationship between ES and CQRS patterns |

## Questions for Further Research

- [ ] How do MongoDB materialized views fit into Level 1 simplified CQRS?
- [ ] What change stream patterns work best for keeping read models updated?
- [ ] How to handle "read-your-own-writes" in eventually consistent scenarios?
- [ ] What specific TMS use cases benefit from pre-computed read models?
