# Infrastructure

Deployment architecture, cloud services, and operational concerns for Viya TMS.

## Environment Overview

| Environment | Purpose | Infrastructure |
|-------------|---------|----------------|
| `local` | Developer machines | Docker Compose, LocalStack |
| `dev` | Integration testing | AWS EKS (shared) |
| `staging` | Pre-production | AWS EKS (dedicated) |
| `production` | Live customers | AWS EKS (dedicated, multi-AZ) |

## Cloud Architecture (AWS)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              AWS Region (eu-west-1)                          │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │                            VPC                                          │ │
│  │                                                                         │ │
│  │  ┌───────────────────┐    ┌───────────────────────────────────────┐   │ │
│  │  │   Public Subnets  │    │         Private Subnets                │   │ │
│  │  │                   │    │                                        │   │ │
│  │  │  ┌─────────────┐  │    │  ┌─────────────┐  ┌─────────────────┐ │   │ │
│  │  │  │     ALB     │  │───▶│  │   EKS       │  │  MongoDB Atlas  │ │   │ │
│  │  │  │             │  │    │  │  (services) │  │   (VPC Peering) │ │   │ │
│  │  │  └─────────────┘  │    │  └─────────────┘  └─────────────────┘ │   │ │
│  │  │                   │    │                                        │   │ │
│  │  │  ┌─────────────┐  │    │  ┌─────────────┐  ┌─────────────────┐ │   │ │
│  │  │  │  CloudFront │  │    │  │ SNS / SQS   │  │       S3        │ │   │ │
│  │  │  └─────────────┘  │    │  └─────────────┘  └─────────────────┘ │   │ │
│  │  └───────────────────┘    └───────────────────────────────────────┘   │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │                      Supporting Services                                │ │
│  │  ECR (images) │ Secrets Manager │ CloudWatch │ Route53                 │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Kubernetes Architecture

### Cluster Layout

```
EKS Cluster
├── Namespace: viya-system
│   ├── nginx-ingress-controller
│   ├── oathkeeper
│   ├── opa
│   └── opa-adapter
│
├── Namespace: viya-app
│   ├── shipping (Deployment, 2-4 replicas)
│   ├── stitch (Deployment, 2-4 replicas)
│   ├── authorizing (Deployment, 2 replicas)
│   ├── rates (Deployment, 2 replicas)
│   ├── hooks (Deployment, 2 replicas)
│   ├── hooks-subscriber (Deployment, 2 replicas)
│   ├── printing (Deployment, 2 replicas)
│   ├── ftp (Deployment, 2 replicas)
│   └── auditor (Deployment, 2 replicas)
│
├── Namespace: viya-jobs
│   └── CronJobs (tracking collection, cleanup, etc.)
│
└── Namespace: monitoring
    ├── prometheus
    ├── grafana
    └── loki
```

### Resource Allocation

| Service | CPU Request | CPU Limit | Memory Request | Memory Limit |
|---------|-------------|-----------|----------------|--------------|
| shipping | 250m | 1000m | 512Mi | 1Gi |
| stitch | 500m | 2000m | 1Gi | 2Gi |
| authorizing | 100m | 500m | 256Mi | 512Mi |
| rates | 100m | 500m | 256Mi | 512Mi |
| hooks | 100m | 500m | 256Mi | 512Mi |
| printing | 100m | 500m | 256Mi | 512Mi |
| ftp | 100m | 500m | 256Mi | 512Mi |
| auditor | 100m | 500m | 256Mi | 512Mi |

### Autoscaling

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: shipping
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: shipping
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

## Database (MongoDB Atlas)

### Cluster Configuration

| Environment | Tier | Nodes | Storage |
|-------------|------|-------|---------|
| dev | M10 | 3 | 10GB |
| staging | M20 | 3 | 50GB |
| production | M30 | 3 (multi-AZ) | 200GB |

### Backup Strategy

- Continuous backup with point-in-time recovery
- Retention: 7 days (dev), 30 days (staging/prod)
- Snapshot backups: Daily

### Connection

```
mongodb+srv://viya-app:<password>@cluster0.abc123.mongodb.net/shipping
```

VPC Peering ensures traffic stays private.

## Message Queue (AWS SNS/SQS)

### Topics

| Topic | Publishers | Purpose |
|-------|------------|---------|
| `viya-shipping-events` | shipping | Shipment lifecycle events |
| `viya-ftp-events` | ftp | File received notifications |

### Queues

| Queue | Subscriber | DLQ | Retention |
|-------|------------|-----|-----------|
| `viya-hooks-queue` | hooks-subscriber | Yes | 14 days |
| `viya-auditor-queue` | auditor | Yes | 14 days |
| `viya-shipping-commands` | shipping | Yes | 14 days |

