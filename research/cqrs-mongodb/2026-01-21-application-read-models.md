---
topic: Application-Embedded Read Models (Non-Reporting)
date: 2026-01-21
project: cqrs-mongodb
sources_count: 9
status: reviewed
tags: [cqrs, mongodb, read-models, projections, pagination, materialized-views, denormalization]
---

# Application-Embedded Read Models (Non-Reporting)

## Summary

Application-embedded read models are pre-computed data structures optimized for specific UI queries, distinct from ad-hoc reporting. In CQRS architectures, these read models serve list views, dropdowns, dashboards, and entity details without the overhead of complex aggregations at query time. The key insight is that read models should be designed per specific query need, not per database table—a single business entity may have multiple read models for different use cases.

MongoDB's materialized views (via `$merge`/`$out`) enable efficient pre-computation of denormalized data structures. Unlike standard views that compute on every read, materialized views persist results to disk, enabling direct indexing and fast retrieval. For application UI queries, this means list views can be served from purpose-built collections with composite indexes matching common filter combinations.

The decision between source collection queries and read models depends on query complexity and frequency. Single entity lookups by ID should query source collections directly—the overhead of maintaining a separate read model isn't justified. However, list views with filtering, sorting, and pagination benefit significantly from purpose-built read models with denormalized data and targeted indexes.

## Key Findings

1. **Design read models per query, not per entity** - A `ShipmentListView` collection optimized for list views (denormalized, indexed for common filters) differs from `ShipmentDetails` for single-entity retrieval. Don't force one read model to serve all purposes.

2. **Cursor-based pagination outperforms offset pagination** - For large datasets, cursor pagination using indexed fields (like `_id` or timestamps) can be 4x faster than offset-based pagination. Offset pagination requires scanning to the offset position; cursor pagination jumps directly to the cursor value.

3. **Denormalize judiciously for frequently-joined data** - The Extended Reference Pattern embeds only frequently-accessed fields from related entities (e.g., customer name and shipping address on orders), avoiding JOINs while minimizing duplication. Update strategies must handle data changes.

4. **Three approaches to nested object projections exist** - Fat events (full data), lean events with lookup at projection time, or normalized storage with query-time joins. Each has trade-offs between write complexity, processing speed, and query performance.

5. **Single entity lookups should bypass read models** - For `GET /shipments/{id}`, query the source collection directly. Read models add complexity without benefit for point lookups that are already efficient with index on `_id`.

6. **Compound indexes must match query patterns** - A read model collection with index `{status: 1, customerId: 1, createdAt: -1}` efficiently serves queries filtering by status+customer sorted by date, but not queries filtering by carrier first.

## Detailed Analysis

### Query Patterns That Benefit from Read Models

Not all queries warrant pre-computed read models. The decision framework:

| Query Type | Benefit from Read Model | Rationale |
|------------|------------------------|-----------|
| List views with filtering | **High** | Multiple filters, sorting, pagination across denormalized data |
| Autocomplete/dropdowns | **Medium-High** | Frequently accessed, small result sets, benefit from pre-filtered collections |
| Dashboard widgets | **High** | Aggregated metrics computed once, read many times |
| Search results | **High** | Full-text and faceted search with complex ranking |
| Single entity lookup | **Low** | Direct `_id` lookup is already optimal |
| Real-time critical ops | **Low** | Cannot tolerate eventual consistency |
| Rarely accessed data | **Low** | Maintenance cost exceeds query savings |

### List View Read Model Design

For list views like "All shipments for organization X", design a dedicated collection:

```javascript
// shipmentsListView collection
{
  _id: ObjectId,
  organizationId: ObjectId,        // Partition key for multi-tenant
  shipmentNumber: "SHP-2026-001",
  status: "InTransit",
  createdAt: ISODate,
  
  // Denormalized for display without joins
  customerName: "Acme Corp",
  carrierName: "FedEx",
  origin: { city: "Amsterdam", country: "NL" },
  destination: { city: "London", country: "UK" },
  
  // Computed/aggregated fields
  totalPackages: 5,
  totalWeight: 125.5,
  
  // For cursor pagination
  sortKey: "2026-01-21T10:30:00Z_SHP-2026-001"
}
```

**Index strategy for common filters:**

```javascript
// Primary list query: org + status + date
{ organizationId: 1, status: 1, createdAt: -1 }

// Search by shipment number
{ organizationId: 1, shipmentNumber: 1 }

// Filter by carrier
{ organizationId: 1, carrierName: 1, createdAt: -1 }

// Cursor pagination support
{ organizationId: 1, sortKey: 1 }
```

