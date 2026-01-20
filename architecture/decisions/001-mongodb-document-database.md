# ADR-001: MongoDB as Document Database

| Property | Value |
|----------|-------|
| **Status** | Accepted |
| **Date** | 2023-01 |
| **Decision Makers** | Engineering Team |
| **Technical Area** | Data |

## Context

Viya TMS needed a primary database to store shipping operations data including shipments, orders, tracking events, carrier configurations, and customer data.

Key requirements:

1. **Schema flexibility** - Each carrier has different data structures for shipments, labels, and tracking. The system integrates with 50+ carriers, each with unique response formats.
2. **Nested/hierarchical data** - Shipments contain consignments which contain packages which contain items. This is naturally hierarchical.
3. **Read-heavy workload** - Most operations are reads (status checks, tracking lookups, reporting).
4. **Team expertise** - The team had prior MongoDB experience from other projects.
5. **Horizontal scaling** - Shipment volume grows with customers; need to scale data tier independently.

## Decision

We will use **MongoDB** as the primary database for all Viya TMS services.

Each microservice will have its own MongoDB database within a shared cluster, enforcing logical separation while sharing infrastructure.

## Options Considered

### Option 1: PostgreSQL (Relational)

Traditional relational database with strong ACID guarantees.

**Pros:**
- Strong consistency and ACID transactions
- Mature tooling and wide industry adoption
- Complex joins for reporting
- Team familiarity with SQL

**Cons:**
- Rigid schema requires migrations for carrier variations
- JSON columns exist but querying is awkward
- Normalization leads to many joins for hierarchical shipment data
- Scaling writes requires sharding complexity

### Option 2: MongoDB (Document Database) ✓

Document-oriented database storing data as flexible BSON documents.

**Pros:**
- Natural fit for hierarchical shipment data (embed consignments, packages)
- Schema flexibility handles carrier-specific fields without migrations
- Horizontal scaling via sharding is first-class
- Good aggregation pipeline for reporting
- Team expertise from prior projects

**Cons:**
- No cross-document transactions (initially; added in 4.0)
- References between collections require application-level joins
- Less mature tooling compared to PostgreSQL
- Memory-mapped storage requires RAM planning

### Option 3: DynamoDB

AWS-native serverless key-value and document database.

**Pros:**
- Fully managed, scales automatically
- Pay-per-request pricing option
- AWS-native integrations

**Cons:**
- Vendor lock-in to AWS
- Limited query flexibility (designed for known access patterns)
- No aggregation capabilities
- Complex data modeling for hierarchical data
- Higher cost at scale

## Consequences

### Positive

- **Rapid development** - No schema migrations when carriers add fields
- **Natural data model** - Shipment documents embed related data, reducing joins
- **Scalable** - MongoDB Atlas handles horizontal scaling transparently
- **Query flexibility** - Aggregation pipeline handles complex reporting needs
- **Operational simplicity** - MongoDB Atlas (managed) reduces DBA burden

### Negative

- **Denormalization** - Some data duplication (e.g., customer name embedded in shipments)
- **Reference management** - Cross-collection lookups require careful design
- **Transaction limitations** - Some operations can't be atomic across collections
- **Cost** - MongoDB Atlas is more expensive than self-managed PostgreSQL

### Risks

- **Schema drift** - Without enforcement, documents can become inconsistent → Mitigation: Application-level validation, schema versioning
- **Query performance** - Unindexed queries on large collections are slow → Mitigation: Index strategy, query review process
- **Atlas dependency** - Vendor lock-in to MongoDB Atlas → Mitigation: Standard MongoDB API, could self-host if needed

## Implementation Notes

### Database per Service

Each microservice owns its database:

| Service | Database | Key Collections |
|---------|----------|-----------------|
| shipping | shipping | shipments, orders, trackingEvents |
| authorizing | authorizing | users, tokens, permissions |
| auditor | auditor | auditLogs |
| rates | rates | contracts, surcharges |
| hooks | hooks | webhooks, subscribers |
| printing | printing | printers, printJobs |
| ftp | ftp | ftpClients, ftpServers |

### Embedding vs References

- **Embed** when data is always accessed together (consignments in shipments)
- **Reference** when data is shared or very large (carriers referenced by ID)

See [Data Model](../data-model.md) for detailed schema documentation.

## Related Decisions

- [ADR-002](./002-microservices-architecture.md) - Database-per-service isolation
- [ADR-003](./003-event-driven-integration.md) - Cross-service data synchronization

## References

- [MongoDB Data Model Design](https://www.mongodb.com/docs/manual/core/data-model-design/)
- [MongoDB Atlas](https://www.mongodb.com/atlas/database)
