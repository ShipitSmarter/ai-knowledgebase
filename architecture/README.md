# Viya Architecture

Technical architecture documentation for Viya TMS. Used by AI agents (via the `technical-architect` skill) and developers for planning features and reviewing technical decisions.

## Documents

| Document | Purpose |
|----------|---------|
| [overview.md](./overview.md) | System boundaries, services, core flows |
| [data-model.md](./data-model.md) | MongoDB schemas, entity relationships |
| [api-design.md](./api-design.md) | REST patterns, versioning, key endpoints |
| [infrastructure.md](./infrastructure.md) | Deployment, scaling, cloud services |
| [decisions/](./decisions/) | Architecture Decision Records (ADRs) |

## Quick Reference

**Tech Stack:**
- Backend: C#/.NET 8, MongoDB, AWS (SNS/SQS/S3)
- Frontend: Vue 3, TypeScript, Pinia, TailwindCSS
- Infrastructure: Kubernetes (EKS), Docker, Helm

**Core Services:**
- `shipping` - Shipments, consignments, tracking
- `stitch` - Carrier integrations (DSL engine)
- `authorizing` - Users, tokens, permissions
- `rates` - Pricing, contracts, surcharges
- `hooks` - Webhooks, scheduled jobs
- `printing` - Label printing (PrintNode)
- `ftp` - SFTP server/client
- `auditor` - Audit trail

**Key Patterns:**
- Microservices with database-per-service
- Event-driven integration via SNS/SQS
- Clean Architecture (Uncle Bob) in C# services
- OpenAPI-first with generated TypeScript clients

## Related Research

For deeper analysis, see `/research/`:
- [Service Architecture](../research/shipitsmarter-repos/2026-01-19-service-architecture.md)
- [MongoDB Data Model](../research/viya-data-model/2026-01-26-mongodb-data-model.md)
- [Repository Catalog](../research/shipitsmarter-repos/2026-01-19-repository-catalog.md)

## Contributing

When making architectural decisions:
1. Create an ADR in `decisions/` using the template
2. Update relevant docs if the decision changes system boundaries
3. Keep docs concise - link to research for deep dives
