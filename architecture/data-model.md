# Data Model

MongoDB database schemas and entity relationships for Viya TMS.

> **Detailed Analysis:** See [MongoDB Data Model Research](../research/viya-data-model/2026-01-26-mongodb-data-model.md) for complete schemas, document examples, and relationship diagrams.

## Database Overview

Each service owns its database. **No cross-database queries.**

| Database | Service | Core Entities |
|----------|---------|---------------|
| `shipping` | shipping | shipments, consignments, handling_units, carrier_tracking_events |
| `authorizing` | authorizing | users, tokens, permission_groups, data_groups |
| `rates` | rates | contracts, rate_cards, zones, surcharges |
| `auditor` | auditor | audit_logs |
| `hooks` | hooks | webhooks, scheduled_jobs |
| `printing` | printing | printers, print_jobs |
| `ftp` | ftp | ftp_clients, ftp_servers |

## Core Entities (Shipping)

### Entity Relationships

```
┌─────────────────┐     1:N      ┌─────────────────┐
│ carrier_profiles│◄─────────────│    shipments    │
│   (Reference)   │              │                 │
└─────────────────┘              └────────┬────────┘
                                          │
                    ┌─────────────────────┼─────────────────────┐
                    │ 1:N                 │ 1:N                 │
                    ▼                     ▼                     │
          ┌─────────────────┐   ┌─────────────────┐            │
          │ handling_units  │   │  consignments   │            │
          │  (by ref array) │   │(embeds shipment)│            │
          └─────────────────┘   └────────┬────────┘            │
                                         │                      │
                                         │ 1:N                  │
                                         ▼                      │
                               ┌─────────────────┐              │
                               │carrier_tracking │◄─────────────┘
                               │    _events      │ (polymorphic)
                               └─────────────────┘
```

### Shipment

The primary entity. Represents a shipping request.

```typescript
interface Shipment {
  _id: string;               // UUID
  TenantId: string;
  CreatedOn: Date;
  Data: {
    Status: 'Created' | 'Ordered' | 'Accepted' | 'Declined' | 'Canceled' | 'Executed';
    Reference: string;       // Customer reference
    CarrierReference: string; // FK to carrier_profiles.Reference
    CarrierLabel: string;
    ServiceLevelReference: string;
    
    // Embedded addresses
    Addresses: {
      Sender: Address;
      Receiver: Address;
      Collection?: Address;
    };
    
    // Embedded time windows
    TimeWindows: {
      Pickup: { Planned?: DateRange; Requested?: DateRange };
      Delivery: { Planned?: DateRange; Requested?: DateRange };
    };
    
    // Embedded pricing
    Rate: {
      Price: { TotalRequestedCurrency: { Value: number; CurrencyCode: string } };
      Weights: { BillableWeight: Weight; PhysicalWeight: Weight };
    };
    
    // References to handling_units (NOT embedded)
    HandlingUnitReferences: string[];
    
    Inbound: boolean;
  };
}
```

### Consignment

Groups shipments for carrier booking. Shipment data is embedded (denormalized).

```typescript
interface Consignment {
  _id: string;
  TenantId: string;
  CreatedOn: Date;
  Data: {
    Status: 'Created' | 'Ordered' | 'Accepted' | 'Declined' | 'Canceled';
    CarrierReference: string;
    CarrierBookingReference?: string;  // From carrier (AWB number)
    Addresses: { Sender: Address; Receiver: Address };
    
    // Embedded shipment summaries
    Loaded: Array<{
      ShipmentId: string;
      ShipmentReference: string;
      HandlingUnits: Array<{
        _id: string;
        Reference: string;
        Weight: Weight;
        Length: number;
        Width: number;
        Height: number;
      }>;
    }>;
  };
}
```

### Carrier Tracking Event

Polymorphic reference to Shipment or Consignment.

```typescript
interface CarrierTrackingEvent {
  _id: string;
  CreatedOn: Date;
  Data: {
    Event: {
      EventDateTime: { DateTime: Date };
      EventType: { Code: string; Description: string };
      Reason: { Code: string };
    };
    Mappings: {
      StandardizedCode: {
        Result: {
          Value: { Name: string; Value: { Process: string; State: string } };
        };
      };
    };
    // Links to Shipment AND/OR Consignment
    MatchingEntities: Array<{
      LogisticsUnitType: 'Shipment' | 'Consignment';
      _id: string;
    }>;
  };
}
```

