---
topic: MongoDB Performance Optimization (Viya TMS)
date: 2026-01-28
project: mongodb-performance
sources_count: 6
status: draft
tags: [mongodb, performance, indexing, explain, aggregation, viya]
---

# MongoDB Performance Optimization (Viya TMS)

## Summary

This document captures practical MongoDB performance optimization guidance for Viya TMS services, with emphasis on how to measure and validate improvements (explain plans, index usage), and how to avoid common scalability regressions (especially N+1 / looped calls patterns across services/repositories).

Key points:

- Most performance issues come from query shapes that don't match indexes, overly broad queries that scan too much data, or aggregation pipelines that process too many documents before filtering.
- For `$regex`, case-sensitive, anchored prefix expressions can use indexes; case-insensitive regex generally won't benefit from case-insensitive indexes because `$regex` is not collation-aware.

## Key findings (with confidence)

1. Use `explain()` to validate changes, not intuition (High).
2. Case-sensitive `$regex` queries can use indexes; anchored prefix regex enables additional optimization (High).
3. Compound index prefixes matter (High).
4. Aggregation pipelines can use indexes, especially when `$match` is early (or becomes early after optimizer rewrites) (High).
5. Use `$indexStats` to understand which indexes are being used (and whether some are never used) (High).
6. In Viya services, the biggest risk is cross-service N+1 (Medium).

## Detailed analysis

### 1) Start with measurement: explain plans and keys/docs examined

Why: Performance work must be grounded in data. "Fast" should mean (a) fewer documents/keys examined, (b) fewer round trips, and (c) predictable scaling as dataset grows.

What to use:

- `db.collection.explain()` / `cursor.explain()` to get query plan details and (with verbosity) execution stats.
- `explain` ignores the plan cache and prevents caching the winning plan (useful for analysis; behavior can differ from steady state).

What to look for:

- `winningPlan` stages include `IXSCAN` (good) vs `COLLSCAN` (often bad at scale).
- In `executionStats`, compare `nReturned`, `totalKeysExamined`, and `totalDocsExamined`.

Source: https://www.mongodb.com/docs/manual/reference/explain-results/

### 2) Indexing strategy: align query shapes to indexes

#### Compound indexes and prefixes

MongoDB can use a compound index for the first field or any prefix of fields.

Example from MongoDB docs: index `{ item: 1, location: 1, stock: 1 }` supports queries on `item`, `item + location`, and `item + location + stock`.

Source: https://www.mongodb.com/docs/manual/core/index-compound/

#### Practical guidance for Viya services

- Prefer one query that returns a set over looping and querying per ID.
- If multiple queries are unavoidable, ensure each is an indexed point lookup and validate end-to-end latency.

### 3) `$regex` performance: what's safe and what's expensive

- Case-sensitive regex can use indexes when an index exists on the field.
- Further optimization occurs for prefix expressions beginning with `^` or `\\A` (e.g. `/^abc.*/`).
- Even when equivalent, `/^a/` can be faster than `/^a.*/`.
- Case-insensitive regex: case-insensitive indexes do not improve performance because `$regex` is not collation-aware.

Source: https://www.mongodb.com/docs/manual/reference/operator/query/regex/

### 4) Aggregation performance: filter early and verify optimizer rewrites

