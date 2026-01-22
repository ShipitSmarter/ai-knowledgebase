---
topic: MV Design Patterns for Common Application Queries
date: 2026-01-21
project: cqrs-mongodb
sources_count: 8
status: draft
tags: [mongodb, materialized-views, cqrs, schema-design, application-patterns, tms]
---

# MV Design Patterns for Common Application Queries

## Summary

This document provides practical MongoDB materialized view (MV) design patterns for application-embedded queries in TMS systems. While [reporting MVs](../viya-reporting/2026-01-21-materialized-view-strategy.md) focus on dimensional aggregation for analytics, **application MVs** serve operational UI: list views with filtering, autocomplete dropdowns, dashboard widgets, and hierarchical entity navigation.

The key distinction: reporting MVs aggregate across time periods for trend analysis; application MVs denormalize related data for fast UI rendering. Both use MongoDB's `$merge` stage but with different schema strategies.

**Core patterns identified:**
1. **Flat List View MV** - Denormalized documents for filterable, sortable list screens
2. **Lookup MV** - Minimal schemas for autocomplete/dropdown population
3. **Dashboard Counter MV** - Pre-aggregated counts for widget display
4. **Hierarchical Projection MV** - Parent context embedded in child records

## Key Findings

1. **Flat denormalization beats JOINs for list views** - MongoDB's Extended Reference Pattern recommends duplicating frequently-accessed related data into the main document. For a shipment list view, embed customer name, carrier label, and status directly rather than using `$lookup` at query time.

2. **Compound indexes follow ESR guideline** - For filterable list MVs, order index fields by: Equality (exact match filters like `status`), Sort (the primary sort field like `createdAt`), Range (date ranges, numeric ranges). This maximizes index efficiency.

3. **Lookup MVs should be tiny** - Autocomplete collections need only `{ _id, label, searchTerms }`. The Computed Pattern suggests pre-computing search-optimized text (lowercase, normalized) during MV refresh rather than at query time.

4. **Counters use single-document pattern for real-time widgets** - The exploration plan's `mv_realtime_ops` pattern (single document with nested counts) is the right approach for dashboard widgets needing <1s refresh.

5. **Bucket Pattern enables time-aggregated counts** - For "shipments per hour" type widgets, bucket by time period rather than per-record aggregation at query time.

