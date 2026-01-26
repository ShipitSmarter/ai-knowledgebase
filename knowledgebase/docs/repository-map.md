# ShipitSmarter Repository Map

A comprehensive guide to all ShipitSmarter repositories, their purpose, and relationships.

---

## Overview

ShipitSmarter has **100+ repositories**. This document organizes them into categories and explains what each one does.

**Legend:**
- 🟢 Active (updated in last 30 days)
- 🟡 Maintained (updated in last 90 days)
- ⚪ Stable/Dormant
- 🔴 Archived

---

## Core Application

These are the main product repositories that make up Viya.

### Frontend

| Repository | Description | Language | Status |
|------------|-------------|----------|--------|
| **[viya-app](https://github.com/ShipitSmarter/viya-app)** | Main Viya frontend application. Vue 3 + TypeScript. Contains docker-compose for local dev with all backend services. | TypeScript | 🟢 |
| **[viya-ui-warehouse](https://github.com/ShipitSmarter/viya-ui-warehouse)** | Shared component library. Published to npm as `@shipitsmarter/viya-ui-warehouse`. Storybook at storybook.viyatest.it | TypeScript | 🟢 |
| **[viya-carrier-app](https://github.com/ShipitSmarter/viya-carrier-app)** | Carrier portal frontend | Vue | 🟡 |

### Backend Services

| Repository | Description | Language | Status |
|------------|-------------|----------|--------|
| **[shipping](https://github.com/ShipitSmarter/shipping)** | Core shipping microservice. Handles shipment creation, labeling, tracking. | C# | 🟢 |
| **[stitch](https://github.com/ShipitSmarter/stitch)** | Integration engine. Transforms and routes data between carriers and Viya. | C# | 🟢 |
| **[stitch-integrations](https://github.com/ShipitSmarter/stitch-integrations)** | Carrier integration definitions (YAML). Contains mappings for all supported carriers. | HTML/YAML | 🟢 |
| **[hooks](https://github.com/ShipitSmarter/hooks)** | Webhook and scheduler service. Handles async events and scheduled tasks. | C# | 🟢 |
| **[rates](https://github.com/ShipitSmarter/rates)** | Rate management service. Handles shipper-specific custom rate cards. | C# | 🟢 |
| **[ftp](https://github.com/ShipitSmarter/ftp)** | SFTP service for Kubernetes. Server + client for file transfers with carriers. | C# | 🟢 |
| **[authorizing](https://github.com/ShipitSmarter/authorizing)** | Authorization service. Manages users, tokens, permissions. | C# | 🟢 |
| **[auditor](https://github.com/ShipitSmarter/auditor)** | Audit logging service. Provides auditability for compliance. | C# | 🟢 |
| **[printing](https://github.com/ShipitSmarter/printing)** | Label printing service | C# | 🟢 |
| **[onboarding](https://github.com/ShipitSmarter/onboarding)** | Customer onboarding service | C# | 🟡 |

### Shared Libraries

| Repository | Description | Language | Status |
|------------|-------------|----------|--------|
| **[viya-core](https://github.com/ShipitSmarter/viya-core)** | Shared .NET libraries. Contains exceptions, use case patterns, validation, serialization helpers. NuGet packages: `Viya.Core`, `Viya.Core.AspNet`, `Viya.Core.Serialization` | C# | 🟢 |
| **[dotnet-templates](https://github.com/ShipitSmarter/dotnet-templates)** | .NET project templates for new services | C# | 🟢 |
| **[stitch-schemas](https://github.com/ShipitSmarter/stitch-schemas)** | JSON schemas for Stitch integration validation | JSON | 🟡 |

---

## Infrastructure

### AWS Infrastructure (Terraform/Terragrunt)

| Repository | Description | Language | Status |
|------------|-------------|----------|--------|
| **[pionative-infra](https://github.com/ShipitSmarter/pionative-infra)** | Main infrastructure as code | HCL | 🟢 |
| **[aws-ng-accounts](https://github.com/ShipitSmarter/aws-ng-accounts)** | AWS account management (next-gen) | HCL | 🟢 |
| **[aws-ng-apps](https://github.com/ShipitSmarter/aws-ng-apps)** | AWS application infrastructure (next-gen) | Smarty | 🟢 |
| **[aws-ng-core](https://github.com/ShipitSmarter/aws-ng-core)** | AWS core infrastructure (next-gen) | HCL | 🟡 |
| **[aws-eks](https://github.com/ShipitSmarter/aws-eks)** | EKS cluster definitions | HCL | 🟡 |
| **[aws-accounts](https://github.com/ShipitSmarter/aws-accounts)** | AWS account deployment | HCL | 🟡 |
| **[aws-networking](https://github.com/ShipitSmarter/aws-networking)** | AWS network infrastructure | HCL | 🟡 |
| **[aws-core](https://github.com/ShipitSmarter/aws-core)** | AWS IAM, IDP, org structure | HCL | 🟡 |
| **[aws-logging](https://github.com/ShipitSmarter/aws-logging)** | AWS logging account setup | HCL | ⚪ |

### Kubernetes & Helm

| Repository | Description | Language | Status |
|------------|-------------|----------|--------|
| **[helm-charts](https://github.com/ShipitSmarter/helm-charts)** | Custom Helm charts for Viya services | Smarty | 🟡 |
| **[data-center-k8s](https://github.com/ShipitSmarter/data-center-k8s)** | Kubernetes playground | - | ⚪ |
| **[mongodb-atlas-kubernetes](https://github.com/ShipitSmarter/mongodb-atlas-kubernetes)** | Fork of MongoDB Atlas Kubernetes Operator | Go | 🟡 |

### Monitoring & Operations

| Repository | Description | Language | Status |
|------------|-------------|----------|--------|
| **[grafana-dashboards](https://github.com/ShipitSmarter/grafana-dashboards)** | Grafana dashboard definitions | JSON | 🟡 |
| **[logging](https://github.com/ShipitSmarter/logging)** | Elasticsearch logging configuration | Python | ⚪ |
| **[az-alerting](https://github.com/ShipitSmarter/az-alerting)** | Azure resource alerting scripts | PowerShell | 🟡 |
| **[data-center-monitoring](https://github.com/ShipitSmarter/data-center-monitoring)** | Prometheus exporters and alerting | PowerShell | ⚪ |

---

## DevOps & CI/CD

| Repository | Description | Language | Status |
|------------|-------------|----------|--------|
| **[actions](https://github.com/ShipitSmarter/actions)** | Reusable GitHub Actions. Standard build/test/deploy workflows. | Python | 🟢 |
| **[pr-checky](https://github.com/ShipitSmarter/pr-checky)** | PR tooling - custom sanity checks, auto-merge | C# | 🟢 |
| **[terragrunt-action](https://github.com/ShipitSmarter/terragrunt-action)** | GitHub Action for Terragrunt | Shell | 🟡 |
| **[manual-approval](https://github.com/ShipitSmarter/manual-approval)** | GitHub Action for manual workflow approval | Go | ⚪ |
| **[github-status-updater](https://github.com/ShipitSmarter/github-status-updater)** | Updates GitHub commit statuses | C# | 🟡 |
| **[renovate](https://github.com/ShipitSmarter/renovate)** | Renovate bot configuration | - | ⚪ |
| **[configmap-watcher](https://github.com/ShipitSmarter/configmap-watcher)** | Watches Kubernetes ConfigMaps for changes | Shell | ⚪ |
| **[pr-version-argocd-plugin](https://github.com/ShipitSmarter/pr-version-argocd-plugin)** | ArgoCD plugin for PR version detection | Go | ⚪ |

---

## Developer Tools

### VS Code Extensions

| Repository | Description | Language | Status |
|------------|-------------|----------|--------|
| **[vscode-stitch](https://github.com/ShipitSmarter/vscode-stitch)** | VS Code extension for creating Stitch integrations. Test and debug carrier integrations. | JavaScript | 🟢 |
| **[vscode-sops-edit](https://github.com/ShipitSmarter/vscode-sops-edit)** | VS Code extension for editing SOPS encrypted files | TypeScript | ⚪ |
| **[vscode-stitch-integration-templater](https://github.com/ShipitSmarter/vscode-stitch-integration-templater)** | Integration templating tool | TypeScript | ⚪ |
| **[vscode-change-naming-convention](https://github.com/ShipitSmarter/vscode-change-naming-convention)** | Naming convention converter | TypeScript | ⚪ |

### Other Tools

| Repository | Description | Language | Status |
|------------|-------------|----------|--------|
| **[app-to-warehouse](https://github.com/ShipitSmarter/app-to-warehouse)** | Tools for moving code from viya-app to viya-ui-warehouse | - | 🟢 |
| **[multi-debug-net](https://github.com/ShipitSmarter/multi-debug-net)** | Multi-service debugging helper | C# | ⚪ |
| **[ShipitSmarter.TestHelpers](https://github.com/ShipitSmarter/ShipitSmarter.TestHelpers)** | Test helper library for .NET projects | C# | ⚪ |

---

## Documentation & Knowledge

| Repository | Description | Language | Status |
|------------|-------------|----------|--------|
| **[ai-knowledgebase](https://github.com/ShipitSmarter/ai-knowledgebase)** | AI workflows, skills, commands, research. Central repository for AI tooling. | Shell | 🟢 |
| **[docs](https://github.com/ShipitSmarter/docs)** | Internal documentation and knowledge base (Obsidian-compatible) | HTML | 🟢 |
| **[roadmap](https://github.com/ShipitSmarter/roadmap)** | Public product roadmap | - | ⚪ |
| **[support](https://github.com/ShipitSmarter/support)** | Support issue tracking | - | ⚪ |
| **[iso27001-compliancy](https://github.com/ShipitSmarter/iso27001-compliancy)** | ISO 27001 compliance documentation | - | 🟡 |

---

## Public Websites

| Repository | Description | Language | Status |
|------------|-------------|----------|--------|
| **[viya-public-website](https://github.com/ShipitSmarter/viya-public-website)** | Main website at viya.me. Contains blogs, docs, careers. | TypeScript | 🟢 |
| **[ecommerce-website](https://github.com/ShipitSmarter/ecommerce-website)** | E-commerce landing page (Astro) | Astro | ⚪ |

---

## Utilities & Scripts

| Repository | Description | Language | Status |
|------------|-------------|----------|--------|
| **[data-center](https://github.com/ShipitSmarter/data-center)** | Platform code that doesn't fit elsewhere | TSQL | 🟡 |
| **[data-center-scheduler](https://github.com/ShipitSmarter/data-center-scheduler)** | Scheduled tasks with cron | PowerShell | 🟢 |
| **[data-center-sftp](https://github.com/ShipitSmarter/data-center-sftp)** | SFTP-related scripts | PowerShell | 🟡 |
| **[fileDownloader](https://github.com/ShipitSmarter/fileDownloader)** | Downloads files from URLs in CSV | Python | ⚪ |
| **[gs1-retrigger](https://github.com/ShipitSmarter/gs1-retrigger)** | Tool to resend failed files | C# | ⚪ |
| **[html-renderer](https://github.com/ShipitSmarter/html-renderer)** | HTML rendering service | Python | 🟡 |
| **[document-renderer](https://github.com/ShipitSmarter/document-renderer)** | Labelary wrapper for label rendering | C# | 🟡 |

---

## Security & Auth

| Repository | Description | Language | Status |
|------------|-------------|----------|--------|
| **[token-checker](https://github.com/ShipitSmarter/token-checker)** | Token validation service | Go | 🟡 |
| **[opa-adapter](https://github.com/ShipitSmarter/opa-adapter)** | Open Policy Agent adapter | Makefile | 🟡 |
| **[permitio-test](https://github.com/ShipitSmarter/permitio-test)** | Testing OPA policies with permit.io | OPA | ⚪ |
| **[url-signer](https://github.com/ShipitSmarter/url-signer)** | URL signing service | Go | 🟡 |
| **[OPNsense](https://github.com/ShipitSmarter/OPNsense)** | Firewall configuration backups | - | 🟡 |
| **[zerotier-github-action](https://github.com/ShipitSmarter/zerotier-github-action)** | GitHub Action for ZeroTier VPN | JavaScript | ⚪ |

---

## Customer-Specific

| Repository | Description | Language | Status |
|------------|-------------|----------|--------|
| **[3m-stitch-integrations](https://github.com/ShipitSmarter/3m-stitch-integrations)** | 3M-specific carrier integrations | Gherkin | 🟡 |
| **[3m-shipping](https://github.com/ShipitSmarter/3m-shipping)** | 3M-specific shipping customizations | C# | 🟡 |
| **[3m-tracking](https://github.com/ShipitSmarter/3m-tracking)** | 3M-specific tracking service | C# | 🟡 |
| **[ups-transport-options](https://github.com/ShipitSmarter/ups-transport-options)** | UPS transport options service | C# | 🟡 |

---

## Experimental / Internal Tools

| Repository | Description | Language | Status |
|------------|-------------|----------|--------|
| **[seeder-ui](https://github.com/ShipitSmarter/seeder-ui)** | UI for seeding data | Go | 🟡 |
| **[viya-seeding](https://github.com/ShipitSmarter/viya-seeding)** | Seed data storage | - | 🟡 |
| **[payload-ui](https://github.com/ShipitSmarter/payload-ui)** | Athena control UI | HTML | 🟡 |
| **[admin-ui](https://github.com/ShipitSmarter/admin-ui)** | Admin interface | HTML | 🟡 |
| **[docs-experiments](https://github.com/ShipitSmarter/docs-experiments)** | Documentation experiments (Astro) | Astro | ⚪ |
| **[playwright-workshop](https://github.com/ShipitSmarter/playwright-workshop)** | Playwright testing workshop | Vue | ⚪ |
| **[viya-ssr](https://github.com/ShipitSmarter/viya-ssr)** | Server-side rendering experiment | TypeScript | ⚪ |
| **[wow-evidence](https://github.com/ShipitSmarter/wow-evidence)** | Evidence dashboard (Svelte) | Svelte | ⚪ |
| **[jsonforms](https://github.com/ShipitSmarter/jsonforms)** | Fork of JSON Forms library | TypeScript | ⚪ |
| **[jsonforms-vuetify-renderers](https://github.com/ShipitSmarter/jsonforms-vuetify-renderers)** | Vuetify renderers for JSON Forms | Vue | ⚪ |
| **[system-containers](https://github.com/ShipitSmarter/system-containers)** | System support containers | C# | 🟡 |
| **[aspnetcore-good-citizen](https://github.com/ShipitSmarter/aspnetcore-good-citizen)** | K8s deployment behavior testing | C# | ⚪ |
| **[prometheus-client-asp-classic](https://github.com/ShipitSmarter/prometheus-client-asp-classic)** | Prometheus client for ASP Classic | C# | ⚪ |
| **[socket-io-sislabs](https://github.com/ShipitSmarter/socket-io-sislabs)** | Socket.io experiments | JavaScript | ⚪ |
| **[aws-demo](https://github.com/ShipitSmarter/aws-demo)** | AWS demo project | C# | ⚪ |

---

## Archived Repositories

| Repository | Description | Why Archived |
|------------|-------------|--------------|
| **carrier-gateway** | Stitch carrier contracts | Merged into stitch |
| **configs** | Configuration management | Replaced |
| **webhooks** | Webhook service | Merged into hooks |
| **scheduler** | Event scheduling | Merged into hooks |
| **ftp-server** | FTP server | Merged into ftp |
| **ftp-uploader** | FTP upload service | Merged into ftp |
| **tenant** | Tenant blueprints | No longer needed |
| **tracking** | Tracking service | Merged into shipping |
| **shipping-ddd** | DDD shipping experiment | Experiment ended |
| **kubernetes** | K8s cluster definitions | Replaced by aws-eks |
| **aws-eks-clusters** | EKS cluster configs | Replaced |
| **carrier-viya-app** | Carrier app | Replaced by viya-carrier-app |

---

## Organization-Level

| Repository | Description |
|------------|-------------|
| **[.github](https://github.com/ShipitSmarter/.github)** | Default community health files (issue templates, SECURITY.md) |

---

## Key Relationships

```
┌─────────────────────────────────────────────────────────────────┐
│                         FRONTEND                                │
│  viya-app ─────────────────────────────────────────────────────│
│     │                                                           │
│     └── uses ──► viya-ui-warehouse (component library)          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                         BACKEND                                 │
│                                                                 │
│  shipping ◄────────────────────────────────────────────────────│
│     │                                                           │
│     ├── calls ──► stitch (integration engine)                   │
│     │                 │                                         │
│     │                 └── uses ──► stitch-integrations (YAML)   │
│     │                                                           │
│     ├── calls ──► rates (rate cards)                            │
│     ├── calls ──► ftp (file transfers)                          │
│     ├── calls ──► hooks (webhooks, scheduling)                  │
│     └── calls ──► authorizing (auth)                            │
│                                                                 │
│  All services use ──► viya-core (shared libraries)              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      INFRASTRUCTURE                             │
│                                                                 │
│  pionative-infra / aws-ng-* ──► AWS accounts, networking        │
│  aws-eks ──► Kubernetes clusters                                │
│  helm-charts ──► Service deployments                            │
│  actions ──► CI/CD pipelines                                    │
└─────────────────────────────────────────────────────────────────┘
```

---

## Getting Started

### For New Developers

1. Clone **viya-app** with submodules
2. Follow docker-compose setup for local backend
3. Install **vscode-stitch** if working on integrations

### For DevOps

1. Review **actions** for CI/CD patterns
2. Check **pionative-infra** and **aws-ng-*** for infrastructure
3. **helm-charts** for Kubernetes deployments

### For Integration Specialists

1. **stitch-integrations** contains all carrier mappings
2. Use **vscode-stitch** for development and testing
3. **stitch-schemas** for validation

---

*Last updated: January 2026*
