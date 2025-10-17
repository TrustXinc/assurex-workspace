---
name: architecture-overview
description: Understand the complete AssureX platform architecture including repository interactions, data flow patterns, technology stack, multi-tenant design, and system boundaries. Essential for design decisions and onboarding.
---

# Architecture Overview Skill

This skill provides comprehensive understanding of the AssureX platform architecture across all repositories.

## System Architecture

### High-Level Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                     External Systems                          │
│  GitHub  │  Jira  │  Okta  │  Entra  │  Auth0  │  Bedrock   │
└─────────────────────────┬────────────────────────────────────┘
                          │
┌─────────────────────────▼────────────────────────────────────┐
│                      AssureX Platform                         │
│                                                                │
│  ┌──────────────┐   ┌────────────────┐   ┌────────────────┐ │
│  │    trustx     │   │  assurex-infra │   │  profile-360   │ │
│  │   Frontend    │◄──┤  Infrastructure│◄──┤    Backend     │ │
│  │  (React/CF)   │   │  (Serverless)  │   │   (FastAPI)    │ │
│  └──────┬────────┘   └────────┬───────┘   └────────┬───────┘ │
│         │                     │                     │         │
│         │        ┌────────────▼────────────┐       │         │
│         │        │   PostgreSQL RDS        │       │         │
│         │        │  Multi-Tenant Schemas   │◄──────┘         │
│         │        └─────────────┬───────────┘                 │
│         │                      │                             │
│         │        ┌─────────────▼───────────┐                 │
│         └────────┤  Insights Engine        │                 │
│                  │  Analytics & AI         │                 │
│                  │  (Lambda + Bedrock)     │                 │
│                  └─────────────────────────┘                 │
└──────────────────────────────────────────────────────────────┘
```

### Repository Responsibilities

| Repository | Purpose | Tech Stack | Deployment |
|------------|---------|------------|------------|
| **trustx** | User interface | React 18, Apollo, Auth0, MUI | Cloudflare Pages |
| **assurex-infra** | Infrastructure & GraphQL | Serverless, Lambda, AppSync, RDS | AWS (Serverless) |
| **profile-360-backend** | REST API & knowledge graph | FastAPI, Neo4j, PostgreSQL | AWS Lambda |
| **assurex-insights-engine** | Analytics & AI processing | Python, Bedrock, pgvector | AWS Lambda |

---

## Data Flow Patterns

### Pattern 1: User Authentication Flow

```
1. User → Auth0 Login
   ↓
2. Auth0 → JWT with custom claims
   {
     "https://trustx.cloud/claims/company": "trustx",
     "https://trustx.cloud/claims/role": "admin",
     "https://trustx.cloud/claims/user_id": "auth0|123"
   }
   ↓
3. Frontend → Stores JWT, validates tenant
   TenantGuard checks public.tenants table
   ↓
4. All API calls → Include JWT in Authorization header
   ↓
5. Backend → Extract company claim, lookup tenant_id
   ↓
6. All queries → Scoped to tenant_{id} schema
```

### Pattern 2: Integration Configuration & Sync

```
1. User configures integration (trustx)
   ↓
2. Frontend → GraphQL mutation (AppSync)
   configureGitHub(input: {orgName, integrationToken})
   ↓
3. AppSync → Lambda resolver (assurex-infra)
   Validates token, creates integration record
   ↓
4. Database → Stores in tenant_{id}.integrations
   ↓
5. User triggers sync → syncIntegration mutation
   ↓
6. Lambda → Fetches data from GitHub API
   Stores raw data in S3: s3://assurex-dev/tenants/{id}/github/
   ↓
7. S3 event → Triggers Insights Engine
   ↓
8. Insights Engine → Processes data with AI/RAG
   Inserts into tenant_{id}.sso_users, group_memberships
   ↓
9. Frontend → Polls getSyncStatus for completion
```

### Pattern 3: Profile360 Analytics

```
1. Insights Engine → Calculates analytics
   Risk scores, anomaly detection, graph analysis
   ↓
2. Stores results → tenant_{id}.user_risk_scores
   ↓
3. Profile360 API → Exposes via REST endpoints
   GET /api/dormant-users
   GET /api/users/{id}/activities
   ↓
