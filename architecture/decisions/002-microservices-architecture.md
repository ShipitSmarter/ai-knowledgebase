# ADR-002: Microservices Architecture

| Property | Value |
|----------|-------|
| **Status** | Accepted |
| **Date** | 2023-01 |
| **Decision Makers** | Engineering Team |
| **Technical Area** | Architecture |

## Context

Viya TMS is a multi-tenant Transportation Management System serving logistics companies. The system needs to:

1. **Scale independently** - Shipment volume varies by customer; some components (label generation) are CPU-heavy while others (webhooks) are I/O-heavy
2. **Deploy independently** - Different parts of the system have different release cadences
3. **Enable team autonomy** - Multiple developers working on different features simultaneously
4. **Support diverse integrations** - 50+ carrier integrations, print services, FTP, webhooks
5. **Maintain reliability** - Failure in one area shouldn't take down the entire system

The initial MVP was a modular monolith, but as complexity grew, the team needed clearer boundaries.

## Decision

We will adopt a **microservices architecture** with the following characteristics:

1. **Domain-driven boundaries** - Services align with business domains (shipping, rates, hooks)
2. **Database per service** - Each service owns its data exclusively
3. **API-first communication** - Services communicate via REST APIs and async events
4. **Clean Architecture internally** - Each service uses layered architecture (API → Domain → Infrastructure)
5. **Shared infrastructure** - Common deployment platform (Kubernetes), shared MongoDB cluster, shared event bus

## Options Considered

### Option 1: Modular Monolith

Single deployable with clear module boundaries.

**Pros:**
- Simpler deployment and operations
- In-process communication (fast)
- Easier transactions across modules
- Lower infrastructure cost

**Cons:**
- Scaling requires scaling everything
- Single point of failure
- Coupling tends to creep across modules
- Team coordination for releases

### Option 2: Microservices ✓

Independently deployable services with clear boundaries.

**Pros:**
- Independent scaling per service
- Isolated failures (shipping can work if hooks is down)
- Team autonomy and ownership
- Technology flexibility per service
- Independent deployments

**Cons:**
- Network latency and reliability concerns
- Distributed systems complexity
- Operational overhead (many services to monitor)
- Cross-service debugging is harder

### Option 3: Serverless (AWS Lambda)

Functions-as-a-Service for each operation.

**Pros:**
- Maximum scaling granularity
- Pay-per-invocation pricing
- No server management

**Cons:**
- Cold start latency problematic for shipping operations
- Vendor lock-in
- Complex local development
- Difficult to maintain long-running processes

## Consequences

### Positive

- **Independent deployment** - Can release shipping without touching rates
- **Fault isolation** - Webhook failures don't block label generation
- **Team ownership** - Clear service ownership and boundaries
- **Scalability** - Scale shipping service for peak seasons independently
- **Technology fit** - Each service can optimize for its specific needs

### Negative

- **Operational complexity** - 8+ services to deploy, monitor, debug
- **Network overhead** - Service-to-service calls add latency
- **Distributed transactions** - Can't rely on database transactions across services
- **Data consistency** - Eventual consistency between services
- **Local development** - Need to run multiple services for integration testing

### Risks

- **Service sprawl** - Too many small services increase overhead → Mitigation: Merge services if they're always deployed together
- **Distributed monolith** - Tight coupling via sync calls → Mitigation: Prefer events over API calls for non-critical paths
- **Data silos** - Hard to query across services → Mitigation: Auditor service aggregates data for reporting

## Implementation Notes

### Service Boundaries

| Service | Domain | Responsibility |
|---------|--------|----------------|
| **shipping** | Core | Shipments, orders, tracking, carriers |
| **stitch** | Integration | Carrier integrations, label generation |
| **authorizing** | Identity | Users, tokens, permissions |
| **rates** | Pricing | Contracts, surcharges, rate calculations |
| **hooks** | Integration | Webhooks, scheduled jobs |
| **printing** | Operations | Printer management, print jobs |
| **ftp** | Integration | SFTP server/client for file transfers |
| **auditor** | Observability | Audit logs, activity tracking |

### Internal Architecture (Clean Architecture)

Each service follows layered architecture:

```
┌─────────────────────────────────┐
│         API Layer               │ ← Controllers, DTOs, OpenAPI
├─────────────────────────────────┤
│       Domain Layer              │ ← Entities, Services, Interfaces
├─────────────────────────────────┤
│    Infrastructure Layer         │ ← MongoDB, AWS, External APIs
└─────────────────────────────────┘
```

- Domain layer has no external dependencies
- Interfaces defined in Domain, implemented in Infrastructure
- Dependency injection wires everything together

### Communication Patterns

| Pattern | Use Case |
|---------|----------|
| Sync REST | User-facing operations, data queries |
| Async Events | Notifications, audit logging, eventual updates |
| Direct DB | Never - services own their data |

See [ADR-003](./003-event-driven-integration.md) for event patterns.

### Database Isolation

Each service has exclusive access to its database. No direct database access across services.

If shipping needs user data from authorizing:
- ✅ Call authorizing API
- ✅ Cache user data locally
- ❌ Query authorizing database directly

## Related Decisions

- [ADR-001](./001-mongodb-document-database.md) - MongoDB per service
- [ADR-003](./003-event-driven-integration.md) - Event-driven integration

## References

- [Building Microservices (Sam Newman)](https://www.oreilly.com/library/view/building-microservices-2nd/9781492034018/)
- [Clean Architecture (Robert Martin)](https://www.oreilly.com/library/view/clean-architecture-a/9780134494272/)
