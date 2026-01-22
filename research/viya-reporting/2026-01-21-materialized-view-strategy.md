---
topic: Materialized View Strategy for Viya TMS Reporting
date: 2026-01-21
project: viya-reporting
sources_count: 4
status: draft
tags: [mongodb, materialized-views, analytics, architecture, embedded-bi]
---

# Materialized View Strategy for Viya TMS Reporting

## Summary

This document defines a minimal, flexible materialized view (MV) architecture for Viya TMS that serves embedded analytics without MV proliferation. The core insight: **4 dimensional MVs can serve 15+ report types** by using composite `_id` fields that support flexible filtering on timeframe, carrier, geography, and service level.

The strategy prioritizes:
1. **Filter flexibility** - Query-time filtering over separate MVs per filter combination
2. **Minimal maintenance** - 4 MVs instead of 10-15+
3. **Appropriate freshness** - Match refresh frequency to user action cycles
4. **Incremental updates** - Use `$merge` with `whenMatched: "replace"` for efficient updates

## Current State

### Existing MVs

| Collection | Purpose | Limitation |
|------------|---------|------------|
| `mv_consignments_flat` | Flattened consignment data | Not aggregated; no time dimension |
| `mv_consignment_event_stats` | Event stats per consignment | Per-record; no filtering |
| `analytics_global_summary` | Global totals | Single doc; no time/carrier filtering |
| `analytics_carrier_summary` | Per-carrier totals | No time dimension |
| `analytics_carrier_daily` | Daily by carrier | Missing geography, service level |

### Gap Analysis

| P0/P1 Report | Required Filters | Current Coverage |
|--------------|------------------|------------------|
| Shipment Status Dashboard | Timeframe, Carrier | None |
| Daily Volume Summary | Timeframe, Carrier, Geography | Partial |
| Carrier Performance | Timeframe, Carrier | Partial |
| On-Time Delivery | Timeframe, Carrier, Lane | None |
| Geographic Distribution | Timeframe, Country, Direction | None |

**Core problem**: Current MVs lack dimensional flexibility for embedded analytics filtering.

## Recommended Architecture

### Design Principles

1. **Composite _id for multi-dimensional filtering**
   - Include all filter dimensions in `_id`
   - Query with `$match` on subset of dimensions
   - Avoids creating MVs per filter combination

2. **Granularity by use case**
   - Daily grain for trend analysis
   - Monthly grain for scorecards
   - Per-shipment for lifecycle tracking
   - Single-doc for real-time ops

3. **Refresh aligned with user cycles**
   - Operations: 5 minutes
   - Daily reporting: hourly
   - Scorecards: nightly
   - Lifecycle: event-driven

### The 4 MVs

```
┌──────────────────────────────────────────────────────────────────┐
│  mv_daily_metrics                                                │
│  ────────────────                                                │
│  Grain: Daily + Carrier + Service + Origin + Destination + Dir   │
│  Refresh: Hourly (incremental)                                   │
│  Serves: 6 report types                                          │
├──────────────────────────────────────────────────────────────────┤
│  mv_carrier_performance                                          │
│  ─────────────────────                                           │
│  Grain: Monthly + Carrier                                        │
│  Refresh: Nightly                                                │
│  Serves: 4 report types                                          │
├──────────────────────────────────────────────────────────────────┤
│  mv_shipment_lifecycle                                           │
│  ────────────────────                                            │
│  Grain: Per shipment                                             │
│  Refresh: Event-driven (change stream)                           │
│  Serves: 3 report types                                          │
├──────────────────────────────────────────────────────────────────┤
│  mv_realtime_ops                                                 │
│  ──────────────                                                  │
│  Grain: Single current-state document                            │
│  Refresh: 5 minutes                                              │
│  Serves: 2 report types                                          │
└──────────────────────────────────────────────────────────────────┘
```

---

## MV 1: Daily Metrics (`mv_daily_metrics`)

### Purpose

Central MV for all shipment/consignment/handling unit volume and cost reporting. Supports filtering by any combination of dimensions.

### Schema

