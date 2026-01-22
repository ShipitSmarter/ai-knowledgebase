# Materialized View Implementation Plan for Viya TMS

**Date:** 2026-01-21  
**Status:** Draft (Updated after architect review)  
**Based on:** CQRS MongoDB Research + Viya Reporting Research  
**Architect Review:** [2026-01-21-mv-implementation-plan.md](../architect-reviews/2026-01-21-mv-implementation-plan.md)

## Executive Summary

This plan consolidates findings from two research projects to define a unified materialized view (MV) architecture for Viya TMS that serves both **reporting/analytics** and **application-embedded queries** (list views, dashboards, lookups).

### Key Architecture Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| CQRS Level | Simplified (Level 1) | Same database, logical separation - 80% benefit, 20% complexity |
| Command/Query Dispatch | MediatR | De facto .NET standard, clean separation |
| Event Propagation | MongoDB Change Streams | Sub-100ms latency for same-database MV sync (see Architecture Note below) |
| MV Refresh | Hybrid (event + scheduled) | Match freshness to user action cycles |
| Multi-tenant | Composite `_id` with `organizationId` | Efficient per-tenant filtering |
| Lookup Data | In-memory cache | Simpler than MVs for low-cardinality, low-churn data |

### Architecture Note: Change Streams vs SNS/SQS

This plan uses MongoDB Change Streams for MV synchronization, which introduces a parallel event mechanism alongside the existing SNS/SQS pattern (ADR-003). The distinction:

| Mechanism | Use Case | Latency | Scope |
|-----------|----------|---------|-------|
| **SNS/SQS** | Cross-service events, external subscribers, audit trail | ~100-200ms | Platform-wide |
| **Change Streams** | Same-database MV sync, real-time UI updates | <100ms | Within shipping service |

**Why Change Streams for MVs:**
1. MVs are internal to the shipping service (not cross-service)
2. List views require sub-100ms freshness for good UX
3. Change streams provide exactly-once ordering within a collection
4. No additional infrastructure (SNS topics/SQS queues) needed

**Prerequisite:** Verify Atlas oplog retention >= 24 hours (to survive handler restarts).

> **ADR Required:** Create ADR-00X to formally document this decision before implementation.

### MV Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           VIYA TMS MV ARCHITECTURE                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  REPORTING MVs (4)                      APPLICATION MVs (3)                 │
│  ─────────────────                      ───────────────────                 │
│                                                                             │
│  ┌─────────────────────┐               ┌─────────────────────┐              │
│  │ mv_daily_metrics    │               │ mv_shipment_list    │              │
│  │ Hourly refresh      │               │ Change stream       │              │
│  │ 6 report types      │               │ List views + SLA    │              │
│  └─────────────────────┘               └─────────────────────┘              │
│                                                                             │
│  ┌─────────────────────┐               ┌─────────────────────┐              │
│  │ mv_carrier_perf     │               │ mv_consignment_list │              │
│  │ Nightly refresh     │               │ Change stream       │              │
│  │ 4 report types      │               │ List + hierarchy    │              │
│  └─────────────────────┘               └─────────────────────┘              │
│                                                                             │
│  ┌─────────────────────┐               ┌─────────────────────┐              │
│  │ mv_realtime_ops     │               │ mv_dashboard_counters│             │
│  │ 5-min refresh       │               │ 5-min scheduled     │              │
│  │ Dashboard           │               │ App dashboard       │              │
│  └─────────────────────┘               └─────────────────────┘              │
│                                                                             │
│  IN-MEMORY CACHE (not MVs)                                                  │
│  ─────────────────────────                                                  │
│  ┌─────────────────────┐  ┌─────────────────────┐                           │
│  │ CustomerLookup      │  │ CarrierLookup       │                           │
│  │ IMemoryCache        │  │ IMemoryCache        │                           │
│  │ 15-min TTL          │  │ 15-min TTL          │                           │
│  └─────────────────────┘  └─────────────────────┘                           │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Part 1: Consolidated MV Inventory

### Complete MV List (7 Collections)

| MV Name | Category | Grain | Refresh | Purpose |
|---------|----------|-------|---------|---------|
| `mv_daily_metrics` | Reporting | Date×Carrier×Service×Geo | Hourly | Volume, cost, geographic reports |
| `mv_carrier_performance` | Reporting | Month×Carrier | Nightly | OTD, scorecards, transit time |
| `mv_realtime_ops` | Reporting | Single doc | 5-min | Operations dashboard |
| `mv_shipment_list` | Application | Per shipment | Change stream | Shipment list view + SLA tracking |
| `mv_consignment_list` | Application | Per consignment | Change stream | Consignment list + parent context |
| `mv_dashboard_counters` | Application | Per org | 5-min | App dashboard widgets |

> **Removed from original plan:** `mv_shipment_lifecycle` (merged into `mv_shipment_list`), `mv_customer_lookup`, `mv_carrier_lookup` (replaced with in-memory cache)

### In-Memory Cache (Not MVs)

| Cache | Source | TTL | Purpose |
|-------|--------|-----|---------|
| `CustomerLookupCache` | `customers` collection | 15 min | Customer autocomplete |
| `CarrierLookupCache` | `carriers` collection | 15 min | Carrier dropdown |

**Rationale:** Low cardinality (~100-1000 customers, ~20-50 carriers per org) and low change frequency make MVs overkill. Simple `IMemoryCache` is sufficient.

### Existing MVs to Deprecate