4. Frontend → Fetches and displays
   Profile360 dashboard components
   ↓
5. Neo4j → Visualizes relationships
   Knowledge graph component
```

---

## Multi-Tenant Architecture

### Database Schema Isolation

```
Database: assurex_dev / assurex_preprod
│
├── public (shared)
│   ├── tenants                # Tenant registry
│   │   ├── tenant_id (PK)
│   │   ├── tenant_name
│   │   ├── company_name
│   │   ├── status (active/inactive)
│   │   └── created_at
│   │
│   ├── frameworks             # SOC2, NIST, ISO 27001
│   ├── controls               # TX-* control codes
│   └── schema_migrations      # Migration tracking
│
├── template_schema (template for new tenants)
│   ├── users
│   ├── user_activities
│   ├── sso_users
│   ├── group_memberships
│   ├── app_assignments
│   └── ... (100+ tables)
│
├── tenant_118230 (trustx - isolated)
│   ├── users
│   ├── user_activities
│   ├── sso_users
│   ├── integrations
│   ├── sync_executions
│   └── ... (100+ tables)
│
└── tenant_758734 (trustxinc - isolated)
    └── ... (same structure)
```

### Tenant Provisioning Flow

```
1. INSERT INTO public.tenants (tenant_name, company_name)
   VALUES ('newcompany', 'New Company Inc')
   RETURNING tenant_id;
   ↓
2. Trigger: create_tenant_schema()
   ↓
3. CREATE SCHEMA tenant_123456;
   ↓
4. Copy all tables from template_schema
   for table in template_schema:
       CREATE TABLE tenant_123456.{table} (LIKE template_schema.{table})
   ↓
5. Grant permissions
   GRANT ALL ON SCHEMA tenant_123456 TO app_user;
   ↓
6. Tenant ready for use
```

### Neo4j Multi-Tenancy

```
- Separate Neo4j Aura instance per tenant
- Credentials in Secrets Manager:
  assurex/{stage}/neo4j/tenant_{id}
  {
    "uri": "neo4j+s://xxxxx.databases.neo4j.io",
    "username": "neo4j",
    "password": "..."
  }
- Complete graph isolation
- No cross-tenant relationships
```

---

## Technology Stack Details

### Frontend (trustx)

**Runtime**: Cloudflare Pages (Edge workers)
**Framework**: React 18.2.0
**State**: Apollo Client (GraphQL), React hooks
**UI**: Material-UI (@mui/material)
**Auth**: Auth0 (@auth0/auth0-react)
**Graph**: Neo4j Driver (browser), react-force-graph-2d
**Build**: react-scripts (CRA)
**Deployment**: Git-based (main → prod, stg → staging)

**Key Libraries**:
- @apollo/client: 3.14.0
- @auth0/auth0-react: 2.2.4
- @mui/material: 5.17.1
- neo4j-driver: 5.28.1
- axios: 1.7.9

### Infrastructure (assurex-infra)

**IaC**: Serverless Framework v3
**Runtime**: Python 3.12 (Lambda)
**Database**: PostgreSQL 17.4 (RDS)
**API**: AWS AppSync (GraphQL)
**Compute**: AWS Lambda
**Storage**: S3, Secrets Manager
**Network**: VPC, NAT Gateway, Security Groups
**Monitoring**: CloudWatch Logs & Metrics

**Key Resources**:
- VPC: Multi-AZ with public/private subnets
- RDS: PostgreSQL 17.4, multi-tenant schemas
- Lambda: Python 3.12 with custom layers
- AppSync: GraphQL API with Lambda resolvers
- S3: Raw data storage (tenant-specific prefixes)

### Profile360 Backend (profile-360-backend)

**Framework**: FastAPI (Python 3.12)
**Database**: PostgreSQL 17.4 (shared RDS)
**Graph DB**: Neo4j Aura (per-tenant instances)
**Runtime**: AWS Lambda (via Mangum)
**API Gateway**: HTTP API (REST)
**Auth**: OAuth2 with Auth0 JWT validation
**Migrations**: Alembic

**Key Libraries**:
- fastapi: ^0.109.0
- neo4j: ^5.28.1
- psycopg2-binary: ^2.9.9
- pydantic: ^2.5.0
- python-jose[cryptography]: ^3.3.0

### Insights Engine (assurex-insights-engine)

**Runtime**: AWS Lambda (Python 3.12)
**AI/ML**: AWS Bedrock (Claude 3 Haiku/Sonnet)
**Vector DB**: pgvector extension (PostgreSQL)
**Analytics**: NumPy, Pandas
**Event-Driven**: S3 events, EventBridge schedules

**Key Capabilities**:
- Traditional ETL (predefined mappings)
- AI ETL (RAG-based schema discovery)
- Hybrid ETL (AI + business logic)
- Risk scoring & anomaly detection
- Graph analytics (PageRank, centrality)
- Cost-optimized AI (Haiku vs Sonnet)

---

## Network Architecture

### VPC Design

```
VPC: 10.0.0.0/16 (dev), 10.1.0.0/16 (preprod)
│
├── Public Subnets (10.0.1.0/24, 10.0.2.0/24)
│   ├── Internet Gateway
│   ├── NAT Gateway (for private subnet egress)
│   └── Bastion Host (for database access)
│
└── Private Subnets (10.0.11.0/24, 10.0.12.0/24)
    ├── RDS PostgreSQL (Multi-AZ)
    ├── Lambda functions (VPC-attached)
    └── ElastiCache Redis (future)
