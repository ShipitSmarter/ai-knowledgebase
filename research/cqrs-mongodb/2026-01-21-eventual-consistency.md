---
topic: Eventual Consistency & Staleness Management in CQRS
date: 2026-01-21
project: cqrs-mongodb
sources_count: 12
status: reviewed
tags: [cqrs, eventual-consistency, ux, optimistic-ui, mongodb, read-your-writes]
---

# Eventual Consistency & Staleness Management in CQRS

## Summary

Separating read and write models in CQRS introduces consistency delays between command execution and query visibility. Managing this "staleness window" is crucial for user experience - users expect to see their own changes immediately, while accepting that other users' changes may arrive with some delay. The key insight from UX research is that **perceived latency matters more than actual latency** - users tolerate delays when they understand what's happening and feel in control.

This research synthesizes UX best practices from Nielsen Norman Group, distributed systems patterns from Jepsen and Microsoft, and MongoDB's causal consistency features to provide practical guidance for TMS applications. The recommended approach combines **optimistic UI updates** for immediate feedback, **read-your-own-writes guarantees** for session consistency, and **clear freshness indicators** to set appropriate user expectations.

## Key Findings

1. **Nielsen's response time limits remain the standard**: 0.1s for instantaneous feel, 1s for uninterrupted flow, 10s for attention retention. Operations exceeding 10s require progress indicators and estimated completion times.

2. **Optimistic UI updates provide immediate feedback** by showing the expected final state before server confirmation, then reverting if the operation fails. This pattern is widely adopted (Twitter likes, Instagram comments, Apple Messages) and significantly increases perceived performance and user satisfaction.

3. **Read-your-own-writes is the minimum consistency guarantee** users expect - if they create or modify something, they must see that change in subsequent reads within their session. MongoDB's causally consistent sessions with `readConcern: "majority"` and `writeConcern: "majority"` provide this guarantee.

4. **Different TMS operations have different freshness requirements** - real-time dashboards need sub-second updates, list views tolerate 1-5 seconds, reports can use batch-refreshed data, and lookup/dropdowns can be stale for minutes to hours.