| Current MV | Replacement | Migration Phase |
|------------|-------------|-----------------|
| `analytics_global_summary` | `mv_realtime_ops` | Phase 1 |
| `analytics_carrier_summary` | `mv_daily_metrics` | Phase 1 |
| `analytics_carrier_daily` | `mv_daily_metrics` | Phase 1 |
| `mv_consignments_flat` | Keep (different purpose) | - |
| `mv_consignment_event_stats` | `mv_shipment_list` (SLA fields) | Phase 2 |

---

## Part 2: Schema Definitions

### 2.1 Reporting MVs

#### mv_daily_metrics
```javascript
{
  _id: {
    organizationId: ObjectId,           // Multi-tenant isolation
    date: "2026-01-21",                 // YYYY-MM-DD
    carrier: "DHLPX",
    service: "DFY-B2C",
    originCountry: "NL",
    destinationCountry: "DE",
    inbound: false
  },
  _schemaVersion: 1,                    // For blue/green MV migrations
  shipments: { total: 150, byStatus: { Created: 5, Confirmed: 120, Delivered: 15 } },
  consignments: { total: 140, byStatus: { ... } },
  handlingUnits: { total: 200, avgPerShipment: 1.33, byType: { Parcel: 180, Pallet: 20 } },
  weights: { billableKg: 1500.5, physicalKg: 1400.0, avgPerShipment: 10.0 },
  costs: { total: 2500.00, currency: "EUR", avgPerShipment: 16.67 },
  updatedAt: ISODate
}
```

#### mv_carrier_performance
```javascript
{
  _id: { organizationId: ObjectId, month: "2026-01", carrier: "DHLPX" },
  _schemaVersion: 1,
  carrierLabel: "DHL Parcel",
  volume: { shipments: 1500, consignments: 1200, weightKg: 15000.0 },
  statusCounts: { Created: 50, Confirmed: 1200, Delivered: 150 },
  otd: { deliveredOnTime: 140, deliveredLate: 10, rate: 0.933, totalDelivered: 150 },
  transit: { avgDays: 2.3, minDays: 1, maxDays: 5, p95Days: 4 },
  costs: { total: 25000.00, currency: "EUR", avgPerShipment: 16.67 },
  exceptions: { total: 15, byType: { AddressIssue: 5, DeliveryFailed: 8 } },
  updatedAt: ISODate
}
```

#### mv_realtime_ops
```javascript
{
  _id: { organizationId: ObjectId, key: "current" },
  _schemaVersion: 1,
  today: { shipped: 45, confirmed: 40, delivered: 12, exceptions: 2 },
  pending: { awaitingConfirmation: 5, awaitingPickup: 25, inTransit: 180 },
  byCarrier: { "DHLPX": { shipped: 20, delivered: 8 }, "POSTNL": { shipped: 15, delivered: 4 } },
  exceptions: [{ shipmentId: "uuid", reference: "REF-123", type: "AddressIssue", ageMinutes: 120 }],
  pickupsToday: { scheduled: 5, completed: 2, upcoming: [...] },
  updatedAt: ISODate
}
```

### 2.2 Application MVs

#### mv_shipment_list (merged with lifecycle tracking)
```javascript
{
  _id: { organizationId: ObjectId, shipmentId: "uuid" },
  _schemaVersion: 1,
  
  // List view fields
  reference: "SHP-2026-001",
  status: "InTransit",
  statusOrder: 4,                       // Numeric for sorting
  carrier: "DHLPX",
  carrierLabel: "DHL Parcel",
  customer: { name: "Acme Corp", code: "ACME" },
  originCountry: "NL",
  originCity: "Amsterdam",
  destinationCountry: "DE",
  destinationCity: "Berlin",
  createdAt: ISODate,
  requestedDelivery: ISODate,
  consignmentCount: 2,
  handlingUnitCount: 5,
  lastEvent: { code: "InTransit", timestamp: ISODate },
  sortKey: "2026-01-21T10:30:00Z_SHP-2026-001",  // Cursor pagination
  
  // SLA/lifecycle fields (merged from mv_shipment_lifecycle)
  timestamps: { 
    created: ISODate, 
    ordered: ISODate, 
    confirmed: ISODate, 
    delivered: ISODate 
  },
  sla: { 
    requestedDelivery: ISODate, 
    actualDelivery: ISODate, 
    onTime: true, 
    varianceHours: -6.5 
  },
  durations: { 
    orderToConfirm: 2.0, 
    pickupToDelivery: 45.0, 
    totalTransit: 49.5 
  },
  cost: { total: 18.50, currency: "EUR" },
  exceptions: [],
  
  updatedAt: ISODate
}
```

#### mv_consignment_list
```javascript
{
  _id: { organizationId: ObjectId, consignmentId: "uuid" },
  _schemaVersion: 1,
  reference: "CON-001",
  status: "Confirmed",
  carrier: "DHLPX",
  carrierLabel: "DHL Parcel",
  trackingNumber: "JVGL1234567890",
  shipment: { id: "uuid", reference: "SHP-001", status: "Confirmed" },  // Parent context
  handlingUnits: { count: 3, totalWeightKg: 45.5, types: ["Parcel", "Pallet"] },
  origin: { country: "NL", city: "Amsterdam" },
  destination: { country: "DE", city: "Berlin" },
  createdAt: ISODate,
  sortKey: "2026-01-21T10:30:00Z_CON-001",
  updatedAt: ISODate
}
```

