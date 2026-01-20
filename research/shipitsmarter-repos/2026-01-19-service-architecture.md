---
topic: ShipitSmarter Service Architecture
date: 2026-01-19
project: shipitsmarter-repos
sources_count: 5
status: draft
tags: [architecture, microservices, authentication, data-flow]
---

# ShipitSmarter Service Architecture

## Summary

ShipitSmarter operates a **microservices architecture** with approximately 10 backend services, all written in C#/.NET. Services communicate via HTTP REST APIs and asynchronous events through AWS SNS/SQS. Each service has its own MongoDB database for data isolation. Authentication is handled through a combination of **Ory Oathkeeper** (API gateway), **OPA** (Open Policy Agent for authorization), and the **authorizing** service for user/token management.

The frontend is a **Vue 3/TypeScript SPA** (`viya-app`) that communicates with all backend services through an nginx reverse proxy that routes `/api/<service>/*` to the appropriate backend.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              FRONTEND                                    │
│                                                                          │
│   ┌──────────────────────────────────────────────────────────────────┐  │
│   │                      viya-app (Vue 3/TS)                          │  │
│   │   Uses openapi-fetch with generated types from backend schemas    │  │
│   └────────────────────────────┬─────────────────────────────────────┘  │
└────────────────────────────────┼────────────────────────────────────────┘
                                 │ HTTP /api/*
                                 ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                          API GATEWAY LAYER                               │
│                                                                          │
│   ┌───────────────┐    ┌───────────────┐    ┌───────────────┐          │
│   │     nginx     │───▶│  oathkeeper   │───▶│  opa-adapter  │          │
│   │  (routing)    │    │ (authn proxy) │    │               │          │
│   └───────────────┘    └───────────────┘    └───────┬───────┘          │
│                                                      │                   │
│                                              ┌───────▼───────┐          │
│                                              │      OPA      │          │
│                                              │ (policies)    │          │
│                                              └───────────────┘          │
└─────────────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         BACKEND SERVICES                                 │
│                                                                          │
│   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐   │
│   │  shipping   │  │   stitch    │  │ authorizing │  │   auditor   │   │
│   │  (core)     │  │ (integr.)   │  │   (auth)    │  │  (logging)  │   │
│   └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘   │
│          │                │                │                │           │
│   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐   │
│   │    rates    │  │   hooks     │  │  printing   │  │     ftp     │   │
│   │  (pricing)  │  │ (webhooks)  │  │  (labels)   │  │   (files)   │   │
│   └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘   │
└──────────┼────────────────┼────────────────┼────────────────┼──────────┘
           │                │                │                │
           ▼                ▼                ▼                ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           DATA LAYER                                     │
│                                                                          │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │                    MongoDB (per-service databases)               │   │
│   │   shipping │ authorizing │ auditor │ rates │ hooks │ printing │ ftp│
│   └─────────────────────────────────────────────────────────────────┘   │
│                                                                          │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │                    AWS SNS/SQS (async events)                    │   │
│   │   shipping-events │ hooks │ ftp │ stitch │ auditor              │   │
│   └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

## Service Dependencies

### shipping (Core Service)

The central service for shipment/labeling operations.

| Depends On | Purpose |
|------------|---------|
| `stitch` | Execute carrier integrations (label generation, tracking) |
| `authorizing` | Get user filters/permissions |
| `hooks` | Trigger webhooks on shipment events |
| `printing` | Print labels to PrintNode printers |
| `ftp` | Handle file uploads/downloads |
| MongoDB `shipping` | Shipments, orders, tracking data |
| AWS SNS | Publish shipment events |
| AWS SQS | Receive async commands |

### stitch (Integration Engine)

Executes carrier integrations using a custom DSL/templating system.

| Depends On | Purpose |
|------------|---------|
| `stitch-integrations` | Integration definitions (YAML/JS files) |
| `html-renderer` | Generate PDFs from HTML templates |
| AWS S3 | Store generated documents |
| External carriers | DHL, UPS, FedEx, etc. APIs |

### authorizing (Auth Service)

Manages users, tokens, and permissions.

| Depends On | Purpose |
|------------|---------|
| `stitch` | Unknown (likely for user provisioning flows) |
| `opa` | Policy evaluation for authorization |
| MongoDB `authorizing` | Users, tokens, permissions |

### hooks (Webhooks & Scheduling)

Delivers webhooks and runs scheduled jobs.

| Depends On | Purpose |
|------------|---------|
| `shipping` | Fetch shipment data for webhook payloads |
| Novu | Notification delivery |
| MongoDB `hooks` | Webhook configs, job schedules |
| AWS SQS | Receive events to process |

### Other Services

| Service | Depends On | Purpose |
|---------|------------|---------|
| `rates` | MongoDB `rates` | Rate calculations, contracts, surcharges |
| `printing` | MongoDB `printing`, PrintNode API | Printer management |
| `ftp` | MongoDB `ftp`, `stitch`, AWS S3 | SFTP server/client |
| `auditor` | MongoDB `auditor`, AWS SQS | Audit log aggregation |

## Authentication & Authorization Flow

```
┌─────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────┐
│ Browser │────▶│ Oathkeeper  │────▶│ OPA Adapter │────▶│   OPA   │
└─────────┘     └──────┬──────┘     └─────────────┘     └────┬────┘
                       │                                      │
                       │ (if authorized)                      │
                       ▼                                      │
               ┌───────────────┐                             │
               │    Backend    │◀────────────────────────────┘
               │   Services    │     (policy decision)
               └───────────────┘
```

### Authentication (AuthN)

1. **Ory Oathkeeper** acts as an authentication proxy
2. Validates JWT tokens from identity provider
3. Enriches requests with user identity headers
4. Routes to `mock-authn` in development for easy testing

### Authorization (AuthZ)

1. **OPA (Open Policy Agent)** evaluates Rego policies
2. Policies defined in `viya-app/authz/opa-policies/`
3. **opa-adapter** bridges Oathkeeper to OPA
4. **authorizing** service manages:
   - API tokens (hash-based lookup)
   - User profiles
   - Permission groups
   - Data groups (row-level filtering)

### Token Types

| Type | Usage |
|------|-------|
| JWT (session) | Browser sessions via Ory/Kratos |
| API Token | Machine-to-machine, hashed in DB |

## Data Flow: Shipment Creation

```
1. viya-app POST /api/shipping/v2/shipments
                    │
2. nginx routes to shipping service
                    │
3. shipping validates via authorizing
                    │
4. shipping calls stitch to generate labels
                    │
5. stitch executes carrier integration
   ├── Calls carrier API (DHL, UPS, etc.)
   └── Returns label PDFs
                    │
6. shipping stores shipment in MongoDB
                    │
7. shipping publishes ShipmentCreated to SNS
                    │
8. hooks-subscriber receives event
   └── Delivers webhooks to configured endpoints
                    │
9. auditor receives event
   └── Stores audit log entry
```

## Event System (AWS SNS/SQS)

Services communicate asynchronously through AWS SNS topics and SQS queues.

### Topics/Queues

| Topic/Queue | Publisher | Subscribers |
|-------------|-----------|-------------|
| `shipping` (SNS) | shipping | hooks, auditor |
| `shipping-events` (SQS) | various | shipping |
| `hooks` (SQS) | SNS subscriptions | hooks-subscriber |
| `ftp` (SNS) | ftp | shipping |
| `stitch` (SQS) | various | stitch |
| `auditor` (SQS) | all services | auditor |

### Event Types (shipping)

From `Shipping.Events` namespace:
- `ShipmentCreated`, `ShipmentAccepted`, `ShipmentDeclined`
- `ConsignmentOrdered`, `ConsignmentAccepted`, `ConsignmentDeclined`
- `TrackingEventCreated`, `TrackingEventUpdated`, `TrackingEventBatchInserted`
- `PickupCreated`, `PickupRequested`, `PickupAccepted`, `PickupRejected`
- `InvoiceLineBatchInserted`
- `AttributeDefinitionChanged`

## Database Schema (Per Service)

Each service owns its MongoDB database with complete isolation.

| Service | Database | Key Collections |
|---------|----------|-----------------|
| shipping | `shipping` | shipments, orders, trackingEvents, carriers, customers |
| authorizing | `authorizing` | users, tokens, permissionGroups, dataGroups |
| auditor | `auditor` | auditLogs, invoices |
| rates | `rates` | contracts, surcharges, zones, serviceLevels |
| hooks | `hooks` | webhooks, subscribers, jobs, notifications |
| printing | `printing` | printers, printJobs, printNodeSettings |
| ftp | `ftp` | ftpClients, ftpServers, files |

## Frontend API Integration

The `viya-app` uses **openapi-fetch** with generated TypeScript types from OpenAPI specs.

### Generated Clients

From `/src/generated/`:
- `shipping` - Shipment operations
- `authorizing` - User/token management
- `auditor` - Audit logs
- `rates` - Rate calculations
- `hooks` - Webhook configuration
- `printing` - Printer management
- `ftp` - FTP client/server

### API Client Pattern

```typescript
// All services accessed through unified client
import { ApiClient } from '@/services/clients';

// Type-safe API calls with path prefixes
ApiClient.GET('/shipping/v2/shipments/{id}', { params: { path: { id } } });
ApiClient.POST('/authorizing/v1/tokens', { body: tokenData });
```

### Service Layer

Each domain has a service class extending `BaseService`:
- `ShipmentService` - CRUD for shipments
- `AuthService` - User info, permissions
- `RateService` - Contract/rate operations
- etc.

## Multi-Tenancy

Data isolation is achieved through:

1. **Tenant ID filtering** - All queries include tenantId
2. **Data Groups** - authorizing service provides row-level filters
3. **API Token scoping** - Tokens bound to specific tenants

## Infrastructure

### Production (AWS)

- **EKS** - Kubernetes cluster
- **MongoDB Atlas** - Managed database
- **SNS/SQS** - Event messaging
- **S3** - Document storage
- **ECR** - Container registry

### Local Development

- **Docker Compose** - Full stack in containers
- **LocalStack** - AWS services simulation
- **MongoDB** - Single instance with replica set
- **nginx** - Reverse proxy
- **mock-authn** - Simplified authentication

## Sources

| # | Source | Key Contribution |
|---|--------|------------------|
| 1 | `viya-app/dev/docker-compose.yaml` | Service topology, dependencies |
| 2 | `viya-app/src/services/clients.ts` | Frontend API integration pattern |
| 3 | `shipping/src/Shipping.Api/appsettings.Development.json` | Service dependencies config |
| 4 | `shipping/src/Shipping.Events/*.cs` | Event type definitions |
| 5 | `authorizing/src/Authorizing.API/` | Auth controller structure |

## Questions for Further Research

- [ ] What identity provider is used in production (Ory Kratos?)?
- [ ] How are tenant configurations managed across services?
- [ ] What is the deployment pipeline (ArgoCD, Helm)?
- [ ] How do services handle distributed transactions/sagas?
- [ ] What monitoring/alerting is in place (Grafana dashboards)?
