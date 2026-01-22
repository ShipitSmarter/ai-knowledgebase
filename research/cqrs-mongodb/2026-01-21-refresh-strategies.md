---
topic: Refresh Strategies & Performance for MongoDB Materialized Views
date: 2026-01-21
project: cqrs-mongodb
sources_count: 8
status: reviewed
tags: [cqrs, mongodb, materialized-views, change-streams, performance, refresh-strategies]
---

# Refresh Strategies & Performance for MongoDB Materialized Views

## Summary

Materialized View (MV) refresh strategies in MongoDB involve a fundamental trade-off between data freshness and system load. MongoDB provides two primary mechanisms: **event-driven refresh** using Change Streams for near-real-time updates, and **scheduled refresh** using aggregation pipelines with `$merge`/`$out` for batch processing. The choice depends on freshness requirements, write volume, and resource constraints.

The `$merge` operator is the cornerstone of incremental MV updates, offering flexible `whenMatched` options (replace, merge, keepExisting, fail, or custom pipeline) that enable efficient partial updates rather than full rebuilds. For MVs with many documents where only a subset changes, incremental updates using `$merge` with time-based filtering can dramatically reduce processing overhead compared to `$out` which always replaces the entire collection.

Performance implications of maintaining multiple MVs include write amplification (each source change may trigger multiple MV updates), index maintenance overhead on target collections, and increased storage costs. MongoDB's Change Stream production recommendations emphasize that change streams cannot use indexes and warn against opening too many specifically-targeted change streams as this impacts server performance. A hybrid approach—using Change Streams for high-priority MVs and scheduled jobs for others—often provides the best balance.

## Key Findings

1. **$merge enables incremental updates while $out always replaces** - Use `$merge` with `whenMatched: "replace"` or `"merge"` for incremental updates; `$out` atomically replaces the entire collection, making it suitable only for full rebuilds or small MVs.

2. **Change Streams have performance constraints** - MongoDB docs explicitly state change streams "cannot use indexes" and recommend limiting the number of specifically-targeted change streams to avoid server performance impact. Pool size must exceed number of open change streams.

3. **Hybrid refresh strategies are optimal** - Event-driven for critical MVs needing sub-second freshness, scheduled batch for reports or less time-sensitive views. The Computed Pattern from MongoDB suggests computing at write time for read-heavy workloads (1M reads/1K writes = compute on write).

4. **Atlas Triggers provide managed Change Stream processing** - For Atlas deployments, Database Triggers handle change stream complexity with built-in retry logic and logging. Ordered triggers process events sequentially; unordered can handle up to 10,000 concurrent events.

5. **Incremental updates require tracking last update time** - Use `$match` with timestamp filter at pipeline start to process only changed documents, combined with `$merge` to update only affected MV records.

6. **Write amplification is proportional to MV count** - Each MV that subscribes to a source collection's changes creates additional write load. Consider consolidating related read models or accepting slightly stale data for less critical views.

7. **Monitor lag, errors, and duration** - Key metrics include time since last refresh (lag), refresh failure rate, refresh duration, and document count processed. Atlas provides built-in trigger logging; self-managed deployments need custom monitoring.

8. **Sharded clusters add complexity** - Change streams on sharded clusters open a stream per shard regardless of whether targeting specific shard key ranges. Cold shards can cause latency; `periodicNoopIntervalSecs` can help.

## Event-Driven vs Scheduled Refresh

### When to Use Event-Driven (Change Streams)

| Use Case | Rationale |
|----------|-----------|
| Real-time dashboards | Sub-second freshness required |
| Critical business MVs | Immediate consistency expectations |
| Low-volume source collections | Change stream overhead is manageable |
| User-facing list views | "Just created" items must appear immediately |
| Operational alerts | Delay could miss time-sensitive events |

**Implementation approach:**
```javascript
// Change stream with $match filter for relevant operations
const changeStream = sourceCollection.watch([
  { $match: { operationType: { $in: ["insert", "update", "replace"] } } }
]);

changeStream.on("change", async (event) => {
  // Run incremental aggregation pipeline
  await sourceCollection.aggregate([
    { $match: { _id: event.documentKey._id } },
    // ... transformation stages ...
    { $merge: { into: "mv_collection", whenMatched: "replace" } }
  ]).toArray();
});
```

### When to Use Scheduled (Batch) Refresh

