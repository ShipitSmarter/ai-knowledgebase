---
topic: TMS Reporting Analysis & Materialized Views for Viya
date: 2026-01-20
project: viya-reporting
sources_count: 4
status: draft
tags: [mongodb, reporting, materialized-views, analytics, tms]
---

# TMS Reporting Analysis & Materialized Views for Viya

## Summary

This document analyzes the Viya TMS MongoDB database structure to design materialized views that support common TMS reporting use cases. We examined the existing schema, identified key entities and relationships, and mapped industry-standard TMS KPIs to the available data.

Key findings:
1. **Some MVs already exist** - `mv_consignments_flat`, `analytics_global_summary`, `analytics_carrier_summary`, `analytics_carrier_daily`
2. **Core data model** centers on shipments → consignments → carrier_tracking_events
3. **Rich address data** enables geographic analytics (origin/destination country, city)
4. **Rate/cost data** is present but often zero in dev data
5. **Time windows** exist for pickup/delivery enabling SLA analysis

## Current Database Structure

### Core Collections

| Collection | Count (dev) | Purpose |
|------------|-------------|---------|
| `shipments` | 178 | Individual shipment requests with addresses, rates, carrier selection |
| `consignments` | 1,261 | Consolidated shipments for carrier booking |
| `carrier_tracking_events` | 16 | Status updates from carriers |
| `events` | 233 | Internal event sourcing log |
| `handling_units` | 200 | Packages/parcels within shipments |
| `carrier_profiles` | 16 | Carrier configuration |
| `invoices` | 0 | Invoice data (empty in dev) |
| `pickup_requests` | 14 | Scheduled pickups |

### Existing Materialized Views

| Collection | Count | Content |
|------------|-------|---------|
| `mv_consignments_flat` | 1,217 | Flattened consignment data (minimal fields) |
| `mv_consignment_event_stats` | 1,217 | Event statistics per consignment |
| `analytics_global_summary` | 1 | Global totals and status counts |
| `analytics_carrier_summary` | 3 | Per-carrier totals |
| `analytics_carrier_daily` | 11 | Daily breakdown by carrier |
| `analytics_event_codes` | 5 | Event code frequency |

### Key Schema Elements

**Shipment Document** (simplified):
```javascript
{
  _id: "uuid",
  CreatedOn: ISODate,
  Data: {
    Status: "Created|Ordered|Confirmed|Delivered",
    Reference: "REF-00001",
    CarrierReference: "DHLPX",
    CarrierLabel: "DHL Parcel",
    ServiceLevelReference: "DFY-B2C",
    Addresses: {
      Sender: { CompanyName, City, PostCode, CountryCode, ... },
      Receiver: { CompanyName, City, PostCode, CountryCode, ... },
      Collection: { ... }
    },
    TimeWindows: {
      Pickup: { Planned: { Start, End }, Requested: { Start, End } },
      Delivery: { Planned: { Start, End }, Requested: { Start, End } }
    },
    Rate: {
      Price: {
        TotalRequestedCurrency: { Value, CurrencyCode }
      },
      Weights: {
        BillableWeight: { Value, Unit },
        PhysicalWeight: { Value, Unit }
      }
    },
    HandlingUnitReferences: ["uuid", ...],
    Inbound: false
  }
}
```

**Consignment Document** (simplified):
```javascript
{
  _id: "uuid",
  CreatedOn: ISODate,
  Data: {
    Status: "Created|Ordered|Confirmed|Delivered",
    CarrierReference: "mail-carrier",
    Addresses: { Sender, Receiver, Collection },
    Loaded: [
      {
        ShipmentId: "uuid",
        ShipmentReference: "REF-00027",
        HandlingUnits: [{ _id, Reference, Weight, Length, Width, Height }]
      }
    ]
  }
}
```

**Carrier Tracking Event** (simplified):
```javascript
{
  _id: "uuid",
  CreatedOn: ISODate,
  Data: {
    Event: {
      EventDateTime: { DateTime: ISODate },
      EventType: { Code: "Booking", Description: "..." },
      Reason: { Code: "Completed" }
    },
    Mappings: {
      StandardizedCode: {
        Result: {
          Value: { Name: "BookingRequested", Value: { Process, State, Description } }
        }
      }
    },
    MatchingEntities: [{ LogisticsUnitType: "Shipment", _id: "uuid" }]
  }
}
```

## Industry TMS KPIs Mapped to Viya Data

### Available Now (data exists)

