---
topic: ShipitSmarter Repository Catalog
date: 2026-01-19
project: shipitsmarter-repos
sources_count: 1
status: draft
tags: [repositories, architecture, organization]
---

# ShipitSmarter Repository Catalog

## Summary

ShipitSmarter maintains **87 repositories** on GitHub, of which **11 are archived**. The active repositories span core product services, infrastructure-as-code, developer tooling, and supporting utilities. This catalog organizes repos by function and includes activity status based on last push date.

## Repository Categories

### Core Backend Services (C#/.NET)

These are the main microservices that power the Viya platform.

| Repository | Description | Last Active |
|------------|-------------|-------------|
| `shipping` | Core shipping and labeling microservice | 2026-01-19 |
| `stitch` | Integration engine for carrier connections | 2026-01-19 |
| `stitch-integrations` | Carrier-specific integration implementations | 2026-01-19 |
| `authorizing` | Authorization and permissions service | 2026-01-19 |
| `hooks` | Webhook delivery and scheduler service | 2026-01-19 |
| `ftp` | SFTP functionality for file transfers | 2026-01-19 |
| `auditor` | Audit logging and invoice data | 2026-01-16 |
| `rates` | Rate calculations and carrier pricing | 2026-01-16 |
| `printing` | Label printing service | 2026-01-16 |
| `ups-transport-options` | UPS-specific transport options | 2025-12-11 |

### Frontend Applications (Vue/TypeScript)

| Repository | Description | Last Active |
|------------|-------------|-------------|
| `viya-app` | Main Viya frontend application | 2026-01-19 |
| `viya-ui-warehouse` | Shared component library | 2026-01-19 |
| `viya-public-website` | Public marketing website | 2026-01-19 |
| `viya-carrier-app` | Carrier portal application | 2025-05-15 |
| `viya-ssr` | Server-side rendered Vue3 app | 2024-09-09 |

### Shared Libraries (C#)

| Repository | Description | Last Active |
|------------|-------------|-------------|
| `viya-core` | Shared .NET libraries and utilities | 2026-01-19 |
| `dotnet-templates` | .NET project templates | 2026-01-19 |
| `ShipitSmarter.TestHelpers` | Testing helper utilities | 2024-10-24 |

### Infrastructure - AWS (Terraform/HCL)

Next-generation AWS infrastructure using Terraform.

| Repository | Description | Last Active |
|------------|-------------|-------------|
| `aws-ng-accounts` | AWS account provisioning | 2026-01-15 |
| `aws-ng-apps` | Application deployments | 2026-01-15 |
| `aws-ng-core` | Core AWS infrastructure | 2026-01-06 |
| `aws-eks` | EKS cluster definitions | 2025-12-16 |
| `aws-core` | IAM, IDP, org structure | 2025-09-09 |
| `aws-networking` | VPC and networking | 2025-07-17 |
| `aws-accounts` | Account deployment | 2025-07-21 |
| `aws-logging` | Centralized logging | 2025-02-02 |

### Infrastructure - Kubernetes

| Repository | Description | Last Active |
|------------|-------------|-------------|
| `helm-charts` | Custom Helm charts | 2026-01-12 |
| `mongodb-atlas-kubernetes` | MongoDB Atlas K8s Operator | 2025-11-20 |
| `data-center-k8s` | Kubernetes playground | 2025-04-04 |
| `configmap-watcher` | ConfigMap change watcher | 2024-10-10 |

### Platform & DevOps Tools

| Repository | Description | Last Active |
|------------|-------------|-------------|
| `actions` | Reusable GitHub Actions | 2026-01-13 |
| `pr-checky` | PR tooling and sanity checks | 2026-01-15 |
| `data-center` | Platform code (misc) | 2026-01-09 |
| `data-center-scheduler` | Cron-scheduled tasks | 2026-01-15 |
| `data-center-sftp` | SFTP scripts | 2025-12-03 |
| `grafana-dashboards` | Monitoring dashboards | 2025-11-17 |
| `github-status-updater` | GitHub status updates | 2025-11-25 |
| `html-renderer` | HTML to image rendering | 2026-01-09 |
| `url-signer` | URL signing service | 2025-11-20 |
| `seeder-ui` | Database seeding UI | 2025-11-20 |
| `token-checker` | Token validation service | 2025-07-17 |

### VS Code Extensions

| Repository | Description | Last Active |
|------------|-------------|-------------|
| `vscode-stitch` | Stitch integration authoring | 2026-01-19 |
| `vscode-sops-edit` | SOPS encrypted file editing | 2024-07-11 |
| `vscode-change-naming-convention` | Naming convention helper | 2024-08-30 |