| Use Case | Rationale |
|----------|-----------|
| Daily/weekly reports | Freshness measured in hours acceptable |
| Analytics aggregations | Complex multi-collection joins |
| High-volume source data | Change stream would overwhelm system |
| Historical summaries | Data rarely changes once written |
| Cost-sensitive environments | Reduce compute by batching |

**Implementation approach:**
```javascript
// Scheduled job (e.g., cron, Azure Functions timer, Hangfire)
async function refreshMonthlySalesMV(startDate) {
  await db.sales.aggregate([
    { $match: { date: { $gte: startDate } } },
    { $group: { 
      _id: { $dateToString: { format: "%Y-%m", date: "$date" } },
      totalAmount: { $sum: "$amount" }
    }},
    { $merge: { into: "mv_monthly_sales", whenMatched: "replace" } }
  ]).toArray();
}
```

### Hybrid Strategy Decision Matrix

| MV Type | Refresh Strategy | Typical Interval |
|---------|------------------|------------------|
| Shipment list view | Change Stream | Real-time |
| Customer dropdown | Scheduled | Every 5-15 min |
| Daily volume dashboard | Scheduled | Every hour |
| Carrier performance | Scheduled | Daily |
| Exception alerts | Change Stream | Real-time |
| Search index | Scheduled | Every 5 min |

## Implementing Incremental Updates Efficiently

### Using $merge with whenMatched Options

```javascript
// Option 1: Full replacement of matched documents
{ $merge: { 
  into: "mv_shipments",
  on: "shipmentId",  // Match key
  whenMatched: "replace",  // Replace entire document
  whenNotMatched: "insert"  // Insert if new
}}

// Option 2: Merge only changed fields (preserves existing fields)
{ $merge: { 
  into: "mv_shipments",
  on: "shipmentId",
  whenMatched: "merge",  // Only update fields in pipeline output
  whenNotMatched: "insert"
}}

// Option 3: Custom update pipeline for computed fields
{ $merge: { 
  into: "mv_shipments",
  on: "shipmentId",
  whenMatched: [
    { $set: { 
      lastUpdated: "$$NOW",
      totalValue: { $add: ["$totalValue", "$$new.incrementValue"] }
    }}
  ],
  whenNotMatched: "insert"
}}

// Option 4: Keep existing (for "insert-only" MVs)
{ $merge: { 
  into: "mv_events",
  on: "eventId",
  whenMatched: "keepExisting",  // Don't update existing
  whenNotMatched: "insert"
}}
```

### Tracking Last Update Time

**Metadata collection approach:**
```javascript
// Store refresh metadata
db.mv_refresh_metadata.updateOne(
  { mvName: "mv_shipments" },
  { $set: { 
    lastRefreshTime: new Date(),
    lastRefreshDuration: durationMs,
    documentsProcessed: count
  }},
  { upsert: true }
);

// Use in next refresh to filter changed documents
const lastRefresh = await db.mv_refresh_metadata.findOne({ mvName: "mv_shipments" });
await db.shipments.aggregate([
  { $match: { updatedAt: { $gte: lastRefresh.lastRefreshTime } } },
  // ... rest of pipeline
  { $merge: { into: "mv_shipments", whenMatched: "replace" } }
]);
```

**Timestamp field in MV approach:**
```javascript
// Include refresh timestamp in MV documents
{ $addFields: { _mvRefreshedAt: "$$NOW" } },
{ $merge: { into: "mv_shipments", whenMatched: "replace" } }

// Query MV with freshness check
db.mv_shipments.find({
  _mvRefreshedAt: { $gte: new Date(Date.now() - 5 * 60 * 1000) }  // Within 5 min
});
```

### Partial vs Full Rebuilds

| Scenario | Approach | Method |
|----------|----------|--------|
| Schema change | Full rebuild | `$out` to new collection, rename |
| Bug fix in aggregation | Full rebuild | `$out` or drop + `$merge` |
| Normal operation | Incremental | `$merge` with time filter |
| Data corruption recovery | Full rebuild | `$out` from backup timestamp |
| New MV creation | Initial build | `$out` then switch to `$merge` |

**Full rebuild pattern:**
```javascript
// 1. Build to temp collection
await db.shipments.aggregate([
  // ... full pipeline without date filter
  { $out: "mv_shipments_new" }
]);

// 2. Atomic rename (drops old, renames new)
await db.mv_shipments_new.renameCollection("mv_shipments", { dropTarget: true });
```

## Performance Implications of Many MVs

### Write Amplification Concerns

**Problem:** Each write to a source collection can trigger updates to multiple MVs, multiplying write load.

