---
topic: MongoDB as a CQRS Platform
date: 2026-01-21
project: cqrs-mongodb
sources_count: 7
status: reviewed
tags: [cqrs, mongodb, change-streams, materialized-views, event-driven, read-models]
---

# MongoDB as a CQRS Platform

## Summary

MongoDB provides native capabilities that make it an effective platform for implementing CQRS (Command Query Responsibility Segregation) without requiring external message brokers. **Change streams** enable real-time event propagation by exposing database changes as a continuous stream, while **$merge and $out operators** allow aggregation results to be persisted as on-demand materialized views that serve as read models.

The key insight is that MongoDB can serve as both the write model store and the event propagation mechanism. Change streams use the oplog (replication log) to deliver ordered change notifications, which can trigger updates to read-optimized collections. This reduces architectural complexity compared to setups requiring separate message brokers like Kafka or RabbitMQ, though it does trade off some message broker capabilities (replay, multi-consumer, dead-letter queues).

For TMS applications, this approach enables maintaining denormalized read models for list views, dashboards, and lookups while keeping the write model normalized for consistency. The eventual consistency delay is typically sub-second for change stream propagation, making it suitable for most application-embedded query use cases.

## Key Findings

1. **Change streams provide ordered, resumable event delivery** - MongoDB guarantees total ordering of changes even across sharded clusters by using a global logical clock. Resume tokens allow restarting from a specific point, enabling recovery after consumer downtime.

2. **$merge enables incremental materialized view updates** - The `$merge` stage can insert, update, replace, or merge documents into an output collection based on matching criteria, supporting incremental updates to read models rather than full rebuilds.

3. **Standard views vs materialized views serve different purposes** - Standard views are computed on read (no storage overhead, always current, but CPU-intensive). On-demand materialized views are pre-computed and stored (fast reads, indexable, but require explicit refresh).

4. **Change streams can replace message brokers for CQRS sync within MongoDB** - For read model synchronization where both sides are MongoDB collections, change streams eliminate the need for external messaging infrastructure. However, they are not a full replacement for message brokers when messages need to reach external systems or require advanced patterns.

5. **Oplog retention limits change stream resumability** - Change streams can only resume from events still in the oplog. For production systems, oplog size should be configured to retain events for longer than maximum expected downtime.

6. **Sharded clusters add latency considerations** - Cold shards (with little activity) can slow change stream response times as mongos must check all shards for ordering guarantees. The `periodicNoopIntervalSecs` parameter can help mitigate this.

## Detailed Analysis

### Change Streams for CQRS Synchronization

#### Mechanics and Capabilities

Change streams allow applications to subscribe to real-time data changes on:
- A single collection
- A database (all non-system collections)
- An entire deployment (all databases except admin, local, config)

```javascript
// Watch a collection for changes
const changeStream = db.collection('shipments').watch([
  { $match: { operationType: { $in: ['insert', 'update', 'replace'] } } }
]);

changeStream.on('change', (change) => {
  // Trigger read model update
  updateShipmentReadModel(change.documentKey._id, change.fullDocument);
});
```

**Key capabilities:**
- Filter by operation type (insert, update, replace, delete, invalidate)
- Filter by specific fields using `$match` on the change event
- Access full document with `fullDocument: 'updateLookup'` option
- Aggregate/transform change events before processing

**Change event structure:**
```json
{
  "_id": { "_data": "<resume token>" },
  "operationType": "update",
  "clusterTime": "<timestamp>",
  "ns": { "db": "tms", "coll": "shipments" },
  "documentKey": { "_id": "abc123" },
  "updateDescription": {
    "updatedFields": { "status": "delivered" },
    "removedFields": []
  },
  "fullDocument": { /* optional: full doc after change */ }
}
```

#### Resume Tokens for Reliability

Every change event includes a resume token that can be stored and used to restart the stream:

```javascript
let resumeToken = null;

changeStream.on('change', (change) => {
  resumeToken = change._id;
  processChange(change);
  // Persist resumeToken to survive restarts
  saveResumeToken(resumeToken);
});

// On restart:
const stream = collection.watch([], { resumeAfter: savedResumeToken });
```

**Important constraints:**
- Resume only works if the token's oplog entry still exists
- Oplog is a capped collection; old entries are removed as it fills
- For production: size oplog to retain entries longer than maximum downtime
- Use `rs.printReplicationInfo()` to check oplog time range