```javascript
{
  _id: {
    date: "2026-01-21",              // YYYY-MM-DD (partition key)
    carrier: "DHLPX",                // CarrierReference
    service: "DFY-B2C",              // ServiceLevelReference
    originCountry: "NL",
    destinationCountry: "DE",
    inbound: false
  },
  
  // Shipment metrics
  shipments: {
    total: 150,
    byStatus: {
      Created: 5,
      Ordered: 10,
      Confirmed: 120,
      Delivered: 15
    }
  },
  
  // Consignment metrics
  consignments: {
    total: 140,
    byStatus: {
      Created: 3,
      Ordered: 8,
      Confirmed: 115,
      Delivered: 14
    }
  },
  
  // Handling unit metrics
  handlingUnits: {
    total: 200,
    avgPerShipment: 1.33,
    byType: {
      Parcel: 180,
      Pallet: 20
    }
  },
  
  // Weight metrics
  weights: {
    billableKg: 1500.5,
    physicalKg: 1400.0,
    avgPerShipment: 10.0
  },
  
  // Cost metrics (when available)
  costs: {
    total: 2500.00,
    currency: "EUR",
    avgPerShipment: 16.67
  },
  
  // Metadata
  updatedAt: ISODate("2026-01-21T14:30:00Z")
}
```

### Aggregation Pipeline

```javascript
// Run hourly for incremental updates
db.shipments.aggregate([
  // Optional: limit to recent changes for incremental
  // { $match: { "UpdatedOn": { $gte: lastRunTime } } },
  
  {
    $group: {
      _id: {
        date: { $dateToString: { format: "%Y-%m-%d", date: "$CreatedOn" } },
        carrier: "$Data.CarrierReference",
        service: "$Data.ServiceLevelReference",
        originCountry: "$Data.Addresses.Sender.CountryCode",
        destinationCountry: "$Data.Addresses.Receiver.CountryCode",
        inbound: { $ifNull: ["$Data.Inbound", false] }
      },
      
      // Shipment counts
      shipmentTotal: { $sum: 1 },
      shipmentCreated: { $sum: { $cond: [{ $eq: ["$Data.Status", "Created"] }, 1, 0] } },
      shipmentOrdered: { $sum: { $cond: [{ $eq: ["$Data.Status", "Ordered"] }, 1, 0] } },
      shipmentConfirmed: { $sum: { $cond: [{ $eq: ["$Data.Status", "Confirmed"] }, 1, 0] } },
      shipmentDelivered: { $sum: { $cond: [{ $eq: ["$Data.Status", "Delivered"] }, 1, 0] } },
      
      // Handling units
      huTotal: { $sum: { $size: { $ifNull: ["$Data.HandlingUnitReferences", []] } } },
      
      // Weights
      billableKg: { $sum: { $toDouble: { $ifNull: ["$Data.Rate.Weights.BillableWeight.Value", 0] } } },
      physicalKg: { $sum: { $toDouble: { $ifNull: ["$Data.Rate.Weights.PhysicalWeight.Value", 0] } } },
      
      // Costs
      totalCost: { $sum: { $toDouble: { $ifNull: ["$Data.Rate.Price.TotalRequestedCurrency.Value", 0] } } },
      currency: { $first: "$Data.Rate.Price.TotalRequestedCurrency.CurrencyCode" }
    }
  },
  
  {
    $project: {
      shipments: {
        total: "$shipmentTotal",
        byStatus: {
          Created: "$shipmentCreated",
          Ordered: "$shipmentOrdered",
          Confirmed: "$shipmentConfirmed",
          Delivered: "$shipmentDelivered"
        }
      },
      handlingUnits: {
        total: "$huTotal",
        avgPerShipment: { $cond: [{ $eq: ["$shipmentTotal", 0] }, 0, { $divide: ["$huTotal", "$shipmentTotal"] }] }
      },
      weights: {
        billableKg: "$billableKg",
        physicalKg: "$physicalKg",
        avgPerShipment: { $cond: [{ $eq: ["$shipmentTotal", 0] }, 0, { $divide: ["$billableKg", "$shipmentTotal"] }] }
      },
      costs: {
        total: "$totalCost",
        currency: "$currency",
        avgPerShipment: { $cond: [{ $eq: ["$shipmentTotal", 0] }, 0, { $divide: ["$totalCost", "$shipmentTotal"] }] }
      },
      updatedAt: new Date()
    }
  },
  
  { $merge: { into: "mv_daily_metrics", whenMatched: "replace", whenNotMatched: "insert" } }
])
```

