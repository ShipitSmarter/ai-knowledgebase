---
topic: Write Model & Command Handling Patterns in CQRS with MongoDB
date: 2026-01-21
project: cqrs-mongodb
sources_count: 9
status: reviewed
tags: [cqrs, mongodb, commands, write-model, domain-events, change-streams, materialized-views]
---

# Write Model & Command Handling Patterns in CQRS with MongoDB

## Summary

In CQRS architectures, the write model handles commands that represent user intentions and trigger state transitions. For MongoDB-based systems, commands are processed through command handlers that execute domain logic and persist changes to the write model. The critical question for TMS applications is how these write model changes propagate to read models (materialized views).

MongoDB provides three primary mechanisms for triggering read model updates: **change streams** (event-driven, near real-time), **post-command hooks** (synchronous, same transaction), and **scheduled batch jobs** (periodic refresh). Change streams are the recommended approach for most scenarios as they decouple the write and read sides while providing reliable event delivery through resume tokens. For systems not requiring Event Sourcing, a "simplified CQRS" approach using the same database with logical separation provides 80% of the benefits with significantly less complexity.

Command validation that requires data queries presents a nuanced challenge. The consensus from DDD literature is to use the write model for validation when possible, but read models may be queried when performance requires it—accepting that eventual consistency can lead to edge cases requiring compensating transactions.

## Key Findings

1. **Commands represent business intentions, not data changes** - Use names like "BookShipment" or "AssignCarrier" rather than "UpdateShipment". This aligns commands with user tasks and domain operations.

2. **Three propagation strategies exist** - Change streams (async, event-driven), synchronous updates (same transaction), and scheduled refresh (batch). Each has distinct consistency/complexity trade-offs.

3. **Change streams provide reliable event delivery** - MongoDB change streams use resume tokens for exactly-once delivery semantics, making them suitable for maintaining read model consistency without a separate message broker.

4. **Idempotent projections are essential** - Whether using change streams or message queues, projections must handle duplicate events gracefully. Store processed event IDs or use upsert operations with deterministic keys.

5. **Domain events bridge write and read models** - Commands produce domain events that projections consume. Events should contain all data needed to update read models, avoiding back-queries to the write model.

6. **Command handlers should not return query data** - Per CQS principle, commands change state but don't return data. If the UI needs the result, follow with a separate query or use optimistic UI updates.

7. **Validation can query read models with caveats** - For performance reasons, validation may use read models, but developers must handle eventual consistency edge cases (e.g., booking the last seat twice).

8. **MongoDB's `$merge` enables incremental MV updates** - Unlike `$out` which replaces collections, `$merge` can update/insert individual documents, supporting efficient partial refreshes.

## Detailed Analysis

### Command Object Design

Commands in CQRS represent the user's intent to change system state. They should:

**Naming convention**: Use imperative verbs that describe business operations:
- `CreateShipmentCommand` - not `InsertShipmentCommand`
- `ConfirmBookingCommand` - not `UpdateBookingStatusCommand`  
- `AssignCarrierCommand` - not `SetCarrierIdCommand`

**Structure**: Commands are simple DTOs (Data Transfer Objects) with the data needed to execute the operation:

```csharp
public record CreateShipmentCommand(
    Guid ShipmentId,
    string OriginAddress,
    string DestinationAddress,
    DateTime RequestedPickupDate,
    List<ConsignmentDto> Consignments
) : ICommand<Result<Guid>>;
```