#### mv_dashboard_counters
```javascript
{
  _id: { organizationId: ObjectId },
  _schemaVersion: 1,
  today: { date: "2026-01-21", created: 45, confirmed: 40, delivered: 12, exceptions: 2 },
  byStatus: { Created: 5, Ordered: 10, Confirmed: 120, InTransit: 85, Delivered: 500 },
  pending: { awaitingConfirmation: 15, awaitingPickup: 25, exceptionsUnresolved: 4 },
  byCarrier: { "DHLPX": { total: 250, inTransit: 45 }, "POSTNL": { total: 180, inTransit: 30 } },
  dailyTrend: [{ date: "2026-01-15", created: 40, delivered: 35 }, ...],
  updatedAt: ISODate
}
```

### 2.3 In-Memory Cache Services

```csharp
// Customer lookup with IMemoryCache
public class CustomerLookupService
{
    private readonly IMemoryCache _cache;
    private readonly IMongoCollection<Customer> _customers;

    public async Task<List<CustomerLookupDto>> SearchAsync(
        string organizationId, 
        string searchTerm, 
        CancellationToken ct)
    {
        var cacheKey = $"customers:{organizationId}";
        
        var customers = await _cache.GetOrCreateAsync(cacheKey, async entry =>
        {
            entry.AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(15);
            
            return await _customers
                .Find(c => c.OrganizationId == organizationId && c.Active)
                .Project(c => new CustomerLookupDto 
                { 
                    Id = c.Id, 
                    Label = c.Name, 
                    Code = c.Code,
                    SearchText = $"{c.Name} {c.Code}".ToLowerInvariant()
                })
                .ToListAsync(ct);
        });
        
        // Client-side filter (cache contains all org customers)
        var searchLower = searchTerm.ToLowerInvariant();
        return customers
            .Where(c => c.SearchText.Contains(searchLower))
            .Take(20)
            .ToList();
    }
}

// Carrier lookup with IMemoryCache
public class CarrierLookupService
{
    private readonly IMemoryCache _cache;
    private readonly IMongoCollection<Carrier> _carriers;

    public async Task<List<CarrierLookupDto>> GetActiveCarriersAsync(
        string organizationId, 
        CancellationToken ct)
    {
        return await _cache.GetOrCreateAsync($"carriers:{organizationId}", async entry =>
        {
            entry.AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(15);
            
            return await _carriers
                .Find(c => c.OrganizationId == organizationId && c.Active)
                .Project(c => new CarrierLookupDto 
                { 
                    Code = c.Code, 
                    Label = c.Name, 
                    Services = c.Services 
                })
                .ToListAsync(ct);
        });
    }
}
```

---

## Part 3: Index Strategy

### ESR (Equality-Sort-Range) Guideline

Order compound index fields by:
1. **Equality** - Exact match filters (organizationId, status)
2. **Sort** - Primary sort field (createdAt, reference)
3. **Range** - Date ranges, numeric comparisons

### Index Definitions

```javascript
// === REPORTING MVs ===

// mv_daily_metrics
db.mv_daily_metrics.createIndex({ "_id.organizationId": 1, "_id.date": -1 });
db.mv_daily_metrics.createIndex({ "_id.organizationId": 1, "_id.date": -1, "_id.carrier": 1 });

// mv_carrier_performance
db.mv_carrier_performance.createIndex({ "_id.organizationId": 1, "_id.month": -1 });
db.mv_carrier_performance.createIndex({ "_id.organizationId": 1, "_id.carrier": 1, "_id.month": -1 });

// mv_realtime_ops (single doc per org - no additional indexes needed)

// === APPLICATION MVs ===

// mv_shipment_list (includes SLA fields from merged lifecycle tracking)
db.mv_shipment_list.createIndex({ "_id.organizationId": 1, "status": 1, "createdAt": -1 });
db.mv_shipment_list.createIndex({ "_id.organizationId": 1, "carrier": 1, "createdAt": -1 });
db.mv_shipment_list.createIndex({ "_id.organizationId": 1, "reference": 1 });
db.mv_shipment_list.createIndex({ "_id.organizationId": 1, "sortKey": 1 });  // Cursor pagination
db.mv_shipment_list.createIndex({ "_id.organizationId": 1, "sla.onTime": 1, "createdAt": -1 });  // SLA reports
db.mv_shipment_list.createIndex({ "_id.organizationId": 1, "sla.requestedDelivery": 1 });  // Due date queries

// mv_consignment_list
db.mv_consignment_list.createIndex({ "_id.organizationId": 1, "status": 1, "createdAt": -1 });
db.mv_consignment_list.createIndex({ "_id.organizationId": 1, "shipment.id": 1 });
db.mv_consignment_list.createIndex({ "_id.organizationId": 1, "trackingNumber": 1 });

// mv_dashboard_counters (single doc per org - no additional indexes needed)
```

> **Note:** Customer and carrier lookups use in-memory `IMemoryCache` - no MongoDB indexes required.

---

## Part 4: Refresh Implementation

### 4.1 Refresh Strategy Summary

| MV | Strategy | Frequency | Trigger |
|----|----------|-----------|---------|
| `mv_daily_metrics` | Scheduled + catch-up | Hourly + nightly full | Hangfire job |
| `mv_carrier_performance` | Scheduled | Nightly | Hangfire job |
| `mv_realtime_ops` | Scheduled | 5 minutes | Hangfire job |
| `mv_shipment_list` | Event-driven | Real-time | Change stream |
| `mv_consignment_list` | Event-driven | Real-time | Change stream |
| `mv_dashboard_counters` | Scheduled | 5 minutes | Hangfire job |

