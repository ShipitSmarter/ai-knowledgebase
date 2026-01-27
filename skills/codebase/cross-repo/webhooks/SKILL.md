---
name: webhooks
description: Understanding the webhook/event system across repositories (shipping, hooks, viya-app, viya-core). Use when adding new event types, debugging webhook delivery, or understanding how events flow from shipping to customer endpoints.
license: MIT
metadata:
  author: shipitsmarter
  version: "1.0"
---

# Webhook & Event System Architecture

The Viya platform uses an event-driven architecture where domain events (e.g., ShipmentAccepted) are published to AWS SNS, consumed by the `hooks` service, and delivered as webhooks to customer-configured endpoints.

---

## Complete Webhook Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  1. EVENT ORIGIN (Shipping Service)                                          │
│     - Events defined in /shipping/src/Shipping.Events/ (e.g., ShipmentAccepted.cs)
│     - All inherit from ShippingEventContract<T> → Event<T> from Viya.Core.Messaging
│     - Published via IShippingEventPublisher to AWS SNS                       │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  2. EVENT ROUTING (AWS Infrastructure)                                       │
│     - AWS SNS topic receives published events                                │
│     - SNS fans out to SQS queue ("hooks" queue)                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  3. EVENT CONSUMPTION (Hooks Service)                                        │
│     - Hooks.Subscriber (AwsSubscriberClient) polls SQS                       │
│     - MessageHandler.Handle(message) routes to WebhookMessageProcessor       │
│     - WebhookMessageProcessor:                                               │
│       a. Deserializes message via MessageDeserializerRegistry                │
│       b. Looks up webhooks for message.Subject in WebhooksStore              │
│          (in-memory cache from MongoDB)                                      │
│       c. For each matching webhook: validates conditions, optionally fetches │
│          resource if resource-uri present, HTTP POSTs to configured URL      │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  4. WEBHOOK DELIVERY                                                         │
│     - HTTP POST to customer-configured URL                                   │
│     - Body: { "Event": { "Id": "...", "Subject": "...", "Message": {...} } } │
│     - Includes retry logic for failed deliveries                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Adding a New Event Type

**CRITICAL: Events must be registered in THREE places!**

| Step | Repository | File | What to Add |
|------|------------|------|-------------|
| 1 | `shipping` | `/src/Shipping.Events/YourEvent.cs` | Event class with payload |
| 2 | `hooks` | `/src/Hooks.Core/DependencyInjection/CoreRegistrations.cs` | `MessageDeserializerRegistry.Register<YourEvent>()` |
| 3 | `viya-app` | `/src/views/configuration/helpers.ts` | Add to `EventNames` enum + `eventTypes` record |

### Step 1: Define the Event (Shipping)

```csharp
// /shipping/src/Shipping.Events/YourNewEvent.cs
namespace Viya.Shipping.Events;

public record YourNewEvent : ShippingEventContract<YourNewEventPayload>
{
    public override string Subject => "Viya.Shipping.Events.YourNewEvent";
}

public record YourNewEventPayload
{
    public required Guid ShipmentId { get; init; }
    public required string Reference { get; init; }
    // Add relevant payload properties
}
```

### Step 2: Register Deserializer (Hooks)

```csharp
// /hooks/src/Hooks.Core/DependencyInjection/CoreRegistrations.cs
// In the MessageDeserializerRegistry setup section:

MessageDeserializerRegistry.Register<YourNewEvent>();
```

### Step 3: Add to UI Dropdown (Viya-App)

```typescript
// /viya-app/src/views/configuration/helpers.ts

// Add to EventNames enum
export enum EventNames {
  // ... existing events
  YourNewEvent = 'Viya.Shipping.Events.YourNewEvent',
}

// Add to eventTypes record
export const eventTypes: Record<EventNames, EventType> = {
  // ... existing entries
  [EventNames.YourNewEvent]: {
    name: 'Your New Event',
    description: 'Triggered when your event occurs',
    category: 'shipment', // or 'tracking', 'consignment', etc.
  },
};
```

---

## Key Files by Repository

### Hooks Service (`/hooks`)

| File | Purpose |
|------|---------|
| `/src/Hooks.Core/Framework/Services/WebhookMessageProcessor.cs` | Main message processing and webhook dispatch |
| `/src/Hooks.Core/Framework/Services/MessageDeserializerRegistry.cs` | Event deserialization registry |
| `/src/Hooks.Core/DependencyInjection/CoreRegistrations.cs` | DI setup including event registration |
| `/src/Hooks.Subscriber/Application/SubscriberClient.cs` | SQS consumer that polls for messages |
| `/src/Hooks.Core/Framework/Services/WebhooksStore.cs` | In-memory webhook configuration cache |

### Shipping Service (`/shipping`)

| File | Purpose |
|------|---------|
| `/src/Shipping.Events/*.cs` | Event class definitions |
| `/src/Shipping.Core/Framework/Services/ShippingEventPublisher.cs` | Publishes events to SNS |
| `/src/Shipping.Core/Framework/Services/IShippingEventPublisher.cs` | Publisher interface |

### Viya-App (`/viya-app`)

| File | Purpose |
|------|---------|
| `/src/views/configuration/helpers.ts` | EventNames enum and eventTypes record |
| `/src/views/configuration/WebhookEditPage.vue` | Webhook configuration UI |
| `/src/views/configuration/WebhooksOverviewPage.vue` | Webhook list view |