```

### Security Groups

```
1. Bastion SG: SSH from developer IPs only
2. ALB SG: HTTPS from 0.0.0.0/0
3. App SG: Traffic from ALB only
4. Lambda SG: Outbound to RDS, Neo4j (7687)
5. Database SG: PostgreSQL (5432) from Lambda SG only
6. Cache SG: Redis (6379) from App SG
7. Local Access SG: Development access
```

### API Endpoints

**GraphQL (Integrations)**:
- Dev: https://ttylf2win0.execute-api.us-east-1.amazonaws.com/graphql
- Staging: https://api-stg.trustx.cloud/graphql
- Production: https://api.trustx.cloud/graphql

**REST (Profile360)**:
- Dev: https://ttylf2win0.execute-api.us-east-1.amazonaws.com/profile360
- Staging: https://api-stg.trustx.cloud/profile360
- Production: https://api.trustx.cloud (no prefix)

**Frontend**:
- Dev: http://localhost:3000
- Staging: https://app-stg.trustx.cloud
- Production: https://app.trustx.cloud

---

## Cost Architecture

### Development Environment (~$75/month)

| Service | Cost | Notes |
|---------|------|-------|
| NAT Gateway | $32.40 | 720 hours/month |
| RDS (db.t3.micro) | $12.00 | After Free Tier |
| Lambda | $2-5 | Pay-per-invoke |
| S3 | $1-2 | Storage + requests |
| Secrets Manager | $0.40 | Per secret |
| CloudWatch Logs | $0.50 | Log storage |
| AppSync | $4-5 | Queries + resolvers |
| **Total** | **~$58/month** | Per environment |

### Cost Optimization Opportunities

1. **VPC Endpoints**: Save ~$25/month on NAT costs
2. **Reserved RDS**: 30% discount for preprod/prod
3. **Lambda ProvisionedConcurrency**: Reduce cold starts
4. **CloudWatch Log retention**: 7 days (dev), 30 days (prod)
5. **S3 Lifecycle**: Move old data to Glacier
6. **Bedrock Haiku**: 89% cheaper than Sonnet for AI

---

## Deployment Architecture

### Environments

| Environment | Region | Purpose | Database | Status |
|-------------|--------|---------|----------|--------|
| **Development** | us-east-1 | Active development | assurex_dev | ✅ Active |
| **Preprod/Staging** | us-east-2 | Pre-production testing | assurex_preprod | ✅ Active |
| **Production** | us-east-1 | Production | Not deployed | ❌ Pending |

### Deployment Strategy

**Gitflow Model**:
- Feature branches → Deploy to dev
- `stg` branch → Deploy to staging
- `main` branch → Deploy to production

**Deployment Order**:
1. Database migrations (assurex-infra)
2. Backend API (profile-360-backend)
3. Analytics functions (assurex-insights-engine)
4. Infrastructure/GraphQL (assurex-infra)
5. Frontend (trustx)

---

## Integration Patterns

### External System Integrations

**Identity Providers (IDPs)**:
- GitHub (OAuth Apps)
- Jira (API tokens)
- Okta (SCIM API)
- Microsoft Entra ID (Graph API)

**Authentication**:
- Auth0 (JWT with custom claims)
- Tenant-based authorization

**AI/ML**:
- AWS Bedrock (Claude 3 Haiku/Sonnet, Titan Embeddings)
- pgvector (similarity search)

**Observability**:
- CloudWatch (logs, metrics, alarms)
- VPC Flow Logs
- RDS Performance Insights (future)

---

## Scalability Considerations

### Horizontal Scaling

**Lambda Functions**: Auto-scales (up to 1000 concurrent)
**RDS**: Vertical scaling (instance size) + Read replicas
**Neo4j**: Aura Professional (auto-scales within instance)
**Frontend**: Cloudflare edge network (global CDN)

### Vertical Scaling

**Database**:
- Current: db.t3.micro (2 vCPU, 1 GB)
- Next: db.t3.small (2 vCPU, 2 GB)
- Production: db.r6g.xlarge (4 vCPU, 32 GB)

**Lambda**:
- Current: 512-1024 MB
- Increased memory = more CPU
- Max: 10 GB memory, 6 vCPUs

### Data Partitioning

**By Tenant**: Schema-based isolation (current approach)
**By Time**: Archive old data to S3 (future)
**By Geography**: Multi-region deployment (future)

---

## Security Architecture

### Authentication & Authorization

**Auth0 Flow**:
1. User logs in → Auth0 Universal Login
2. Auth0 validates credentials
3. Auth0 issues JWT with custom claims
4. Frontend stores JWT (httpOnly cookie)
5. All API calls include JWT
6. Backend validates JWT signature
7. Backend extracts tenant from claims
8. Backend scopes queries to tenant schema

**JWT Claims**:
```json
{
  "https://trustx.cloud/claims/company": "trustx",
  "https://trustx.cloud/claims/role": "admin",
  "https://trustx.cloud/claims/user_id": "auth0|123",
  "iss": "https://trustx.us.auth0.com/",
  "aud": ["https://api-dev.trustx.cloud"],
  "exp": 1698765432
}
```

### Data Encryption

**At Rest**:
- RDS: AES-256 encryption enabled
- S3: Server-side encryption (SSE-S3)
- Secrets Manager: KMS encryption
- EBS: Encrypted volumes

**In Transit**:
- HTTPS/TLS 1.2+ for all APIs
- RDS: SSL/TLS connections enforced
- Neo4j: TLS encrypted connections
- VPC: Traffic between services encrypted

### Network Security

**Principle of Least Privilege**:
- Database in private subnets only
- Lambda egress only to required ports
- Security groups deny by default
- IAM roles with minimal permissions

---

## Disaster Recovery

### Backup Strategy

**RDS**:
- Automated daily backups (7-day retention)
- Manual snapshots before major changes
- Point-in-time recovery (PITR)

**Neo4j**:
- Aura automatic backups (daily)
- Export graphs before migrations

**S3**:
- Versioning enabled
- Cross-region replication (future)

### Rollback Procedures

**Infrastructure**: Redeploy previous Serverless version
**API**: Lambda version aliases for quick rollback
**Frontend**: Cloudflare rollback to previous deployment
**Database**: PITR or restore from snapshot

---

## Monitoring & Observability

### Metrics

**Lambda**:
- Invocations, errors, duration
- Concurrent executions
- Throttles

**RDS**:
- CPU, memory, disk usage
- Connections, queries/sec
- Replication lag (if Multi-AZ)

**AppSync**:
- Requests, latency
- Resolver errors
- 4xx, 5xx errors

### Logging

**Structured Logging**:
- JSON format
- Correlation IDs for tracing
- Tenant ID in all logs
- Sensitive data masked

**Log Retention**:
- Dev: 7 days
- Staging: 14 days
- Production: 30 days

---

## When to Use This Skill

Invoke this skill when you need to:
- Understand overall system architecture
- Design new features spanning multiple repos
- Make architectural decisions
- Debug complex cross-service issues
- Onboard to the AssureX platform
- Plan scalability improvements
- Understand security model
- Design integrations with external systems