> **Note:** Customer/carrier lookups use in-memory `IMemoryCache` with 15-minute TTL (see Section 2.3).

### 4.2 Change Stream Handler Architecture

```csharp
// Background service pattern for change stream handlers
public class ShipmentChangeStreamService : BackgroundService
{
    private readonly IMongoDatabase _database;
    private readonly IServiceProvider _serviceProvider;
    private readonly ILogger<ShipmentChangeStreamService> _logger;

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        var collection = _database.GetCollection<Shipment>("shipments");
        
        var pipeline = new EmptyPipelineDefinition<ChangeStreamDocument<Shipment>>()
            .Match(change => 
                change.OperationType == ChangeStreamOperationType.Insert ||
                change.OperationType == ChangeStreamOperationType.Update ||
                change.OperationType == ChangeStreamOperationType.Replace);
        
        var options = new ChangeStreamOptions
        {
            FullDocument = ChangeStreamFullDocumentOption.UpdateLookup,
            ResumeAfter = await GetStoredResumeTokenAsync()
        };

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                using var cursor = await collection.WatchAsync(pipeline, options, stoppingToken);
                
                await cursor.ForEachAsync(async change =>
                {
                    await ProcessChangeAsync(change, stoppingToken);
                    await StoreResumeTokenAsync(change.ResumeToken);
                }, stoppingToken);
            }
            catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
            {
                break;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Change stream error, reconnecting...");
                await Task.Delay(5000, stoppingToken);
            }
        }
    }

    private async Task ProcessChangeAsync(ChangeStreamDocument<Shipment> change, CancellationToken ct)
    {
        using var scope = _serviceProvider.CreateScope();
        
        // Update multiple MVs from single change event
        var shipmentListUpdater = scope.ServiceProvider.GetRequiredService<IShipmentListMvUpdater>();
        var lifecycleUpdater = scope.ServiceProvider.GetRequiredService<IShipmentLifecycleMvUpdater>();
        
        await Task.WhenAll(
            shipmentListUpdater.UpsertAsync(change.FullDocument, ct),
            lifecycleUpdater.UpsertAsync(change.FullDocument, ct)
        );
    }
}
```

### 4.3 Scheduled Job Pattern (Hangfire)

```csharp
public class MvRefreshJobs
{
    private readonly IMongoDatabase _database;
    
    // Hourly - incremental daily metrics
    [AutomaticRetry(Attempts = 3)]
    public async Task RefreshDailyMetricsIncrementalAsync()
    {
        var lastRun = await GetLastRunTimeAsync("mv_daily_metrics");
        
        await _database.GetCollection<BsonDocument>("shipments")
            .Aggregate()
            .Match(new BsonDocument("UpdatedOn", new BsonDocument("$gte", lastRun)))
            // ... pipeline stages
            .MergeAsync(
                _database.GetCollection<BsonDocument>("mv_daily_metrics"),
                new MergeStageOptions<BsonDocument> { WhenMatched = MergeStageWhenMatched.Replace }
            );
        
        await UpdateLastRunTimeAsync("mv_daily_metrics");
    }
    
    // Nightly - full carrier performance rebuild
    [AutomaticRetry(Attempts = 3)]
    public async Task RefreshCarrierPerformanceAsync()
    {
        await _database.GetCollection<BsonDocument>("shipments")
            .Aggregate()
            // ... full pipeline (no date filter)
            .MergeAsync(
                _database.GetCollection<BsonDocument>("mv_carrier_performance"),
                new MergeStageOptions<BsonDocument> { WhenMatched = MergeStageWhenMatched.Replace }
            );
    }
    
    // Every 5 minutes - realtime ops
    [AutomaticRetry(Attempts = 2)]
    public async Task RefreshRealtimeOpsAsync()
    {
        // Fast aggregation for single-doc pattern
        // ...
    }
}

// Hangfire registration
public static class HangfireConfiguration
{
    public static void ConfigureMvJobs()
    {
        RecurringJob.AddOrUpdate<MvRefreshJobs>(
            "mv-daily-metrics-hourly",
            x => x.RefreshDailyMetricsIncrementalAsync(),
            Cron.Hourly);
        
        RecurringJob.AddOrUpdate<MvRefreshJobs>(
            "mv-carrier-performance-nightly",
            x => x.RefreshCarrierPerformanceAsync(),
            "0 2 * * *");  // 2 AM daily
        
        RecurringJob.AddOrUpdate<MvRefreshJobs>(
            "mv-realtime-ops",
            x => x.RefreshRealtimeOpsAsync(),
            "*/5 * * * *");  // Every 5 minutes
        
        RecurringJob.AddOrUpdate<MvRefreshJobs>(
            "mv-dashboard-counters",
            x => x.RefreshDashboardCountersAsync(),
            "*/5 * * * *");  // Every 5 minutes
    }
}
```

### 4.4 Reconciliation Strategy

Change streams can fail to process events during handler restarts, deploys, or network issues. This section defines how we detect and correct MV drift.

#### Drift Detection

A nightly Hangfire job compares source collection counts vs MV counts per organization:

```csharp
public class MvReconciliationJob
{
    private readonly IMongoDatabase _database;
    private readonly IMetrics _metrics;
    private readonly ILogger<MvReconciliationJob> _logger;

    // Runs nightly at 3 AM (after carrier performance refresh at 2 AM)
    [AutomaticRetry(Attempts = 2)]
    public async Task ReconcileAllMvsAsync()
    {
        var mvConfigs = new[]
        {
            new { Mv = "mv_shipment_list", Source = "shipments", IdField = "shipmentId" },
            new { Mv = "mv_consignment_list", Source = "consignments", IdField = "consignmentId" }
        };

        foreach (var config in mvConfigs)
        {
            await ReconcileMvAsync(config.Mv, config.Source, config.IdField);
        }
    }

    private async Task ReconcileMvAsync(string mvName, string sourceCollection, string idField)
    {
        var sourceCol = _database.GetCollection<BsonDocument>(sourceCollection);
        var mvCol = _database.GetCollection<BsonDocument>(mvName);

        // Get counts per organization from both source and MV
        var sourceCounts = await sourceCol.Aggregate()
            .Group(new BsonDocument { { "_id", "$organizationId" }, { "count", new BsonDocument("$sum", 1) } })
            .ToListAsync();

        var mvCounts = await mvCol.Aggregate()
            .Group(new BsonDocument { { "_id", "$_id.organizationId" }, { "count", new BsonDocument("$sum", 1) } })
            .ToListAsync();

        var sourceDict = sourceCounts.ToDictionary(x => x["_id"].ToString(), x => x["count"].ToInt64());
        var mvDict = mvCounts.ToDictionary(x => x["_id"].ToString(), x => x["count"].ToInt64());

        foreach (var (orgId, sourceCount) in sourceDict)
        {
            var mvCount = mvDict.GetValueOrDefault(orgId, 0);
            var drift = sourceCount - mvCount;
            var driftPct = sourceCount > 0 ? (double)Math.Abs(drift) / sourceCount * 100 : 0;

            // Emit metric for monitoring
            _metrics.Measure.Gauge.SetValue(
                new GaugeOptions { Name = "viya_mv_drift_count", Tags = new MetricTags("mv", mvName) },
                drift);

            // Alert threshold: >1% drift or >100 documents
            if (driftPct > 1 || Math.Abs(drift) > 100)
            {
                _logger.LogWarning(
                    "MV drift detected: {Mv} org={OrgId} source={Source} mv={MvCount} drift={Drift} ({DriftPct:F2}%)",
                    mvName, orgId, sourceCount, mvCount, drift, driftPct);

                // Queue targeted rebuild for this org
                BackgroundJob.Enqueue<MvRebuildJob>(x => x.RebuildForOrgAsync(mvName, orgId));
            }
        }
    }
}
```

#### Targeted Rebuild

When drift is detected, rebuild only the affected organization (not the entire MV):

```csharp
public class MvRebuildJob
{
    private readonly IMongoDatabase _database;
    private readonly ILogger<MvRebuildJob> _logger;

    [AutomaticRetry(Attempts = 3)]
    [Queue("mv-rebuild")]  // Separate queue to not block regular jobs
    public async Task RebuildForOrgAsync(string mvName, string organizationId)
    {
        _logger.LogInformation("Starting targeted rebuild: {Mv} org={OrgId}", mvName, organizationId);

        switch (mvName)
        {
            case "mv_shipment_list":
                await RebuildShipmentListForOrgAsync(organizationId);
                break;
            case "mv_consignment_list":
                await RebuildConsignmentListForOrgAsync(organizationId);
                break;
        }

        _logger.LogInformation("Completed targeted rebuild: {Mv} org={OrgId}", mvName, organizationId);
    }

    private async Task RebuildShipmentListForOrgAsync(string organizationId)
    {
        var shipments = _database.GetCollection<Shipment>("shipments");
        var mv = _database.GetCollection<ShipmentListItem>("mv_shipment_list");

        // Delete existing MV docs for this org
        await mv.DeleteManyAsync(x => x.Id.OrganizationId == organizationId);

        // Re-project from source
        var cursor = await shipments
            .Find(s => s.OrganizationId == organizationId)
            .ToCursorAsync();

        var batch = new List<ShipmentListItem>(1000);
        await cursor.ForEachAsync(async shipment =>
        {
            batch.Add(ProjectToMv(shipment));
            if (batch.Count >= 1000)
            {
                await mv.InsertManyAsync(batch);
                batch.Clear();
            }
        });

        if (batch.Any())
            await mv.InsertManyAsync(batch);
    }
}
```

#### Manual Rebuild Scripts

For emergency full rebuilds (e.g., schema migration), provide CLI scripts:

```bash
# Rebuild single MV for all orgs
dotnet run -- rebuild-mv --name mv_shipment_list

# Rebuild single MV for specific org
dotnet run -- rebuild-mv --name mv_shipment_list --org 507f1f77bcf86cd799439011

# Rebuild all MVs (use with caution - high load)
dotnet run -- rebuild-mv --all
```

---

## Part 5: CQRS Integration

### 5.1 MediatR Command/Query Structure

```
src/
├── Application/
│   ├── Commands/
│   │   ├── CreateShipment/
│   │   │   ├── CreateShipmentCommand.cs
│   │   │   ├── CreateShipmentCommandHandler.cs
│   │   │   └── CreateShipmentCommandValidator.cs
│   │   └── UpdateShipmentStatus/
│   │       └── ...
│   ├── Queries/
│   │   ├── GetShipmentList/
│   │   │   ├── GetShipmentListQuery.cs        // Filter params
│   │   │   ├── GetShipmentListQueryHandler.cs  // Reads from mv_shipment_list
│   │   │   └── ShipmentListItemDto.cs
│   │   ├── GetCarrierPerformance/
│   │   │   └── ...                             // Reads from mv_carrier_performance
│   │   └── GetDashboardMetrics/
│   │       └── ...                             // Reads from mv_dashboard_counters
│   └── Behaviors/
│       ├── ValidationBehavior.cs
│       └── LoggingBehavior.cs
├── Infrastructure/
│   ├── Persistence/
│   │   ├── Repositories/
│   │   │   ├── ShipmentRepository.cs           // Write model
│   │   │   └── ShipmentReadRepository.cs       // Read model (MVs)
│   │   └── ChangeStreams/
│   │       ├── ShipmentChangeStreamService.cs
│   │       └── MvUpdaters/
│   │           ├── ShipmentListMvUpdater.cs    // Includes SLA/lifecycle fields
│   │           └── ConsignmentListMvUpdater.cs
│   └── Jobs/
│       └── MvRefreshJobs.cs
```

