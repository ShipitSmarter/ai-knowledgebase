# API Design

REST API patterns, versioning strategy, and key endpoints for Viya TMS.

## Design Principles

### 1. OpenAPI-First

All APIs are defined in OpenAPI 3.0 specs before implementation.

```yaml
# Generated clients use these specs
openapi: 3.0.3
info:
  title: Shipping API
  version: v2
paths:
  /api/shipping/v2/shipments:
    post:
      operationId: createShipment
      # ...
```

**Benefits:**
- Type-safe clients generated for frontend
- Contract testing between services
- Auto-generated documentation

### 2. Resource-Oriented URLs

```
# Good: Resources as nouns
GET  /api/shipping/v2/shipments
POST /api/shipping/v2/shipments
GET  /api/shipping/v2/shipments/{id}
PUT  /api/shipping/v2/shipments/{id}

# Actions as sub-resources
PUT  /api/shipping/v2/shipments/{id}/order
PUT  /api/shipping/v2/shipments/{id}/cancel
GET  /api/shipping/v2/shipments/{id}/labels
GET  /api/shipping/v2/shipments/{id}/tracking-events

# Bad: Verbs in URL
POST /api/shipping/v2/createShipment  ❌
POST /api/shipping/v2/shipments/order ❌ (missing {id})
```

### 3. Consistent Error Responses

All errors follow RFC 7807 Problem Details:

```json
{
  "type": "https://viya.shipitsmarter.com/errors/validation",
  "title": "Validation Error",
  "status": 400,
  "detail": "Receiver postal code is invalid for country DE",
  "instance": "/api/shipping/v2/shipments/abc123",
  "errors": [
    {
      "field": "Data.Addresses.Receiver.PostCode",
      "message": "Invalid format for German postal code"
    }
  ]
}
```

### 4. Idempotency

Non-GET operations support idempotency via headers:

```http
POST /api/shipping/v2/shipments
Idempotency-Key: client-generated-uuid
```

If the same key is sent twice, the second request returns the original response.

## Versioning Strategy

### URL-Based Versioning

```
/api/{service}/v{major}/{resource}
```

Examples:
- `/api/shipping/v2/shipments`
- `/api/authorizing/v1/users`
- `/api/rates/v1/contracts`

### When to Increment Version

| Change Type | Version Impact | Action |
|-------------|----------------|--------|
| Add optional field | None | Safe |
| Add new endpoint | None | Safe |
| Change field type | **Major** | New version |
| Remove field | **Major** | New version |
| Rename field | **Major** | New version |
| Change required→optional | None | Safe |
| Change optional→required | **Major** | New version |

### Migration Process

See [Service versioning and Migrations](../docs-external/internal/Viya/Service%20versioning%20and%20Migrations.md) for detailed steps.

Summary:
1. Create `v{N+1}` directories (contracts, controllers, tests)
2. Old version remains supported during deprecation period
3. Update swagger generation for both versions
4. Deprecate old version after migration window

## Authentication

### Bearer Token (JWT)

```http
GET /api/shipping/v2/shipments
Authorization: Bearer eyJhbGciOiJSUzI1NiIs...
```

Used by: Browser sessions via identity provider

### API Token

```http
GET /api/shipping/v2/shipments
Authorization: ApiKey sk_live_abc123...
```

Used by: Machine-to-machine integrations

Both are validated by Oathkeeper and authorized by OPA.

## Key Endpoints

### Shipping Service

| Method | Endpoint | Purpose |
|--------|----------|---------|
| `POST` | `/api/shipping/v2/shipments` | Create shipment |
| `GET` | `/api/shipping/v2/shipments/{id}` | Get shipment |
| `PUT` | `/api/shipping/v2/shipments/{id}` | Update shipment (only if `Created`) |
| `PUT` | `/api/shipping/v2/shipments/{id}/order` | Book with carrier |
| `PUT` | `/api/shipping/v2/shipments/{id}/cancel` | Cancel shipment |
| `PUT` | `/api/shipping/v2/shipments/{id}/reset` | Reset to `Created` |
| `GET` | `/api/shipping/v2/shipments/{id}/labels` | Get label PDFs |
| `GET` | `/api/shipping/v2/shipments/{id}/tracking-events` | Get tracking |
| `GET` | `/api/shipping/v2/consignments` | List consignments |
| `GET` | `/api/shipping/v2/carrier-profiles` | List carriers |

### Authorizing Service

| Method | Endpoint | Purpose |
|--------|----------|---------|
| `GET` | `/api/authorizing/v1/users/me` | Current user info |
| `GET` | `/api/authorizing/v1/users` | List users |
| `POST` | `/api/authorizing/v1/tokens` | Create API token |
| `DELETE` | `/api/authorizing/v1/tokens/{id}` | Revoke token |
| `GET` | `/api/authorizing/v1/permission-groups` | List roles |

### Rates Service

| Method | Endpoint | Purpose |
|--------|----------|---------|
| `POST` | `/api/rates/v1/calculate` | Calculate rate for shipment |
| `GET` | `/api/rates/v1/contracts` | List contracts |
| `POST` | `/api/rates/v1/contracts` | Create contract |

### Hooks Service