### Pagination Strategies

#### Offset Pagination (Traditional)
```javascript
// Page 1000, 10 items per page
db.shipmentsListView
  .find({ organizationId: orgId })
  .sort({ createdAt: -1 })
  .skip(9990)
  .limit(10)
```

**Problem:** MongoDB must scan 9,990 documents before returning 10. Performance degrades linearly with offset size.

#### Cursor Pagination (Recommended)
```javascript
// After cursor "2026-01-20T15:00:00Z_SHP-2025-999"
db.shipmentsListView
  .find({ 
    organizationId: orgId,
    sortKey: { $lt: "2026-01-20T15:00:00Z_SHP-2025-999" }
  })
  .sort({ sortKey: -1 })
  .limit(10)
```

**Advantage:** Uses index to jump directly to cursor position. Performance is constant regardless of "page depth."

**Cursor composition pattern:**
- Combine sort field with unique field: `${isoDate}_${uniqueId}`
- Enables deterministic ordering even when primary sort field has duplicates
- Client receives opaque cursor, decodes on server

### Dropdown/Autocomplete Read Models

For lookups like "select carrier" or "customer autocomplete":

```javascript
// carriersLookup collection - lightweight for fast loading
{
  _id: ObjectId,
  organizationId: ObjectId,
  carrierId: ObjectId,           // Reference to full carrier
  name: "FedEx International",
  code: "FEDEX",
  isActive: true,
  searchTerms: ["fedex", "federal express"]  // For autocomplete
}

// Index for autocomplete
{ organizationId: 1, isActive: 1, name: 1 }

// Text index for search
{ searchTerms: "text" }
```

**Design principles for lookups:**
- Include only display fields + identifiers
- Pre-filter inactive/archived items (or include flag for filtering)
- Consider text indexes for autocomplete scenarios
- Keep documents small for fast full-collection scans on small datasets

### Dashboard Widget Read Models

Dashboard metrics often combine data from multiple sources:

```javascript
// operationsDashboard - one document per org per time period
{
  _id: ObjectId,
  organizationId: ObjectId,
  date: ISODate("2026-01-21"),
  period: "day",
  
  metrics: {
    shipmentsCreated: 45,
    shipmentsDelivered: 38,
    shipmentsInTransit: 127,
    exceptionsRaised: 3,
    avgDeliveryTime: 2.3  // days
  },
  
  topCarriers: [
    { carrierId: ObjectId, name: "FedEx", shipmentCount: 23 },
    { carrierId: ObjectId, name: "DHL", shipmentCount: 15 }
  ],
  
  updatedAt: ISODate
}
```

**Refresh strategy:** Event-driven updates for near-real-time widgets, or scheduled aggregation for historical metrics.

### When to Query Source Collections Directly

**Single entity retrieval:**
```javascript
// Direct lookup - read model unnecessary
db.shipments.findOne({ _id: shipmentId })
```

**Real-time critical operations:**
- Payment processing - cannot show stale data
- Inventory checks before booking
- User authentication/authorization

**Ad-hoc queries from admin tools:**
- One-off investigations don't warrant read model creation
- Use source collections with appropriate indexes

### Entity Lookup Patterns in CQRS

For retrieving full entity details, three patterns exist:

#### 1. Read-Through Caching
Query source collection, cache result:
```
GET /shipments/{id}
→ Check cache
→ If miss: Query shipments collection, cache result
→ Return
```
Invalidate cache on write events.

#### 2. Denormalized Detail View
Maintain separate `shipmentDetails` collection with all display data:
```javascript
{
  _id: shipmentId,
  // Full shipment data
  shipmentNumber: "...",
  status: "...",
  // Embedded related data
  customer: { id: ObjectId, name: "...", phone: "..." },
  carrier: { id: ObjectId, name: "...", trackingUrl: "..." },
  events: [
    { timestamp: ISODate, type: "Created", actor: "..." },
    { timestamp: ISODate, type: "PickedUp", actor: "..." }
  ]
}
```
Updated via projections on domain events.

#### 3. Hybrid: Light Read Model + Source Lookup
Read model for list display, source collection for details:
```
List view → shipmentsListView (read model)
Detail view → shipments (source) + lazy-load related data
```

**Recommendation:** Start with hybrid approach. Add denormalized detail views only when join overhead becomes problematic.

### Projection Design for Nested Objects

When events contain nested or related data, projection handlers must decide how to store it.