### 5.2 Query Handler Example

```csharp
public class GetShipmentListQuery : IRequest<PagedResult<ShipmentListItemDto>>
{
    public string OrganizationId { get; init; }
    public string? Status { get; init; }
    public string? Carrier { get; init; }
    public DateTime? FromDate { get; init; }
    public DateTime? ToDate { get; init; }
    public string? Cursor { get; init; }
    public int PageSize { get; init; } = 50;
}

public class GetShipmentListQueryHandler 
    : IRequestHandler<GetShipmentListQuery, PagedResult<ShipmentListItemDto>>
{
    private readonly IMongoCollection<ShipmentListItem> _mvCollection;
    
    public async Task<PagedResult<ShipmentListItemDto>> Handle(
        GetShipmentListQuery request, 
        CancellationToken ct)
    {
        var filterBuilder = Builders<ShipmentListItem>.Filter;
        var filter = filterBuilder.Eq(x => x.Id.OrganizationId, request.OrganizationId);
        
        if (!string.IsNullOrEmpty(request.Status))
            filter &= filterBuilder.Eq(x => x.Status, request.Status);
        
        if (!string.IsNullOrEmpty(request.Carrier))
            filter &= filterBuilder.Eq(x => x.Carrier, request.Carrier);
        
        if (request.FromDate.HasValue)
            filter &= filterBuilder.Gte(x => x.CreatedAt, request.FromDate.Value);
        
        // Cursor-based pagination
        if (!string.IsNullOrEmpty(request.Cursor))
            filter &= filterBuilder.Lt(x => x.SortKey, request.Cursor);
        
        var items = await _mvCollection
            .Find(filter)
            .SortByDescending(x => x.SortKey)
            .Limit(request.PageSize + 1)  // Fetch one extra to detect next page
            .ToListAsync(ct);
        
        var hasMore = items.Count > request.PageSize;
        if (hasMore) items = items.Take(request.PageSize).ToList();
        
        return new PagedResult<ShipmentListItemDto>
        {
            Items = items.Select(x => x.ToDto()).ToList(),
            NextCursor = hasMore ? items.Last().SortKey : null
        };
    }
}
```

---

## Part 6: Implementation Phases

### Phase 1: Foundation (Weeks 1-2)

**Goal:** Core infrastructure + first reporting MV

| Task | Priority | Owner | Est. |
|------|----------|-------|------|
| Add MediatR to project | P0 | Backend | 2d |
| Create change stream service infrastructure | P0 | Backend | 3d |
| Implement `mv_daily_metrics` pipeline | P0 | Backend | 2d |
| Set up Hangfire recurring jobs | P0 | Backend | 1d |
| Create resume token persistence | P0 | Backend | 1d |
| Unit tests for MV pipelines | P0 | Backend | 2d |

**Deliverables:**
- MediatR integrated
- Change stream service running
- `mv_daily_metrics` populating hourly
- Basic monitoring in place

### Phase 2: Application MVs (Weeks 3-4)

**Goal:** List views and caching

| Task | Priority | Owner | Est. |
|------|----------|-------|------|
| Implement `mv_shipment_list` + handler | P0 | Backend | 3d |
| Implement `mv_consignment_list` + handler | P1 | Backend | 2d |
| Implement CustomerLookupCache service | P1 | Backend | 0.5d |
| Implement CarrierLookupCache service | P1 | Backend | 0.5d |
| Implement `mv_dashboard_counters` | P1 | Backend | 2d |
| Create query handlers with cursor pagination | P0 | Backend | 2d |
| Integration tests | P0 | Backend | 2d |

**Deliverables:**
- Shipment/consignment list views use MVs
- Autocomplete uses in-memory cache
- Dashboard uses counter MV
- Cursor pagination working

### Phase 3: Reporting MVs (Weeks 5-6)

**Goal:** Complete reporting architecture

| Task | Priority | Owner | Est. |
|------|----------|-------|------|
| Implement `mv_carrier_performance` pipeline | P0 | Backend | 2d |
| Implement `mv_realtime_ops` | P1 | Backend | 2d |
| OTD calculation with carrier events | P1 | Backend | 3d |
| Query handlers for reports | P0 | Backend | 2d |
| Performance testing with prod-scale data | P0 | Backend | 2d |

**Deliverables:**
- All 6 MVs operational
- Carrier performance reports available
- SLA tracking via mv_shipment_list
- Performance validated

### Phase 4: Migration & Cleanup (Week 7)

**Goal:** Deprecate old MVs

| Task | Priority | Owner | Est. |
|------|----------|-------|------|
| Migrate queries from old MVs | P0 | Backend | 2d |
| Validate data consistency | P0 | Backend | 1d |
| Drop deprecated MVs | P1 | Backend | 1d |
| Documentation | P1 | Backend | 1d |
| Monitoring & alerting setup | P0 | DevOps | 1d |

