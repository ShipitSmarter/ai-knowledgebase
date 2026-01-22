# Architect Review: MV Implementation Plan

**Date:** 2026-01-21  
**Reviewed:** [plan/2026-01-21-mv-implementation-plan.md](../plan/2026-01-21-mv-implementation-plan.md)  
**Status:** Review Complete - All Critical/High Issues Resolved  
**Verdict:** Ready for implementation with 6 MVs + cache architecture

---

## Summary

The MV implementation plan proposes 6 materialized views (reduced from 9) with a hybrid refresh strategy (change streams + scheduled jobs) and MediatR-based CQRS integration. All critical and high-severity issues from the initial review have been addressed in the updated plan.

**Key Changes Since Initial Review:**
- Added Change Streams vs SNS/SQS architecture decision (Part 1)
- Added reconciliation strategy with drift detection (Part 4.4)
- Added MV worker K8s deployment specification (Part 7)
- Added Prometheus metrics and Grafana alerts (Part 8)
- Added MV versioning strategy with blue/green deployment (Part 9)
- Replaced lookup MVs with in-memory cache (reduced complexity)
- Merged `mv_shipment_lifecycle` into `mv_shipment_list` (reduced to 6 MVs)

---

## Issues Identified

| # | Issue | Severity | Category | Status |
|---|-------|----------|----------|--------|
| 1 | Change streams vs SNS/SQS conflict with ADR-003 | **Critical** | Architecture fit | **Resolved** |
| 2 | No reconciliation strategy for change stream failures | **High** | Reliability | **Resolved** |
| 3 | Hangfire deployment location unspecified | **Medium** | Infrastructure | **Resolved** |
| 4 | No MV versioning/rollback strategy | **Medium** | Operations | **Resolved** |
| 5 | Incomplete monitoring integration | **Medium** | Observability | **Resolved** |
| 6 | Lookup MVs may be over-engineered | **Low** | Complexity | **Resolved** |

---

## Issue Details

### Issue 1: Change Streams vs SNS/SQS (ADR-003 Conflict)

**Problem:** ADR-003 establishes SNS/SQS as the event-driven integration pattern. This plan introduces MongoDB Change Streams as a parallel event propagation mechanism without addressing the architectural overlap.

**Current architecture (per ADR-003):**
```
Shipment Change → SNS Topic → SQS Queues → hooks, auditor
```

**Proposed (parallel path):**
```
Shipment Change → Change Stream → MV Updaters
```

**Questions requiring answers:**

| Question | Why It Matters |
|----------|----------------|
| What's the oplog retention on Atlas? | Change streams fail if oplog rolls past resume token |
| Why not consume existing SNS events? | `ShipmentCreated`, `ConsignmentOrdered` already exist |
| What's the latency requirement? | SNS adds ~100-200ms; is that acceptable? |

**Recommendation:** Document when to use each mechanism:

| Mechanism | Use Case |
|-----------|----------|
| SNS/SQS | Cross-service events, external subscribers, audit trail |
| Change Streams | Same-database MV sync where <100ms latency required |

---

### Issue 2: Missing Reconciliation Strategy

**Problem:** Change stream handlers can lose events due to:
- Oplog rollover past stored resume token
- Handler bugs that skip documents
- Partial processing failures

The plan mentions resume token persistence but no catch-up mechanism.

**Risk:** MV diverges from source data silently.

**Recommendation:** Add reconciliation layer:

```csharp
// Nightly reconciliation job
public async Task ReconcileMvShipmentListAsync()
{
    var sourceCount = await _shipments.CountDocumentsAsync(filter);
    var mvCount = await _mvShipmentList.CountDocumentsAsync(filter);
    
    if (Math.Abs(sourceCount - mvCount) > threshold)
    {
        _logger.LogWarning("MV drift: source={S}, mv={M}", sourceCount, mvCount);
        await TriggerFullRebuildAsync("mv_shipment_list");
    }
}
```

Add metrics:
- `viya_mv_drift_count{mv}` - Records with mismatched counts
- `viya_mv_staleness_seconds{mv}` - Age of oldest unprocessed change

---

### Issue 3: Hangfire Deployment Location

**Problem:** Plan doesn't specify where Hangfire runs. Per `infrastructure.md`:
- `viya-jobs` namespace exists for CronJobs
- Hangfire is not currently deployed

**Recommendation:** Use dedicated worker service in `viya-jobs` namespace:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mv-worker
  namespace: viya-jobs
spec:
  replicas: 1
  template:
    spec:
      containers:
      - name: mv-worker
        image: shipping:latest
        command: ["dotnet", "Shipping.Worker.dll"]
        resources:
          requests: { cpu: 500m, memory: 1Gi }
          limits: { cpu: 2000m, memory: 4Gi }