### Sample Queries

**Daily volume trend (all carriers):**
```javascript
db.mv_daily_metrics.aggregate([
  { $match: { "_id.date": { $gte: "2026-01-01", $lte: "2026-01-31" } } },
  { $group: { _id: "$_id.date", total: { $sum: "$shipments.total" } } },
  { $sort: { "_id": 1 } }
])
```

**Carrier comparison (timeframe):**
```javascript
db.mv_daily_metrics.aggregate([
  { $match: { "_id.date": { $gte: "2026-01-01" } } },
  { $group: { 
      _id: "$_id.carrier", 
      shipments: { $sum: "$shipments.total" },
      avgCost: { $avg: "$costs.avgPerShipment" }
  }},
  { $sort: { shipments: -1 } }
])
```

**Top destinations (by carrier):**
```javascript
db.mv_daily_metrics.aggregate([
  { $match: { "_id.date": { $gte: "2026-01-01" }, "_id.carrier": "DHLPX" } },
  { $group: { _id: "$_id.destinationCountry", total: { $sum: "$shipments.total" } } },
  { $sort: { total: -1 } },
  { $limit: 10 }
])
```

**Lane analysis (origin-destination):**
```javascript
db.mv_daily_metrics.aggregate([
  { $match: { "_id.date": { $gte: "2026-01-01" } } },
  { $group: {
      _id: { origin: "$_id.originCountry", destination: "$_id.destinationCountry" },
      shipments: { $sum: "$shipments.total" },
      totalCost: { $sum: "$costs.total" }
  }},
  { $sort: { shipments: -1 } }
])
```

### Reports Served

| Report | Filter Combination |
|--------|-------------------|
| Daily Volume Summary | `date` |
| Carrier Mix | `date` + group by `carrier` |
| Geographic Distribution | `date` + group by `destinationCountry` |
| Lane Analysis | `date` + group by `origin` + `destination` |
| Service Level Mix | `date` + group by `service` |
| Inbound vs Outbound | `date` + group by `inbound` |

---

## MV 2: Carrier Performance (`mv_carrier_performance`)

### Purpose

Monthly carrier scorecards with OTD metrics, transit time analysis, and volume trends.

### Schema

```javascript
{
  _id: {
    month: "2026-01",               // YYYY-MM
    carrier: "DHLPX"
  },
  
  carrierLabel: "DHL Parcel",
  
  // Volume
  volume: {
    shipments: 1500,
    consignments: 1200,
    handlingUnits: 2000,
    weightKg: 15000.0
  },
  
  // Status distribution
  statusCounts: {
    Created: 50,
    Ordered: 100,
    Confirmed: 1200,
    Delivered: 150
  },
  
  // On-time delivery (requires carrier events)
  otd: {
    deliveredOnTime: 140,
    deliveredLate: 10,
    rate: 0.933,                    // 93.3%
    totalDelivered: 150
  },
  
  // Transit time analysis
  transit: {
    avgDays: 2.3,
    minDays: 1,
    maxDays: 5,
    p95Days: 4                      // 95th percentile
  },
  
  // Cost efficiency
  costs: {
    total: 25000.00,
    currency: "EUR",
    avgPerShipment: 16.67,
    avgPerKg: 1.67
  },
  
  // Exceptions (when tracked)
  exceptions: {
    total: 15,
    byType: {
      AddressIssue: 5,
      DeliveryAttemptFailed: 8,
      DamagedPackage: 2
    }
  },
  
  updatedAt: ISODate("2026-01-22T02:00:00Z")
}
```

### Aggregation Pipeline