Key design principles from Microsoft and MediatR patterns:
- Commands should be **immutable** (use records in C#)
- Include a **unique identifier** (command ID or correlation ID) for idempotency
- Commands can return a **result type** indicating success/failure (pragmatic exception to pure CQS)
- Use **value objects** for complex validated data (addresses, dates, quantities)

### Command Handler Patterns

Command handlers implement the business logic that processes commands. The Microsoft eShopOnContainers reference architecture demonstrates a typical pattern:

```csharp
public class CreateShipmentCommandHandler : ICommandHandler<CreateShipmentCommand, Result<Guid>>
{
    private readonly IShipmentRepository _shipmentRepository;
    private readonly IUnitOfWork _unitOfWork;
    private readonly IDateTimeProvider _dateTimeProvider;

    public async Task<Result<Guid>> Handle(
        CreateShipmentCommand command,
        CancellationToken cancellationToken)
    {
        // 1. Validate business rules
        if (command.RequestedPickupDate < _dateTimeProvider.UtcNow.AddHours(4))
        {
            return Result.Failure<Guid>(ShipmentErrors.PickupDateTooSoon);
        }

        // 2. Create domain entity (encapsulates business logic)
        var shipment = Shipment.Create(
            command.ShipmentId,
            command.OriginAddress,
            command.DestinationAddress,
            command.RequestedPickupDate,
            command.Consignments.Select(c => c.ToDomainObject()).ToList()
        );

        // 3. Persist through repository
        _shipmentRepository.Add(shipment);
        
        // 4. Commit transaction (may also publish domain events)
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return Result.Success(shipment.Id);
    }
}
```

**Handler responsibilities**:
1. **Validate** command data and business rules
2. **Load** existing aggregates if needed (for updates)
3. **Execute** domain logic through the aggregate
4. **Persist** changes through repository
5. **Publish** domain events (explicitly or via infrastructure)

### Domain Events as the Bridge

Domain events represent facts that have occurred in the system. They bridge the write model to read models:

```csharp
public record ShipmentCreatedEvent(
    Guid ShipmentId,
    string OriginAddress,
    string DestinationAddress,
    DateTime RequestedPickupDate,
    DateTime CreatedAt,
    int ConsignmentCount,
    decimal TotalWeight
) : IDomainEvent;
```

**Event design principles**:
- Events are **past tense** facts (`ShipmentCreated`, not `CreateShipment`)
- Include **all data** needed by projections to update read models
- Events should be **self-contained** (projections shouldn't need to query back)
- Consider **fat events** that include denormalized data for projection efficiency

### Propagation Strategy Comparison

#### Option 1: Change Streams (Recommended for Most Cases)

MongoDB change streams provide real-time notifications of document changes:

```csharp
// Change stream listener for shipments collection
public class ShipmentChangeStreamHandler : BackgroundService
{
    private readonly IMongoCollection<Shipment> _shipments;
    private readonly IShipmentListViewProjection _projection;
    private readonly ICheckpointStore _checkpointStore;

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        var resumeToken = await _checkpointStore.GetResumeTokenAsync("shipments");
        
        var options = new ChangeStreamOptions
        {
            FullDocument = ChangeStreamFullDocumentOption.UpdateLookup,
            ResumeAfter = resumeToken
        };

        using var cursor = await _shipments.WatchAsync(options, stoppingToken);
        
        await cursor.ForEachAsync(async change =>
        {
            await _projection.ApplyAsync(change);
            await _checkpointStore.SaveResumeTokenAsync("shipments", change.ResumeToken);
        }, stoppingToken);
    }
}
```

**Pros**:
- Decouples write and read sides
- No message broker required (MongoDB provides the event stream)
- Resume tokens enable exactly-once processing
- Near real-time (typically <100ms latency)
- Can filter events at the database level

**Cons**:
- Requires replica set or sharded cluster
- Connection pool overhead (one connection per stream)
- Handler must be running to process changes
- Backlog can grow if handler is down

**When to use**: Default choice for application-embedded read models that need near real-time updates.

#### Option 2: Synchronous Post-Command Updates

Update read models in the same transaction as the write model:

```csharp
public async Task<Result<Guid>> Handle(CreateShipmentCommand command, CancellationToken ct)
{
    using var session = await _client.StartSessionAsync();
    session.StartTransaction();
    
    try
    {
        // Write model update
        var shipment = Shipment.Create(/* ... */);
        await _shipmentRepository.AddAsync(shipment, session);
        
        // Read model update (same transaction)
        var listViewItem = new ShipmentListItem
        {
            Id = shipment.Id,
            Status = shipment.Status.ToString(),
            Origin = shipment.Origin.City,
            // ... denormalized fields
        };
        await _shipmentListViewCollection.InsertOneAsync(session, listViewItem);
        
        await session.CommitTransactionAsync();
        return Result.Success(shipment.Id);
    }
    catch
    {
        await session.AbortTransactionAsync();
        throw;
    }
}
```

**Pros**:
- Strong consistency (read model always reflects write model)
- Simple mental model
- No eventual consistency edge cases
- No separate infrastructure needed

**Cons**:
- Tight coupling between write and read concerns
- Transaction scope grows with each read model
- Write performance degraded by read model updates
- Single point of failure (one slow projection blocks all)

**When to use**: Simple systems where immediate consistency is required and read models are few/simple.

#### Option 3: Scheduled Batch Refresh

Periodically recompute materialized views using aggregation pipelines:

```csharp
// Scheduled job (runs every 5 minutes)
public async Task RefreshShipmentListView()
{
    var pipeline = new[]
    {
        new BsonDocument("$lookup", new BsonDocument
        {
            { "from", "customers" },
            { "localField", "customerId" },
            { "foreignField", "_id" },
            { "as", "customer" }
        }),
        new BsonDocument("$unwind", "$customer"),
        new BsonDocument("$project", new BsonDocument
        {
            { "_id", 1 },
            { "status", 1 },
            { "customerName", "$customer.name" },
            { "origin", "$origin.city" },
            { "destination", "$destination.city" },
            { "createdAt", 1 }
        }),
        new BsonDocument("$merge", new BsonDocument
        {
            { "into", "shipmentListView" },
            { "whenMatched", "replace" },
            { "whenNotMatched", "insert" }
        })
    };
    
    await _shipmentsCollection.AggregateAsync<BsonDocument>(pipeline);
}
```

**Pros**:
- Simple to implement and understand
- Can rebuild entire view if needed
- No connection overhead
- Works with any MongoDB topology

**Cons**:
- Data can be stale (up to refresh interval)
- Full refresh can be expensive for large collections
- Not suitable for user-facing real-time needs

**When to use**: Reporting views, dashboards, analytics where staleness is acceptable.

### Ensuring Reliable Propagation

#### Idempotent Projections

Projections must handle duplicate events gracefully:

```csharp
public class ShipmentListProjection
{
    public async Task ApplyAsync(ChangeStreamDocument<Shipment> change)
    {
        var filter = Builders<ShipmentListItem>.Filter.Eq(x => x.Id, change.FullDocument.Id);
        
        // Upsert pattern - safe for replays
        var update = Builders<ShipmentListItem>.Update
            .Set(x => x.Status, change.FullDocument.Status.ToString())
            .Set(x => x.Origin, change.FullDocument.Origin.City)
            .Set(x => x.LastUpdated, DateTime.UtcNow)
            .SetOnInsert(x => x.CreatedAt, DateTime.UtcNow);
            
        await _collection.UpdateOneAsync(filter, update, new UpdateOptions { IsUpsert = true });
    }
}
```

#### Checkpoint Management

Store resume tokens to survive restarts:

```csharp
public class MongoCheckpointStore : ICheckpointStore
{
    private readonly IMongoCollection<Checkpoint> _checkpoints;

    public async Task SaveResumeTokenAsync(string streamName, BsonDocument resumeToken)
    {
        await _checkpoints.ReplaceOneAsync(
            c => c.StreamName == streamName,
            new Checkpoint { StreamName = streamName, ResumeToken = resumeToken, UpdatedAt = DateTime.UtcNow },
            new ReplaceOptions { IsUpsert = true }
        );
    }
}
```

#### Failure Recovery

If the change stream handler fails:
1. Handler restarts and loads last checkpoint (resume token)
2. MongoDB replays events from that point forward
3. Idempotent projections handle any duplicates safely
4. Gap in processing time results in temporary staleness, not data loss

### Command Validation Requiring Queries

Sometimes validation needs to check existing data:

```csharp
public async Task<Result<Guid>> Handle(BookShipmentCommand command, CancellationToken ct)
{
    // Option 1: Query write model (safest but may be slow)
    var existingBookings = await _shipmentRepository.GetByDateRangeAsync(command.Date);
    
    // Option 2: Query read model (faster but eventual consistency risk)
    var availableSlots = await _availabilityReadModel.GetSlotsAsync(command.Date);
    
    if (availableSlots.Count == 0)
    {
        return Result.Failure<Guid>(BookingErrors.NoSlotsAvailable);
    }
    
    // Proceed with booking...
    // Note: Another request could book the last slot between validation and save
}
```

**Handling the race condition**:
1. **Optimistic concurrency** - Use version numbers, fail on conflict
2. **Reservation pattern** - Temporarily reserve resources before confirming
3. **Compensating transactions** - Detect conflicts after commit, trigger compensation
4. **Accept and handle** - For non-critical cases, handle double-booking gracefully

### MongoDB-Specific Patterns

#### Using `$merge` for Incremental Updates

The `$merge` stage enables efficient partial updates to materialized views:

```javascript
db.shipments.aggregate([
    { $match: { updatedAt: { $gte: lastRefreshTime } } },
    { $lookup: { from: "customers", localField: "customerId", foreignField: "_id", as: "customer" } },
    { $unwind: "$customer" },
    { $project: { 
        _id: 1, 
        status: 1, 
        customerName: "$customer.name",
        origin: "$origin.city" 
    }},
    { $merge: { 
        into: "shipmentListView", 
        on: "_id",
        whenMatched: "replace",
        whenNotMatched: "insert"
    }}
])
```

#### Change Stream Filtering

Filter at the database level to reduce network traffic:

```csharp
var pipeline = new EmptyPipelineDefinition<ChangeStreamDocument<BsonDocument>>()
    .Match(change => 
        change.OperationType == ChangeStreamOperationType.Insert ||
        change.OperationType == ChangeStreamOperationType.Update ||
        change.OperationType == ChangeStreamOperationType.Replace)
    .Match("fullDocument.organizationId", organizationId); // Multi-tenant filter
```

## Sources

| Source | Type | Key Contribution |
|--------|------|------------------|
| [Microsoft CQRS Pattern](https://learn.microsoft.com/azure/architecture/patterns/cqrs) | Official docs | Comprehensive pattern definition; command vs query separation |
| [Microsoft .NET Microservices eBook - CQRS Reads](https://learn.microsoft.com/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/cqrs-microservice-reads) | Official docs | Practical implementation; ViewModels; Dapper for queries |
| [Microsoft DDD-Oriented Microservice](https://learn.microsoft.com/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/ddd-oriented-microservice) | Official docs | Domain model layer; command handler patterns |
| [MongoDB Change Streams](https://www.mongodb.com/docs/manual/changeStreams/) | Official docs | Real-time change notifications; resume tokens; filtering |
| [MongoDB On-Demand Materialized Views](https://www.mongodb.com/docs/manual/core/materialized-views/) | Official docs | $merge and $out stages; incremental refresh patterns |
| [Kurrent (EventStore) - Event Sourcing and CQRS](https://www.kurrent.io/blog/event-sourcing-and-cqrs) | Vendor blog | Projections; subscriptions; checkpoints; read model scope |
| [Milan Jovanovic - CQRS with MediatR](https://www.milanjovanovic.tech/blog/cqrs-pattern-with-mediatr) | Blog | Logical CQRS in single database; MediatR patterns |
| [Particular Software - Messaging Concepts](https://docs.particular.net/nservicebus/concepts/) | Vendor docs | Commands vs events; idempotency |
| [Martin Fowler - Reporting Database](https://martinfowler.com/bliki/ReportingDatabase.html) | Blog | Historical context; operations vs reporting |

## Questions for Further Research

- [ ] How do change streams perform under high write load (thousands of writes/second)?
- [ ] What are the memory implications of maintaining many concurrent change stream cursors?
- [ ] How to handle change stream gaps when the oplog rolls over during extended downtime?
- [ ] Best practices for testing command handlers with change stream projections?
- [ ] How to implement saga/process manager patterns with MongoDB without a dedicated message broker?
