---
topic: MongoDB to PostgreSQL Migration for Viya TMS
date: 2026-01-26
project: database-migration
sources_count: 6
status: draft
tags: [postgresql, mongodb, migration, self-hosted, kubernetes, infrastructure]
---

# MongoDB to PostgreSQL Migration for Viya TMS

## Summary

This document outlines the steps, considerations, and risks for migrating Viya TMS from MongoDB Atlas to self-hosted PostgreSQL. The migration is motivated by cost control (MongoDB Atlas ~$800/month for production) and vendor independence.

**Key Finding**: This is a significant undertaking due to:
1. **Schema transformation** - Document model → relational model requires careful redesign
2. **Embedded documents** - Addresses, TimeWindows, Rate data need normalization or JSONB hybrid
3. **Polymorphic references** - `carrier_tracking_events.MatchingEntities` needs redesign
4. **7 databases** - shipping, authorizing, rates, auditor, hooks, printing, ftp all need migration
5. **Application code changes** - Every service needs driver and query rewrites

**Recommendation**: Use a **hybrid approach** with PostgreSQL's native `JSONB` type for flexibility while normalizing core entities. Migrate incrementally by service, starting with low-risk services (auditor, printing).

---

## Key Findings

1. **PostgreSQL JSONB is mature** - Supports indexing (GIN), containment queries, jsonpath, making it viable for document-like workloads
2. **CloudNativePG is production-ready** - CNCF sandbox project (7.9k stars), native Kubernetes operator for HA PostgreSQL
3. **Patroni is the HA standard** - Template for HA PostgreSQL using distributed consensus (etcd/Consul/Kubernetes)
4. **Schema transformation is the hard part** - Not the infrastructure, but data model and application code changes
5. **Dual-write migration pattern** - Safest approach for zero-downtime migration
6. **Estimate 3-6 months** - For a phased migration of all 7 databases with proper testing

---

## Current MongoDB Architecture

### Databases & Collections

| Database | Service | Key Collections | Complexity |
|----------|---------|-----------------|------------|
| `shipping` | shipping | shipments, consignments, handling_units, carrier_tracking_events | **High** - Core domain, complex relationships |
| `authorizing` | authorizing | users, tokens, permission_groups, data_groups | Medium - Standard auth patterns |
| `rates` | rates | contracts, surcharges, zones, rate_cards | **High** - Nested pricing rules |
| `auditor` | auditor | audit_logs | Low - Append-only logs |
| `hooks` | hooks | webhooks, scheduled_jobs | Low - Simple CRUD |
| `printing` | printing | printers, print_jobs | Low - Simple CRUD |
| `ftp` | ftp | ftp_clients, ftp_servers | Low - Simple CRUD |

### Document Patterns in Current System

**1. Embedded Documents** (need normalization or JSONB)
```javascript
// MongoDB: Addresses embedded in shipments
{
  _id: "uuid",
  Data: {
    Addresses: {
      Sender: { CompanyName, Street, City, PostCode, CountryCode },
      Receiver: { ... },
      Collection: { ... }
    },
    TimeWindows: {
      Pickup: { Planned: { Start, End }, Requested: { Start, End } },
      Delivery: { ... }
    },
    Rate: {
      Price: { TotalRequestedCurrency: { Value, CurrencyCode } },
      Weights: { BillableWeight, PhysicalWeight }
    }
  }
}
```

**2. Polymorphic References** (need type column or separate tables)
```javascript
// MongoDB: MatchingEntities can reference Shipment OR Consignment
{
  MatchingEntities: [
    { LogisticsUnitType: "Shipment", _id: "uuid-1" },
    { LogisticsUnitType: "Consignment", _id: "uuid-2" }
  ]
}
```

**3. Array of References** (need junction table or array column)
```javascript
// MongoDB: HandlingUnitReferences as UUID array
{
  HandlingUnitReferences: ["uuid-1", "uuid-2", "uuid-3"]
}
```

---

## Schema Transformation Strategy

### Option A: Full Normalization (Traditional Relational)

**Approach**: Decompose all documents into normalized tables.

```sql
-- Example: Shipment address normalization
CREATE TABLE addresses (
  id UUID PRIMARY KEY,
  company_name VARCHAR(255),
  contact_name VARCHAR(255),
  street VARCHAR(255),
  city VARCHAR(100),
  post_code VARCHAR(20),
  country_code CHAR(2)
);

CREATE TABLE shipments (
  id UUID PRIMARY KEY,
  tenant_id VARCHAR(100) NOT NULL,
  created_on TIMESTAMPTZ NOT NULL,
  status VARCHAR(50) NOT NULL,
  reference VARCHAR(100),
  carrier_reference VARCHAR(50),
  sender_address_id UUID REFERENCES addresses(id),
  receiver_address_id UUID REFERENCES addresses(id),
  collection_address_id UUID REFERENCES addresses(id)
);
```