**Deliverables:**
- Old MVs removed
- All queries using new architecture
- Runbook for MV operations

---

## Part 7: MV Worker Deployment

The MV worker runs as a dedicated Kubernetes deployment in the `viya-jobs` namespace, handling both change stream processing and Hangfire scheduled jobs.

### Kubernetes Manifest

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: viya-mv-worker
  namespace: viya-jobs
  labels:
    app: viya-mv-worker
    component: background-jobs
spec:
  replicas: 1  # Single replica - Hangfire handles job concurrency
  strategy:
    type: Recreate  # Ensure clean handoff of change stream cursors
  selector:
    matchLabels:
      app: viya-mv-worker
  template:
    metadata:
      labels:
        app: viya-mv-worker
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8080"
        prometheus.io/path: "/metrics"
    spec:
      containers:
      - name: mv-worker
        image: viya-shipping-service:latest
        args: ["--run-mode", "worker"]
        resources:
          requests:
            cpu: "500m"
            memory: "1Gi"
          limits:
            cpu: "2000m"
            memory: "4Gi"
        ports:
        - name: metrics
          containerPort: 8080
        - name: health
          containerPort: 8081
        env:
        - name: ASPNETCORE_ENVIRONMENT
          value: "Production"
        - name: ConnectionStrings__MongoDB
          valueFrom:
            secretKeyRef:
              name: viya-shipping-secrets
              key: mongodb-connection-string
        - name: ConnectionStrings__Hangfire
          valueFrom:
            secretKeyRef:
              name: viya-shipping-secrets
              key: hangfire-connection-string
        livenessProbe:
          httpGet:
            path: /health/live
            port: 8081
          initialDelaySeconds: 10
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 8081
          initialDelaySeconds: 5
          periodSeconds: 10
        startupProbe:
          httpGet:
            path: /health/startup
            port: 8081
          failureThreshold: 30
          periodSeconds: 10
      terminationGracePeriodSeconds: 60  # Allow change stream handlers to checkpoint
```

### Health Check Implementation

```csharp
public class MvWorkerHealthCheck : IHealthCheck
{
    private readonly IEnumerable<IChangeStreamHandler> _handlers;
    private readonly IMongoDatabase _database;

    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context, 
        CancellationToken ct)
    {
        var issues = new List<string>();

        // Check all change stream handlers are running
        foreach (var handler in _handlers)
        {
            if (!handler.IsRunning)
                issues.Add($"Change stream handler {handler.Name} is not running");
            
            if (handler.LastEventTime < DateTime.UtcNow.AddMinutes(-5))
                issues.Add($"Change stream handler {handler.Name} has not received events in 5 minutes");
        }

        // Check MongoDB connectivity
        try
        {
            await _database.RunCommandAsync<BsonDocument>(new BsonDocument("ping", 1), cancellationToken: ct);
        }
        catch (Exception ex)
        {
            issues.Add($"MongoDB ping failed: {ex.Message}");
        }

        if (issues.Any())
            return HealthCheckResult.Unhealthy(string.Join("; ", issues));

        return HealthCheckResult.Healthy();
    }
}
```

### Scaling Considerations

| Scenario | Configuration |
|----------|---------------|
| Single cluster | 1 replica, `Recreate` strategy |
| Multi-region | 1 replica per region, partition change streams by org geography |
| High volume (>10k events/sec) | Scale Hangfire workers horizontally, keep change stream handler at 1 |

> **Note:** Change stream handlers must be single-instance per collection to maintain ordering. Scale write throughput via Hangfire worker queues, not handler replicas.

---

## Part 8: Monitoring & Operations

### Prometheus Metrics

| Metric Name | Type | Labels | Description |
|-------------|------|--------|-------------|
| `viya_mv_change_stream_lag_events` | Gauge | `mv` | Events behind real-time |
| `viya_mv_change_stream_events_total` | Counter | `mv`, `operation` | Total events processed |
| `viya_mv_refresh_duration_seconds` | Histogram | `mv`, `type` | Job execution time |
| `viya_mv_staleness_seconds` | Gauge | `mv`, `org` | Time since last update |
| `viya_mv_drift_count` | Gauge | `mv` | Source vs MV document count difference |
| `viya_mv_error_total` | Counter | `mv`, `error_type` | Errors by type |
| `viya_mv_rebuild_duration_seconds` | Histogram | `mv` | Full rebuild time |

### Grafana Alert Definitions

```yaml
groups:
- name: viya-mv-alerts
  rules:
  - alert: MvChangeStreamLagHigh
    expr: viya_mv_change_stream_lag_events > 5000
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "MV {{ $labels.mv }} change stream is lagging"
      description: "{{ $value }} events behind, check handler health"

  - alert: MvChangeStreamStopped
    expr: rate(viya_mv_change_stream_events_total[5m]) == 0
    for: 10m
    labels:
      severity: critical
    annotations:
      summary: "MV {{ $labels.mv }} change stream has stopped"
      description: "No events processed in 10 minutes"

  - alert: MvRefreshJobSlow
    expr: viya_mv_refresh_duration_seconds > 180
    for: 0m
    labels:
      severity: warning
    annotations:
      summary: "MV {{ $labels.mv }} refresh job is slow"
      description: "Job took {{ $value }}s (threshold: 180s)"

  - alert: MvDriftDetected
    expr: abs(viya_mv_drift_count) > 100
    for: 0m
    labels:
      severity: warning
    annotations:
      summary: "MV {{ $labels.mv }} has data drift"
      description: "{{ $value }} document difference from source"

  - alert: MvStale
    expr: viya_mv_staleness_seconds > 3600
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "MV {{ $labels.mv }} is stale"
      description: "Not updated in {{ $value | humanizeDuration }}"