```javascript
// Run nightly after business day closes
db.shipments.aggregate([
  {
    $group: {
      _id: {
        month: { $dateToString: { format: "%Y-%m", date: "$CreatedOn" } },
        carrier: "$Data.CarrierReference"
      },
      
      carrierLabel: { $first: "$Data.CarrierLabel" },
      
      shipmentCount: { $sum: 1 },
      totalWeight: { $sum: { $toDouble: { $ifNull: ["$Data.Rate.Weights.BillableWeight.Value", 0] } } },
      huCount: { $sum: { $size: { $ifNull: ["$Data.HandlingUnitReferences", []] } } },
      
      // Status counts
      created: { $sum: { $cond: [{ $eq: ["$Data.Status", "Created"] }, 1, 0] } },
      ordered: { $sum: { $cond: [{ $eq: ["$Data.Status", "Ordered"] }, 1, 0] } },
      confirmed: { $sum: { $cond: [{ $eq: ["$Data.Status", "Confirmed"] }, 1, 0] } },
      delivered: { $sum: { $cond: [{ $eq: ["$Data.Status", "Delivered"] }, 1, 0] } },
      
      // Costs
      totalCost: { $sum: { $toDouble: { $ifNull: ["$Data.Rate.Price.TotalRequestedCurrency.Value", 0] } } },
      currency: { $first: "$Data.Rate.Price.TotalRequestedCurrency.CurrencyCode" }
    }
  },
  
  {
    $project: {
      carrierLabel: 1,
      volume: {
        shipments: "$shipmentCount",
        handlingUnits: "$huCount",
        weightKg: "$totalWeight"
      },
      statusCounts: {
        Created: "$created",
        Ordered: "$ordered",
        Confirmed: "$confirmed",
        Delivered: "$delivered"
      },
      // OTD placeholder - needs enrichment from carrier events
      otd: {
        deliveredOnTime: 0,
        deliveredLate: 0,
        rate: null,
        totalDelivered: "$delivered"
      },
      transit: {
        avgDays: null,              // Needs carrier event enrichment
        minDays: null,
        maxDays: null
      },
      costs: {
        total: "$totalCost",
        currency: "$currency",
        avgPerShipment: { $cond: [{ $eq: ["$shipmentCount", 0] }, 0, { $divide: ["$totalCost", "$shipmentCount"] }] },
        avgPerKg: { $cond: [{ $eq: ["$totalWeight", 0] }, 0, { $divide: ["$totalCost", "$totalWeight"] }] }
      },
      updatedAt: new Date()
    }
  },
  
  { $merge: { into: "mv_carrier_performance", whenMatched: "replace", whenNotMatched: "insert" } }
])
```

### Reports Served

| Report | Query |
|--------|-------|
| Monthly Carrier Scorecard | `$match: { "_id.month": "2026-01" }` |
| Carrier Comparison | `$match: { "_id.month": "2026-01" }` + `$sort: volume.shipments` |
| OTD Trend by Carrier | `$match: { "_id.carrier": "DHLPX" }` + `$sort: "_id.month"` |
| Cost per Shipment Trend | Group by month, project `costs.avgPerShipment` |

---

## MV 3: Shipment Lifecycle (`mv_shipment_lifecycle`)

### Purpose

Per-shipment view combining shipment data with carrier events for SLA tracking, exception detection, and individual shipment queries.

### Schema

```javascript
{
  _id: "shipment-uuid",
  
  // Identity
  reference: "REF-00001",
  carrier: "DHLPX",
  carrierLabel: "DHL Parcel",
  service: "DFY-B2C",
  
  // Current status
  status: "Delivered",
  
  // Geography
  origin: { country: "NL", city: "Amsterdam", postalCode: "1011" },
  destination: { country: "DE", city: "Berlin", postalCode: "10115" },
  
  // Lifecycle timestamps
  timestamps: {
    created: ISODate("2026-01-15T10:00:00Z"),
    ordered: ISODate("2026-01-15T10:05:00Z"),
    confirmed: ISODate("2026-01-15T12:00:00Z"),
    pickedUp: ISODate("2026-01-15T14:30:00Z"),
    inTransit: ISODate("2026-01-15T15:00:00Z"),
    outForDelivery: ISODate("2026-01-17T08:00:00Z"),
    delivered: ISODate("2026-01-17T11:30:00Z")
  },
  
  // Calculated durations (hours)
  durations: {
    orderToConfirm: 2.0,
    confirmToPickup: 2.5,
    pickupToDelivery: 45.0,
    totalTransit: 49.5
  },
  
  // SLA compliance
  sla: {
    requestedDelivery: ISODate("2026-01-17T18:00:00Z"),
    actualDelivery: ISODate("2026-01-17T11:30:00Z"),
    onTime: true,
    varianceHours: -6.5                // Negative = early
  },
  
  // Package info
  handlingUnits: {
    count: 2,
    totalWeightKg: 15.5,
    refs: ["hu-001", "hu-002"]
  },
  
  // Cost
  cost: {
    total: 18.50,
    currency: "EUR"
  },
  
  // Latest event
  lastEvent: {
    code: "Delivered",
    timestamp: ISODate("2026-01-17T11:30:00Z"),
    description: "Package delivered to recipient"
  },
  
  // Exceptions (if any)
  exceptions: [
    // { type: "DeliveryAttemptFailed", timestamp: ISODate, resolved: true }
  ],
  
  updatedAt: ISODate("2026-01-17T11:35:00Z")
}
```