```

---

### Issue 4: MV Versioning Strategy

**Problem:** No strategy for handling schema changes to MVs in production.

**Recommendation:** Blue/green MV deployment pattern:

1. Create `mv_shipment_list_v2` with new schema
2. Run full rebuild to populate v2
3. Validate: count comparison + spot checks
4. Switch query handlers to v2 (config flag)
5. Monitor for errors
6. Drop `mv_shipment_list_v1`

Add schema version to documents:

```javascript
{
  _id: { organizationId, shipmentId },
  _schemaVersion: 2,
  // ... rest of fields
}
```

---

### Issue 5: Monitoring Integration Gap

**Problem:** Part 7 lists metrics but doesn't show integration with existing Prometheus/Grafana stack.

**Required metrics:**

```yaml
viya_mv_change_stream_lag_events{mv="shipment_list"}
viya_mv_refresh_duration_seconds{mv="daily_metrics",type="incremental|full"}
viya_mv_staleness_seconds{mv="realtime_ops",org="tenant_id"}
viya_mv_error_total{mv="shipment_list",error="timeout|validation|db"}
```

**Required alerts:**

| Alert | Condition | Severity |
|-------|-----------|----------|
| MV change stream stopped | No events in 5min | Critical |
| MV refresh job failed | 3 consecutive failures | Critical |
| MV data drift detected | count diff > 1% | Warning |
| MV staleness exceeded | staleness > 2x target | Warning |

---

### Issue 6: Lookup MVs May Be Over-Engineered

**Question:** Do `mv_customer_lookup` and `mv_carrier_lookup` need to be MVs?

| Data | Cardinality | Change Frequency |
|------|-------------|------------------|
| Customers | ~100-1000/org | Low (daily) |
| Carriers | ~20-50/org | Very low (weekly) |

**Alternative:** In-memory cache with 15-minute TTL is simpler and sufficient.

**Recommendation:** Use memory cache for lookups. Reserve MVs for high-cardinality, frequently-queried data.

---

## Additional Observations

### Multi-Tenant Change Streams

Single stream filtering all orgs is correct. One stream per org doesn't scale.

### Optimistic UI

Not needed initially. Change stream latency is typically <100ms.

### Testing Change Streams

Use Testcontainers with MongoDB replica set for integration tests.

### mv_daily_metrics Cardinality

Composite `_id` with 7 fields may create excessive documents (5,000+ docs/day/org). Consider splitting into summary + detail MVs.

### mv_shipment_lifecycle vs mv_shipment_list Overlap

Evaluate if `mv_shipment_list` could include SLA fields to reduce to 8 MVs.

---

## Follow-Up Items

### Must Address Before Implementation

- [x] **ADR Required:** Create ADR-00X documenting change streams vs SNS/SQS decision
  - Owner: Architect
  - **Resolved:** Architecture decision documented in plan Part 1 (Executive Summary)
  - **Remaining:** Formal ADR document still needs to be created in `/architecture/decisions/`
   
- [ ] **Verify oplog retention:** Check Atlas oplog retention window
  - Owner: Platform/DBA
  - Blocks: Change stream design finalization
  - **Note:** Plan now documents this as a prerequisite

- [x] **Add reconciliation design:** Document reconciliation job + drift detection
  - Owner: Plan author
  - **Resolved:** Part 4.4 added with drift detection, targeted rebuild, and manual scripts

### Must Address Before Production

- [x] **Specify worker deployment:** Add MV worker K8s manifests to plan
  - Owner: DevOps + Plan author
  - **Resolved:** Part 7 added with full K8s deployment manifest, health checks, and scaling guidance

- [x] **Add versioning strategy:** Document MV schema migration approach
  - Owner: Plan author
  - **Resolved:** Part 9 Decision 4 documents blue/green deployment with `_schemaVersion` field

- [x] **Define Prometheus metrics:** Add concrete metric names and labels
  - Owner: Plan author
  - **Resolved:** Part 8 includes full metric table and Grafana alert definitions

### Should Address (Simplification) - All Resolved

- [x] **Evaluate lookup MVs:** Decide cache vs MV for customer/carrier lookups
  - **Resolved:** Replaced with `IMemoryCache` services (Part 2.3)
  - **Outcome:** Removed 2 MVs, added cache services

- [x] **Review mv_daily_metrics cardinality:** Confirm granularity is intentional
  - **Resolved:** Kept as-is; cardinality is intentional for reporting drill-down

- [x] **Evaluate lifecycle/list merge:** Can SLA fields go in mv_shipment_list?
  - **Resolved:** Merged `mv_shipment_lifecycle` into `mv_shipment_list` (Part 2.2)
  - **Outcome:** Reduced from 9 to 6 MVs

---

## Remaining Open Items

1. **Create formal ADR-00X** - Document change streams vs SNS/SQS decision in `/architecture/decisions/`
2. **Verify Atlas oplog retention** - Confirm >= 24 hours before production deployment
3. **Carrier event ingestion** - Define how carrier tracking events flow into system (for OTD)
4. **Historical data migration** - Strategy for backfilling MVs from existing shipments

---

## Review Metadata

- **Reviewer:** Technical Architect (AI-assisted)
- **Architecture docs referenced:**
  - architecture/overview.md
  - architecture/infrastructure.md
  - architecture/decisions/003-event-driven-integration.md
- **Next review:** After follow-up items addressed