## Design Patterns

### Embedded vs Referenced

| Pattern | Used For | Example |
|---------|----------|---------|
| **Embedded** | Data always accessed together, bounded | Addresses in Shipment |
| **Referenced** | Data accessed independently, unbounded | HandlingUnits from Shipment |
| **Hybrid** | Summary embedded, details referenced | Shipment in Consignment |

**Decision criteria:**
- Embed if: Always queried together, <100 items, rarely updated independently
- Reference if: Large/unbounded, frequently updated independently, shared across documents

### Soft References (String Keys)

Carrier and service level use **string keys**, not ObjectIds:

```javascript
// Good: Readable, portable
{ CarrierReference: "DHLPX" }

// Avoided: Opaque
{ CarrierId: ObjectId("...") }
```

This allows lookups across services without direct DB access.

### Multi-Tenancy

Every document MUST include `TenantId` at root:

```javascript
{
  _id: "...",
  TenantId: "tenant_abc",  // REQUIRED
  // ...
}
```

All queries MUST filter by TenantId. Repositories enforce this.

### Schema Versioning

When changing document structure:

1. Add new fields as nullable
2. Mark deprecated fields with `[Obsolete("vX")]`
3. Increment schema version
4. Run migration job after deployment

See [Service versioning and Migrations](../docs-external/internal/Viya/Service%20versioning%20and%20Migrations.md) for full process.

## Indexes

### Shipping Database

```javascript
// Primary queries
db.shipments.createIndex({ TenantId: 1, _id: 1 })
db.shipments.createIndex({ TenantId: 1, "Data.Reference": 1 })
db.shipments.createIndex({ TenantId: 1, "Data.Status": 1, CreatedOn: -1 })

// Carrier reports
db.shipments.createIndex({ TenantId: 1, "Data.CarrierReference": 1, CreatedOn: -1 })

// Geographic queries
db.shipments.createIndex({ 
  TenantId: 1,
  "Data.Addresses.Sender.CountryCode": 1,
  "Data.Addresses.Receiver.CountryCode": 1 
})

// Tracking lookup
db.carrier_tracking_events.createIndex({ 
  "Data.MatchingEntities._id": 1,
  CreatedOn: -1 
})
```

## Materialized Views

Pre-aggregated data for reporting. See [Reporting Materialized Views](../research/viya-reporting/2026-01-20-reporting-materialized-views.md).

| Collection | Purpose | Refresh |
|------------|---------|---------|
| `mv_shipments_daily` | Daily aggregations | Hourly |
| `mv_carrier_performance` | Carrier scorecards | Daily |
| `analytics_global_summary` | Total counts | Real-time |

## Cross-Service Data Access

Services **never** directly query another service's database.

| Service A needs | From Service B | Solution |
|-----------------|----------------|----------|
| User permissions | authorizing | HTTP API call |
| Shipment data | shipping | HTTP API call |
| Contract rates | rates | HTTP API call |
| Carrier config | shipping | String reference lookup |

Events (SNS/SQS) handle eventual consistency for derived data.

## Common Queries

### Get shipment with handling units
```javascript
// Step 1: Get shipment
const shipment = db.shipments.findOne({ _id: shipmentId, TenantId: tenantId });

// Step 2: Get handling units (separate query)
const handlingUnits = db.handling_units.find({
  _id: { $in: shipment.Data.HandlingUnitReferences }
});
```

### Get shipment with tracking
```javascript
const events = db.carrier_tracking_events.find({
  "Data.MatchingEntities": {
    $elemMatch: { LogisticsUnitType: "Shipment", _id: shipmentId }
  }
}).sort({ CreatedOn: -1 });
```

### Get daily shipment count by carrier
```javascript
db.shipments.aggregate([
  { $match: { TenantId: tenantId, CreatedOn: { $gte: startDate } } },
  { $group: {
    _id: {
      date: { $dateToString: { format: "%Y-%m-%d", date: "$CreatedOn" } },
      carrier: "$Data.CarrierReference"
    },
    count: { $sum: 1 }
  }}
]);
```

## Related Documentation

- [MongoDB Data Model Research](../research/viya-data-model/2026-01-26-mongodb-data-model.md) - Full schemas and diagrams
- [Reporting MVs](../research/viya-reporting/2026-01-20-reporting-materialized-views.md) - Aggregation pipelines