| KPI | Source | Calculation |
|-----|--------|-------------|
| **Shipment Volume** | shipments | Count by time period |
| **Status Distribution** | shipments.Data.Status | Group by status |
| **Carrier Mix** | shipments.Data.CarrierReference | Group by carrier |
| **Geographic Distribution** | shipments.Data.Addresses.Receiver.CountryCode | Group by destination |
| **Service Level Mix** | shipments.Data.ServiceLevelReference | Group by service |
| **Inbound vs Outbound** | shipments.Data.Inbound | Split by direction |
| **Weight Distribution** | shipments.Data.Rate.Weights.BillableWeight | Histogram/avg |

### Partially Available (needs enrichment)

| KPI | Source | Gap |
|-----|--------|-----|
| **On-Time Delivery %** | TimeWindows.Delivery.Planned vs actual | Need delivery timestamp from carrier events |
| **Transit Time** | CreatedOn to Delivered event | Need to join with carrier_tracking_events |
| **Cost Per Shipment** | Rate.Price.TotalRequestedCurrency | Often zero in dev; need real rate data |

### Not Currently Available

| KPI | Required Data |
|-----|---------------|
| **Claims Rate** | Need claims/damage tracking |
| **Tender Acceptance Rate** | Need carrier tender/rejection tracking |
| **Invoice Accuracy** | Need invoice reconciliation data |

## Recommended Materialized Views

### 1. Daily Shipment Summary (`mv_shipments_daily`)

**Purpose**: Enable daily/weekly/monthly volume and status reporting

```javascript
{
  _id: {
    date: "2026-01-20",           // YYYY-MM-DD
    carrierReference: "DHLPX",
    serviceLevelReference: "DFY-B2C",
    originCountry: "NL",
    destinationCountry: "DE",
    inbound: false
  },
  // Counts
  shipmentCount: 150,
  confirmedCount: 120,
  deliveredCount: 100,
  exceptionCount: 5,
  
  // Weights
  totalBillableWeight: 1500.5,       // kg
  totalPhysicalWeight: 1400.0,
  avgWeightPerShipment: 10.0,
  
  // Packages
  totalHandlingUnits: 200,
  avgHandlingUnitsPerShipment: 1.33,
  
  // Costs (when available)
  totalCost: 2500.00,
  currency: "EUR",
  avgCostPerShipment: 16.67,
  
  // Metadata
  updatedAt: ISODate("2026-01-20T23:59:00Z")
}
```

**Aggregation Pipeline**:
```javascript
db.shipments.aggregate([
  {
    $group: {
      _id: {
        date: { $dateToString: { format: "%Y-%m-%d", date: "$CreatedOn" } },
        carrierReference: "$Data.CarrierReference",
        serviceLevelReference: "$Data.ServiceLevelReference",
        originCountry: "$Data.Addresses.Sender.CountryCode",
        destinationCountry: "$Data.Addresses.Receiver.CountryCode",
        inbound: "$Data.Inbound"
      },
      shipmentCount: { $sum: 1 },
      confirmedCount: { $sum: { $cond: [{ $eq: ["$Data.Status", "Confirmed"] }, 1, 0] } },
      deliveredCount: { $sum: { $cond: [{ $eq: ["$Data.Status", "Delivered"] }, 1, 0] } },
      totalBillableWeight: { $sum: { $toDouble: "$Data.Rate.Weights.BillableWeight.Value" } },
      totalCost: { $sum: { $toDouble: "$Data.Rate.Price.TotalRequestedCurrency.Value" } },
      currency: { $first: "$Data.Rate.Price.TotalRequestedCurrency.CurrencyCode" },
      totalHandlingUnits: { $sum: { $size: { $ifNull: ["$Data.HandlingUnitReferences", []] } } }
    }
  },
  {
    $addFields: {
      avgWeightPerShipment: { $divide: ["$totalBillableWeight", "$shipmentCount"] },
      avgCostPerShipment: { $divide: ["$totalCost", "$shipmentCount"] },
      avgHandlingUnitsPerShipment: { $divide: ["$totalHandlingUnits", "$shipmentCount"] },
      updatedAt: new Date()
    }
  },
  { $merge: { into: "mv_shipments_daily", whenMatched: "replace", whenNotMatched: "insert" } }
])
```

### 2. Carrier Performance Summary (`mv_carrier_performance`)

**Purpose**: Carrier scorecard and comparison

