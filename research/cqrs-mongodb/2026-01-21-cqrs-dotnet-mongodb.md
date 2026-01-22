---
topic: CQRS in C#/.NET with MongoDB
date: 2026-01-21
project: cqrs-mongodb
sources_count: 9
status: reviewed
tags: [cqrs, dotnet, mongodb, mediatr, change-streams, clean-architecture, implementation]
---

# CQRS in C#/.NET with MongoDB

## Summary

This document provides implementation-specific guidance for CQRS (Command Query Responsibility Segregation) patterns in C#/.NET applications using MongoDB as the data store. The focus is on practical patterns applicable to Viya TMS and similar enterprise applications.

The core library stack for CQRS in .NET is **MediatR** for command/query dispatch, **MongoDB.Driver** for data access, and **BackgroundService** (or IHostedService) for change stream handlers. MediatR provides a clean separation between command/query definition and handling through its `IRequest<T>/IRequestHandler<T>` pattern, while MongoDB's change streams enable event-driven synchronization of read models without external message brokers.

Key insight: Microsoft's eShopOnContainers reference application demonstrates that CQRS doesn't require separate databases or event sourcing. A "simplified CQRS" approach uses the same database with logical separation—applying DDD patterns to the write side while keeping queries simple and optimized for reading. This pragmatic approach fits well with MongoDB, where the same database can serve both command handlers (writing to source collections) and query handlers (reading from materialized views).

## Key Findings

1. **MediatR is the de facto standard** for CQRS in .NET—it decouples in-process message sending from handling with minimal overhead. Commands and queries are both implemented as `IRequest<TResponse>`, with the convention being queries return data while commands return `Unit` (void) or a result type.

2. **Pipeline behaviors provide cross-cutting concerns**—validation, logging, transaction management, and performance monitoring can be added as behaviors that wrap all request handlers without modifying handler code.

3. **MongoDB change streams enable event-driven MV updates**—the C# driver's `Watch()` method returns a cursor that yields change events in real-time, which can be processed by a `BackgroundService` to update materialized views.

4. **Resume tokens ensure change stream reliability**—when a change stream handler restarts, it can resume from the last processed position using stored resume tokens, ensuring no events are lost during downtime.

5. **FluentValidation integrates cleanly with MediatR**—validation behaviors can automatically validate commands/queries before they reach handlers, centralizing validation logic and keeping handlers focused on business logic.

## Detailed Analysis

### 1. Structuring Commands and Queries in C#

#### The MediatR Pattern

MediatR provides two core interfaces for request handling:

```csharp
// Query - returns data
public class GetShipmentQuery : IRequest<ShipmentDto>
{
    public string ShipmentId { get; init; }
}

// Command - performs action, may return result
public class CreateShipmentCommand : IRequest<CreateShipmentResult>
{
    public string CustomerId { get; init; }
    public AddressDto Origin { get; init; }
    public AddressDto Destination { get; init; }
}

// Command - void return (uses Unit internally)
public class UpdateShipmentStatusCommand : IRequest
{
    public string ShipmentId { get; init; }
    public ShipmentStatus NewStatus { get; init; }
}
```

#### Handler Implementation

```csharp
public class GetShipmentQueryHandler : IRequestHandler<GetShipmentQuery, ShipmentDto>
{
    private readonly IMongoCollection<ShipmentReadModel> _readCollection;
    
    public GetShipmentQueryHandler(IMongoDatabase database)
    {
        // Query handler reads from materialized view
        _readCollection = database.GetCollection<ShipmentReadModel>("shipments_mv");
    }
    
    public async Task<ShipmentDto> Handle(
        GetShipmentQuery request, 
        CancellationToken cancellationToken)
    {
        var shipment = await _readCollection
            .Find(x => x.Id == request.ShipmentId)
            .FirstOrDefaultAsync(cancellationToken);
            
        return shipment?.ToDto();
    }
}

public class CreateShipmentCommandHandler : IRequestHandler<CreateShipmentCommand, CreateShipmentResult>
{
    private readonly IMongoCollection<Shipment> _shipments;
    
    public CreateShipmentCommandHandler(IMongoDatabase database)
    {
        // Command handler writes to source collection
        _shipments = database.GetCollection<Shipment>("shipments");
    }
    
    public async Task<CreateShipmentResult> Handle(
        CreateShipmentCommand request, 
        CancellationToken cancellationToken)
    {
        var shipment = new Shipment
        {
            Id = ObjectId.GenerateNewId().ToString(),
            CustomerId = request.CustomerId,
            Origin = request.Origin.ToDomain(),
            Destination = request.Destination.ToDomain(),
            Status = ShipmentStatus.Created,
            CreatedAt = DateTime.UtcNow
        };
        
        await _shipments.InsertOneAsync(shipment, cancellationToken: cancellationToken);
        
        return new CreateShipmentResult(shipment.Id);
    }
}
```