### Aggregation Pipeline

```javascript
// Run on change stream or scheduled batch
// This is a complex join - best done with $lookup

db.shipments.aggregate([
  {
    $lookup: {
      from: "carrier_tracking_events",
      let: { shipmentId: "$_id" },
      pipeline: [
        { $match: { $expr: { $in: ["$$shipmentId", "$Data.MatchingEntities._id"] } } },
        { $sort: { "Data.Event.EventDateTime.DateTime": 1 } }
      ],
      as: "events"
    }
  },
  
  {
    $project: {
      reference: "$Data.Reference",
      carrier: "$Data.CarrierReference",
      carrierLabel: "$Data.CarrierLabel",
      service: "$Data.ServiceLevelReference",
      status: "$Data.Status",
      
      origin: {
        country: "$Data.Addresses.Sender.CountryCode",
        city: "$Data.Addresses.Sender.City",
        postalCode: "$Data.Addresses.Sender.PostCode"
      },
      destination: {
        country: "$Data.Addresses.Receiver.CountryCode",
        city: "$Data.Addresses.Receiver.City",
        postalCode: "$Data.Addresses.Receiver.PostCode"
      },
      
      timestamps: {
        created: "$CreatedOn",
        // Other timestamps from events - complex extraction
      },
      
      sla: {
        requestedDelivery: "$Data.TimeWindows.Delivery.Requested.End",
        // actualDelivery from events
      },
      
      handlingUnits: {
        count: { $size: { $ifNull: ["$Data.HandlingUnitReferences", []] } },
        refs: "$Data.HandlingUnitReferences"
      },
      
      cost: {
        total: { $toDouble: { $ifNull: ["$Data.Rate.Price.TotalRequestedCurrency.Value", 0] } },
        currency: "$Data.Rate.Price.TotalRequestedCurrency.CurrencyCode"
      },
      
      events: { $slice: ["$events", -1] },  // Last event
      
      updatedAt: new Date()
    }
  },
  
  { $merge: { into: "mv_shipment_lifecycle", whenMatched: "replace", whenNotMatched: "insert" } }
])
```

### Reports Served

| Report | Query |
|--------|-------|
| Individual Shipment Tracking | `$match: { _id: "uuid" }` or `{ reference: "REF-001" }` |
| Exception List | `$match: { "exceptions.0": { $exists: true } }` |
| SLA Analysis | `$match: { "sla.onTime": false }` |

---

## MV 4: Real-time Operations (`mv_realtime_ops`)

### Purpose

Single document for operations dashboard showing current state. Lightweight aggregation for fast refresh.

### Schema