| Method | Endpoint | Purpose |
|--------|----------|---------|
| `GET` | `/api/hooks/v1/webhooks` | List webhooks |
| `POST` | `/api/hooks/v1/webhooks` | Create webhook |
| `GET` | `/api/hooks/v1/webhooks/{id}/deliveries` | Delivery history |

## Request/Response Patterns

### Create Shipment

```http
POST /api/shipping/v2/shipments
Content-Type: application/json

{
  "reference": "ORD-2026-00123",
  "carrierReference": "DHLPX",
  "serviceLevelReference": "DFY-B2C",
  "addresses": {
    "sender": {
      "companyName": "Acme Corp",
      "street": "Hoofdweg 123",
      "city": "Amsterdam",
      "postCode": "1012AB",
      "countryCode": "NL"
    },
    "receiver": {
      "contactName": "John Doe",
      "street": "Berliner Str. 45",
      "city": "Berlin",
      "postCode": "10115",
      "countryCode": "DE"
    }
  },
  "handlingUnits": [
    {
      "reference": "PKG-001",
      "weight": { "value": 2.5, "unit": "kg" },
      "dimensions": { "length": 30, "width": 20, "height": 15, "unit": "cm" }
    }
  ]
}
```

**Response (201 Created):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "reference": "ORD-2026-00123",
  "status": "Created",
  "createdOn": "2026-01-20T10:30:00Z",
  "_links": {
    "self": { "href": "/api/shipping/v2/shipments/550e8400..." },
    "order": { "href": "/api/shipping/v2/shipments/550e8400.../order" }
  }
}
```

### Order Shipment

```http
PUT /api/shipping/v2/shipments/550e8400.../order
```

**Response (200 OK):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "status": "Accepted",
  "carrierBookingReference": "1Z999AA10123456784",
  "trackingUrl": "https://track.dhl.com/...",
  "_links": {
    "self": { "href": "/api/shipping/v2/shipments/550e8400..." },
    "labels": { "href": "/api/shipping/v2/shipments/550e8400.../labels" },
    "cancel": { "href": "/api/shipping/v2/shipments/550e8400.../cancel" }
  }
}
```

### List with Pagination

```http
GET /api/shipping/v2/shipments?status=Created&limit=50&offset=100
```

**Response:**
```json
{
  "items": [...],
  "total": 1234,
  "limit": 50,
  "offset": 100,
  "_links": {
    "self": { "href": "/api/shipping/v2/shipments?limit=50&offset=100" },
    "next": { "href": "/api/shipping/v2/shipments?limit=50&offset=150" },
    "prev": { "href": "/api/shipping/v2/shipments?limit=50&offset=50" }
  }
}
```

## Error Handling

### HTTP Status Codes

| Code | Meaning | When to Use |
|------|---------|-------------|
| 200 | OK | Successful GET, PUT |
| 201 | Created | Successful POST |
| 204 | No Content | Successful DELETE |
| 400 | Bad Request | Validation error |
| 401 | Unauthorized | Missing/invalid auth |
| 403 | Forbidden | Authenticated but not allowed |
| 404 | Not Found | Resource doesn't exist |
| 409 | Conflict | State conflict (e.g., already ordered) |
| 422 | Unprocessable | Business rule violation |
| 500 | Server Error | Unexpected error |

### State Transition Errors

```json
{
  "type": "https://viya.shipitsmarter.com/errors/invalid-state-transition",
  "title": "Invalid State Transition",
  "status": 409,
  "detail": "Cannot cancel shipment in 'Executed' status",
  "currentStatus": "Executed",
  "allowedTransitions": []
}
```

### Carrier Integration Errors

```json
{
  "type": "https://viya.shipitsmarter.com/errors/carrier-error",
  "title": "Carrier Rejected Request",
  "status": 422,
  "detail": "DHL rejected booking: Invalid postal code for country",
  "carrier": "DHLPX",
  "carrierErrorCode": "ADDR_001",
  "carrierMessage": "Postleitzahl ungültig"
}
```

## Frontend Integration

### Generated Clients

```typescript
// Auto-generated from OpenAPI
import { ApiClient } from '@/generated/shipping';

// Type-safe API calls
const shipment = await ApiClient.GET('/api/shipping/v2/shipments/{id}', {
  params: { path: { id: shipmentId } }
});

// shipment is fully typed
console.log(shipment.data?.status);
```

### Service Layer

```typescript
// src/services/ShipmentService.ts
class ShipmentService extends BaseService {
  async createShipment(data: CreateShipmentRequest): Promise<Shipment> {
    const response = await this.client.POST('/api/shipping/v2/shipments', {
      body: data
    });
    return this.handleResponse(response);
  }
}
```

## Rate Limiting

| Endpoint Type | Limit | Window |
|---------------|-------|--------|
| Read (GET) | 1000 | 1 minute |
| Write (POST/PUT) | 100 | 1 minute |
| Bulk operations | 10 | 1 minute |

Response headers:
```http
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 947
X-RateLimit-Reset: 1705750800
```

## Related Documentation

- [Service Architecture](../research/shipitsmarter-repos/2026-01-19-service-architecture.md)
- [Coding Standards](../docs-external/internal/Viya/KnowledgeBase/Coding-Standards-Draft.md)
