# ADR-003: Event-Driven Integration

| Property | Value |
|----------|-------|
| **Status** | Accepted |
| **Date** | 2023-06 |
| **Decision Makers** | Engineering Team |
| **Technical Area** | Integration |

## Context

With microservices architecture ([ADR-002](./002-microservices-architecture.md)), services need to communicate changes without tight coupling. Key scenarios:

1. **Webhook delivery** - When a shipment changes, notify customer systems
2. **Audit logging** - Every significant action must be logged for compliance
3. **Tracking updates** - Carrier tracking events need to flow to multiple consumers
4. **Notifications** - Alert users when orders fail or pickups are scheduled

Requirements:

- **Reliability** - Messages must not be lost (audit, webhooks are critical)
- **Decoupling** - Publishers shouldn't know about subscribers
- **Scalability** - Handle bursts during peak shipping hours
- **Ordering** - Events for same shipment should be processed in order (when needed)
- **Observability** - Trace events across services

## Decision

We will use **AWS SNS/SQS** for event-driven integration between services.

- **SNS (Simple Notification Service)** - Pub/sub for fan-out to multiple subscribers
- **SQS (Simple Queue Service)** - Durable queues for reliable processing

Pattern: Publishers send to SNS topics; each subscriber has an SQS queue subscribed to topics it cares about.

## Options Considered

### Option 1: Direct HTTP Calls

Services call each other directly via REST APIs.

**Pros:**
- Simple to implement
- Immediate feedback (success/failure)
- Easy to debug

**Cons:**
- Tight coupling (caller must know callee)
- Cascading failures (if hooks is down, shipping calls fail)
- No fan-out (caller must know all consumers)
- Retry logic in every caller

### Option 2: RabbitMQ

Self-managed message broker with sophisticated routing.

**Pros:**
- Flexible routing patterns
- Better delivery guarantees
- Local development is straightforward

**Cons:**
- Operational burden (manage cluster)
- Scaling requires manual intervention
- Another component to maintain

### Option 3: AWS SNS/SQS ✓

Managed pub/sub (SNS) and queuing (SQS) services.

**Pros:**
- Fully managed, scales automatically
- SNS fan-out to multiple SQS queues
- SQS provides reliable delivery with retries
- Dead-letter queues for failed messages
- Integrates with AWS infrastructure
- Pay-per-use pricing

**Cons:**
- At-least-once delivery (must handle duplicates)
- Limited message size (256KB)
- AWS vendor lock-in
- Local development needs LocalStack

### Option 4: Apache Kafka

Distributed streaming platform with persistent log.

**Pros:**
- High throughput
- Message replay capability
- Strong ordering guarantees
- Event sourcing friendly

**Cons:**
- Complex to operate
- Overkill for current scale
- Higher cost and expertise required
- Steeper learning curve

## Consequences

### Positive

- **Loose coupling** - Services don't know about each other; just publish events
- **Reliability** - SQS durably stores messages until processed
- **Fan-out** - Single event can trigger webhooks, audit, notifications
- **Resilience** - If a consumer is down, messages queue up and process when it recovers
- **Scalability** - AWS scales SNS/SQS automatically

### Negative

- **Eventual consistency** - Data may be briefly out of sync across services
- **Duplicate processing** - At-least-once delivery means handlers must be idempotent
- **Message size limit** - 256KB max; must reference large payloads via S3
- **Local complexity** - Need LocalStack for local development
- **Debugging** - Tracing events across services requires correlation IDs

### Risks

- **Message loss** - SNS delivery can fail → Mitigation: SQS dead-letter queues, monitoring
- **Ordering issues** - Events processed out of order → Mitigation: Include timestamps, design for idempotency
- **Poison messages** - Bad messages block queue → Mitigation: Dead-letter queues, alerting

## Implementation Notes

### Topics and Queues

| Topic (SNS) | Publisher | Purpose |
|-------------|-----------|---------|
| `shipping` | shipping | Shipment lifecycle events |
| `ftp` | ftp | File upload/download events |

| Queue (SQS) | Subscriber | Receives From |
|-------------|------------|---------------|
| `shipping-events` | shipping | Various internal commands |
| `hooks` | hooks | `shipping` topic (webhooks) |
| `auditor` | auditor | All topics (audit logging) |
| `stitch` | stitch | Async integration tasks |

### Event Structure

All events follow a standard envelope:

```json
{
  "eventId": "uuid",
  "eventType": "ShipmentCreated",
  "timestamp": "2024-01-15T10:30:00Z",
  "correlationId": "request-uuid",
  "tenantId": "tenant-123",
  "payload": {
    "shipmentId": "SHP-001",
    "status": "created"
  }
}
```

### Event Types (shipping domain)

From `Shipping.Events` namespace:

| Event | Trigger |
|-------|---------|
| `ShipmentCreated` | New shipment created |
| `ShipmentAccepted` | Shipment processing completed |
| `ShipmentDeclined` | Shipment processing failed |
| `ConsignmentOrdered` | Label requested from carrier |
| `ConsignmentAccepted` | Label received from carrier |
| `ConsignmentDeclined` | Carrier rejected shipment |
| `TrackingEventCreated` | New tracking update received |
| `PickupCreated` | Pickup scheduled |
| `PickupAccepted` | Carrier confirmed pickup |

### Consumer Patterns

1. **Idempotent handlers** - Use `eventId` to deduplicate
2. **Dead-letter queues** - Failed messages go to DLQ after N retries
3. **Visibility timeout** - Prevent duplicate processing during handling
4. **Batch processing** - SQS allows batch receive for efficiency

### Local Development

Use **LocalStack** to emulate SNS/SQS locally:

```yaml
# docker-compose.yaml
localstack:
  image: localstack/localstack
  environment:
    - SERVICES=sns,sqs
```

Infrastructure-as-code creates topics/queues on startup.

## Related Decisions

- [ADR-001](./001-mongodb-document-database.md) - Data storage
- [ADR-002](./002-microservices-architecture.md) - Service boundaries

## References

- [AWS SNS Documentation](https://docs.aws.amazon.com/sns/)
- [AWS SQS Documentation](https://docs.aws.amazon.com/sqs/)
- [Enterprise Integration Patterns](https://www.enterpriseintegrationpatterns.com/)