5. **Visibility of system status** (NN/g Heuristic #1) applies to data freshness - users should know when data was last updated and whether they're viewing potentially stale information. This reduces anxiety and increases trust.

## Detailed Analysis

### Latency Tolerance by Use Case

Based on Nielsen's response time research and TMS operational requirements:

| Use Case | Acceptable Latency | Rationale |
|----------|-------------------|-----------|
| **Operations Dashboard** | < 1 second | Real-time decision making; users expect "live" data |
| **Shipment Status Updates** | < 2 seconds | Critical for customer-facing tracking |
| **List Views (Shipments, Consignments)** | 1-5 seconds | Users accept brief delays on navigation |
| **Search Results** | 1-3 seconds | Consistency with list view expectations |
| **Dropdowns/Autocomplete** | Can be stale (minutes-hours) | Carrier list, address suggestions change infrequently |
| **Daily Reports** | Batch acceptable (15min-1hr) | Used for trend analysis, not real-time decisions |
| **Analytics/Charts** | Batch acceptable (hourly) | Historical data by nature |

#### Critical Insight: "Real-time" vs "Near-real-time"

Many TMS operations labeled "real-time" actually tolerate delays of 1-5 seconds without user complaints. True real-time requirements (< 1s) should be limited to:
- Active shipment tracking during delivery
- Operations dashboard "today's pickups" countdown
- Exception alerts requiring immediate action

### Optimistic UI Patterns

Optimistic UIs update the interface immediately upon user action, before the server confirms success. This creates a perception of instantaneous response.

#### Core Pattern

```
1. User initiates action (e.g., clicks "Mark Delivered")
2. UI immediately shows success state (button changes, row updates)
3. Command is sent to server asynchronously
4. On success: do nothing (UI already correct)
5. On failure: revert UI to previous state, show error
```

#### Implementation Considerations

**When to Use Optimistic Updates:**
- Low-consequence actions (likes, toggles, sorting preferences)
- High-success-rate operations (> 99%)
- Actions where immediate visual feedback is valuable

**When NOT to Use Optimistic Updates:**
- Financial transactions
- Irreversible operations (delete without trash)
- Operations with complex validation that may fail server-side
- Multi-step workflows requiring coordination

**Error Handling Strategies (from UX Planet):**
1. **Inline error indicators**: Show error icon next to the failed item, allow retry
2. **Revert with explanation**: Undo the optimistic change, show toast explaining why
3. **Silent retry**: Automatically retry 2-3 times before showing error (for transient failures)

**Preventing Double-Submit:**
Track pending requests per action; disable or queue subsequent requests until the first completes.

### Read-Your-Own-Writes in CQRS

The "read-your-own-writes" (RYW) guarantee ensures that within a session, any read operation observes the effects of all prior write operations from that same session.

#### Why This Matters for CQRS

In CQRS, there's a propagation delay between:
1. Command executes against write model
2. Event triggers materialized view refresh
3. Query returns from read model

Without RYW guarantees, this sequence is problematic:
```
User creates shipment → redirected to shipment list → shipment not visible
User: "Where did my shipment go?!"
```

#### Implementation Strategies

**1. Session-Scoped Caching (Client-Side)**
```
- After successful command, cache the affected entity in session storage
- When querying, merge cached entities with read model results
- Expire cache after read model is likely refreshed (e.g., 5-10 seconds)
```

**2. Bypass Read Model for Recent Writes**
```
- After command success, track affected entity IDs in session
- For ~5 seconds, query write database directly for those specific entities
- After timeout, fall back to read model
```

**3. MongoDB Causal Consistency (Recommended)**
```javascript
// Start a causally consistent session
const session = client.startSession({ causalConsistency: true });

// Write operation
await collection.updateOne(
  { _id: shipmentId },
  { $set: { status: 'delivered' } },
  { session, writeConcern: { w: 'majority' } }
);

// Subsequent read WILL see the write
const shipment = await collection.findOne(
  { _id: shipmentId },
  { session, readConcern: { level: 'majority' } }
);
```

This approach uses MongoDB's built-in cluster time to ensure the read node has received the write before returning.

**4. Hybrid: Optimistic UI + RYW Fallback**
```
1. Optimistically show the created/updated entity in UI
2. Trigger background refresh of the actual read model query
3. When refresh completes, merge results (keeping optimistic data if still pending)
4. Replace optimistic data with confirmed data once available
```

### Communicating Data Freshness to Users

Based on NN/g's "Visibility of System Status" principle, users should understand the freshness of what they're seeing.

#### Recommended Patterns

**1. Last Updated Timestamps**
Show when data was last refreshed. Format contextually:
- Recent: "Updated 30 seconds ago"
- Moderate: "Updated 5 minutes ago"  
- Stale: "Updated at 14:30"

**2. Auto-Refresh Indicators**
- Show a subtle spinner/dot animation when data is refreshing
- Indicate auto-refresh interval: "Updates every 30 seconds"
- Provide manual refresh button for user control

**3. Stale Data Warnings**
For critical data that's unusually stale, show explicit warning:
- Yellow banner: "Data may be up to 5 minutes old due to high load"
- Explicit staleness: "Showing cached data from 10:15 AM"

**4. "Just Created" Indicators**
For items the user just created (via optimistic UI):
- Subtle highlight or badge: "Just added" or pulsing animation
- Automatically remove indicator after read model catches up

#### What NOT to Do

- Don't show timestamps for reference data (carrier lists, country codes)
- Don't refresh full lists on every single change (overwhelming)
- Don't block UI waiting for read model to sync (defeats CQRS purpose)
- Don't show loading spinners for < 1 second operations (feels sluggish)

### TMS-Specific Recommendations

**Operations Dashboard**
- Use WebSocket or polling for near-real-time updates (every 5-10 seconds)
- Show "Last updated" timestamp prominently
- Individual widgets can have different refresh rates based on importance
- Critical counts (exceptions, pending pickups) refresh more frequently

**Shipment List Views**
- Initial load from materialized view (fast)
- After creating/editing shipment, use optimistic update OR session cache
- Manual refresh button + auto-refresh every 30-60 seconds
- Filter/sort changes can tolerate brief loading state

**Entity Detail Pages**
- Load from write model directly (single document, low overhead)
- Or use read model with RYW guarantee via causal sessions
- Show edit history with timestamps

**Lookup Dropdowns (Carriers, Customers)**
- Cache aggressively (5-60 minutes depending on volatility)
- Background refresh; show cached data immediately
- Only show loading indicator if cache is empty

## Sources

| Source | Type | Key Contribution |
|--------|------|------------------|
| [NN/g Response Times](https://www.nngroup.com/articles/response-times-3-important-limits/) | Primary | 0.1s/1s/10s response time limits; psychological basis for latency tolerance |
| [NN/g Progress Indicators](https://www.nngroup.com/articles/progress-indicators/) | Primary | When to use looped vs percent-done indicators; user satisfaction research |
| [NN/g Visibility of System Status](https://www.nngroup.com/articles/visibility-system-status/) | Primary | Heuristic #1; communication builds trust; "don't blindfold your users" |
| [Microsoft CQRS Pattern](https://learn.microsoft.com/en-us/azure/architecture/patterns/cqrs) | Primary | Eventual consistency challenges; separate read/write model synchronization |
| [Martin Fowler CQRS](https://martinfowler.com/bliki/CQRS.html) | Primary | CQRS raises questions about consistency; likelihood of eventual consistency |
| [Jepsen Read Your Writes](https://jepsen.io/consistency/models/read-your-writes) | Primary | Formal definition of RYW guarantee; session-scoped visibility |
| [MongoDB Causal Consistency](https://www.mongodb.com/docs/manual/core/causal-consistency-read-write-concerns/) | Primary | readConcern/writeConcern majority for causal guarantees |
| [TanStack Query Optimistic Updates](https://tanstack.com/query/latest/docs/framework/react/guides/optimistic-updates) | Primary | Client-side cache manipulation for optimistic UI; revert on error |
| [UX Planet Optimistic UIs](https://uxplanet.org/optimistic-1000-34d9eefe4c05) | Primary | Real-world examples (Messages, Instagram, Trello); error handling patterns |
| [Bits and Pieces Optimistic UI React](https://blog.bitsrc.io/building-an-optimistic-user-interface-in-react-b943656e75e3) | Secondary | setState updater factory pattern; preventing double-submit |
| AWS Prescriptive Guidance Eventual Consistency | Secondary | Cloud architecture patterns for consistency management |
| Exploration Plan | Context | Prior research context from cqrs-mongodb project |

## Questions for Further Research

- [ ] How do MongoDB change streams interact with causal consistency guarantees?
- [ ] What is the typical propagation delay for materialized view updates in MongoDB Atlas?
- [ ] How to implement optimistic UI patterns effectively in Vue 3 with Pinia stores?
- [ ] Are there patterns for "optimistic" list operations (add/remove from lists) vs single entity updates?
- [ ] How to handle optimistic updates for operations that trigger backend side-effects (e.g., creating shipment sends carrier notification)?