6. **Hierarchical data benefits from bidirectional embedding** - Embed parent summary in child MV (consignment knows its shipment's status) AND embed child summary in parent MV (shipment knows consignment count/status breakdown).

7. **Multi-tenant filtering belongs in MV `_id`** - For SaaS applications, include `organizationId` in the composite `_id` to enable efficient per-tenant queries and data isolation.

8. **Atlas Search indexes complement MVs for text search** - For autocomplete with fuzzy matching, combine a Lookup MV with Atlas Search indexing rather than building complex regex patterns.

---

## Pattern 1: Flat List View MV

### Use Case

Shipment list screen with filters for status, carrier, date range, and customer. Users expect:
- Instant filtering on any combination
- Sort by date, reference, status
- Pagination (50-100 items per page)

### Problem with Source Data

Shipments collection has nested structure requiring multiple field accesses. Carrier labels, customer names, and address details are embedded deeply or referenced from other collections.

```javascript
// Source shipment - deep nesting, requires $lookup for customer name
{
  _id: "shipment-uuid",
  Data: {
    Reference: "SHP-001",
    Status: "Confirmed",
    CarrierReference: "DHLPX",
    CarrierLabel: "DHL Parcel",
    Addresses: {
      Sender: { Company: "Acme Corp", CountryCode: "NL", City: "Amsterdam" },
      Receiver: { Company: "Beta Inc", CountryCode: "DE", City: "Berlin" }
    },
    TimeWindows: { Delivery: { Requested: { End: ISODate(...) } } }
  },
  CreatedOn: ISODate("2026-01-21T10:00:00Z"),
  OrganizationId: "org-123"
}
```

### MV Schema: `mv_shipment_list`

Flatten all filterable/displayable fields to top level:

```javascript
{
  _id: {
    organizationId: "org-123",    // Multi-tenant isolation
    shipmentId: "shipment-uuid"   // Unique within org
  },
  
  // Display fields (denormalized)
  reference: "SHP-001",
  status: "Confirmed",
  statusOrder: 3,                 // Numeric for sorting
  carrier: "DHLPX",
  carrierLabel: "DHL Parcel",
  
  // Customer info (embedded from reference or address)
  customer: {
    name: "Acme Corp",            // Sender.Company or Customer reference
    code: "ACME"                  // If tracked separately
  },
  
  // Geography (flattened)
  originCountry: "NL",
  originCity: "Amsterdam",
  destinationCountry: "DE",
  destinationCity: "Berlin",
  
  // Dates (flattened for filtering/sorting)
  createdAt: ISODate("2026-01-21T10:00:00Z"),
  requestedDelivery: ISODate("2026-01-22T18:00:00Z"),
  
  // Counts (pre-computed)
  consignmentCount: 2,
  handlingUnitCount: 5,
  
  // Last event (for status context)
  lastEvent: {
    code: "InTransit",
    timestamp: ISODate("2026-01-21T14:00:00Z"),
    description: "Shipment in transit"
  },
  
  updatedAt: ISODate("2026-01-21T14:00:00Z")
}
```

### Aggregation Pipeline

```javascript
db.shipments.aggregate([
  // Optional: incremental filter
  // { $match: { "UpdatedOn": { $gte: lastRunTime } } },
  
  // Lookup consignment count
  {
    $lookup: {
      from: "consignments",
      let: { shipmentId: "$_id" },
      pipeline: [
        { $match: { $expr: { $eq: ["$ShipmentId", "$$shipmentId"] } } },
        { $count: "count" }
      ],
      as: "consignmentStats"
    }
  },
  
  // Project flat structure
  {
    $project: {
      _id: {
        organizationId: "$OrganizationId",
        shipmentId: "$_id"
      },
      reference: "$Data.Reference",
      status: "$Data.Status",
      statusOrder: {
        $switch: {
          branches: [
            { case: { $eq: ["$Data.Status", "Created"] }, then: 1 },
            { case: { $eq: ["$Data.Status", "Ordered"] }, then: 2 },
            { case: { $eq: ["$Data.Status", "Confirmed"] }, then: 3 },
            { case: { $eq: ["$Data.Status", "InTransit"] }, then: 4 },
            { case: { $eq: ["$Data.Status", "Delivered"] }, then: 5 },
            { case: { $eq: ["$Data.Status", "Cancelled"] }, then: 6 }
          ],
          default: 0
        }
      },
      carrier: "$Data.CarrierReference",
      carrierLabel: "$Data.CarrierLabel",
      customer: {
        name: "$Data.Addresses.Sender.Company",
        code: { $ifNull: ["$Data.CustomerReference", null] }
      },
      originCountry: "$Data.Addresses.Sender.CountryCode",
      originCity: "$Data.Addresses.Sender.City",
      destinationCountry: "$Data.Addresses.Receiver.CountryCode",
      destinationCity: "$Data.Addresses.Receiver.City",
      createdAt: "$CreatedOn",
      requestedDelivery: "$Data.TimeWindows.Delivery.Requested.End",
      consignmentCount: { $ifNull: [{ $arrayElemAt: ["$consignmentStats.count", 0] }, 0] },
      handlingUnitCount: { $size: { $ifNull: ["$Data.HandlingUnitReferences", []] } },
      updatedAt: new Date()
    }
  },
  
  { $merge: { into: "mv_shipment_list", whenMatched: "replace", whenNotMatched: "insert" } }
])
```

### Index Design (ESR Guideline)

```javascript
// Primary list view: filter by org + status, sort by date
db.mv_shipment_list.createIndex({
  "_id.organizationId": 1,  // Equality (always filtered)
  "status": 1,               // Equality (common filter)
  "createdAt": -1            // Sort (descending = newest first)
});

// Carrier filter variant
db.mv_shipment_list.createIndex({
  "_id.organizationId": 1,
  "carrier": 1,
  "createdAt": -1
});

// Date range queries
db.mv_shipment_list.createIndex({
  "_id.organizationId": 1,
  "createdAt": -1
});

// Reference lookup (exact match)
db.mv_shipment_list.createIndex({
  "_id.organizationId": 1,
  "reference": 1
});
```

### Sample Queries

**Basic list (paginated, newest first):**
```javascript
db.mv_shipment_list.find({
  "_id.organizationId": "org-123"
})
.sort({ createdAt: -1 })
.skip(0).limit(50);
```

**Filtered by status and carrier:**
```javascript
db.mv_shipment_list.find({
  "_id.organizationId": "org-123",
  "status": "Confirmed",
  "carrier": "DHLPX"
})
.sort({ createdAt: -1 })
.limit(50);
```

**Date range filter:**
```javascript
db.mv_shipment_list.find({
  "_id.organizationId": "org-123",
  "createdAt": { $gte: ISODate("2026-01-01"), $lt: ISODate("2026-02-01") }
})
.sort({ createdAt: -1 });
```

### Refresh Strategy

| Trigger | Frequency | Method |
|---------|-----------|--------|
| Shipment created/updated | Event-driven | Change stream on `shipments` |
| Consignment added | Event-driven | Change stream on `consignments` |
| Carrier event received | Event-driven | Recalc affected shipment |
| Scheduled catch-up | Hourly | Full rebuild with `$merge` |

---

## Pattern 2: Lookup MV for Autocomplete/Dropdowns

### Use Case

Customer selector dropdown with search-as-you-type. User types "acm" and sees "Acme Corp (ACME001)".

### MV Schema: `mv_customer_lookup`

Minimal document optimized for search:

```javascript
{
  _id: {
    organizationId: "org-123",
    customerId: "customer-uuid"
  },
  
  // Display
  label: "Acme Corp",           // Primary display text
  code: "ACME001",              // Secondary display
  
  // Search optimization
  searchText: "acme corp acme001",  // Lowercase, combined for regex
  searchTokens: ["acme", "corp", "acme001"],  // For prefix matching
  
  // Optional grouping
  type: "Shipper",              // For categorized dropdowns
  
  // Freshness
  active: true,
  updatedAt: ISODate("2026-01-21T10:00:00Z")
}
```

### Index Design

```javascript
// Prefix search with regex (^acm)
db.mv_customer_lookup.createIndex({
  "_id.organizationId": 1,
  "searchText": 1
});

// For Atlas Search (recommended for fuzzy matching)
// Create search index with autocomplete mapping on "label" and "code"
```

### Query Patterns

**Prefix search (basic):**
```javascript
db.mv_customer_lookup.find({
  "_id.organizationId": "org-123",
  "searchText": { $regex: "^acm", $options: "i" },
  "active": true
})
.limit(20)
.project({ label: 1, code: 1 });
```

**With Atlas Search (fuzzy):**
```javascript
db.mv_customer_lookup.aggregate([
  {
    $search: {
      index: "customer_autocomplete",
      compound: {
        must: [
          { equals: { path: "_id.organizationId", value: "org-123" } }
        ],
        should: [
          { autocomplete: { query: "acm", path: "label", fuzzy: { maxEdits: 1 } } },
          { autocomplete: { query: "acm", path: "code" } }
        ]
      }
    }
  },
  { $limit: 20 },
  { $project: { label: 1, code: 1, score: { $meta: "searchScore" } } }
]);
```

### Other Lookup MVs

| Collection | Purpose | Key Fields |
|------------|---------|------------|
| `mv_carrier_lookup` | Carrier selector | `{ label, code, services[], active }` |
| `mv_service_lookup` | Service level selector | `{ label, carrier, code, description }` |
| `mv_country_lookup` | Country selector | `{ label, code, region }` |
| `mv_address_lookup` | Address book search | `{ label, company, city, country, searchText }` |

### Refresh Strategy

Lookup MVs change infrequently. Refresh:
- On entity create/update (change stream)
- Nightly full rebuild as safety net

---

## Pattern 3: Dashboard Counter MV

### Use Case

Operations dashboard showing:
- Today's shipment count
- Pending confirmations
- In-transit count
- Exceptions requiring action

### MV Schema: `mv_dashboard_counters`

Single document per organization with nested counters:

```javascript
{
  _id: "org-123",              // One doc per org
  
  // Today's activity
  today: {
    date: "2026-01-21",
    created: 45,
    confirmed: 40,
    delivered: 12,
    exceptions: 2
  },
  
  // Current state counts
  byStatus: {
    Created: 5,
    Ordered: 10,
    Confirmed: 120,
    InTransit: 85,
    Delivered: 500,
    Cancelled: 3
  },
  
  // Pending work (requires action)
  pending: {
    awaitingConfirmation: 15,
    awaitingPickup: 25,
    exceptionsUnresolved: 4
  },
  
  // By carrier (top 5)
  byCarrier: {
    "DHLPX": { total: 250, inTransit: 45, exceptions: 1 },
    "POSTNL": { total: 180, inTransit: 30, exceptions: 2 },
    "UPS": { total: 90, inTransit: 10, exceptions: 1 }
  },
  
  // Trend (last 7 days)
  dailyTrend: [
    { date: "2026-01-15", created: 40, delivered: 35 },
    { date: "2026-01-16", created: 42, delivered: 38 },
    // ... last 7 days
  ],
  
  updatedAt: ISODate("2026-01-21T14:30:00Z")
}
```

### Aggregation Pipeline (with $facet)

```javascript
const today = new Date().toISOString().split('T')[0];
const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);

db.shipments.aggregate([
  { $match: { OrganizationId: "org-123" } },
  
  {
    $facet: {
      // Today's counts
      today: [
        { $match: { CreatedOn: { $gte: new Date(today) } } },
        {
          $group: {
            _id: null,
            created: { $sum: 1 },
            confirmed: { $sum: { $cond: [{ $eq: ["$Data.Status", "Confirmed"] }, 1, 0] } },
            delivered: { $sum: { $cond: [{ $eq: ["$Data.Status", "Delivered"] }, 1, 0] } }
          }
        }
      ],
      
      // All-time by status
      byStatus: [
        {
          $group: {
            _id: "$Data.Status",
            count: { $sum: 1 }
          }
        }
      ],
      
      // By carrier
      byCarrier: [
        {
          $group: {
            _id: "$Data.CarrierReference",
            total: { $sum: 1 },
            inTransit: { $sum: { $cond: [{ $in: ["$Data.Status", ["Confirmed", "InTransit"]] }, 1, 0] } }
          }
        },
        { $sort: { total: -1 } },
        { $limit: 5 }
      ],
      
      // Daily trend
      dailyTrend: [
        { $match: { CreatedOn: { $gte: sevenDaysAgo } } },
        {
          $group: {
            _id: { $dateToString: { format: "%Y-%m-%d", date: "$CreatedOn" } },
            created: { $sum: 1 },
            delivered: { $sum: { $cond: [{ $eq: ["$Data.Status", "Delivered"] }, 1, 0] } }
          }
        },
        { $sort: { _id: 1 } }
      ]
    }
  },
  
  // Transform to final shape
  {
    $project: {
      _id: "org-123",
      today: {
        date: today,
        created: { $ifNull: [{ $arrayElemAt: ["$today.created", 0] }, 0] },
        confirmed: { $ifNull: [{ $arrayElemAt: ["$today.confirmed", 0] }, 0] },
        delivered: { $ifNull: [{ $arrayElemAt: ["$today.delivered", 0] }, 0] }
      },
      byStatus: {
        $arrayToObject: {
          $map: {
            input: "$byStatus",
            as: "s",
            in: { k: "$$s._id", v: "$$s.count" }
          }
        }
      },
      byCarrier: {
        $arrayToObject: {
          $map: {
            input: "$byCarrier",
            as: "c",
            in: { k: "$$c._id", v: { total: "$$c.total", inTransit: "$$c.inTransit" } }
          }
        }
      },
      dailyTrend: {
        $map: {
          input: "$dailyTrend",
          as: "d",
          in: { date: "$$d._id", created: "$$d.created", delivered: "$$d.delivered" }
        }
      },
      updatedAt: new Date()
    }
  },
  
  { $merge: { into: "mv_dashboard_counters", whenMatched: "replace", whenNotMatched: "insert" } }
]);
```

### Query Pattern

Dashboard widgets call:
```javascript
db.mv_dashboard_counters.findOne({ _id: "org-123" });
```

Single read returns all widget data. UI can destructure as needed.

### Refresh Strategy

| Frequency | Use Case |
|-----------|----------|
| Every 5 minutes | Real-time operations dashboard |
| Hourly | Management dashboard |
| On-demand | After significant batch operations |

For real-time feel, combine MV with client-side optimistic updates.

---

## Pattern 4: Hierarchical Projection MV

### Use Case

TMS data is hierarchical: `Shipment → Consignment(s) → HandlingUnit(s)`. Common queries:
- Show consignment list with shipment reference
- Show handling units with shipment status
- Navigate from any level to others

### Problem

Without denormalization, displaying a consignment list requires `$lookup` to get shipment reference and status. This adds latency and complexity.

### MV Schema: `mv_consignment_list`

Embed parent (shipment) summary in consignment MV:

```javascript
{
  _id: {
    organizationId: "org-123",
    consignmentId: "consignment-uuid"
  },
  
  // Consignment fields
  reference: "CON-001",
  status: "Confirmed",
  carrier: "DHLPX",
  carrierLabel: "DHL Parcel",
  trackingNumber: "JVGL1234567890",
  
  // Parent context (denormalized from shipment)
  shipment: {
    id: "shipment-uuid",
    reference: "SHP-001",
    status: "Confirmed"
  },
  
  // Child summary (aggregated)
  handlingUnits: {
    count: 3,
    totalWeightKg: 45.5,
    types: ["Parcel", "Pallet"]
  },
  
  // Route info
  origin: { country: "NL", city: "Amsterdam" },
  destination: { country: "DE", city: "Berlin" },
  
  // Dates
  createdAt: ISODate("2026-01-21T10:00:00Z"),
  
  updatedAt: ISODate("2026-01-21T14:00:00Z")
}
```

### Bidirectional Embedding

Also update `mv_shipment_list` to include consignment summary:

```javascript
// In mv_shipment_list, add:
{
  consignments: {
    count: 2,
    statuses: { Created: 0, Confirmed: 2, Delivered: 0 },
    carriers: ["DHLPX", "POSTNL"]
  }
}
```

### Aggregation Pipeline

```javascript
db.consignments.aggregate([
  // Lookup parent shipment
  {
    $lookup: {
      from: "shipments",
      localField: "ShipmentId",
      foreignField: "_id",
      as: "shipmentDoc"
    }
  },
  { $unwind: "$shipmentDoc" },
  
  // Lookup child handling units count
  {
    $lookup: {
      from: "handling_units",
      let: { consignmentId: "$_id" },
      pipeline: [
        { $match: { $expr: { $eq: ["$ConsignmentId", "$$consignmentId"] } } },
        {
          $group: {
            _id: null,
            count: { $sum: 1 },
            totalWeight: { $sum: "$Data.Weight.Value" },
            types: { $addToSet: "$Data.PackageType" }
          }
        }
      ],
      as: "huStats"
    }
  },
  
  // Project flat structure
  {
    $project: {
      _id: {
        organizationId: "$OrganizationId",
        consignmentId: "$_id"
      },
      reference: "$Data.Reference",
      status: "$Data.Status",
      carrier: "$Data.CarrierReference",
      carrierLabel: "$Data.CarrierLabel",
      trackingNumber: "$Data.TrackingNumber",
      
      shipment: {
        id: "$shipmentDoc._id",
        reference: "$shipmentDoc.Data.Reference",
        status: "$shipmentDoc.Data.Status"
      },
      
      handlingUnits: {
        count: { $ifNull: [{ $arrayElemAt: ["$huStats.count", 0] }, 0] },
        totalWeightKg: { $ifNull: [{ $arrayElemAt: ["$huStats.totalWeight", 0] }, 0] },
        types: { $ifNull: [{ $arrayElemAt: ["$huStats.types", 0] }, []] }
      },
      
      origin: {
        country: "$Data.Addresses.Sender.CountryCode",
        city: "$Data.Addresses.Sender.City"
      },
      destination: {
        country: "$Data.Addresses.Receiver.CountryCode",
        city: "$Data.Addresses.Receiver.City"
      },
      
      createdAt: "$CreatedOn",
      updatedAt: new Date()
    }
  },
  
  { $merge: { into: "mv_consignment_list", whenMatched: "replace", whenNotMatched: "insert" } }
]);
```

### Query Patterns

**List consignments with shipment context:**
```javascript
db.mv_consignment_list.find({
  "_id.organizationId": "org-123"
})
.sort({ createdAt: -1 })
.limit(50);
```

**Filter by shipment:**
```javascript
db.mv_consignment_list.find({
  "_id.organizationId": "org-123",
  "shipment.id": "shipment-uuid"
});
```

**Filter by tracking number (carrier lookup):**
```javascript
db.mv_consignment_list.findOne({
  "_id.organizationId": "org-123",
  "trackingNumber": "JVGL1234567890"
});
```

### When to Denormalize Parent vs Reference

| Scenario | Approach |
|----------|----------|
| Parent field rarely changes (reference, ID) | Embed in child MV |
| Parent field changes often (status) | Embed, accept eventual consistency |
| Need to filter by parent field | Embed for index support |
| Display only, never filter | Could use `$lookup` at query time |
| Child count needed on parent list | Embed summary in parent MV |

---

## Index Strategy Summary

### Compound Index Order (ESR)

1. **Equality fields first** - organizationId, status, carrier (exact match filters)
2. **Sort fields second** - createdAt, reference (ORDER BY clause)
3. **Range fields last** - date ranges, numeric comparisons

### Example for `mv_shipment_list`

```javascript
// Most common query: org + status filter + date sort
{ "_id.organizationId": 1, "status": 1, "createdAt": -1 }

// Carrier filter variant
{ "_id.organizationId": 1, "carrier": 1, "createdAt": -1 }

// Reference lookup (unique within org)
{ "_id.organizationId": 1, "reference": 1 }

// Geographic filter
{ "_id.organizationId": 1, "destinationCountry": 1, "createdAt": -1 }
```

### Index Limits

- MongoDB allows up to 64 indexes per collection
- Each index adds write overhead
- Monitor with `db.collection.aggregate([{ $indexStats: {} }])`
- Remove unused indexes after validation period

---

## Refresh Strategies Comparison

| Pattern | Ideal Refresh | Staleness Tolerance |
|---------|---------------|---------------------|
| Flat List View | Event-driven (change stream) | Seconds to minutes |
| Lookup MV | Entity change + nightly | Hours to days |
| Dashboard Counter | Scheduled (5-60 min) | Minutes |
| Hierarchical | Event-driven on any entity change | Seconds to minutes |

### Change Stream Handler Pattern

```javascript
// Simplified handler for mv_shipment_list
const pipeline = [
  { $match: { "operationType": { $in: ["insert", "update", "replace"] } } }
];

const changeStream = db.shipments.watch(pipeline);

changeStream.on("change", async (change) => {
  const shipmentId = change.documentKey._id;
  
  // Re-run aggregation for single shipment
  await db.shipments.aggregate([
    { $match: { _id: shipmentId } },
    // ... same pipeline as batch
    { $merge: { into: "mv_shipment_list", whenMatched: "replace" } }
  ]).toArray();
});
```

---

## Sources

| Source | Type | Key Contribution |
|--------|------|------------------|
| [MongoDB On-Demand Materialized Views](https://www.mongodb.com/docs/manual/core/materialized-views/) | Official docs | `$merge`/`$out` usage, MV vs standard view comparison |
| [Extended Reference Pattern](https://www.mongodb.com/blog/post/building-with-patterns-the-extended-reference-pattern) | Vendor blog | Denormalizing frequently-JOINed data into main document |
| [Computed Pattern](https://www.mongodb.com/blog/post/building-with-patterns-the-computed-pattern) | Vendor blog | Pre-computing expensive calculations for read-heavy workloads |
| [Bucket Pattern](https://www.mongodb.com/blog/post/building-with-patterns-the-bucket-pattern) | Vendor blog | Time-bucketed aggregation for time-series/metrics |
| [Compound Indexes](https://www.mongodb.com/docs/manual/core/indexes/index-types/index-compound/) | Official docs | ESR guideline, index prefix support |
| [Model One-to-Many Relationships](https://www.mongodb.com/docs/manual/tutorial/model-embedded-one-to-many-relationships-between-documents/) | Official docs | Embedding vs referencing decision criteria |
| [MongoDB Text Search](https://www.mongodb.com/docs/manual/text-search/) | Official docs | Atlas Search for autocomplete |
| [Viya Reporting MV Strategy](../viya-reporting/2026-01-21-materialized-view-strategy.md) | Internal | Existing MV architecture for reporting context |

---

## Questions for Further Research

- [ ] **Change stream reliability** - What happens when handler is down? Resume token persistence strategy?
- [ ] **MV validation** - How to detect stale MVs? Reconciliation job patterns?
- [ ] **Atlas Search vs text index** - Cost/benefit for autocomplete at scale?
- [ ] **Multi-tenant sharding** - How do MVs interact with sharded source collections?
- [ ] **Write amplification** - What's the overhead of maintaining N MVs from single write?