- MongoDB may rewrite pipeline order (for example, moving parts of `$match` earlier when they don't depend on computed fields).
- Aggregation pipelines can use indexes from the input collection. Use `aggregate(..., { explain: true })` to verify.

Source: https://www.mongodb.com/docs/manual/core/aggregation-pipeline-optimization/

### 5) Index usage verification: `$indexStats`

Use `$indexStats` to gather per-index usage statistics.

Notes:

- `$indexStats` must be the first stage in a pipeline.
- Stats reset on node restart, index drop/recreate, or index modification.

Source: https://www.mongodb.com/docs/manual/reference/operator/aggregation/indexStats/

### 6) Index definitions: avoid duplicating volatile code

Shipping (and other services) define indexes in code. Those definitions change over time; rather than copying index lists into documentation, treat them as a living contract:

- Before changing a query shape, check the current index definitions in the service repo.
- After changing a query shape or adding an index, verify with `explain` and (when relevant) `$indexStats`.

This doc focuses on patterns and diagnostics, not enumerating index files.

### 7) The biggest scaling regression: nested calls that become N+1

The most common (and highest impact) MongoDB performance regression we see is not a single slow query—it's a *fast* query called in a loop.

This often happens because a call stack looks “reasonable” in isolation, but becomes pathological when it is nested under an iteration:

1. A service endpoint fetches a list of IDs (shipments/consignments/handling units/etc.).
2. For each ID, the code calls another method that performs its own DB query.
3. That nested method may itself call further methods that also query the DB.

The result is an **N × M** explosion in database calls, and latency that grows linearly (or worse) with dataset size.

#### What this looks like (anti-pattern)

Pseudo-code:

```csharp
var shipments = await shipmentRepo.SearchAsync(filter); // returns N shipments
foreach (var shipment in shipments)
{
    // Hidden DB call (1 per shipment)
    shipment.HandlingUnits = await handlingUnitRepo.GetByIdsAsync(shipment.HandlingUnitIds);

    // Another hidden DB call (1 per shipment)
    shipment.LatestTracking = await trackingRepo.GetLatestForShipmentAsync(shipment.Id);
}
```

Even if each inner query is indexed and “fast”, 2 extra DB calls per shipment turns into:

- N=100 -> +200 queries
- N=1,000 -> +2,000 queries
- N=10,000 -> +20,000 queries

This also amplifies network round-trips, deserialization cost, and threadpool pressure.

#### The fix: batch at the call site (replace per-item reads with set-based queries)

The key optimization is to **collect keys first**, then issue **one query per collection** using a set filter (e.g. `$in`) and map results back.

```csharp
var shipments = await shipmentRepo.SearchAsync(filter);

var shipmentIds = shipments.Select(s => s.Id).ToList();
var handlingUnitIds = shipments.SelectMany(s => s.HandlingUnitIds).Distinct().ToList();

// 1 query instead of N
var handlingUnits = await handlingUnitRepo.GetByIdsAsync(handlingUnitIds);
var huById = handlingUnits.ToDictionary(hu => hu.Id);

// 1 query instead of N
var latestTrackingByShipmentId = await trackingRepo.GetLatestForShipmentsAsync(shipmentIds);

foreach (var shipment in shipments)
{
    shipment.HandlingUnits = shipment.HandlingUnitIds.Select(id => huById.GetValueOrDefault(id)).Where(x => x != null).ToList();
    shipment.LatestTracking = latestTrackingByShipmentId.GetValueOrDefault(shipment.Id);
}
```

#### Where to look for this in reviews

High-signal indicators:

- A method returns a list, and immediately after you see `.Select(async ...)`, `foreach`, or `.ForEach(...)` with `await` inside.
- A helper method with a “simple name” (e.g. `GetLatest…`, `Get…Summary`, `Enrich…`) does a DB query, and is called from within a loop.
- A repository method accepts a single id (`GetById`) and is used in a loop, instead of having a `GetByIds` / `GetMany` / `Search` variant.

#### Rule of thumb

If a method can be called for **many items**, it should usually have a **batched equivalent**:

- `GetById(id)` -> `GetByIds(ids)`
- `GetLatestForShipment(id)` -> `GetLatestForShipments(ids)`
- `GetForConsignment(id)` -> `GetForConsignments(ids)`

Then the *caller* decides whether to call the batched variant based on context.

#### Validation

When you apply a batching change, validate in two ways:

1. **Count the DB operations** for the endpoint (before/after) under a representative payload.
2. For each new batch query, confirm it is selective and uses indexes with `explain`.

#### What if the `$in` list gets large?

Batching with `$in` is usually a major win, but very large ID lists can create new issues (large requests, big BSON documents, long server-side planning, or returning too much data at once).

Practical approach:

- **Chunk IDs** into bounded sizes (for example, a few hundred to a few thousand IDs per query), then merge results in-memory.
- **Keep projections tight** (return only fields needed for the enrichment step) to reduce payload and deserialization cost.
- **Preserve ordering at the application layer**: MongoDB doesn't guarantee result order for `$in`; map by id and re-assemble in the desired order.

The goal is still “small number of round trips” (e.g., 5-20) instead of “one per item” (e.g., 5,000).

### 8) Testing guidance: test on large datasets early

Optimizations that look fine on small datasets can fail at scale (unindexed scans, regex that can't use indexes, pipelines that sort/group too many documents, looped calls that multiply latency). Validate with production-shaped, large datasets during testing.

## Sources

| Source | Tier | Date (as accessed) | Key contribution |
|---|---:|---|---|
| https://www.mongodb.com/docs/manual/reference/operator/query/regex/ | 1 | 2026-01-28 | Regex index usage rules; prefix expressions; case-insensitive limitations |
| https://www.mongodb.com/docs/manual/reference/explain-results/ | 1 | 2026-01-28 | Explain plan structure; executionStats; plan cache caveat |
| https://www.mongodb.com/docs/manual/core/index-compound/ | 1 | 2026-01-28 | Compound index prefixes; prefix vs non-prefix behavior |
| https://www.mongodb.com/docs/manual/core/aggregation-pipeline-optimization/ | 1 | 2026-01-28 | Pipeline optimizer behavior; index usage in aggregation |
| https://www.mongodb.com/docs/manual/reference/operator/aggregation/indexStats/ | 1 | 2026-01-28 | `$indexStats` semantics and constraints; reset behavior |
| https://www.mongodb.com/docs/manual/administration/analyzing-mongodb-performance/ | 1 | 2026-01-28 | General performance framing |

## Questions for further research

- [ ] For each Viya core collection (by service), what are the top query shapes and their explain plans at production scale?
- [ ] Which indexes are effectively unused (via `$indexStats`) and should be reviewed?
- [ ] Where do we see the highest-impact N+1 patterns (UI -> service -> repository -> MongoDB), and what batching strategy fits each?
- [ ] Which regex searches should migrate to Atlas Search (if applicable), vs being constrained to prefix regex on indexed fields?
