# ShipitSmarter Repository Research

This project documents the ShipitSmarter GitHub organization repositories, their purposes, and how they relate to each other.

## Documents

| Date | Document | Description |
|------|----------|-------------|
| 2026-01-19 | [Repository Catalog](./2026-01-19-repository-catalog.md) | Complete catalog of all repos |
| 2026-01-19 | [Service Architecture](./2026-01-19-service-architecture.md) | How services connect and communicate |

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