```javascript
{
  _id: {
    period: "2026-01",              // YYYY-MM for monthly rollup
    carrierReference: "DHLPX"
  },
  carrierLabel: "DHL Parcel",
  
  // Volume
  totalShipments: 1500,
  totalConsignments: 1200,
  
  // Status breakdown
  statusCounts: {
    Created: 50,
    Ordered: 100,
    Confirmed: 1200,
    Delivered: 150
  },
  
  // Delivery performance (when tracking available)
  deliveredOnTime: 140,
  deliveredLate: 10,
  onTimeDeliveryRate: 0.933,        // 93.3%
  
  // Transit time (days)
  avgTransitDays: 2.3,
  minTransitDays: 1,
  maxTransitDays: 5,
  
  // Weight
  totalWeight: 15000.0,
  avgWeightPerShipment: 10.0,
  
  // Cost
  totalCost: 25000.00,
  avgCostPerShipment: 16.67,
  
  updatedAt: ISODate
}
```

### 3. Geographic Lane Analysis (`mv_lanes_summary`)

**Purpose**: Origin-destination analysis for rate negotiation and capacity planning

```javascript
{
  _id: {
    period: "2026-01",
    originCountry: "NL",
    originCity: "Amsterdam",
    destinationCountry: "DE",
    destinationCity: "Berlin"
  },
  
  // Volume
  shipmentCount: 500,
  totalWeight: 5000.0,
  
  // Carriers used
  carrierBreakdown: {
    "DHLPX": { count: 300, avgCost: 15.00 },
    "UPS": { count: 200, avgCost: 18.00 }
  },
  
  // Cost
  avgCostPerShipment: 16.20,
  totalCost: 8100.00,
  
  // Performance
  avgTransitDays: 2.1,
  
  updatedAt: ISODate
}
```

### 4. Shipment Event Timeline (`mv_shipment_events`)

**Purpose**: Track full lifecycle of each shipment for SLA monitoring

```javascript
{
  _id: "shipment-uuid",
  reference: "REF-00001",
  carrierReference: "DHLPX",
  
  // Timestamps
  createdAt: ISODate,
  orderedAt: ISODate,
  confirmedAt: ISODate,
  pickedUpAt: ISODate,
  inTransitAt: ISODate,
  deliveredAt: ISODate,
  
  // Calculated metrics
  orderToConfirmHours: 2.5,
  confirmToPickupHours: 4.0,
  pickupToDeliveryHours: 48.0,
  totalTransitHours: 54.5,
  
  // SLA compliance
  requestedDeliveryDate: ISODate,
  actualDeliveryDate: ISODate,
  deliveredOnTime: true,
  deliveryVarianceDays: -1,          // Negative = early
  
  // Current status
  currentStatus: "Delivered",
  lastEventAt: ISODate,
  
  updatedAt: ISODate
}
```

### 5. Real-time Operations Dashboard (`mv_operations_current`)

**Purpose**: Live dashboard for warehouse/operations teams

```javascript
{
  _id: "current",
  
  // Today's snapshot
  todayShipments: 45,
  todayConfirmed: 40,
  todayDelivered: 12,
  todayExceptions: 2,
  
  // Pending work
  pendingConfirmation: 5,
  pendingPickup: 25,
  inTransit: 180,
  
  // Exceptions requiring attention
  exceptions: [
    { shipmentId: "...", reference: "REF-123", type: "AddressIssue", age: "2h" }
  ],
  
  // By carrier (today)
  carrierToday: {
    "DHLPX": { shipped: 20, delivered: 8 },
    "POSTNL": { shipped: 15, delivered: 4 }
  },
  
  updatedAt: ISODate
}
```

## Implementation Recommendations

### Phase 1: Core Daily Aggregations
1. Implement `mv_shipments_daily` - foundational for all volume reporting
2. Enhance existing `analytics_carrier_daily` with more metrics
3. Add indexes on `CreatedOn`, `Data.Status`, `Data.CarrierReference`

### Phase 2: Performance Tracking
1. Implement `mv_shipment_events` to track lifecycle
2. Join carrier_tracking_events to get actual delivery times
3. Calculate on-time delivery rates

### Phase 3: Advanced Analytics
1. Implement `mv_lanes_summary` for geographic analysis
2. Add cost analytics once rate data is populated
3. Implement `mv_operations_current` for real-time dashboard

### Refresh Strategy

| MV | Refresh Frequency | Trigger |
|----|-------------------|---------|
| `mv_shipments_daily` | Hourly (batch) | Scheduled job |
| `mv_carrier_performance` | Daily (batch) | End of day |
| `mv_lanes_summary` | Daily (batch) | End of day |
| `mv_shipment_events` | On event | Change stream |
| `mv_operations_current` | 5 minutes | Scheduled job |

### Indexing Recommendations