**Pros**:
- Strong data integrity
- Efficient updates (no data duplication)
- Standard SQL tooling

**Cons**:
- Many JOINs for common queries
- Significant schema change
- Requires extensive application code changes
- Loses flexibility for carrier-specific fields

### Option B: Hybrid JSONB (Recommended)

**Approach**: Normalize core identifiers and relationships; keep flexible/nested data as JSONB.

```sql
-- Example: Hybrid approach
CREATE TABLE shipments (
  id UUID PRIMARY KEY,
  tenant_id VARCHAR(100) NOT NULL,
  created_on TIMESTAMPTZ DEFAULT NOW(),
  
  -- Normalized for indexing and foreign keys
  status VARCHAR(50) NOT NULL,
  reference VARCHAR(100),
  carrier_reference VARCHAR(50),
  service_level_reference VARCHAR(50),
  inbound BOOLEAN DEFAULT FALSE,
  
  -- JSONB for nested/flexible data
  addresses JSONB NOT NULL,  -- Sender, Receiver, Collection
  time_windows JSONB,        -- Pickup/Delivery planned/requested
  rate JSONB,                -- Price, Weights
  
  -- Indexes
  CONSTRAINT shipments_tenant_idx UNIQUE (tenant_id, id)
);

-- GIN index for JSONB queries
CREATE INDEX shipments_addresses_gin ON shipments USING GIN (addresses jsonb_path_ops);

-- Partial index for common status queries
CREATE INDEX shipments_status_idx ON shipments (tenant_id, status, created_on DESC) 
  WHERE status IN ('Created', 'Ordered', 'Accepted');
```

**Pros**:
- Preserves document flexibility
- Smaller schema migration
- Easier application code changes
- Can query JSONB with indexes
- Progressive normalization possible later

**Cons**:
- Less strict data integrity for JSONB fields
- Need to manage JSONB schema at application level
- Some operations less efficient than normalized

### Handling Specific Patterns

**Polymorphic References → Type Column**
```sql
CREATE TABLE carrier_tracking_events (
  id UUID PRIMARY KEY,
  created_on TIMESTAMPTZ NOT NULL,
  event_data JSONB NOT NULL,
  mappings JSONB
);

CREATE TABLE tracking_event_entities (
  event_id UUID REFERENCES carrier_tracking_events(id) ON DELETE CASCADE,
  entity_type VARCHAR(20) NOT NULL,  -- 'Shipment' or 'Consignment'
  entity_id UUID NOT NULL,
  PRIMARY KEY (event_id, entity_type, entity_id)
);

-- Index for lookups
CREATE INDEX tracking_by_entity ON tracking_event_entities (entity_id, entity_type);
```

**Array References → Array Column or Junction Table**
```sql
-- Option 1: PostgreSQL native array
CREATE TABLE shipments (
  ...
  handling_unit_ids UUID[] NOT NULL DEFAULT '{}'
);
CREATE INDEX shipments_hu_idx ON shipments USING GIN (handling_unit_ids);

-- Option 2: Junction table (more normalized)
CREATE TABLE shipment_handling_units (
  shipment_id UUID REFERENCES shipments(id) ON DELETE CASCADE,
  handling_unit_id UUID REFERENCES handling_units(id) ON DELETE CASCADE,
  position INT NOT NULL,  -- Preserve order
  PRIMARY KEY (shipment_id, handling_unit_id)
);
```

---

## Self-Hosted PostgreSQL Infrastructure

### Option 1: CloudNativePG (Recommended for Kubernetes)

**CloudNativePG** is a CNCF Sandbox project designed for PostgreSQL on Kubernetes.

**Features**:
- Native Kubernetes operator (no external HA tools)
- Automatic failover with quorum-based consistency
- Rolling updates and in-place upgrades
- Backup to S3/object storage
- Prometheus metrics built-in
- Supports PostgreSQL 12-17

**Architecture**:
```yaml
# Example CloudNativePG cluster
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: shipping-pg
  namespace: viya-app
spec:
  instances: 3
  postgresql:
    parameters:
      max_connections: "200"
      shared_buffers: "256MB"
  
  storage:
    size: 50Gi
    storageClass: gp3
  
  backup:
    barmanObjectStore:
      destinationPath: s3://viya-backups/shipping
      s3Credentials:
        accessKeyId:
          name: s3-creds
          key: ACCESS_KEY_ID
        secretAccessKey:
          name: s3-creds
          key: SECRET_ACCESS_KEY
      wal:
        compression: gzip
  
  monitoring:
    enablePodMonitor: true
```