#### Comparison to External Message Brokers

| Feature | MongoDB Change Streams | Kafka/RabbitMQ |
|---------|----------------------|----------------|
| Setup complexity | None (built-in) | Separate infrastructure |
| Ordering guarantee | Total ordering with global clock | Partition-level ordering |
| Message replay | Limited by oplog retention | Configurable retention |
| Consumer groups | Not native (implement manually) | Native support |
| Dead-letter queues | Not supported | Supported |
| Cross-system events | Only to MongoDB watchers | Any subscriber |
| Persistence | Oplog (capped) | Configurable long-term |
| Throughput | Tied to MongoDB capacity | Independent scaling |

**When change streams are sufficient:**
- Read model sync within same MongoDB deployment
- Low to moderate change volume
- Acceptable to miss events during extended outages (or can rebuild)
- No need for multiple independent consumers

**When external brokers are needed:**
- Events must reach non-MongoDB systems
- Guaranteed delivery with dead-letter handling required
- Multiple independent consumer groups needed
- Very high volume requiring independent scaling
- Long-term event storage/replay requirements

### Patterns for Maintaining Read Models with $merge/$out

#### $merge for Incremental Updates

The `$merge` operator writes aggregation results to an output collection with flexible handling for existing documents:

```javascript
db.shipments.aggregate([
  { $match: { updatedAt: { $gte: lastRefreshTime } } },
  { $project: {
    _id: 1,
    reference: 1,
    status: 1,
    customerName: '$customer.name',
    originCity: '$origin.city',
    destinationCity: '$destination.city'
  }},
  { $merge: {
    into: 'shipment_list_view',
    on: '_id',
    whenMatched: 'replace',
    whenNotMatched: 'insert'
  }}
]);
```

**whenMatched options:**
- `replace` - Replace entire document (good for complete denormalization)
- `merge` - Merge fields, keeping existing fields not in new doc
- `keepExisting` - Don't update if exists (insert-only pattern)
- `fail` - Error if document exists (one-time loads)
- Custom pipeline - Apply transformations during merge

**whenNotMatched options:**
- `insert` - Add new documents
- `discard` - Ignore documents that don't match
- `fail` - Error if no match found

**Incremental update pattern:**
```javascript
// Store last refresh time
const refreshMeta = db.mv_metadata.findOne({ view: 'shipment_list' });
const lastRefresh = refreshMeta?.lastRefresh || new Date(0);

// Only process documents changed since last refresh
db.shipments.aggregate([
  { $match: { updatedAt: { $gte: lastRefresh } } },
  // ... transformations ...
  { $merge: { into: 'shipment_list_view', on: '_id', whenMatched: 'replace' }}
]);

// Update refresh timestamp
db.mv_metadata.updateOne(
  { view: 'shipment_list' },
  { $set: { lastRefresh: new Date() } },
  { upsert: true }
);
```

#### $out for Full Rebuilds

The `$out` operator replaces the entire output collection:

```javascript
db.shipments.aggregate([
  // Complex aggregation...
  { $out: 'shipment_summary_daily' }
]);
```

**Key differences from $merge:**
- Atomically replaces collection (old docs visible until completion)
- Cannot be used with sharded output collections
- Simpler but more resource-intensive for large collections
- **Cannot use change streams** on $out collections (use $merge instead)

**When to use $out:**
- Complete recalculations (daily summaries, reports)
- Schema migrations of read models
- When incremental updates are too complex

### MongoDB Views vs On-Demand Materialized Views

#### Standard Views (Computed on Read)

```javascript
db.createView('shipment_summary', 'shipments', [
  { $group: { _id: '$status', count: { $sum: 1 } } }
]);

// Queries run the aggregation pipeline at read time
db.shipment_summary.find();
```

**Characteristics:**
- Always current data
- No storage overhead
- CPU computed on every query
- Uses underlying collection's indexes
- Cannot create indexes on view itself
- Subject to 100MB memory limit for blocking operations

#### On-Demand Materialized Views (Pre-computed)

```javascript
// Refresh function
function refreshShipmentListMV() {
  db.shipments.aggregate([
    { $lookup: { from: 'customers', ... }},
    { $project: { /* denormalized fields */ }},
    { $merge: { into: 'mv_shipment_list', on: '_id', whenMatched: 'replace' }}
  ]);
}

// Query the materialized view directly
db.mv_shipment_list.find({ status: 'pending' }).sort({ createdAt: -1 });
```