#### Registering MediatR with DI

```csharp
// Program.cs or Startup.cs
services.AddMediatR(cfg => {
    cfg.RegisterServicesFromAssembly(typeof(Program).Assembly);
    
    // Register behaviors in order of execution
    cfg.AddOpenBehavior(typeof(LoggingBehavior<,>));
    cfg.AddOpenBehavior(typeof(ValidationBehavior<,>));
    cfg.AddOpenBehavior(typeof(PerformanceBehavior<,>));
});
```

### 2. Pipeline Behaviors for Cross-Cutting Concerns

#### Validation Behavior with FluentValidation

```csharp
public class ValidationBehavior<TRequest, TResponse> : IPipelineBehavior<TRequest, TResponse>
    where TRequest : IRequest<TResponse>
{
    private readonly IEnumerable<IValidator<TRequest>> _validators;
    
    public ValidationBehavior(IEnumerable<IValidator<TRequest>> validators)
    {
        _validators = validators;
    }
    
    public async Task<TResponse> Handle(
        TRequest request, 
        RequestHandlerDelegate<TResponse> next, 
        CancellationToken cancellationToken)
    {
        if (!_validators.Any())
            return await next();
        
        var context = new ValidationContext<TRequest>(request);
        
        var validationResults = await Task.WhenAll(
            _validators.Select(v => v.ValidateAsync(context, cancellationToken)));
        
        var failures = validationResults
            .SelectMany(r => r.Errors)
            .Where(f => f != null)
            .ToList();
        
        if (failures.Count > 0)
            throw new ValidationException(failures);
        
        return await next();
    }
}
```

#### Logging Behavior

```csharp
public class LoggingBehavior<TRequest, TResponse> : IPipelineBehavior<TRequest, TResponse>
    where TRequest : IRequest<TResponse>
{
    private readonly ILogger<LoggingBehavior<TRequest, TResponse>> _logger;
    
    public LoggingBehavior(ILogger<LoggingBehavior<TRequest, TResponse>> logger)
    {
        _logger = logger;
    }
    
    public async Task<TResponse> Handle(
        TRequest request, 
        RequestHandlerDelegate<TResponse> next, 
        CancellationToken cancellationToken)
    {
        var requestName = typeof(TRequest).Name;
        
        _logger.LogInformation("Handling {RequestName}", requestName);
        
        var response = await next();
        
        _logger.LogInformation("Handled {RequestName}", requestName);
        
        return response;
    }
}
```

#### Performance Behavior

```csharp
public class PerformanceBehavior<TRequest, TResponse> : IPipelineBehavior<TRequest, TResponse>
    where TRequest : IRequest<TResponse>
{
    private readonly ILogger<PerformanceBehavior<TRequest, TResponse>> _logger;
    private readonly Stopwatch _timer;
    
    public PerformanceBehavior(ILogger<PerformanceBehavior<TRequest, TResponse>> logger)
    {
        _timer = new Stopwatch();
        _logger = logger;
    }
    
    public async Task<TResponse> Handle(
        TRequest request, 
        RequestHandlerDelegate<TResponse> next, 
        CancellationToken cancellationToken)
    {
        _timer.Start();
        
        var response = await next();
        
        _timer.Stop();
        
        var elapsedMs = _timer.ElapsedMilliseconds;
        
        if (elapsedMs > 500)
        {
            var requestName = typeof(TRequest).Name;
            _logger.LogWarning(
                "Long running request: {RequestName} ({ElapsedMs}ms)", 
                requestName, elapsedMs);
        }
        
        return response;
    }
}
```

### 3. MongoDB Change Stream Handlers in .NET

#### BackgroundService for Change Stream Processing

