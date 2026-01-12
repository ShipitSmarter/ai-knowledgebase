# MongoDB Kubernetes

## Overview
Research project exploring MongoDB deployment strategies in Kubernetes environments, comparing managed (Atlas) vs self-managed approaches.

## Documents
| Date | Topic | Status |
|------|-------|--------|
| 2026-01-12 | [Atlas Operator vs Self-Managed](./2026-01-12-atlas-operator-vs-self-managed.md) | draft |

## Key Insights
- **Atlas Operator is recommended for most teams** - provides managed database with K8s-native GitOps workflows
- Self-managed only makes sense for data residency requirements, air-gapped environments, or very large scale
- Both approaches use Kubernetes Custom Resources for configuration
- Stateful workloads in K8s are inherently complex; Atlas abstracts this away

## Open Questions
- [ ] What are the specific Atlas pricing tiers for production workloads?
- [ ] How does backup/restore work with each approach?
- [ ] What's the migration path between approaches?
- [ ] What are the Percona/Bitnami alternatives for community MongoDB in K8s?