**Characteristics:**
- Pre-computed, fast reads
- Can create indexes on the MV collection
- Requires explicit refresh (manual, scheduled, or change stream triggered)
- Eventually consistent with source data
- Storage overhead for duplicate data
- Can use change streams to watch for changes

#### CQRS Architecture Mapping

| CQRS Concept | MongoDB Implementation |
|--------------|----------------------|
| Write Model | Source collections (shipments, customers, etc.) |
| Events/Commands | Change stream events / Write operations |
| Event Bus | Change streams (or external broker) |
| Read Models | On-demand materialized view collections |
| Projections | Aggregation pipelines that populate MVs |

### Consistency Guarantees and Latency

#### Change Stream Latency

Change stream events are delivered after the write operation is majority-committed:

1. Write operation received by primary
2. Write replicated to majority of replica set
3. Write acknowledged to client
4. Change event becomes available in change stream

**Typical latency:** Sub-second in healthy clusters (often <100ms)

**Factors affecting latency:**
- Replication lag in replica set
- Network latency (especially geo-distributed)
- Cold shards in sharded clusters
- Number of open change streams (connection pool pressure)

#### Consistency Model

```
Write to Source → Majority Commit → Change Stream Event → Read Model Update
                                                              ↓
                        User sees stale data ←←←←←←←← User queries read model
```

**Guarantees:**
- Causal consistency: Changes appear in order they were committed
- No lost updates: All majority-committed writes generate events
- Resume capability: Can restart from last processed event

**What MongoDB does NOT guarantee:**
- Immediate read-your-own-writes from read models
- Exactly-once delivery (at-least-once; handlers must be idempotent)
- Events during extended outages beyond oplog retention

#### Handling Failures and Retries

**Pattern for reliable change stream processing:**

```javascript
async function processChangesReliably() {
  let resumeToken = await loadResumeToken();
  
  while (true) {
    try {
      const stream = collection.watch(pipeline, { 
        resumeAfter: resumeToken,
        fullDocument: 'updateLookup'
      });
      
      for await (const change of stream) {
        await processChangeIdempotently(change);
        resumeToken = change._id;
        await saveResumeToken(resumeToken);
      }
    } catch (error) {
      if (isResumableError(error)) {
        console.log('Reconnecting...');
        await sleep(1000);
        continue;
      }
      throw error;
    }
  }
}

async function processChangeIdempotently(change) {
  // Use upsert with version check to handle duplicates
  await readModelCollection.updateOne(
    { _id: change.documentKey._id },
    { $set: { ...change.fullDocument, _lastEventId: change._id } },
    { upsert: true }
  );
}
```

## Sources

| Source | Type | Key Contribution |
|--------|------|------------------|
| [MongoDB Change Streams](https://www.mongodb.com/docs/manual/changeStreams/) | Official docs | Core mechanics, availability, cursor lifecycle |
| [Change Streams Production Recommendations](https://www.mongodb.com/docs/manual/administration/change-streams-production-recommendations/) | Official docs | Oplog sizing, sharded cluster considerations, performance |
| [On-Demand Materialized Views](https://www.mongodb.com/docs/manual/core/materialized-views/) | Official docs | MV creation, refresh patterns, comparison with standard views |
| [$merge Aggregation Stage](https://www.mongodb.com/docs/manual/reference/operator/aggregation/merge/) | Official docs | whenMatched/whenNotMatched options, incremental updates |
| [MongoDB Views](https://www.mongodb.com/docs/manual/core/views/) | Official docs | Standard view behavior, limitations, access control |
| [Building With Patterns: The Computed Pattern](https://www.mongodb.com/blog/post/building-with-patterns-the-computed-pattern) | Vendor blog | Pre-computing for read-heavy workloads, CPU reduction |
| [CQRS Exploration Plan](./2026-01-21-exploration-plan.md) | Internal | Context on Viya TMS use cases and overall research scope |

## Questions for Further Research

- [ ] What is the maximum practical number of concurrent change streams a MongoDB deployment can support?
- [ ] How do Atlas Triggers compare to self-managed change stream handlers for MV refresh?
- [ ] What patterns exist for handling schema evolution in materialized views?
- [ ] How to implement "read-your-own-writes" guarantees in a CQRS architecture?
- [ ] What monitoring/alerting should be in place for change stream lag?
- [ ] How does multi-tenant (organization-scoped) data affect MV design?