**Option A: Fat Events (denormalized in event)**
```csharp
// Event contains full nested data
record ShipmentCreated(
    Guid ShipmentId,
    CustomerInfo Customer,  // Name, address embedded
    CarrierInfo Carrier     // Name, code embedded
);

// Projection simply copies
void Handle(ShipmentCreated e, ShipmentListView view) {
    view.CustomerName = e.Customer.Name;
    view.CarrierName = e.Carrier.Name;
}
```
*Pros:* Fast projection, no lookups. *Cons:* Data duplication in events, harder to update if source changes.

**Option B: Lean Events + Lookup at Projection Time**
```csharp
// Event contains only IDs
record ShipmentCreated(
    Guid ShipmentId,
    Guid CustomerId,
    Guid CarrierId
);

// Projection fetches related data
void Handle(ShipmentCreated e, ShipmentListView view) {
    var customer = _db.Customers.Find(e.CustomerId);
    var carrier = _db.Carriers.Find(e.CarrierId);
    view.CustomerName = customer.Name;
    view.CarrierName = carrier.Name;
}
```
*Pros:* Smaller events, single source of truth. *Cons:* Slower projection, dependency on other collections.

**Option C: Normalized Storage + Query-Time Joins**
```csharp
// Store only IDs in read model
void Handle(ShipmentCreated e, ShipmentListView view) {
    view.CustomerId = e.CustomerId;
    view.CarrierId = e.CarrierId;
}

// Query uses lookup/join
db.shipmentsListView.aggregate([
  { $match: { organizationId: orgId } },
  { $lookup: { from: "customers", localField: "customerId", ... } }
])
```
*Pros:* No duplication, always fresh. *Cons:* Query complexity, performance impact.

**Recommendation for TMS:** Use Option B (lean events + lookup) for most cases. The lookup cost during projection is acceptable, and it keeps events clean. Reserve Option A for high-volume scenarios where projection performance is critical.

### Handling Data Changes in Denormalized Views

When source data changes (e.g., customer renames), denormalized read models need updates:

**Strategy 1: Event-driven cascade**
```csharp
// When customer name changes
void Handle(CustomerRenamed e) {
    // Update all shipments referencing this customer
    _db.ShipmentsListView.UpdateMany(
        { customerId: e.CustomerId },
        { $set: { customerName: e.NewName } }
    );
}
```

**Strategy 2: Accept staleness for display fields**
- Customer name on historical shipments may not need updating
- Document the staleness tolerance in system design

**Strategy 3: Background reconciliation**
- Periodic job compares read models with source
- Fixes discrepancies, handles missed events

## Sources

| Source | Type | Key Contribution |
|--------|------|------------------|
| [Microsoft CQRS Pattern](https://learn.microsoft.com/azure/architecture/patterns/cqrs) | Official docs | Read model design principles, separate optimization for reads/writes |
| [MongoDB On-Demand Materialized Views](https://www.mongodb.com/docs/manual/core/materialized-views/) | Official docs | `$merge`/`$out` for persisting aggregation results |
| [MongoDB cursor.skip()](https://www.mongodb.com/docs/manual/reference/method/cursor.skip/) | Official docs | Offset pagination behavior, cursor pagination alternative |
| [Cursor Paging with EF Core](https://khalidabuhakmeh.com/cursor-paging-with-entity-framework-core-and-aspnet-core) | Blog | 4x performance improvement with cursor vs offset pagination |
| [Oskar Dudycz - Event Projections](https://event-driven.io/en/how_to_do_events_projections_with_entity_framework/) | Blog | Projection patterns, fluent API design, event handler composition |
| [Oskar Dudycz - Nested Object Projections](https://event-driven.io/en/how_to_create_projections_of_events_for_nested_object_structures/) | Blog | Three approaches to nested data: fat events, lean+lookup, normalized |
| [MongoDB Extended Reference Pattern](https://www.mongodb.com/blog/post/building-with-patterns-the-extended-reference-pattern) | Vendor blog | Denormalize frequently-accessed fields to avoid JOINs |
| [Kurrent CQRS Guide](https://www.kurrent.io/cqrs-pattern) | Vendor docs | CQRS fundamentals, read/write model separation |
| [MongoDB Indexes](https://www.mongodb.com/docs/manual/indexes/) | Official docs | Compound index design, query optimization |

## Questions for Further Research

- [ ] How to handle full-text search across read models? Atlas Search integration patterns?
- [ ] What's the optimal refresh frequency for dashboard metrics - event-driven vs scheduled?
- [ ] How do change streams interact with Atlas Search indexes for real-time search updates?
- [ ] Patterns for A/B testing different read model schemas without full migration?
- [ ] How to monitor and alert on read model staleness/drift from source?