```csharp
public class ShipmentChangeStreamService : BackgroundService
{
    private readonly IMongoDatabase _database;
    private readonly ILogger<ShipmentChangeStreamService> _logger;
    private readonly IServiceProvider _serviceProvider;
    
    public ShipmentChangeStreamService(
        IMongoDatabase database,
        ILogger<ShipmentChangeStreamService> logger,
        IServiceProvider serviceProvider)
    {
        _database = database;
        _logger = logger;
        _serviceProvider = serviceProvider;
    }
    
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        var collection = _database.GetCollection<Shipment>("shipments");
        
        // Configure change stream pipeline to filter relevant operations
        var pipeline = new EmptyPipelineDefinition<ChangeStreamDocument<Shipment>>()
            .Match(change => 
                change.OperationType == ChangeStreamOperationType.Insert ||
                change.OperationType == ChangeStreamOperationType.Update ||
                change.OperationType == ChangeStreamOperationType.Replace ||
                change.OperationType == ChangeStreamOperationType.Delete);
        
        var options = new ChangeStreamOptions
        {
            FullDocument = ChangeStreamFullDocumentOption.UpdateLookup,
            // Resume from stored token if available
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
                // Graceful shutdown
                break;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Change stream error, reconnecting in 5 seconds...");
                await Task.Delay(TimeSpan.FromSeconds(5), stoppingToken);
            }
        }
    }
    
    private async Task ProcessChangeAsync(
        ChangeStreamDocument<Shipment> change, 
        CancellationToken cancellationToken)
    {
        using var scope = _serviceProvider.CreateScope();
        var mvUpdater = scope.ServiceProvider.GetRequiredService<IShipmentMvUpdater>();
        
        switch (change.OperationType)
        {
            case ChangeStreamOperationType.Insert:
            case ChangeStreamOperationType.Update:
            case ChangeStreamOperationType.Replace:
                await mvUpdater.UpsertAsync(change.FullDocument, cancellationToken);
                break;
                
            case ChangeStreamOperationType.Delete:
                var deletedId = change.DocumentKey["_id"].AsString;
                await mvUpdater.DeleteAsync(deletedId, cancellationToken);
                break;
        }
        
        _logger.LogDebug(
            "Processed {Operation} for shipment {Id}", 
            change.OperationType, 
            change.DocumentKey);
    }
    
    private async Task<BsonDocument?> GetStoredResumeTokenAsync()
    {
        // Load from persistent storage (e.g., dedicated collection)
        var tokenCollection = _database.GetCollection<ResumeTokenDocument>("_changestream_tokens");
        var doc = await tokenCollection
            .Find(x => x.StreamName == "shipments")
            .FirstOrDefaultAsync();
        return doc?.Token;
    }
    
    private async Task StoreResumeTokenAsync(BsonDocument token)
    {
        var tokenCollection = _database.GetCollection<ResumeTokenDocument>("_changestream_tokens");
        await tokenCollection.ReplaceOneAsync(
            x => x.StreamName == "shipments",
            new ResumeTokenDocument { StreamName = "shipments", Token = token, UpdatedAt = DateTime.UtcNow },
            new ReplaceOptions { IsUpsert = true });
    }
}

public class ResumeTokenDocument
{
    public string StreamName { get; set; }
    public BsonDocument Token { get; set; }
    public DateTime UpdatedAt { get; set; }
}
```

#### Materialized View Updater

```csharp
public interface IShipmentMvUpdater
{
    Task UpsertAsync(Shipment shipment, CancellationToken cancellationToken);
    Task DeleteAsync(string shipmentId, CancellationToken cancellationToken);
}

public class ShipmentMvUpdater : IShipmentMvUpdater
{
    private readonly IMongoCollection<ShipmentReadModel> _mvCollection;
    
    public ShipmentMvUpdater(IMongoDatabase database)
    {
        _mvCollection = database.GetCollection<ShipmentReadModel>("shipments_mv");
    }
    
    public async Task UpsertAsync(Shipment shipment, CancellationToken cancellationToken)
    {
        var readModel = new ShipmentReadModel
        {
            Id = shipment.Id,
            CustomerName = shipment.Customer?.Name, // Denormalized
            OriginCity = shipment.Origin?.City,
            DestinationCity = shipment.Destination?.City,
            Status = shipment.Status.ToString(),
            CreatedAt = shipment.CreatedAt,
            // Pre-computed fields
            DaysInTransit = CalculateDaysInTransit(shipment),
            IsDelayed = IsDelayed(shipment)
        };
        
        await _mvCollection.ReplaceOneAsync(
            x => x.Id == readModel.Id,
            readModel,
            new ReplaceOptions { IsUpsert = true },
            cancellationToken);
    }
    
    public async Task DeleteAsync(string shipmentId, CancellationToken cancellationToken)
    {
        await _mvCollection.DeleteOneAsync(x => x.Id == shipmentId, cancellationToken);
    }
}
```

