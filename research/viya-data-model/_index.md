# Viya Data Model

Documentation of MongoDB database structure, entity relationships, and cross-service data flows for Viya TMS.

## Documents

| Date | Topic | Status |
|------|-------|--------|
| 2026-01-26 | [MongoDB Entity Relationships & Data Model](./2026-01-26-mongodb-data-model.md) | draft |

## Key Insights

- **Microservices isolation**: Each service owns its MongoDB database
- **Event-driven integration**: Services communicate via AWS SNS/SQS, not direct DB access
- **Embedded vs Referenced**: Shipping database uses mix - addresses embedded, handling units referenced
- **Tenant isolation**: All queries filter by tenantId

## Related Research

- [Service Architecture](../shipitsmarter-repos/2026-01-19-service-architecture.md) - Overall system architecture
- [Reporting Materialized Views](../viya-reporting/2026-01-20-reporting-materialized-views.md) - Shipping DB schema details
