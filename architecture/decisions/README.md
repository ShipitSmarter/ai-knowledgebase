# Architecture Decision Records

This folder contains Architecture Decision Records (ADRs) documenting significant technical decisions.

## Index

| ID | Title | Status | Date |
|----|-------|--------|------|
| [ADR-001](./001-mongodb-document-database.md) | MongoDB as Document Database | Accepted | 2023-01 |
| [ADR-002](./002-microservices-architecture.md) | Microservices Architecture | Accepted | 2023-01 |
| [ADR-003](./003-event-driven-integration.md) | Event-Driven Integration | Accepted | 2023-06 |

## What is an ADR?

An Architecture Decision Record captures a significant architectural decision along with its context and consequences.

**When to write an ADR:**
- Choosing a technology (database, framework, cloud service)
- Defining a pattern that all teams should follow
- Making a decision that's hard to reverse
- Making a trade-off between competing concerns

**When NOT to write an ADR:**
- Implementation details that only affect one service
- Temporary workarounds
- Obvious choices with no real alternatives

## Template

See [000-template.md](./000-template.md) for the ADR template.

## Status Values

| Status | Meaning |
|--------|---------|
| **Draft** | Under discussion, not yet decided |
| **Proposed** | Ready for review |
| **Accepted** | Decision made, should be followed |
| **Deprecated** | No longer applies (superseded or context changed) |
| **Superseded by ADR-XXX** | Replaced by another decision |