### 4. Clean Architecture Alignment

#### Project Structure

```
src/
├── Domain/
│   ├── Entities/
│   │   └── Shipment.cs
│   ├── ValueObjects/
│   │   └── Address.cs
│   └── Enums/
│       └── ShipmentStatus.cs
│
├── Application/
│   ├── Commands/
│   │   ├── CreateShipment/
│   │   │   ├── CreateShipmentCommand.cs
│   │   │   ├── CreateShipmentCommandHandler.cs
│   │   │   └── CreateShipmentCommandValidator.cs
│   │   └── UpdateShipmentStatus/
│   │       └── ...
│   ├── Queries/
│   │   ├── GetShipment/
│   │   │   ├── GetShipmentQuery.cs
│   │   │   ├── GetShipmentQueryHandler.cs
│   │   │   └── ShipmentDto.cs
│   │   └── ListShipments/
│   │       └── ...
│   ├── Behaviors/
│   │   ├── ValidationBehavior.cs
│   │   └── LoggingBehavior.cs
│   └── Interfaces/
│       ├── IShipmentRepository.cs (write)
│       └── IShipmentReadRepository.cs (read)
│
├── Infrastructure/
│   ├── Persistence/
│   │   ├── MongoDbContext.cs
│   │   ├── Repositories/
│   │   │   ├── ShipmentRepository.cs
│   │   │   └── ShipmentReadRepository.cs
│   │   └── ChangeStreams/
│   │       ├── ShipmentChangeStreamService.cs
│   │       └── ShipmentMvUpdater.cs
│   └── DependencyInjection.cs
│
└── WebApi/
    ├── Controllers/
    │   └── ShipmentsController.cs
    └── Program.cs
```

#### Repository Pattern with Separate Read/Write Interfaces

```csharp
// Write repository - works with domain entities
public interface IShipmentRepository
{
    Task<Shipment?> GetByIdAsync(string id, CancellationToken cancellationToken);
    Task AddAsync(Shipment shipment, CancellationToken cancellationToken);
    Task UpdateAsync(Shipment shipment, CancellationToken cancellationToken);
}

// Read repository - works with DTOs/read models directly
public interface IShipmentReadRepository
{
    Task<ShipmentDto?> GetByIdAsync(string id, CancellationToken cancellationToken);
    Task<PagedResult<ShipmentListItemDto>> ListAsync(
        ShipmentFilter filter, 
        PagingOptions paging,
        CancellationToken cancellationToken);
}
```

### 5. Testing Strategies for CQRS

#### Unit Testing Command Handlers

```csharp
public class CreateShipmentCommandHandlerTests
{
    [Fact]
    public async Task Handle_ValidCommand_CreatesShipment()
    {
        // Arrange
        var mockCollection = new Mock<IMongoCollection<Shipment>>();
        var mockDatabase = new Mock<IMongoDatabase>();
        mockDatabase.Setup(d => d.GetCollection<Shipment>("shipments", null))
            .Returns(mockCollection.Object);
        
        var handler = new CreateShipmentCommandHandler(mockDatabase.Object);
        
        var command = new CreateShipmentCommand
        {
            CustomerId = "cust-123",
            Origin = new AddressDto { City = "Amsterdam" },
            Destination = new AddressDto { City = "Rotterdam" }
        };
        
        // Act
        var result = await handler.Handle(command, CancellationToken.None);
        
        // Assert
        result.ShipmentId.Should().NotBeNullOrEmpty();
        mockCollection.Verify(c => c.InsertOneAsync(
            It.Is<Shipment>(s => s.CustomerId == "cust-123"),
            null,
            CancellationToken.None), Times.Once);
    }
}
```

#### Integration Testing with MongoDB