**Calculation:**
```
Effective write load = Base writes × (1 + Number of event-driven MVs)
```

**Mitigation strategies:**
1. **Batch change stream processing** - Don't update MV on every change; buffer and batch
2. **Debounce rapid updates** - If same document updated multiple times in short period, process once
3. **Filter change streams** - Use `$match` in change stream pipeline to ignore irrelevant changes
4. **Prioritize MVs** - Only high-priority MVs get real-time; others batch

```javascript
// Example: Batched change stream processing
const buffer = new Map();
const BATCH_INTERVAL = 1000; // 1 second

changeStream.on("change", (event) => {
  buffer.set(event.documentKey._id.toString(), event);
});

setInterval(async () => {
  if (buffer.size === 0) return;
  
  const batch = Array.from(buffer.values());
  buffer.clear();
  
  // Process batch with single aggregation
  const ids = batch.map(e => e.documentKey._id);
  await sourceCollection.aggregate([
    { $match: { _id: { $in: ids } } },
    // ... pipeline
    { $merge: { into: "mv_collection", whenMatched: "replace" } }
  ]).toArray();
}, BATCH_INTERVAL);
```

### Index Maintenance Overhead

- Each MV collection has its own indexes to maintain
- Index builds on MVs happen during `$merge` writes
- Consider index count per MV—only create indexes used by queries

**Best practice:** Create indexes on MV after initial population, not before:
```javascript
// 1. Initial population
await db.source.aggregate([...pipeline, { $out: "mv_new" }]);

// 2. Create indexes
await db.mv_new.createIndex({ customerId: 1, createdAt: -1 });
await db.mv_new.createIndex({ status: 1 });

// 3. Rename to production
await db.mv_new.renameCollection("mv_target", { dropTarget: true });
```

### Storage Costs

| Factor | Impact | Mitigation |
|--------|--------|------------|
| Duplicate data | Each MV copies some source data | Project only needed fields |
| Denormalization | Embedded lookups increase size | Accept trade-off for read perf |
| Index storage | Each MV index consumes space | Minimize index count |
| Version history | If using `$out`, old collection persists briefly | Automatic cleanup |

**Projection optimization:**
```javascript
// Bad: Copying entire document
{ $project: { shipment: "$$ROOT" } }

// Good: Only needed fields
{ $project: { 
  shipmentId: "$_id",
  status: 1,
  customerName: "$customer.name",
  createdAt: 1
}}
```

### Query Routing Complexity

With multiple MVs, application code must route queries to correct MV:

```csharp
// C# example: MV query router
public class ShipmentQueryService
{
    public async Task<List<ShipmentListItem>> GetShipmentList(ShipmentListFilter filter)
    {
        // Route to list view MV
        return await _mvShipmentList
            .Find(BuildFilter(filter))
            .SortByDescending(x => x.CreatedAt)
            .Limit(filter.PageSize)
            .ToListAsync();
    }
    
    public async Task<ShipmentDetail> GetShipmentDetail(string shipmentId)
    {
        // Route to source collection for full detail
        return await _shipments
            .Find(x => x.Id == shipmentId)
            .FirstOrDefaultAsync();
    }
    
    public async Task<DashboardMetrics> GetDashboardMetrics(DateTime date)
    {
        // Route to dashboard MV
        return await _mvDashboard
            .Find(x => x.Date == date.Date)
            .FirstOrDefaultAsync();
    }
}
```

## Monitoring and Troubleshooting

### Key Metrics to Track

| Metric | Description | Alert Threshold |
|--------|-------------|-----------------|
| `refresh_lag_seconds` | Time since last successful refresh | Varies by MV criticality |
| `refresh_duration_ms` | How long refresh took | >2x baseline |
| `documents_processed` | Count of docs in refresh | Unexpected drops |
| `refresh_errors` | Failed refresh attempts | Any occurrence |
| `change_stream_lag` | Events pending processing | >1000 events |
| `mv_document_count` | Total docs in MV | Unexpected changes |

### Atlas Trigger Monitoring

Atlas provides built-in monitoring for Database Triggers:
- Trigger logs show execution history
- Error states visible in Atlas UI
- Can forward logs to external services

```javascript
// Atlas Function with logging
exports = async function(changeEvent) {
  const startTime = Date.now();
  
  try {
    // ... refresh logic
    
    console.log(JSON.stringify({
      event: "mv_refresh_success",
      mv: "mv_shipments",
      duration: Date.now() - startTime,
      documentId: changeEvent.documentKey._id
    }));
  } catch (error) {
    console.error(JSON.stringify({
      event: "mv_refresh_error",
      mv: "mv_shipments",
      error: error.message,
      documentId: changeEvent.documentKey._id
    }));
    throw error; // Allows Atlas to retry
  }
};
```