```javascript
// For time-based queries
db.shipments.createIndex({ "CreatedOn": -1 })
db.consignments.createIndex({ "CreatedOn": -1 })

// For carrier reports
db.shipments.createIndex({ "Data.CarrierReference": 1, "CreatedOn": -1 })

// For status filtering
db.shipments.createIndex({ "Data.Status": 1, "CreatedOn": -1 })

// For geographic queries
db.shipments.createIndex({ 
  "Data.Addresses.Sender.CountryCode": 1, 
  "Data.Addresses.Receiver.CountryCode": 1 
})

// Compound for dashboard queries
db.shipments.createIndex({ 
  "Data.Status": 1, 
  "Data.CarrierReference": 1, 
  "CreatedOn": -1 
})
```

## Sample Queries for Common Reports

### Daily Volume Report
```javascript
db.mv_shipments_daily.aggregate([
  { $match: { "_id.date": { $gte: "2026-01-01", $lte: "2026-01-31" } } },
  {
    $group: {
      _id: "$_id.date",
      totalShipments: { $sum: "$shipmentCount" },
      totalWeight: { $sum: "$totalBillableWeight" },
      totalCost: { $sum: "$totalCost" }
    }
  },
  { $sort: { "_id": 1 } }
])
```

### Carrier Comparison
```javascript
db.mv_shipments_daily.aggregate([
  { $match: { "_id.date": { $gte: "2026-01-01" } } },
  {
    $group: {
      _id: "$_id.carrierReference",
      totalShipments: { $sum: "$shipmentCount" },
      avgCost: { $avg: "$avgCostPerShipment" },
      avgWeight: { $avg: "$avgWeightPerShipment" }
    }
  },
  { $sort: { totalShipments: -1 } }
])
```

### Top Destination Countries
```javascript
db.mv_shipments_daily.aggregate([
  { $match: { "_id.date": { $gte: "2026-01-01" } } },
  {
    $group: {
      _id: "$_id.destinationCountry",
      totalShipments: { $sum: "$shipmentCount" },
      totalWeight: { $sum: "$totalBillableWeight" }
    }
  },
  { $sort: { totalShipments: -1 } },
  { $limit: 10 }
])
```

## Sources

| # | Source | Contribution |
|---|--------|--------------|
| 1 | Viya MongoDB shipping database | Schema analysis, existing MVs |
| 2 | TMS industry research | KPI definitions, reporting best practices |
| 3 | MongoDB aggregation docs | Pipeline design patterns |
| 4 | TMS vendor marketing/documentation | Competitor feature analysis |

---

## Appendix: TMS Competitor Reporting Analysis

### Competitor Overview

| Vendor | Key Reporting Features | Differentiators |
|--------|------------------------|-----------------|
| **Oracle TMS** | Transportation Intelligence, KPI dashboards, ML-powered ETA prediction, carrier scorecards | 18x Gartner Leader; ML models that self-improve; Digital Assistant for natural language queries |
| **project44** | Real-time visibility, carrier performance, port congestion intel, emissions monitoring | AI Disruption Navigator; 90-day trend dashboards; 600+ exception categories |
| **Flexport** | 90-day trend dashboards, container utilization, landed cost analytics, supplier performance | Modern UI; Strong emphasis on trend visualization |
| **Blue Yonder** | Control Tower dashboards, strategic modeling, carrier scorecards, sustainability | AI/cognitive solutions; End-to-end supply chain integration |
| **e2open** | Transportation Intelligence, carrier scorecards, control tower, ESG reporting | Carrier Reporting as a Service; Multi-modal analytics |
| **Descartes** | Shipment Portal analytics, multimodal tracking, fleet AI | Rich analytics for trend identification; Global logistics network |
| **SAP TM** | Integrated with SAP Analytics Cloud, freight cost analytics | Deep ERP integration; Enterprise-wide visibility |
| **Transporeon** | Visibility Hub, carrier benchmarks, emissions tracking | Strong European presence; Carrier collaboration focus |
| **Shipwell** | Real-time dashboards, spend analytics, carrier performance | SMB-focused; Modern UI |

### "Must-Have" Reports (Industry Standard)

Every major TMS vendor offers these core reports - these are **table stakes**:

| Report | Description | Viya Status |
|--------|-------------|-------------|
| **Shipment Tracking Dashboard** | Real-time status of all shipments in transit | ✅ Can build from existing data |
| **On-Time Delivery (OTD)** | % of shipments delivered by promised date | ⚠️ Needs carrier event enrichment |
| **Carrier Performance Scorecards** | Rating carriers by OTD, claims, responsiveness | ⚠️ Partial - needs claims data |
| **Freight Cost/Spend Analysis** | Total spend by lane, carrier, mode, customer | ⚠️ Needs rate data populated |
| **Exception/Alert Management** | Late shipments, delays, at-risk deliveries | ✅ Can build from status + time windows |
| **Transit Time Analysis** | Actual vs. planned transit times | ⚠️ Needs delivery timestamps |
| **Shipment Volume Reports** | Trends by period, lane, mode | ✅ Can build now |
| **Invoice Reconciliation** | Freight audit and payment tracking | ❌ No invoice data yet |

### Differentiating/Advanced Reports

These reports set leading TMS vendors apart:

| Category | Capability | Vendors | Viya Opportunity |
|----------|------------|---------|------------------|
| **Predictive Analytics** | ML-based ETA prediction, delay forecasting | Oracle, project44, Blue Yonder | Future - needs ML pipeline |
| **Sustainability** | Scope 3 emissions, carbon per shipment | project44, Flexport, Blue Yonder | High potential - differentiator |
| **AI Exception Handling** | Auto-classify and prioritize exceptions | project44, Oracle | Future - needs event classification |
| **Network Optimization** | What-if scenario modeling | Oracle, Blue Yonder | Complex - future phase |
| **Rate Benchmarking** | Market rate intelligence | project44, e2open | Needs rate data sources |
| **Port Intelligence** | Congestion forecasts, D&D optimization | project44, Oracle | N/A for parcel-focused |
| **Customer Portals** | Branded tracking for end customers | Flexport, project44, Descartes | ✅ Good opportunity |
| **Container Utilization** | 3D load optimization | Flexport, Blue Yonder | Partial - have handling unit data |

### Modern Trends in TMS Reporting

**1. Real-Time Visibility Dashboards**
- All major vendors emphasize live tracking across modes
- Exception-based workflows showing only what needs attention
- project44: "600+ exceptions organized by category and priority"

**2. Predictive Analytics / AI**
- Oracle: "ML models become more accurate in self-improving process"
- project44: AI Disruption Navigator predicts supply chain impacts
- Blue Yonder: "Cognitive Solutions" for autonomous decisions

**3. Carbon/Sustainability Reporting** (Emerging Standard)
- Becoming table stakes - all major vendors now offer emissions tracking
- Flexport: Open Emissions Calculator
- project44: Scope 3 measurement
- **Viya opportunity**: Add emissions estimates based on carrier/mode/distance

**4. Self-Service BI / Conversational Analytics**
- Oracle Digital Assistant: Natural language queries
- project44 "MO": AI assistant for insights
- Trend toward democratizing analytics access

**5. Control Tower / Command Center**
- Unified view across planning, execution, visibility
- Blue Yonder: Supply Chain Command Center
- project44: Decision Intelligence Platform

### Common Dashboard UI Patterns

Based on competitor marketing materials:

| Pattern | Description | Example |
|---------|-------------|---------|
| **Exception-first** | Prioritize at-risk shipments at top | "5 shipments at risk of delay" |
| **Map-based views** | Geographic visualization of in-transit inventory | Real-time shipment map |
| **90-day trend charts** | Rolling metrics with clear trends | Flexport prominently features this |
| **Scorecard layouts** | Carrier/supplier performance grades (A/B/C or %) | Carrier OTD: 94% ▲ |
| **KPI tiles** | Key metrics at a glance | 📦 1,234 shipments · ⏱️ 96% OTD · 💰 €12.50 avg |
| **Drill-down** | From aggregate to individual shipment | Click carrier → see shipments |

### Recommendations for Viya

**Phase 1 - Match Table Stakes:**
1. Shipment volume dashboard with trends
2. Carrier performance summary
3. Exception/alert view
4. Geographic distribution

**Phase 2 - Build Differentiators:**
1. **Sustainability reporting** - Estimate CO2 per shipment (high value, competitors pushing this)
2. **Customer-facing portal** - Branded tracking experience
3. **90-day trend dashboards** - Flexport-style visualization

**Phase 3 - Advanced:**
1. Predictive ETA (requires ML investment)
2. Rate benchmarking (requires market data)
3. Self-service BI/natural language queries

---

## Next Steps

1. [ ] Review with team - validate KPI priorities
2. [ ] Implement Phase 1 MVs with tests
3. [ ] Create refresh jobs (background service or scheduled)
4. [ ] Build sample dashboard to validate MV design
5. [ ] Performance test with production-scale data
6. [ ] Research emissions calculation methodology for sustainability reports