### Viya-Core (`/viya-core`)

| File | Purpose |
|------|---------|
| `/src/Viya.Core.Messaging/Event.cs` | Base `Event<T>` class |
| `/src/Viya.Core.Messaging/IMessageContract.cs` | Message contract interface |
| `/src/Viya.Core.Messaging.Publisher/AwsPublisherClientSNS.cs` | SNS publisher implementation |

---

## Webhook Payload Structure

All webhooks are delivered with this standard envelope:

```json
{
  "Event": {
    "Id": "550e8400-e29b-41d4-a716-446655440000",
    "Subject": "Viya.Shipping.Events.ShipmentAccepted",
    "Message": {
      // Deserialized event payload
      "ShipmentId": "...",
      "Reference": "...",
      // Event-specific fields
    }
  }
}
```

### C# Structure

```csharp
public class WebhookRequest
{
    public EventInformation Event { get; set; }
    
    public class EventInformation
    {
        public string Id { get; set; }           // Message ID
        public string Subject { get; set; }      // e.g., "Viya.Shipping.Events.ShipmentAccepted"
        public object Message { get; set; }      // Deserialized event payload
    }
}
```

---

## Currently Supported Events

Events registered in `hooks/src/Hooks.Core/DependencyInjection/CoreRegistrations.cs`:

### Shipment Events
- `ShipmentCreated` - Shipment created in system
- `ShipmentOrdered` - Shipment sent to carrier
- `ShipmentAccepted` - Carrier accepted the shipment
- `ShipmentDeclined` - Carrier rejected the shipment
- `ShipmentRateUpdated` - Rate information updated

### Tracking Events
- `TrackingEventCreated` - New tracking scan received
- `TrackingEventUpdated` - Tracking event modified
- `TrackingEventBatchInserted` - Batch of tracking events

### Consignment Events
- `ConsignmentAccepted` - Carrier accepted consignment
- `ConsignmentDeclined` - Carrier rejected consignment
- `ConsignmentOrdered` - Consignment sent to carrier

### Pickup Events
- `PickupCreated` - Pickup scheduled
- `PickupRequested` - Pickup request sent
- `PickupAccepted` - Carrier confirmed pickup
- `PickupRejected` - Carrier rejected pickup
- `PickupDeparted` - Pickup completed
- `PickupCanceled` - Pickup cancelled
- `PickupDeleted` - Pickup removed
- `PickupReset` - Pickup reset to initial state

---

## Debugging Webhooks

### Event Not Being Delivered?

1. **Check event is published** (Shipping)
   - Verify `IShippingEventPublisher.Publish<T>()` is called
   - Check CloudWatch logs for SNS publish

2. **Check event is registered** (Hooks)
   - Verify `MessageDeserializerRegistry.Register<T>()` in CoreRegistrations.cs
   - Missing registration = silent failure (message consumed but not processed)

3. **Check webhook configuration** (MongoDB)
   ```javascript
   // In hooks database
   db.webhooks.find({ events: "Viya.Shipping.Events.YourEvent" })
   ```

4. **Check webhook conditions**
   - WebhookMessageProcessor validates conditions before dispatch
   - Review condition logic in webhook configuration

### Testing Webhooks Locally

1. **Use webhook.site or similar** for a test endpoint
2. **Configure a test webhook** in the UI pointing to your test endpoint
3. **Trigger the event** (e.g., create/order a shipment)
4. **Check hooks service logs** for processing information

---

## Architecture Diagram

```
┌──────────────┐     ┌─────────────┐     ┌─────────────┐     ┌──────────────┐
│   Viya-App   │     │  Shipping   │     │    Hooks    │     │   Customer   │
│  (Frontend)  │     │  Service    │     │   Service   │     │   Endpoint   │
└──────┬───────┘     └──────┬──────┘     └──────┬──────┘     └──────┬───────┘
       │                    │                   │                   │
       │ Configure          │                   │                   │
       │ Webhooks           │                   │                   │
       │ ───────────────────│───────────────────│───► MongoDB       │
       │                    │                   │    (webhooks      │
       │                    │                   │     collection)   │
       │                    │                   │                   │
       │                    │ Publish Event     │                   │
       │                    │ ──────────────►   │                   │
       │                    │     AWS SNS       │                   │
       │                    │                   │                   │
       │                    │                   │ Poll SQS          │
       │                    │                   │ ◄─────────────    │
       │                    │                   │                   │
       │                    │                   │ Lookup Webhooks   │
       │                    │                   │ for Event Subject │
       │                    │                   │                   │
       │                    │                   │ HTTP POST         │
       │                    │                   │ ─────────────────►│
       │                    │                   │                   │
```

---

## Event Inheritance Chain

```
IMessageContract (viya-core)
    │
    ▼
Event<T> (viya-core)
    │
    ▼
ShippingEventContract<T> (shipping)
    │
    ▼
Specific Events (shipping)
    - ShipmentAccepted
    - TrackingEventCreated
    - etc.
```

---

## Related Skills

| Skill | When to Use |
|-------|-------------|
| **shipping-structure** | Understanding Shipping service codebase |
| **logistics-entities** | Understanding Shipment, Consignment, HandlingUnit relationships |
| **viya-app-structure** | Finding frontend configuration files |
| **mongodb-development** | Querying webhook configurations |