```javascript
{
  _id: "current",
  
  // Today's metrics
  today: {
    shipped: 45,
    confirmed: 40,
    delivered: 12,
    exceptions: 2
  },
  
  // Pending work
  pending: {
    awaitingConfirmation: 5,
    awaitingPickup: 25,
    inTransit: 180
  },
  
  // By carrier (today)
  byCarrier: {
    "DHLPX": { shipped: 20, delivered: 8, exceptions: 0 },
    "POSTNL": { shipped: 15, delivered: 4, exceptions: 1 }
  },
  
  // Active exceptions requiring action
  exceptions: [
    { 
      shipmentId: "uuid", 
      reference: "REF-123", 
      type: "AddressIssue",
      carrier: "DHLPX",
      ageMinutes: 120,
      createdAt: ISODate("2026-01-21T12:00:00Z")
    }
  ],
  
  // Pickups scheduled today
  pickupsToday: {
    scheduled: 5,
    completed: 2,
    upcoming: [
      { pickupId: "uuid", carrier: "DHLPX", window: "14:00-16:00", packages: 12 }
    ]
  },
  
  updatedAt: ISODate("2026-01-21T14:35:00Z")
}
```

### Aggregation Pipeline

```javascript
// Run every 5 minutes
const today = new Date().toISOString().split('T')[0];

// Use $facet for multiple aggregations in one pass
db.shipments.aggregate([
  {
    $facet: {
      todayMetrics: [
        { $match: { CreatedOn: { $gte: new Date(today) } } },
        { $group: {
            _id: null,
            shipped: { $sum: 1 },
            confirmed: { $sum: { $cond: [{ $eq: ["$Data.Status", "Confirmed"] }, 1, 0] } },
            delivered: { $sum: { $cond: [{ $eq: ["$Data.Status", "Delivered"] }, 1, 0] } }
        }}
      ],
      pending: [
        { $match: { "Data.Status": { $in: ["Created", "Ordered", "Confirmed"] } } },
        { $group: {
            _id: "$Data.Status",
            count: { $sum: 1 }
        }}
      ],
      byCarrier: [
        { $match: { CreatedOn: { $gte: new Date(today) } } },
        { $group: {
            _id: "$Data.CarrierReference",
            shipped: { $sum: 1 },
            delivered: { $sum: { $cond: [{ $eq: ["$Data.Status", "Delivered"] }, 1, 0] } }
        }}
      ]
    }
  },
  
  // Transform and merge
  {
    $project: {
      _id: "current",
      today: { $arrayElemAt: ["$todayMetrics", 0] },
      pending: { $arrayToObject: { $map: { input: "$pending", as: "p", in: { k: "$$p._id", v: "$$p.count" } } } },
      byCarrier: { $arrayToObject: { $map: { input: "$byCarrier", as: "c", in: { k: "$$c._id", v: { shipped: "$$c.shipped", delivered: "$$c.delivered" } } } } },
      updatedAt: new Date()
    }
  },
  
  { $merge: { into: "mv_realtime_ops", whenMatched: "replace", whenNotMatched: "insert" } }
])
```

### Reports Served

| Report | Query |
|--------|-------|
| Operations Dashboard | `db.mv_realtime_ops.findOne({ _id: "current" })` |
| Exception Alert View | Access `exceptions` array from current doc |
| Today's Pickups | Access `pickupsToday` from current doc |

---

## Indexing Strategy

### On Source Collections

```javascript
// Time-based queries (critical for all MVs)
db.shipments.createIndex({ "CreatedOn": -1 })
db.consignments.createIndex({ "CreatedOn": -1 })

// Status + time (for operations queries)
db.shipments.createIndex({ "Data.Status": 1, "CreatedOn": -1 })

// Carrier + time (for carrier reports)
db.shipments.createIndex({ "Data.CarrierReference": 1, "CreatedOn": -1 })

// Geographic queries
db.shipments.createIndex({
  "Data.Addresses.Sender.CountryCode": 1,
  "Data.Addresses.Receiver.CountryCode": 1,
  "CreatedOn": -1
})
```

### On MVs

```javascript
// mv_daily_metrics - query by date range + carrier
db.mv_daily_metrics.createIndex({ "_id.date": -1 })
db.mv_daily_metrics.createIndex({ "_id.date": -1, "_id.carrier": 1 })

// mv_carrier_performance - query by month + carrier
db.mv_carrier_performance.createIndex({ "_id.month": -1 })
db.mv_carrier_performance.createIndex({ "_id.carrier": 1, "_id.month": -1 })

// mv_shipment_lifecycle - query by reference, carrier, status
db.mv_shipment_lifecycle.createIndex({ "reference": 1 })
db.mv_shipment_lifecycle.createIndex({ "carrier": 1, "status": 1 })
db.mv_shipment_lifecycle.createIndex({ "sla.onTime": 1 })
```

