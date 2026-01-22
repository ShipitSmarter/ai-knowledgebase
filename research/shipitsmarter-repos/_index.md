# ShipitSmarter Repository Research

This project documents the ShipitSmarter GitHub organization repositories, their purposes, and how they relate to each other.

## Documents

| Date | Document | Description | Status |
|------|----------|-------------|--------|
| 2026-01-19 | [Repository Catalog](./2026-01-19-repository-catalog.md) | Complete catalog of all repos | draft |
| 2026-01-19 | [Service Architecture](./2026-01-19-service-architecture.md) | How services connect and communicate | **final** |

## Key Findings

From Service Architecture research:

| Question | Answer |
|----------|--------|
| Identity Provider | Ory (Kratos + Oathkeeper) hosted on Ory Cloud |
| Deployment Pipeline | GitHub Actions (CI) + ArgoCD + Helm (CD) |
| Monitoring | OpenTelemetry + Grafana Tempo + Dash0 |
| Tenant Config | IUserContext middleware + Oathkeeper headers |
| Transactions | Eventual consistency via events (no sagas) |

## Quick Reference

### Core Product Repos
- `viya-app` - Main frontend application (Vue/TypeScript)
- `viya-core` - Shared .NET libraries
- `viya-ui-warehouse` - Component library

### Backend Services
- `shipping` - Core shipping/labeling service
- `stitch` - Integration engine
- `stitch-integrations` - Carrier integrations
- `auditor` - Audit logging
- `authorizing` - Authorization service
- `rates` - Rate calculations
- `hooks` - Webhooks & scheduling
- `printing` - Label printing
- `ftp` - SFTP functionality

### Infrastructure
- `aws-ng-*` - Next-gen AWS infrastructure (Terraform)
- `helm-charts` - Kubernetes Helm charts
- `data-center-*` - Platform tooling