```csharp
public class ShipmentQueryHandlerIntegrationTests : IClassFixture<MongoDbFixture>
{
    private readonly IMongoDatabase _database;
    
    public ShipmentQueryHandlerIntegrationTests(MongoDbFixture fixture)
    {
        _database = fixture.Database;
    }
    
    [Fact]
    public async Task GetShipmentQuery_ExistingShipment_ReturnsDto()
    {
        // Arrange
        var mvCollection = _database.GetCollection<ShipmentReadModel>("shipments_mv");
        var testShipment = new ShipmentReadModel
        {
            Id = "test-123",
            CustomerName = "Test Customer",
            Status = "Created"
        };
        await mvCollection.InsertOneAsync(testShipment);
        
        var handler = new GetShipmentQueryHandler(_database);
        var query = new GetShipmentQuery { ShipmentId = "test-123" };
        
        // Act
        var result = await handler.Handle(query, CancellationToken.None);
        
        // Assert
        result.Should().NotBeNull();
        result.Id.Should().Be("test-123");
        result.CustomerName.Should().Be("Test Customer");
    }
}
```

#### Testing Pipeline Behaviors

```csharp
public class ValidationBehaviorTests
{
    [Fact]
    public async Task Handle_InvalidRequest_ThrowsValidationException()
    {
        // Arrange
        var validator = new CreateShipmentCommandValidator();
        var behavior = new ValidationBehavior<CreateShipmentCommand, CreateShipmentResult>(
            new[] { validator });
        
        var invalidCommand = new CreateShipmentCommand
        {
            CustomerId = "", // Invalid - required
            Origin = null   // Invalid - required
        };
        
        Task<CreateShipmentResult> Next() => Task.FromResult(new CreateShipmentResult("id"));
        
        // Act & Assert
        await Assert.ThrowsAsync<ValidationException>(() =>
            behavior.Handle(invalidCommand, Next, CancellationToken.None));
    }
}
```

### 6. Integration with Viya Architecture

For Viya TMS specifically:

1. **Service Registration**: Add MediatR and change stream services to the DI container in `Program.cs`

2. **Multi-tenancy**: Change stream handlers should be organization-aware, filtering changes by `organizationId`

3. **Existing Patterns**: The command/query structure aligns with existing Viya API patterns—controllers become thin dispatchers to MediatR

4. **Gradual Migration**: CQRS can be adopted incrementally—start with new features, then migrate existing endpoints

## Sources

| Source | Key Contribution |
|--------|------------------|
| [Microsoft CQRS/DDD in eShopOnContainers](https://learn.microsoft.com/en-us/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/) | Simplified CQRS pattern, same-database approach, DDD for write side |
| [Microsoft CQRS Reads Implementation](https://learn.microsoft.com/en-us/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/cqrs-microservice-reads) | ViewModels for queries, Dapper micro-ORM approach |
| [MediatR Wiki - Home](https://github.com/jbogard/MediatR/wiki) | IRequest/IRequestHandler patterns, notifications, setup |
| [MediatR Wiki - Behaviors](https://github.com/jbogard/MediatR/wiki/Behaviors) | Pipeline behaviors, pre/post processors |
| [MongoDB Change Streams Docs](https://www.mongodb.com/docs/manual/changeStreams/) | Watch API, resume tokens, pipeline filtering |
| [MongoDB C# Driver Docs](https://www.mongodb.com/docs/drivers/csharp/current/) | .NET driver v3.5, CRUD operations, aggregation |
| [Microsoft Worker Services](https://learn.microsoft.com/en-us/dotnet/core/extensions/workers) | BackgroundService, IHostedService patterns |
| [FluentValidation ASP.NET Docs](https://docs.fluentvalidation.net/en/latest/aspnet.html) | Validator setup, DI registration, manual validation |
| [Microsoft eShop CQRS Approach](https://learn.microsoft.com/en-us/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/eshoponcontainers-cqrs-ddd-microservice) | CQRS is not top-level architecture, applies within bounded contexts |

## Questions for Further Research

- [ ] How to handle eventual consistency in UI when user creates shipment but MV not yet updated?
- [ ] What's the optimal batch size for processing change stream events?
- [ ] How to implement idempotency in command handlers for retry scenarios?
- [ ] Should validation that requires database lookups happen in validator or handler?
- [ ] How to version commands/queries when API evolves?