**Cost Estimate** (comparable to current MongoDB Atlas):
- 3x m5.large EKS nodes: ~$200/month
- 200GB gp3 EBS: ~$20/month
- S3 backups: ~$5/month
- **Total: ~$225/month** (vs $800/month MongoDB Atlas)

### Option 2: Patroni (Traditional HA)

**Patroni** is a template for HA PostgreSQL using distributed consensus.

**When to use**:
- Non-Kubernetes deployments
- Need maximum control over HA behavior
- Existing etcd/Consul infrastructure

**Architecture**:
```
┌─────────────────────────────────────────────────────────────┐
│                      HAProxy / pgbouncer                     │
│                     (Connection pooling)                     │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐     ┌───────────────┐     ┌───────────────┐
│  PostgreSQL   │     │  PostgreSQL   │     │  PostgreSQL   │
│   Primary     │────▶│   Replica     │────▶│   Replica     │
│  + Patroni    │     │  + Patroni    │     │  + Patroni    │
└───────────────┘     └───────────────┘     └───────────────┘
        │                     │                     │
        └─────────────────────┼─────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │  etcd / Consul  │
                    │   (DCS for HA)  │
                    └─────────────────┘
```

### Option 3: Managed PostgreSQL (Simpler but Less Control)

If full self-hosting is too complex, consider:
- **AWS RDS PostgreSQL**: Managed, Multi-AZ, ~$400/month for production
- **DigitalOcean Managed PostgreSQL**: ~$150/month
- **Supabase/Neon**: PostgreSQL-as-a-service

---

## Migration Roadmap

### Phase 0: Preparation (2-4 weeks)

- [ ] Design PostgreSQL schema for all databases
- [ ] Set up CloudNativePG in dev environment
- [ ] Create data migration scripts (MongoDB → PostgreSQL)
- [ ] Update application code to support both databases (feature flag)
- [ ] Set up monitoring and alerting for PostgreSQL

### Phase 1: Low-Risk Services (4-6 weeks)

**Migrate first**: auditor, printing, ftp

**Why**: 
- Simple schemas (mostly CRUD)
- Low traffic
- Easy rollback if issues

**Pattern**: Dual-write migration
```
1. Deploy PostgreSQL cluster
2. Update service to write to both MongoDB AND PostgreSQL
3. Run migration script for historical data
4. Validate data consistency
5. Switch reads to PostgreSQL
6. Stop MongoDB writes
7. Decommission MongoDB database
```

### Phase 2: Medium-Risk Services (6-8 weeks)

**Migrate next**: authorizing, hooks

**Challenges**:
- authorizing: Permission checks are latency-sensitive
- hooks: Webhook reliability is business-critical

**Extra steps**:
- Performance benchmarking before cutover
- Load testing with production-like traffic
- Detailed runbook for rollback

### Phase 3: High-Risk Services (8-12 weeks)

**Migrate last**: shipping, rates

**Challenges**:
- shipping: Core domain, highest traffic, complex queries
- rates: Complex nested pricing rules, calculation logic

**Strategy**:
- Feature flag for gradual rollout (10% → 50% → 100%)
- Real-time data comparison between MongoDB and PostgreSQL
- Extended parallel running period
- Off-hours cutover with rollback plan

### Phase 4: Decommission MongoDB Atlas (2-4 weeks)

- [ ] Verify all services running on PostgreSQL
- [ ] Final backup of MongoDB data
- [ ] Cancel MongoDB Atlas subscription
- [ ] Document lessons learned

---

## Application Code Changes

### Driver Changes