### Message Format

```json
{
  "Type": "ShipmentCreated",
  "TenantId": "tenant_abc",
  "Timestamp": "2026-01-20T10:30:00Z",
  "Payload": {
    "ShipmentId": "550e8400...",
    "Reference": "ORD-123"
  }
}
```

## Object Storage (AWS S3)

| Bucket | Purpose | Lifecycle |
|--------|---------|-----------|
| `viya-labels-{env}` | Generated label PDFs | 90 days |
| `viya-documents-{env}` | Commercial invoices, etc. | 7 years |
| `viya-ftp-{env}` | SFTP file staging | 30 days |
| `viya-backups-{env}` | Database exports | 90 days |

## CI/CD Pipeline

```
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐
│  Push   │────▶│  Build  │────▶│  Test   │────▶│ Deploy  │
│         │     │ & Scan  │     │         │     │         │
└─────────┘     └─────────┘     └─────────┘     └─────────┘
                    │                               │
                    ▼                               ▼
              ┌─────────┐                     ┌─────────┐
              │   ECR   │                     │ ArgoCD  │
              └─────────┘                     └─────────┘
```

### Pipeline Steps

1. **Build**: Docker multi-stage build
2. **Scan**: Trivy security scan
3. **Test**: Unit + integration tests
4. **Push**: Image to ECR with SHA tag
5. **Deploy**: ArgoCD sync (GitOps)

### Deployment Strategy

- **Rolling update** for normal releases
- **Blue/green** for major versions (via Argo Rollouts)
- Automatic rollback on health check failure

## Monitoring & Observability

### Metrics (Prometheus + Grafana)

Key dashboards:
- Request rate, latency, error rate (RED)
- Resource utilization per service
- MongoDB connection pool, query times
- SQS queue depth, age of oldest message

### Logging (Loki)

```
{namespace="viya-app", app="shipping"} |= "error"
```

Structured JSON logs with correlation IDs.

### Alerting

| Alert | Condition | Severity |
|-------|-----------|----------|
| High error rate | >1% 5xx in 5m | Critical |
| High latency | p99 >5s in 5m | Warning |
| Queue depth | >1000 messages | Warning |
| Pod restarts | >3 in 10m | Critical |
| MongoDB slow queries | >100ms avg | Warning |

## Security

### Network

- All traffic TLS 1.3
- VPC with private subnets for services
- Security groups restrict inter-service traffic
- No public IPs on pods

### Secrets Management

```yaml
# Secrets from AWS Secrets Manager via External Secrets Operator
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: shipping-secrets
spec:
  secretStoreRef:
    name: aws-secrets-manager
  target:
    name: shipping-secrets
  data:
  - secretKey: mongodb-connection-string
    remoteRef:
      key: viya/shipping/mongodb
```

### Authentication

- Oathkeeper validates JWTs from identity provider
- API tokens hashed (SHA-256) before storage
- OPA policies in version control

## Local Development

### Docker Compose

```bash
cd viya-app/dev
docker compose up -d
```

Services available:
- MongoDB: `localhost:27017`
- LocalStack (SNS/SQS/S3): `localhost:4566`
- nginx: `localhost:8080`

### Service Versions

Use `set-service-version.sh` to pin specific service versions:

```bash
./dev/set-service-version.sh shipping feature/my-branch
docker compose up -d shipping
```

## Disaster Recovery

### RTO/RPO Targets

| Tier | RTO | RPO | Examples |
|------|-----|-----|----------|
| Critical | 1 hour | 5 min | shipping, authorizing |
| Important | 4 hours | 1 hour | rates, hooks |
| Standard | 24 hours | 24 hours | auditor, printing |

### Recovery Procedures

1. **Database failure**: Restore from Atlas point-in-time backup
2. **Service failure**: ArgoCD automatic rollback + restart
3. **Region failure**: DNS failover to DR region (future)

## Cost Management

### Major Cost Drivers

| Service | Monthly (prod) | Optimization |
|---------|----------------|--------------|
| EKS | ~$500 | Spot instances for non-critical |
| MongoDB Atlas | ~$800 | Right-size based on usage |
| Data transfer | ~$300 | CloudFront caching |
| S3 | ~$100 | Lifecycle policies |

### Cost Allocation Tags

All resources tagged with:
- `Environment`: dev/staging/production
- `Service`: shipping/stitch/etc.
- `Team`: platform/shipping/etc.

## Related Documentation

- [Repository Catalog](../research/shipitsmarter-repos/2026-01-19-repository-catalog.md)
- [Service Architecture](../research/shipitsmarter-repos/2026-01-19-service-architecture.md)