---

## Refresh Strategy

| MV | Frequency | Trigger | Implementation |
|----|-----------|---------|----------------|
| `mv_daily_metrics` | Hourly + nightly full | Scheduled job | Incremental by `UpdatedOn`; full rebuild nightly |
| `mv_carrier_performance` | Nightly | Scheduled job | Full rebuild after EOD cutoff (e.g., 2 AM) |
| `mv_shipment_lifecycle` | Event-driven | Change stream | On shipment update or carrier event |
| `mv_realtime_ops` | 5 minutes | Scheduled job | Full rebuild (single doc, fast) |

### Incremental Update Pattern

For `mv_daily_metrics`, use incremental updates during the day:

```javascript
// Track last run time in a metadata collection
const lastRun = db.mv_metadata.findOne({ _id: "mv_daily_metrics" })?.lastRun || new Date(0);

db.shipments.aggregate([
  { $match: { "UpdatedOn": { $gte: lastRun } } },
  // ... rest of pipeline
  { $merge: { into: "mv_daily_metrics", whenMatched: "replace", whenNotMatched: "insert" } }
]);

// Update last run time
db.mv_metadata.updateOne(
  { _id: "mv_daily_metrics" },
  { $set: { lastRun: new Date() } },
  { upsert: true }
);
```

---

## Migration from Existing MVs

### Deprecation Plan

| Current MV | Replacement | Action |
|------------|-------------|--------|
| `analytics_global_summary` | `mv_realtime_ops` | Replace after new MV validated |
| `analytics_carrier_summary` | `mv_daily_metrics` (aggregated) | Replace |
| `analytics_carrier_daily` | `mv_daily_metrics` | Replace (superset) |
| `mv_consignments_flat` | Keep | Used for different purpose |
| `mv_consignment_event_stats` | `mv_shipment_lifecycle` | Evaluate overlap |

### Migration Steps

1. Deploy new MVs alongside existing
2. Update application queries to use new MVs
3. Monitor query patterns and performance
4. Deprecate old MVs after 2-week validation period

---

## Handling Unit Integration

The `mv_daily_metrics` includes handling unit counts, but detailed package-level queries should use:

1. **For totals**: Use `handlingUnits.total` from `mv_daily_metrics`
2. **For package details**: Query `handling_units` collection directly (not high-volume query pattern)
3. **For per-shipment packages**: Use `mv_shipment_lifecycle.handlingUnits`

If package-level analytics become a frequent pattern, consider adding:

```javascript
// Optional: mv_handling_units_daily
{
  _id: { date, carrier, packageType },
  count: 500,
  totalWeightKg: 2500,
  avgWeightKg: 5.0
}
```

Only add this if query patterns justify it.

---

## Summary

### Before: 6 MVs with gaps

- No time-series filtering
- No geographic dimensions
- No OTD metrics
- Separate MVs for related data

### After: 4 MVs covering all P0/P1 reports

| MV | Dimensions | Refresh | Reports Served |
|----|------------|---------|----------------|
| `mv_daily_metrics` | Date × Carrier × Service × Geography × Direction | Hourly | 6 |
| `mv_carrier_performance` | Month × Carrier | Nightly | 4 |
| `mv_shipment_lifecycle` | Per shipment | Event-driven | 3 |
| `mv_realtime_ops` | Current state | 5 min | 2 |

### Key Benefits

1. **Flexible filtering** - Composite `_id` allows any dimension combination
2. **Minimal maintenance** - 4 MVs instead of 10+
3. **Aligned freshness** - Refresh matches user action cycles
4. **Incremental updates** - `$merge` avoids full rebuilds

---

## Next Steps

1. [ ] Review schema with engineering team
2. [ ] Implement `mv_daily_metrics` pipeline with tests
3. [ ] Set up scheduled refresh jobs (Hangfire or similar)
4. [ ] Build sample dashboard queries to validate design
5. [ ] Performance test with production-scale data
6. [ ] Implement change stream handler for `mv_shipment_lifecycle`
7. [ ] Plan carrier event enrichment for OTD metrics