### Self-Managed Monitoring

```javascript
// Custom monitoring collection
const refreshMetrics = {
  mvName: "mv_shipments",
  timestamp: new Date(),
  refreshType: "incremental", // or "full"
  durationMs: 1234,
  documentsProcessed: 567,
  errorCount: 0,
  lastError: null
};

await db.mv_refresh_metrics.insertOne(refreshMetrics);

// Query for monitoring dashboard
const recentRefreshes = await db.mv_refresh_metrics.aggregate([
  { $match: { timestamp: { $gte: new Date(Date.now() - 24*60*60*1000) } } },
  { $group: {
    _id: "$mvName",
    avgDuration: { $avg: "$durationMs" },
    maxDuration: { $max: "$durationMs" },
    errorRate: { $avg: { $cond: [{ $gt: ["$errorCount", 0] }, 1, 0] } },
    refreshCount: { $sum: 1 }
  }}
]).toArray();
```

### Debugging Stale Data Issues

**Diagnostic checklist:**
1. **Check refresh metadata** - When did last refresh run?
2. **Verify change stream is running** - Is handler process alive?
3. **Check for errors** - Any exceptions in logs?
4. **Verify source data** - Is source collection updated?
5. **Check MV document timestamps** - Are `_mvRefreshedAt` values recent?
6. **Inspect aggregation pipeline** - Does `$match` filter correctly?

**Debug query:**
```javascript
// Find potentially stale MV documents
const staleThreshold = new Date(Date.now() - 15 * 60 * 1000); // 15 min

const potentiallyStale = await db.mv_shipments.aggregate([
  { $lookup: {
    from: "shipments",
    localField: "shipmentId",
    foreignField: "_id",
    as: "source"
  }},
  { $unwind: "$source" },
  { $match: {
    $expr: { $gt: ["$source.updatedAt", "$_mvRefreshedAt"] }
  }},
  { $project: {
    shipmentId: 1,
    mvRefreshedAt: "$_mvRefreshedAt",
    sourceUpdatedAt: "$source.updatedAt",
    staleness: { $subtract: ["$source.updatedAt", "$_mvRefreshedAt"] }
  }},
  { $limit: 100 }
]).toArray();
```

### Alerting Strategies

| Alert | Condition | Severity |
|-------|-----------|----------|
| Refresh failure | Error count > 0 in last 5 min | High |
| Excessive lag | Lag > 2x normal for MV type | Medium |
| Change stream down | No events processed in 5 min despite source writes | Critical |
| Slow refresh | Duration > 3x baseline | Low |
| MV size anomaly | Document count changed >20% unexpectedly | Medium |

## Sources

| Source | URL | Key Contribution |
|--------|-----|------------------|
| MongoDB On-Demand Materialized Views | https://www.mongodb.com/docs/manual/core/materialized-views/ | Core concepts, $merge/$out comparison, refresh examples |
| MongoDB $merge Documentation | https://www.mongodb.com/docs/manual/reference/operator/aggregation/merge/ | whenMatched options, incremental update patterns |
| MongoDB Change Streams | https://www.mongodb.com/docs/manual/changeStreams/ | Event-driven refresh mechanics, cursor management |
| Change Streams Production Recommendations | https://www.mongodb.com/docs/manual/administration/change-streams-production-recommendations/ | Performance constraints, sharded cluster considerations |
| MongoDB $out Documentation | https://www.mongodb.com/docs/manual/reference/operator/aggregation/out/ | Full rebuild patterns, time series support |
| Building with Patterns: Computed Pattern | https://www.mongodb.com/blog/post/building-with-patterns-the-computed-pattern | When to compute at write time vs read time |
| Atlas Triggers Documentation | https://www.mongodb.com/docs/atlas/atlas-ui/triggers/ | Managed change stream processing, throughput limits |
| Exploration Plan | research/cqrs-mongodb/2026-01-21-exploration-plan.md | Context and questions framing this research |

## Questions for Further Research

- [ ] How to handle MV refresh during source schema migrations?
- [ ] What are the oplog size implications of heavy MV usage?
- [ ] How to implement cross-collection MV refresh (multiple source collections)?
- [ ] Best practices for MV versioning when aggregation logic changes?
- [ ] How to test MV refresh logic in CI/CD pipelines?