```

### Key Metrics Summary

| Metric | Target | Alert Threshold |
|--------|--------|-----------------|
| Change stream lag | < 1000 events | > 5000 events |
| Refresh job duration | < 60s | > 180s |
| MV staleness | Per MV target | 2x target |
| Error rate | < 1% | > 5% |
| Drift count | 0 | > 100 documents |

### Runbook Checklist

- [ ] Change stream handler health check endpoint (`/health/ready`)
- [ ] Resume token backup/recovery procedure (stored in `mv_resume_tokens` collection)
- [ ] Full MV rebuild scripts (`dotnet run -- rebuild-mv --name <mv>`)
- [ ] Staleness detection queries (see Prometheus `viya_mv_staleness_seconds`)
- [ ] Hangfire dashboard access for job management (`/hangfire` with admin auth)
- [ ] PagerDuty integration for critical alerts

---

## Part 9: Architecture Decisions

The following questions from the original draft have been resolved:

### Decision 1: Hangfire vs Dedicated Worker Service

**Decision:** Dedicated worker service (`viya-mv-worker`)

**Rationale:**
- Change stream handlers need long-running connections (not suitable for web app lifecycle)
- Allows independent scaling and deployment of MV processing
- Cleaner separation of concerns: API serves requests, worker processes background jobs
- Easier to debug and monitor dedicated workloads

### Decision 2: Multi-org Change Streams

**Decision:** Single stream filtering all orgs

**Rationale:**
- MongoDB charges per change stream cursor (cost consideration)
- Most orgs have low volume; dedicated streams only make sense for very high-volume tenants
- Simpler operational model (one handler per collection, not per org)
- If needed later, can partition by org geography for multi-region deployments

### Decision 3: Optimistic UI for Read-Your-Own-Writes

**Decision:** No optimistic UI; rely on fast change streams

**Rationale:**
- Change streams provide sub-100ms propagation for most events
- Optimistic UI adds frontend complexity and potential consistency bugs
- If specific flows need instant feedback, use command response (not MV query)
- Reassess if user complaints about "stale data" emerge

### Decision 4: MV Versioning Strategy

**Decision:** Blue/green deployment pattern with `_schemaVersion` field

**Implementation:**
1. All MV documents include `_schemaVersion: 1` field
2. For schema changes, create new collection (e.g., `mv_shipment_list_v2`)
3. Run full rebuild to populate v2
4. Validate: compare counts, spot-check random documents
5. Switch query handlers via feature flag or config change
6. Monitor for 24-48 hours
7. Drop old collection

**Example Migration:**

```csharp
// Feature flag controls which version to query
public class ShipmentListQueryHandler
{
    private readonly IFeatureManager _features;

    public async Task<PagedResult<ShipmentListItemDto>> Handle(...)
    {
        var collectionName = await _features.IsEnabledAsync("MvShipmentListV2") 
            ? "mv_shipment_list_v2" 
            : "mv_shipment_list";
        
        var collection = _database.GetCollection<ShipmentListItem>(collectionName);
        // ... query logic
    }
}
```

**Rollback:** Simply toggle feature flag back to v1 (old collection still exists until explicitly dropped)

### Decision 5: Testing Change Stream Handlers

**Decision:** Integration tests with MongoDB Docker + Unit tests with mocked collections

**Approach:**
1. **Unit tests:** Mock `IChangeStreamCursor<T>` to test handler logic
2. **Integration tests:** Use `Testcontainers.MongoDb` with replica set for real change streams
3. **Local dev:** Docker Compose with MongoDB replica set (`rs.initiate()`)

```csharp
// Integration test example
public class ShipmentChangeStreamTests : IClassFixture<MongoDbFixture>
{
    private readonly MongoDbFixture _fixture;

    [Fact]
    public async Task ProcessChange_WhenShipmentCreated_UpdatesMvShipmentList()
    {
        // Arrange
        var shipments = _fixture.Database.GetCollection<Shipment>("shipments");
        var mv = _fixture.Database.GetCollection<ShipmentListItem>("mv_shipment_list");
        
        using var handler = new ShipmentChangeStreamService(...);
        await handler.StartAsync(CancellationToken.None);

        // Act
        await shipments.InsertOneAsync(new Shipment { ... });
        await Task.Delay(500); // Allow propagation

        // Assert
        var mvDoc = await mv.Find(x => x.Id.ShipmentId == ...).FirstOrDefaultAsync();
        mvDoc.Should().NotBeNull();
    }
}
```

---

## Part 10: Open Items

Items still requiring team input or future work:

1. **Carrier event ingestion** - How do carrier tracking events flow into the system? (Needed for accurate OTD in `mv_carrier_performance`)

2. **Historical data migration** - Strategy for backfilling MVs from existing shipments (one-time job vs gradual migration)

3. **Multi-region replication** - If Viya expands to multiple regions, how do MVs handle cross-region queries?

---

## Appendix: Research Sources

- [CQRS MongoDB Research](./../research/cqrs-mongodb/_index.md) - 9 documents, 69 sources
- [Viya Reporting Research](./../research/viya-reporting/_index.md) - 10 documents, 50+ sources
- [MV Strategy](./../research/viya-reporting/2026-01-21-materialized-view-strategy.md) - Detailed pipeline definitions