**Before (MongoDB - C#)**:
```csharp
// MongoDB.Driver
var collection = _database.GetCollection<Shipment>("shipments");
var filter = Builders<Shipment>.Filter.And(
    Builders<Shipment>.Filter.Eq(x => x.TenantId, tenantId),
    Builders<Shipment>.Filter.Eq("Data.Status", "Created")
);
var shipments = await collection.Find(filter).ToListAsync();
```

**After (PostgreSQL - C# with Dapper or EF Core)**:
```csharp
// Dapper
var shipments = await _connection.QueryAsync<Shipment>(
    @"SELECT * FROM shipments 
      WHERE tenant_id = @TenantId AND status = @Status",
    new { TenantId = tenantId, Status = "Created" }
);

// Or EF Core
var shipments = await _context.Shipments
    .Where(s => s.TenantId == tenantId && s.Status == "Created")
    .ToListAsync();
```

### JSONB Query Changes

**Before (MongoDB aggregation)**:
```javascript
db.shipments.aggregate([
  { $match: { TenantId: tenantId } },
  { $match: { "Data.Addresses.Sender.CountryCode": "NL" } }
])
```

**After (PostgreSQL JSONB)**:
```sql
SELECT * FROM shipments
WHERE tenant_id = $1
  AND addresses->'Sender'->>'CountryCode' = 'NL';

-- Or with jsonpath
SELECT * FROM shipments
WHERE tenant_id = $1
  AND addresses @@ '$.Sender.CountryCode == "NL"';
```

### Repository Pattern Changes

Recommend using **Repository pattern** with interface to abstract database:

```csharp
public interface IShipmentRepository
{
    Task<Shipment?> GetByIdAsync(string tenantId, Guid id);
    Task<IEnumerable<Shipment>> GetByStatusAsync(string tenantId, string status);
    Task InsertAsync(Shipment shipment);
    Task UpdateAsync(Shipment shipment);
}

// Implement MongoShipmentRepository and PostgresShipmentRepository
// Use feature flag to switch between them
```

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Data loss during migration | Low | Critical | Dual-write, continuous backup, validation scripts |
| Performance degradation | Medium | High | Benchmarking, proper indexing, connection pooling |
| Application bugs post-migration | Medium | High | Extensive testing, feature flags, phased rollout |
| Extended dual-running costs | Medium | Medium | Strict timeline, automated migration validation |
| Team knowledge gap (PostgreSQL) | Medium | Medium | Training, documentation, pair programming |
| Downtime during cutover | Low | High | Zero-downtime migration pattern, off-hours cutover |

---

## Cost-Benefit Analysis

### Current Costs (MongoDB Atlas)
- Production M30: ~$800/month
- Staging M20: ~$300/month
- Dev M10: ~$100/month
- **Total: ~$1,200/month**

### Projected Costs (Self-Hosted PostgreSQL on EKS)
- 3x m5.large nodes (HA cluster): ~$200/month
- EBS storage (200GB gp3): ~$20/month
- S3 backups: ~$5/month
- **Total: ~$225/month** (per environment)

### Savings
- **Monthly savings**: ~$650/month (production only)
- **Annual savings**: ~$7,800/year (production only)
- **Migration investment**: 3-6 months engineering time

### Break-Even
Assuming 1 engineer at half-time for 6 months:
- Migration cost: ~$50,000 (salary + opportunity cost)
- Break-even: ~6.5 years

**Conclusion**: Cost savings alone do NOT justify migration. Consider if:
- Vendor independence is strategically important
- Team prefers PostgreSQL expertise
- Long-term platform evolution benefits from PostgreSQL (e.g., PostGIS, full-text search)

---

## Decision Checklist

Before starting migration, confirm:

- [ ] Strategic reason beyond cost (vendor independence, features, expertise)
- [ ] Team has PostgreSQL expertise or training plan
- [ ] All 7 services can be migrated incrementally
- [ ] Rollback plan for each phase
- [ ] Monitoring and alerting ready for PostgreSQL
- [ ] Performance benchmarks established
- [ ] Data validation scripts ready
- [ ] Executive buy-in for 3-6 month timeline

---

## Sources

| # | Source | Contribution |
|---|--------|--------------|
| 1 | [PostgreSQL JSON Types Documentation](https://www.postgresql.org/docs/current/datatype-json.html) | JSONB capabilities, indexing, jsonpath |
| 2 | [Patroni Documentation](https://patroni.readthedocs.io/) | HA PostgreSQL template, DCS options |
| 3 | [CloudNativePG GitHub](https://github.com/cloudnative-pg/cloudnative-pg) | Kubernetes-native PostgreSQL operator |
| 4 | [Viya MongoDB Data Model](../viya-data-model/2026-01-26-mongodb-data-model.md) | Current schema and relationships |
| 5 | [ADR-001: MongoDB Decision](../../architecture/decisions/001-mongodb-document-database.md) | Original database selection rationale |
| 6 | [Infrastructure Overview](../../architecture/infrastructure.md) | Current MongoDB Atlas configuration |

---

## Open Questions

- [ ] Which ORM/data access pattern to use in C# services? (Dapper vs EF Core)
- [ ] Should rates/pricing rules use full normalization or JSONB?
- [ ] How to handle multi-tenant schema? (Shared tables vs schema-per-tenant)
- [ ] What's the connection pooling strategy? (PgBouncer built-in to CloudNativePG?)
- [ ] How to handle materialized views (mv_*) in PostgreSQL? (Native MVs vs custom refresh)