### Documentation & Knowledge

| Repository | Description | Last Active |
|------------|-------------|-------------|
| `docs` | Main documentation repo | 2026-01-19 |
| `ai-knowledgebase` | AI workflows and research | 2026-01-19 |
| `iso27001-compliancy` | ISO 27001 compliance docs | 2025-09-18 |
| `roadmap` | Product roadmap | 2025-03-25 |
| `onboarding` | Developer onboarding | 2025-08-22 |

### Infrastructure - Other

| Repository | Description | Last Active |
|------------|-------------|-------------|
| `pionative-infra` | Pionative infrastructure | 2026-01-17 |
| `OPNsense` | Firewall backups | 2026-01-09 |
| `az-alerting` | Azure resource alerting | 2026-01-06 |
| `logging` | Elasticsearch logging config | 2025-03-20 |

### Client/Customer Specific

| Repository | Description | Last Active |
|------------|-------------|-------------|
| `3m-stitch-integrations` | 3M carrier integrations | 2025-12-01 |
| `3m-tracking` | 3M tracking service | 2025-11-13 |
| `3m-shipping` | 3M shipping service | 2025-07-19 |

### Utilities & One-off Tools

| Repository | Description | Last Active |
|------------|-------------|-------------|
| `app-to-warehouse` | Code migration tooling | 2026-01-16 |
| `fileDownloader` | CSV URL file downloader | 2025-10-24 |
| `stitch-schemas` | Stitch JSON schemas | 2025-12-22 |
| `viya-seeding` | Seed data storage | 2025-12-23 |
| `multi-debug-net` | Multi-project debugging | 2025-04-30 |
| `terragrunt-action` | Terragrunt GitHub Action | 2025-07-07 |
| `zerotier-github-action` | ZeroTier GitHub Action | 2024-10-15 |
| `manual-approval` | GitHub Actions approval gate | 2024-12-11 |
| `opa-adapter` | Open Policy Agent adapter | 2025-07-17 |

### Archived Repositories

These repos are no longer actively maintained.

| Repository | Description | Archived |
|------------|-------------|----------|
| `carrier-gateway` | Stitch carrier contracts | Yes |
| `carrier-viya-app` | Old carrier portal | Yes |
| `configs` | Legacy configs | Yes |
| `aws-eks-clusters` | Old EKS cluster repo | Yes |
| `ftp-server` | Old SFTP server | Yes |
| `ftp-uploader` | Old FTP uploader | Yes |
| `kubernetes` | Old K8s/GitOps repo | Yes |
| `scheduler` | Old scheduler (replaced by hooks) | Yes |
| `shipping-ddd` | DDD experiment | Yes |
| `tenant` | Tenant blueprint | Yes |
| `tracking` | Old tracking service | Yes |
| `webhooks` | Old webhooks (replaced by hooks) | Yes |

## Activity Summary

### Very Active (pushed in last 7 days)
- `shipping`, `stitch`, `stitch-integrations`, `authorizing`, `hooks`, `ftp`
- `viya-app`, `viya-core`, `viya-ui-warehouse`, `viya-public-website`
- `docs`, `dotnet-templates`, `vscode-stitch`, `ai-knowledgebase`

### Active (pushed in last 30 days)
- `auditor`, `rates`, `printing`, `app-to-warehouse`
- `aws-ng-accounts`, `aws-ng-apps`, `pionative-infra`, `pr-checky`
- `data-center-scheduler`, `helm-charts`, `actions`

### Maintenance Mode (pushed 1-6 months ago)
- Most infrastructure repos
- Client-specific repos (3m-*)
- Supporting utilities

## Technology Stack

| Layer | Technology |
|-------|------------|
| Frontend | Vue 3, TypeScript, Vite |
| Backend Services | C# / .NET |
| Integration Engine | Stitch (custom) |
| Database | MongoDB (Atlas in prod) |
| Infrastructure | AWS, Terraform, Kubernetes |
| CI/CD | GitHub Actions |
| Monitoring | Grafana, Prometheus |
| Auth | Custom (authorizing service) |

## Sources

| # | Source | Key Contribution |
|---|--------|------------------|
| 1 | GitHub API (`gh repo list`) | Repository metadata and descriptions |

## Questions for Further Research

- [ ] How do the backend services communicate (REST, events, etc.)?
- [ ] What is the deployment flow from PR to production?
- [ ] How is multi-tenancy implemented across services?
- [ ] What databases does each service use?
