# AssureX Platform Architecture

**Complete architectural overview of the AssureX multi-tenant SaaS platform**

**Last Updated**: October 31, 2025
**Version**: 1.0.0

---

## 📋 Table of Contents

1. [System Overview](#system-overview)
2. [High-Level Architecture](#high-level-architecture)
3. [Repository Architecture](#repository-architecture)
4. [AWS Infrastructure](#aws-infrastructure)
5. [Data Flow & Pipeline Orchestration](#data-flow--pipeline-orchestration)
6. [Multi-Tenant Architecture](#multi-tenant-architecture)
7. [Security Architecture](#security-architecture)
8. [Network Architecture](#network-architecture)
9. [API Architecture](#api-architecture)
10. [AI/ML Architecture](#aiml-architecture)
11. [Deployment Architecture](#deployment-architecture)

---

## System Overview

AssureX is a multi-tenant SaaS compliance and security management platform that combines traditional reliability with AI-powered intelligence for real-time insights, automated workflows, and seamless security integrations.

### Core Components

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Frontend** | Next.js 14, React, TailwindCSS | User interface and experience |
| **Integration API** | AWS AppSync, Lambda, GraphQL | Third-party integrations (GitHub, Jira, Okta, Entra) |
| **Profile360 API** | FastAPI, Lambda, API Gateway | User analytics and insights |
| **Insights Engine** | Python, Lambda, Bedrock | ETL processing and AI agents |
| **Database** | PostgreSQL RDS | Persistent data storage (multi-tenant schemas) |
| **Knowledge Graph** | Neo4j Aura | User-app-group relationship graphs |
| **Authentication** | Auth0 | JWT-based authentication and authorization |

### Technology Stack

```
Frontend:    Next.js 14, React, TypeScript, TailwindCSS
Backend:     Python 3.12, Node.js 18+, FastAPI
AWS:         Lambda, AppSync, API Gateway, RDS, Secrets Manager, Bedrock
Database:    PostgreSQL 17.4, Neo4j Aura
AI/ML:       AWS Bedrock (Claude Haiku, Claude Sonnet, Titan Embeddings)
IaC:         Serverless Framework, CloudFormation
Auth:        Auth0 (JWT tokens)
```

---

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           AssureX Platform                               │
│                    Multi-Tenant SaaS Architecture                        │
└─────────────────────────────────────────────────────────────────────────┘

                                  │
                    ┌─────────────┼─────────────┐
                    │             │             │
                    ▼             ▼             ▼

        ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
        │   Frontend UI    │  │  Integration API │  │  Profile360 API  │
        │                  │  │                  │  │                  │
        │  Next.js App     │  │  AppSync         │  │  FastAPI         │
        │  Vercel          │  │  GraphQL         │  │  REST API        │
        │                  │◄─┤  Lambda          │  │  Lambda          │
        │  app.trustx      │  │                  │  │                  │
        │  .cloud          │  │  AWS AppSync     │  │  API Gateway     │
        └──────────────────┘  └─────────┬────────┘  └─────────┬────────┘
                                        │                      │
                    ┌───────────────────┼──────────────────────┘
                    │                   │
                    ▼                   ▼
        ┌────────────────────────────────────────────────────────┐
        │              Insights Engine (ETL & AI)                │
        │                                                         │
        │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
        │  │Event Router  │  │AI Agents     │  │ETL Processors│ │
        │  │(Orchestrator)│──│(Bedrock)     │  │(Traditional) │ │
        │  └──────────────┘  └──────────────┘  └──────────────┘ │
        │                                                         │
        │  Lambda Functions • S3 Storage • EventBridge Triggers   │
        └────────────────────┬───────────────┬───────────────────┘
                             │               │
                    ┌────────┴────────┐      │
                    │                 │      │
                    ▼                 ▼      ▼
        ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
        │   PostgreSQL     │  │   Neo4j Aura     │  │  AWS Bedrock     │
        │   RDS (Multi-    │  │   (Multi-Tenant) │  │  (AI/ML)         │
        │   Tenant)        │  │                  │  │                  │
        │                  │  │  Knowledge Graph │  │  Claude Haiku    │
        │  Schema per      │  │  Per Tenant      │  │  Claude Sonnet   │
        │  Tenant          │  │                  │  │  Titan Embeddings│
        └──────────────────┘  └──────────────────┘  └──────────────────┘

                    ┌────────────────────────────────────┐
                    │       External Integrations         │
                    │  GitHub • Jira • Okta • Entra ID   │
                    └────────────────────────────────────┘
```

---

## Repository Architecture

AssureX consists of 4 independent repositories working together:

```
┌─────────────────────────────────────────────────────────────────────┐
│                      Repository Architecture                         │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────┐         ┌─────────────────────┐
│   trustx (Frontend) │         │  assurex-infra      │
│                     │         │  (Infrastructure)   │
│  • Next.js 14       │         │                     │
│  • React Components │◄────────┤  • Lambda Functions │
│  • Auth0 JWT        │         │  • AppSync GraphQL  │
│  • API Clients      │         │  • VPC/Networking   │
│  • TailwindCSS      │         │  • RDS PostgreSQL   │
│                     │         │  • Secrets Manager  │
│  Deployment:        │         │                     │
│  Vercel (main)      │         │  Deployment:        │
└─────────────────────┘         │  Serverless (dev)   │
                                │  Serverless (preprod)│
                                └──────────┬──────────┘
                                           │
                    ┌──────────────────────┼──────────────────────┐
                    │                      │                      │
                    ▼                      ▼                      ▼
        ┌─────────────────────┐  ┌─────────────────────┐  ┌─────────────────────┐
        │ profile-360-backend │  │ assurex-insights-   │  │ External Resources  │
        │ (User Analytics)    │  │ engine (ETL & AI)   │  │                     │
        │                     │  │                     │  │ • Neo4j Aura        │
        │ • FastAPI           │  │ • Event Router      │  │ • AWS Bedrock       │
        │ • Neo4j Client      │  │ • ETL Processors    │  │ • Auth0             │
        │ • PostgreSQL        │  │ • AI Agents:        │  │ • GitHub API        │
        │ • Lambda Handler    │  │   - Dormant User    │  │ • Jira API          │
        │ • API Gateway       │  │   - Privilege Creep │  │ • Okta API          │
        │                     │  │ • Vectorization     │  │ • Entra ID API      │
        │ Deployment:         │  │ • Neo4j Sync        │  └─────────────────────┘
        │ Serverless (dev)    │  │                     │
        │ Serverless (preprod)│  │ Deployment:         │
        └─────────────────────┘  │ Serverless (dev)    │
                                 │ Serverless (preprod)│
                                 └─────────────────────┘
```

### Repository Responsibilities

| Repository | Lines of Code | Primary Language | Deployment Target | Key Responsibility |
|------------|---------------|------------------|-------------------|-------------------|
| **trustx** | ~15,000 | TypeScript | Vercel | User interface, Auth0 integration |
| **assurex-infra** | ~8,000 | Python, JavaScript | AWS Lambda | Integration handlers, GraphQL API |
| **profile-360-backend** | ~5,000 | Python | AWS Lambda | User analytics, Neo4j, REST API |
| **assurex-insights-engine** | ~7,000 | Python | AWS Lambda | ETL, AI agents, data orchestration |

---

## AWS Infrastructure

### Infrastructure Components

```
┌─────────────────────────────────────────────────────────────────────┐
│                      AWS Infrastructure Layout                       │
└─────────────────────────────────────────────────────────────────────┘

Region: us-east-1 (dev/prod) | us-east-2 (preprod)

┌─────────────────────────────────────────────────────────────────────┐
│  VPC (10.0.0.0/16 dev | 10.1.0.0/16 preprod)                       │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Public Subnets (2 AZs)                                     │    │
│  │  • 10.0.1.0/24 (us-east-1a)                                │    │
│  │  • 10.0.2.0/24 (us-east-1b)                                │    │
│  │                                                             │    │
│  │  ┌───────────────┐  ┌───────────────┐                     │    │
│  │  │ NAT Gateway   │  │ Internet      │                     │    │
│  │  │ (AZ-A)        │  │ Gateway       │                     │    │
│  │  └───────────────┘  └───────────────┘                     │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Private Subnets (2 AZs)                                    │    │
│  │  • 10.0.11.0/24 (us-east-1a)                               │    │
│  │  • 10.0.12.0/24 (us-east-1b)                               │    │
│  │                                                             │    │
│  │  ┌─────────────────────────────────────────────────────┐  │    │
│  │  │  Lambda Functions (VPC-attached)                     │  │    │
│  │  │  • Integration handlers                              │  │    │
│  │  │  • Profile360 API                                    │  │    │
│  │  │  • ETL processors                                    │  │    │
│  │  │  • AI agents                                         │  │    │
│  │  │  • Event router                                      │  │    │
│  │  └─────────────────────────────────────────────────────┘  │    │
│  │                                                             │    │
│  │  ┌─────────────────────────────────────────────────────┐  │    │
│  │  │  RDS PostgreSQL (Multi-AZ)                          │  │    │
│  │  │  • Engine: PostgreSQL 17.4                          │  │    │
│  │  │  • Instance: db.t3.micro                            │  │    │
│  │  │  • Storage: 20GB gp3 (encrypted)                    │  │    │
│  │  │  • Multi-tenant schemas                             │  │    │
│  │  └─────────────────────────────────────────────────────┘  │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Security Groups                                            │    │
│  │  • Lambda SG (outbound: 443, 5432, 7687, 53)              │    │
│  │  • RDS SG (inbound: 5432 from Lambda SG)                  │    │
│  │  • Bastion SG (inbound: 22 from specific IPs)             │    │
│  └────────────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│  API Gateway & AppSync (Internet-facing)                            │
│  • API Gateway HTTP API (Profile360)                                │
│  • AppSync GraphQL API (Integrations)                               │
│  • Custom domains: api-dev.trustx.cloud, api-stg.trustx.cloud      │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│  External Services (Outside VPC)                                    │
│  • Neo4j Aura (per tenant, internet-accessible)                     │
│  • AWS Bedrock (managed AI/ML service)                              │
│  • AWS Secrets Manager (credentials storage)                        │
│  • S3 (integration data, ETL staging)                               │
│  • CloudWatch Logs (monitoring)                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### AWS Services Used

| Service | Purpose | Configuration |
|---------|---------|---------------|
| **Lambda** | Serverless compute for all backend logic | Python 3.12, 512MB memory, 30s timeout |
| **API Gateway v2** | HTTP API for Profile360 | Custom domain, JWT authorizer |
| **AppSync** | GraphQL API for integrations | AWS Cognito & Lambda authorizers |
| **RDS PostgreSQL** | Primary database | 17.4, db.t3.micro, 20GB gp3, multi-tenant schemas |
| **VPC** | Network isolation | 2 AZs, public/private subnets, NAT Gateway |
| **Secrets Manager** | Credential storage | Per-tenant secrets, Neo4j configs |
| **S3** | Data storage | Integration data, ETL staging, logs |
| **Bedrock** | AI/ML models | Claude Haiku, Claude Sonnet, Titan Embeddings |
| **CloudWatch** | Logging & monitoring | Lambda logs, metrics, alarms |
| **EventBridge** | Event routing | Scheduled triggers, custom events |

---

## Data Flow & Pipeline Orchestration

### Complete Data Pipeline

```
┌─────────────────────────────────────────────────────────────────────┐
│                    End-to-End Data Pipeline                          │
└─────────────────────────────────────────────────────────────────────┘

Step 1: User Initiates Sync
────────────────────────────
┌──────────┐
│  User    │  Clicks "Sync" button for GitHub integration
│ (trustx) │
└────┬─────┘
     │
     │ GraphQL mutation: syncIntegration
     ▼
┌──────────────────┐
│ AppSync GraphQL  │  Validates JWT, routes to Lambda
│ (assurex-infra)  │
└────┬─────────────┘
     │
     │ Invokes integration handler
     ▼

Step 2: Integration Handler
────────────────────────────
┌──────────────────────────┐
│ Integration Lambda       │  Calls GitHub API
│ (assurex-infra)          │  Fetches users, repos, teams
│                          │
│ • github_handler.py      │  Transforms data
│ • API authentication     │  Stores to S3
│ • Data extraction        │
└────┬─────────────────────┘
     │
     │ Writes raw JSON to S3
     ▼
┌──────────────────────────┐
│ S3 Bucket                │  assurex-dev-tenant-{tenant_id}/
│ (Integration Data)       │  integrations/github/raw/
│                          │  YYYY-MM-DD-HH-MM-SS.json
└────┬─────────────────────┘
     │
     │ S3 event notification (future)
     │ OR manual trigger
     ▼

Step 3: Event Router (Orchestrator)
────────────────────────────────────
┌─────────────────────────────────────────────────────────────────────┐
│                Event Router Lambda                                   │
│           (assurex-insights-engine)                                  │
│                                                                      │
│  Input: { tenant_id, trigger_source: "sync_completed" }            │
│                                                                      │
│  Orchestrates 6 Lambda functions asynchronously (parallel):         │
│                                                                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐             │
│  │ 1. ETL       │  │ 2. Vector-   │  │ 3. Neo4j     │             │
│  │              │  │    ization   │  │    Sync      │             │
│  └──────────────┘  └──────────────┘  └──────────────┘             │
│                                                                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐             │
│  │ 4. Analytics │  │ 5. Dormant   │  │ 6. Privilege │             │
│  │              │  │    User      │  │    Creep     │             │
│  └──────────────┘  └──────────────┘  └──────────────┘             │
│                                                                      │
│  All invocations return 202 (async processing)                      │
└──────────────────┬──────────────────┬─────────────────┬─────────────┘
                   │                  │                 │
            ┌──────┴────┐      ┌─────┴─────┐    ┌─────┴─────┐
            ▼            ▼      ▼           ▼    ▼           ▼

Step 4: Parallel Processing
────────────────────────────

┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│ ETL Processor    │  │ Vectorization    │  │ Neo4j Sync       │
│                  │  │                  │  │                  │
│ • Extract from   │  │ • Generate       │  │ • Sync users     │
│   S3             │  │   embeddings     │  │ • Sync groups    │
│ • Transform data │  │ • Store in       │  │ • Sync apps      │
│ • Load to DB     │  │   pgvector       │  │ • Create edges   │
│                  │  │ • Use Bedrock    │  │                  │
│ Result:          │  │   Titan          │  │ Result:          │
│ 91 users         │  │                  │  │ 45 users         │
│ 178 groups       │  │ Result:          │  │ 33 groups        │
│ 561 apps         │  │ 150 embeddings   │  │ 63 apps          │
└──────────────────┘  └──────────────────┘  │ 252 relationships│
                                            └──────────────────┘

┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│ Analytics        │  │ Dormant User     │  │ Privilege Creep  │
│                  │  │ Agent (AI)       │  │ Agent (AI)       │
│ • Calculate      │  │                  │  │                  │
│   metrics        │  │ • Query inactive │  │ • Analyze perms  │
│ • User stats     │  │   users          │  │ • Use Bedrock    │
│ • App usage      │  │ • Use Bedrock    │  │   Claude         │
│ • Group analysis │  │   Claude         │  │ • Generate       │
│                  │  │ • Generate       │  │   insights       │
│ Result:          │  │   insights       │  │                  │
│ 25 insights      │  │                  │  │ Result:          │
│ 10 reports       │  │ Result:          │  │ 31 users         │
└──────────────────┘  │ 12 dormant users │  │ 5 HIGH_RISK      │
                      └──────────────────┘  │ 9 MODERATE       │
                                            │ 17 APPROPRIATE   │
                                            └──────────────────┘

Step 5: Storage & Retrieval
────────────────────────────
┌──────────────────────────────────────────────────────────────────┐
│  Data Storage                                                     │
│                                                                   │
│  ┌───────────────────┐  ┌───────────────────┐                   │
│  │ PostgreSQL RDS    │  │ Neo4j Aura        │                   │
│  │                   │  │                   │                   │
│  │ tenant_123456:    │  │ Graph per tenant: │                   │
│  │ • sso_users       │  │ • User nodes      │                   │
│  │ • groups          │  │ • Group nodes     │                   │
│  │ • apps            │  │ • App nodes       │                   │
│  │ • insights        │  │ • Relationships   │                   │
│  │ • embeddings      │  │                   │                   │
│  └───────────────────┘  └───────────────────┘                   │
└──────────────────────────────────────────────────────────────────┘
                              │
                              │ API requests
                              ▼
Step 6: API Access
──────────────────
┌──────────────────────────────────────────────────────────────────┐
│  Profile360 API (FastAPI)                                        │
│                                                                   │
│  GET /api/privilege-creep/summary                                │
│  GET /api/dormant-users                                          │
│  GET /api/knowledge-graph/stats                                  │
│  GET /api/analytics/user-insights                                │
└──────────────────────────────────────────────────────────────────┘
                              │
                              │ HTTP responses
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  Frontend (trustx)                                               │
│  Displays insights, privilege creep, dormant users to user       │
└──────────────────────────────────────────────────────────────────┘
```

### Event Router Orchestration Details

**Event Format:**
```json
{
  "tenant_id": 118230,
  "trigger_source": "sync_completed",
  "triggered_at": "2025-10-31T01:13:32.920304"
}
```

**Invocation Pattern:**
- All 6 Lambda functions invoked asynchronously (`InvocationType='Event'`)
- Each returns status code `202` (Accepted)
- Processing continues in background
- No blocking between components

**Error Handling:**
- Individual component failures don't block others
- Event router logs all invocations
- CloudWatch alarms for failures
- Dead-letter queues for failed events (future)

---

## Multi-Tenant Architecture

### Tenant Isolation Strategy

```
┌─────────────────────────────────────────────────────────────────────┐
│                     Multi-Tenant Isolation                           │
└─────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────┐
│  Database: PostgreSQL RDS                                          │
│  Pattern: Schema-based multi-tenancy                               │
│                                                                     │
│  ┌────────────────────────────────────────────────────────────┐   │
│  │  public schema (shared)                                     │   │
│  │  • tenants (registry)                                       │   │
│  │  • frameworks (SOC2, ISO 27001, NIST)                       │   │
│  │  • controls (TX-* codes)                                    │   │
│  └────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌────────────────────────────────────────────────────────────┐   │
│  │  tenant_118230 (trustx - completely isolated)               │   │
│  │  • sso_users, groups, apps                                  │   │
│  │  • group_memberships, app_assignments                       │   │
│  │  • user_activities, user_profiles                           │   │
│  │  • privilege_creep_insights, dormant_user_insights          │   │
│  │  • embeddings, knowledge_graph_metadata                     │   │
│  │  • ... 100+ tables                                          │   │
│  └────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌────────────────────────────────────────────────────────────┐   │
│  │  tenant_758734 (trustxinc - completely isolated)            │   │
│  │  Same structure as tenant_118230                            │   │
│  │  100% data isolation, separate schema namespace             │   │
│  └────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│  Neo4j: Separate instance per tenant                                │
│                                                                      │
│  Tenant 118230:                    Tenant 758734:                   │
│  • URI: neo4j+s://abc.neo4j.io   • URI: neo4j+s://xyz.neo4j.io    │
│  • Database: neo4j                • Database: neo4j                 │
│  • Credentials in Secrets Manager • Credentials in Secrets Manager  │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│  S3: Separate bucket prefixes per tenant                            │
│                                                                      │
│  Bucket: assurex-dev-tenant-118230/                                 │
│  • integrations/github/raw/                                         │
│  • integrations/jira/raw/                                           │
│  • etl/staging/                                                     │
│  • etl/processed/                                                   │
│                                                                      │
│  Bucket: assurex-dev-tenant-758734/                                 │
│  Same structure, completely separate bucket                         │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│  Secrets Manager: Per-tenant secrets                                │
│                                                                      │
│  assurex/dev/tenant/118230/integrations                             │
│  {                                                                   │
│    "neo4j": { "uri": "...", "user": "...", "password": "..." },    │
│    "github": { "token": "..." },                                    │
│    "jira": { "token": "..." }                                       │
│  }                                                                   │
│                                                                      │
│  assurex/dev/tenant/758734/integrations                             │
│  Separate credentials, separate secret                              │
└─────────────────────────────────────────────────────────────────────┘
```

### Tenant Resolution Flow

```
1. User Login
   ↓
   Auth0 generates JWT with custom claims:
   - https://trustx.cloud/claims/company = "trustx"
   - https://trustx.cloud/claims/user_id = "auth0|123..."
   - https://trustx.cloud/claims/role = "admin"
   ↓
2. API Request
   Frontend sends JWT in Authorization header
   ↓
3. API Gateway / AppSync Authorizer
   Validates JWT signature and expiration
   ↓
4. Lambda Handler
   Extracts company claim from JWT
   Queries: SELECT id FROM public.tenants WHERE tenant_name = 'trustx'
   Gets: tenant_id = 118230
   ↓
5. Database Queries
   All queries use: SET search_path TO tenant_118230
   Complete data isolation enforced
   ↓
6. Neo4j Queries
   Fetches tenant-specific Neo4j config from Secrets Manager
   Connects to tenant's dedicated Neo4j instance
   ↓
7. Response
   Returns only data for tenant 118230
   Zero visibility into other tenants
```

### Benefits of This Pattern

✅ **Complete Data Isolation**: Each tenant's data in separate schema/instance
✅ **Scalability**: Easy to move tenants to dedicated databases if needed
✅ **Performance**: No cross-tenant queries, efficient indexes per schema
✅ **Security**: Schema-level access control, credential isolation
✅ **Compliance**: Tenant data can be deleted/exported independently
✅ **Debugging**: Easy to inspect single tenant's data

---

## Security Architecture

### Authentication & Authorization Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                  Authentication & Authorization                      │
└─────────────────────────────────────────────────────────────────────┘

1. User Login
   ┌──────────┐
   │  User    │  Navigates to app.trustx.cloud
   │ (Browser)│  Clicks "Login"
   └────┬─────┘
        │
        │ Redirect to Auth0
        ▼
   ┌──────────────────┐
   │  Auth0           │  Universal Login page
   │  trustx.us.      │  Email/password or SSO
   │  auth0.com       │
   └────┬─────────────┘
        │
        │ Successful authentication
        │ Generate JWT with custom claims
        ▼
   ┌──────────────────────────────────────────────────────────┐
   │  JWT Token                                                │
   │  {                                                        │
   │    "iss": "https://trustx.us.auth0.com/",                │
   │    "sub": "auth0|679b1a896743...",                       │
   │    "aud": ["https://api-dev.trustx.cloud"],             │
   │    "exp": 1759595768,                                    │
   │    "https://trustx.cloud/claims/company": "trustx",      │
   │    "https://trustx.cloud/claims/user_id": "auth0|...",   │
   │    "https://trustx.cloud/claims/role": "admin"           │
   │  }                                                        │
   └──────────────────┬───────────────────────────────────────┘
                      │
                      │ Stored in browser (httpOnly cookie or localStorage)
                      ▼

2. API Request
   ┌──────────┐
   │  Frontend│  Sends API request
   │  (trustx)│  Authorization: Bearer <JWT>
   └────┬─────┘
        │
        │ HTTP request with JWT
        ▼
   ┌──────────────────┐
   │  API Gateway     │  HTTP API with JWT authorizer
   │  (Profile360)    │  OR
   │                  │  AppSync with Lambda authorizer
   │  OR              │
   │                  │  1. Validates JWT signature (RS256)
   │  AppSync         │  2. Checks expiration
   │  (Integrations)  │  3. Verifies audience
   └────┬─────────────┘
        │
        │ JWT valid, passes to Lambda
        ▼
   ┌──────────────────┐
   │  Lambda Handler  │  1. Extract claims from JWT
   │                  │  2. Get tenant_id from company claim
   │  • Tenant        │  3. Set database context
   │    resolution    │  4. Enforce row-level security
   │  • Authorization │  5. Execute business logic
   │    checks        │
   └──────────────────┘
```

### Security Layers

| Layer | Mechanism | Purpose |
|-------|-----------|---------|
| **Network** | VPC, Security Groups, NACLs | Isolate Lambda/RDS in private subnets |
| **Transport** | TLS 1.2+ | Encrypt all data in transit |
| **Authentication** | Auth0 JWT (RS256) | Verify user identity |
| **Authorization** | JWT claims, role-based access | Control what users can access |
| **Data** | Tenant schema isolation | Prevent cross-tenant data access |
| **Secrets** | AWS Secrets Manager | Secure credential storage |
| **Storage** | RDS encryption at rest (AES-256) | Protect data at rest |
| **API** | Rate limiting, WAF (future) | Prevent abuse |

### IAM Roles & Policies

**Lambda Execution Role:**
- AWSLambdaVPCAccessExecutionRole (managed policy)
- SecretsManager:GetSecretValue (tenant-specific secrets)
- RDS:DescribeDBInstances (read-only)
- S3:GetObject, S3:PutObject (tenant-specific buckets)
- Bedrock:InvokeModel (AI/ML inference)
- CloudWatch:PutLogEvents (logging)

**Principle of Least Privilege:**
- Each Lambda has minimal required permissions
- Tenant-specific secrets scoped by tenant_id
- No wildcard permissions in production

---

## Network Architecture

### VPC Design

```
┌─────────────────────────────────────────────────────────────────────┐
│  VPC: assurex-dev (10.0.0.0/16) - us-east-1                        │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│  Availability Zone: us-east-1a                                      │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Public Subnet A (10.0.1.0/24)                             │    │
│  │  • NAT Gateway                                             │    │
│  │  • Bastion Host (t3.nano)                                  │    │
│  │  • Elastic IP attached                                     │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Private Subnet A (10.0.11.0/24)                           │    │
│  │  • Lambda ENIs                                             │    │
│  │  • RDS Primary Instance                                    │    │
│  │  • No direct internet access                               │    │
│  │  • Routes through NAT Gateway for outbound                 │    │
│  └────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│  Availability Zone: us-east-1b                                      │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Public Subnet B (10.0.2.0/24)                             │    │
│  │  • Internet Gateway (shared)                               │    │
│  │  • Future: Second NAT Gateway for HA                       │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Private Subnet B (10.0.12.0/24)                           │    │
│  │  • Lambda ENIs                                             │    │
│  │  • RDS Standby Instance (Multi-AZ)                         │    │
│  │  • Automatic failover support                              │    │
│  └────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│  Security Groups                                                    │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Lambda-SG (attached to all Lambda functions)              │    │
│  │  Inbound: None                                             │    │
│  │  Outbound:                                                 │    │
│  │    • TCP 443 → 0.0.0.0/0 (HTTPS - API calls, Bedrock)     │    │
│  │    • TCP 5432 → RDS-SG (PostgreSQL)                        │    │
│  │    • TCP 7687 → 0.0.0.0/0 (Neo4j Bolt protocol)           │    │
│  │    • UDP 53 → 0.0.0.0/0 (DNS)                             │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  RDS-SG (attached to RDS PostgreSQL)                       │    │
│  │  Inbound:                                                  │    │
│  │    • TCP 5432 from Lambda-SG                               │    │
│  │    • TCP 5432 from Bastion-SG                              │    │
│  │  Outbound: None required                                   │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Bastion-SG (attached to bastion host)                     │    │
│  │  Inbound:                                                  │    │
│  │    • TCP 22 from specific IP (dev workstation)             │    │
│  │  Outbound:                                                 │    │
│  │    • TCP 5432 → RDS-SG (database access)                   │    │
│  └────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│  Route Tables                                                       │
│                                                                      │
│  Public Subnets:                                                    │
│  • 0.0.0.0/0 → Internet Gateway (igw-xxx)                          │
│  • 10.0.0.0/16 → local                                             │
│                                                                      │
│  Private Subnets:                                                   │
│  • 0.0.0.0/0 → NAT Gateway (nat-xxx)                               │
│  • 10.0.0.0/16 → local                                             │
└─────────────────────────────────────────────────────────────────────┘
```

### Network Flow Examples

**Lambda → RDS:**
```
Lambda (10.0.11.x) → RDS-SG → RDS (10.0.11.y:5432)
✅ Allowed by Lambda-SG outbound + RDS-SG inbound
```

**Lambda → Neo4j Aura:**
```
Lambda (10.0.11.x) → NAT Gateway → Internet Gateway → Neo4j (internet)
✅ Allowed by Lambda-SG outbound 443
```

**Lambda → AWS Bedrock:**
```
Lambda (10.0.11.x) → NAT Gateway → Internet Gateway → Bedrock API
✅ Allowed by Lambda-SG outbound 443
```

**Developer → RDS (via Bastion):**
```
Developer (internet) → Bastion (10.0.1.x:22) → RDS (10.0.11.y:5432)
✅ SSH tunnel through bastion, then psql connection
```

---

## API Architecture

### API Gateway & AppSync

```
┌─────────────────────────────────────────────────────────────────────┐
│                        API Architecture                              │
└─────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  Integration API (GraphQL - AppSync)                             │
│  Domain: https://api-dev.trustx.cloud/graphql                    │
│                                                                   │
│  Mutations:                                                       │
│  • configureGitHub(input: ConfigureGitHubInput!)                 │
│  • configureJira(input: ConfigureJiraInput!)                     │
│  • configureOkta(input: ConfigureOktaInput!)                     │
│  • configureEntraID(input: ConfigureEntraIDInput!)               │
│  • syncIntegration(integrationId: ID!)                           │
│                                                                   │
│  Queries:                                                         │
│  • listIntegrations                                               │
│  • getIntegration(id: ID!)                                        │
│  • getSyncStatus(integrationId: ID!)                              │
│                                                                   │
│  Authorization: Lambda authorizer (JWT validation)                │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  Profile360 API (REST - API Gateway HTTP API)                   │
│  Domain: https://api-dev.trustx.cloud/profile360                │
│                                                                   │
│  User Management:                                                 │
│  GET    /api/users                                                │
│  GET    /api/users/{user_id}                                      │
│  PUT    /api/users/{user_id}                                      │
│  POST   /api/users/{user_id}/activities                           │
│                                                                   │
│  Dormant User Detection:                                          │
│  GET    /api/dormant-users?days=90                                │
│  GET    /api/users/{email}/stale-apps?days=60                     │
│                                                                   │
│  Privilege Creep Detection:                                       │
│  GET    /api/privilege-creep/summary                              │
│  GET    /api/privilege-creep/users?risk_level=HIGH                │
│  GET    /api/privilege-creep/users/{user_id}                      │
│  GET    /api/privilege-creep/risk-distribution                    │
│  GET    /api/privilege-creep/insights?category=excessive_apps     │
│                                                                   │
│  Knowledge Graph (Neo4j):                                         │
│  GET    /api/knowledge-graph/health                               │
│  POST   /api/knowledge-graph/query                                │
│  GET    /api/knowledge-graph/stats                                │
│                                                                   │
│  Analytics:                                                        │
│  GET    /api/analytics/user-insights                              │
│  GET    /api/analytics/health                                     │
│                                                                   │
│  Authorization: JWT authorizer (Auth0)                            │
│  Authentication: Bearer token in Authorization header             │
└──────────────────────────────────────────────────────────────────┘
```

### API Request Flow

```
Client Request
     │
     │ HTTPS (TLS 1.2+)
     ▼
┌──────────────────┐
│  CloudFront      │  Optional CDN layer (future)
│  (future)        │
└────┬─────────────┘
     │
     ▼
┌──────────────────┐
│  API Gateway     │  • Rate limiting
│  or AppSync      │  • JWT validation
│                  │  • Request transformation
└────┬─────────────┘
     │
     │ Invoke Lambda
     ▼
┌──────────────────┐
│  Lambda Handler  │  • VPC-attached
│                  │  • Tenant resolution
│                  │  • Business logic
└────┬─────────────┘
     │
     ├──────────────┬─────────────┬─────────────┐
     │              │             │             │
     ▼              ▼             ▼             ▼
┌─────────┐  ┌───────────┐  ┌────────┐  ┌────────────┐
│PostgreSQL│ │ Neo4j Aura│  │Bedrock │  │ S3 Bucket  │
│   RDS    │  │  (Graph)  │  │ (AI)   │  │            │
└─────────┘  └───────────┘  └────────┘  └────────────┘
     │              │             │             │
     └──────────────┴─────────────┴─────────────┘
                    │
                    ▼
              Response JSON
                    │
                    ▼
                 Client
```

---

## AI/ML Architecture

### AWS Bedrock Integration

```
┌─────────────────────────────────────────────────────────────────────┐
│                   AI/ML Architecture (AWS Bedrock)                   │
└─────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  Use Case 1: Privilege Creep Detection                          │
│                                                                   │
│  Input:                                                           │
│  • User profile (name, email, department)                         │
│  • Number of groups user is member of                             │
│  • Number of applications user has access to                      │
│  • Peer users in same department (for comparison)                 │
│                                                                   │
│  Model: Claude 3 Haiku (anthropic.claude-3-haiku-20240307-v1:0) │
│                                                                   │
│  Prompt:                                                          │
│  "Analyze this user's access permissions and determine if they   │
│   exhibit privilege creep. Consider their role, department, and   │
│   compare with peer users. Classify as HIGH_RISK_CREEP,          │
│   MODERATE_CREEP, LOW_RISK, or APPROPRIATE_ACCESS. Provide       │
│   specific recommendations."                                      │
│                                                                   │
│  Output (JSON):                                                   │
│  {                                                                │
│    "classification": "HIGH_RISK_CREEP",                          │
│    "confidence_score": 0.92,                                     │
│    "risk_factors": ["Excessive app access", "Stale group"],     │
│    "recommendations": ["Remove access to legacy apps", ...]      │
│  }                                                                │
│                                                                   │
│  Cost: ~$0.00025 per request (Haiku pricing)                     │
│  Performance: ~500ms average response time                        │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  Use Case 2: Dormant User Detection                             │
│                                                                   │
│  Input:                                                           │
│  • User last login date                                           │
│  • Application access history (last 90 days)                      │
│  • Historical activity patterns                                   │
│                                                                   │
│  Model: Claude 3 Haiku                                           │
│                                                                   │
│  Output:                                                          │
│  • Dormancy classification (Dormant, At-Risk, Active)            │
│  • Stale applications (apps not accessed in X days)              │
│  • Recommended actions (disable access, notify manager)          │
│                                                                   │
│  Cost: ~$0.00020 per request                                     │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  Use Case 3: Embeddings for Semantic Search                     │
│                                                                   │
│  Input:                                                           │
│  • User profiles (name, email, role, department)                 │
│  • Application descriptions                                       │
│  • Group descriptions                                             │
│                                                                   │
│  Model: Titan Embeddings V2 (amazon.titan-embed-text-v2:0)      │
│                                                                   │
│  Output:                                                          │
│  • 1024-dimensional vector embeddings                             │
│  • Stored in PostgreSQL pgvector extension                        │
│  • Enables semantic similarity search                             │
│                                                                   │
│  Example Query:                                                   │
│  SELECT * FROM tenant_123.embeddings                             │
│  ORDER BY embedding <=> query_embedding                          │
│  LIMIT 10;                                                        │
│                                                                   │
│  Cost: ~$0.00010 per 1000 tokens                                 │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  Model Selection Strategy                                        │
│                                                                   │
│  Development/Testing:                                             │
│  • Claude 3 Haiku - Fast, cost-effective                         │
│  • Cost: $0.00025 per request                                    │
│  • Speed: ~500ms                                                  │
│                                                                   │
│  Production (future):                                             │
│  • Claude 3 Sonnet - Higher accuracy for critical decisions      │
│  • Cost: $0.003 per request                                      │
│  • Speed: ~1000ms                                                 │
│  • Use for: High-risk privilege creep detection                  │
│                                                                   │
│  Embeddings (all environments):                                   │
│  • Titan Embeddings V2 - Optimized for semantic search           │
│  • Cost: $0.00010 per 1000 tokens                                │
│  • Speed: ~200ms                                                  │
└──────────────────────────────────────────────────────────────────┘
```

### AI Agent Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        AI Agent Pattern                              │
└─────────────────────────────────────────────────────────────────────┘

Agent: Privilege Creep Agent
Location: assurex-insights-engine/functions/privilege-creep-agent/

┌──────────────────────────────────────────────────────────────────┐
│  Lambda Function: assurex-privilege-creep-agent-{stage}          │
│                                                                   │
│  Trigger:                                                         │
│  • Event Router (async invocation)                               │
│  • Manual API call (testing)                                     │
│  • EventBridge schedule (future)                                 │
│                                                                   │
│  Processing Flow:                                                 │
│  1. Receive tenant_id                                            │
│  2. Query PostgreSQL for users, groups, apps                     │
│  3. Batch users (default: 50 per batch)                          │
│  4. For each user:                                               │
│     a. Fetch profile and access data                             │
│     b. Query peer users for comparison                           │
│     c. Build prompt with context                                 │
│     d. Call Bedrock Claude Haiku                                 │
│     e. Parse JSON response                                       │
│     f. Store insight in privilege_creep_insights table           │
│  5. Generate summary statistics                                  │
│  6. Return results                                               │
│                                                                   │
│  Output:                                                          │
│  {                                                                │
│    "users_analyzed": 31,                                         │
│    "insights_generated": 31,                                     │
│    "classifications": {                                           │
│      "HIGH_RISK_CREEP": 5,                                       │
│      "MODERATE_CREEP": 9,                                        │
│      "LOW_RISK": 0,                                              │
│      "APPROPRIATE_ACCESS": 17                                    │
│    },                                                             │
│    "total_cost_usd": 0.008                                       │
│  }                                                                │
│                                                                   │
│  Performance:                                                     │
│  • 31 users analyzed in ~15 seconds                              │
│  • Parallel Bedrock calls (asyncio)                              │
│  • Cost: $0.008 for 31 users (~$0.00025/user)                   │
└──────────────────────────────────────────────────────────────────┘
```

---

## Deployment Architecture

### Environments

| Environment | Region | VPC CIDR | Frontend URL | API URL | Status |
|-------------|--------|----------|--------------|---------|--------|
| **Development** | us-east-1 | 10.0.0.0/16 | localhost:3000 | api-dev.trustx.cloud | ✅ Active |
| **Preprod** | us-east-2 | 10.1.0.0/16 | app-stg.trustx.cloud | api-stg.trustx.cloud | ✅ Active |
| **Production** | us-east-1 | 10.2.0.0/16 | app.trustx.cloud | api.trustx.cloud | ❌ Pending |

### Deployment Pipeline

```
┌─────────────────────────────────────────────────────────────────────┐
│                      Deployment Pipeline                             │
└─────────────────────────────────────────────────────────────────────┘

Repository: trustx (Frontend)
──────────────────────────────
Developer → Git Push → GitHub → Vercel
                                  │
                                  ├─→ Preview (PR branches)
                                  ├─→ Staging (dev branch)
                                  └─→ Production (main branch)

Repository: assurex-infra (Infrastructure)
──────────────────────────────────────────
Developer → Git Commit → Manual Deploy
                         │
                         └─→ serverless deploy --stage {stage}
                               • Lambda functions
                               • AppSync API
                               • CloudFormation stacks

Repository: profile-360-backend (Profile360 API)
────────────────────────────────────────────────
Developer → Git Push → GitHub Actions
                         │
                         ├─→ PR: Deploy to dev
                         └─→ Merge: Deploy to preprod

Repository: assurex-insights-engine (ETL & AI)
──────────────────────────────────────────────
Developer → Git Commit → Manual Deploy
                         │
                         └─→ serverless deploy --stage {stage}
                               • Event router
                               • AI agents
                               • ETL processors
```

### Deployment Commands

```bash
# Frontend (trustx)
cd trustx/
git push origin main  # Auto-deploys to Vercel production

# Infrastructure (assurex-infra)
cd assurex-infra/
serverless deploy --stage dev --region us-east-1
serverless deploy --stage preprod --region us-east-2

# Profile360 API (profile-360-backend)
cd profile-360-backend/
serverless deploy --stage dev --region us-east-1
# OR
npm run deploy:dev

# Insights Engine (assurex-insights-engine)
cd assurex-insights-engine/functions/privilege-creep-agent/
serverless deploy --stage dev --region us-east-1

cd ../event-router/
serverless deploy --stage dev --region us-east-1
```

---

## Monitoring & Observability

### CloudWatch Integration

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Monitoring & Logging                              │
└─────────────────────────────────────────────────────────────────────┘

Lambda Logs:
• /aws/lambda/assurex-privilege-creep-agent-dev
• /aws/lambda/assurex-profile360-event-router-dev
• /aws/lambda/assurex-profile360-neo4j-sync-dev
• /aws/lambda/profile-360-backend-dev-api

Metrics:
• Invocation count
• Error rate
• Duration (p50, p90, p99)
• Concurrent executions
• Throttles

Alarms (future):
• Lambda error rate > 5%
• API Gateway 5xx errors > 1%
• RDS CPU > 80%
• Lambda duration > 25s
```

### Performance Metrics

| Component | Metric | Target | Current |
|-----------|--------|--------|---------|
| **API Gateway** | Latency (p99) | < 1s | ~500ms |
| **Lambda Cold Start** | Duration | < 5s | ~3s |
| **Lambda Warm** | Duration | < 1s | ~300ms |
| **RDS Queries** | Response time | < 100ms | ~50ms |
| **Neo4j Queries** | Response time | < 200ms | ~150ms |
| **Bedrock Inference** | Response time | < 2s | ~500ms |

---

## Cost Analysis

### Monthly Cost Estimate (Development)

| Service | Usage | Cost |
|---------|-------|------|
| **RDS PostgreSQL** | db.t3.micro, 20GB gp3 | $35 |
| **NAT Gateway** | 1 NAT @ $0.045/hr | $32 |
| **Lambda** | 1M requests, 512MB, 5s avg | $8 |
| **API Gateway** | 1M requests | $3.50 |
| **Neo4j Aura** | Free tier per tenant | $0 |
| **Bedrock** | 10K requests/month Haiku | $2.50 |
| **S3** | 10GB storage, 100K requests | $0.50 |
| **Secrets Manager** | 5 secrets | $2 |
| **CloudWatch** | Logs, metrics | $5 |
| **VPC** | Flow logs | $2 |
| **Total** | | **~$90/month** |

### Production Scaling

At 1000 tenants, 1M users:
- RDS: Upgrade to db.r5.xlarge (~$500/month)
- Lambda: ~$200/month (more invocations)
- Bedrock: ~$100/month (more AI inference)
- Neo4j: ~$2000/month (paid tiers, multiple instances)
- Total: **~$3000/month**

---

## Future Enhancements

### Planned Architecture Changes

1. **S3 Event Notifications**
   - Auto-trigger event router on S3 uploads
   - Eliminate manual pipeline triggers

2. **GraphRAG Integration**
   - Phase 5: Natural language queries on knowledge graph
   - Bedrock + Neo4j semantic search

3. **Production Environment**
   - us-east-1 production deployment
   - Multi-region failover (future)

4. **Advanced Monitoring**
   - X-Ray tracing
   - CloudWatch alarms
   - Slack notifications

5. **Performance Optimization**
   - Lambda SnapStart
   - Connection pooling for RDS
   - Redis cache layer (future)

6. **Security Enhancements**
   - AWS WAF for API Gateway
   - GuardDuty for threat detection
   - VPC endpoints for AWS services

---

**Document Version**: 1.0.0
**Last Updated**: October 31, 2025
**Maintained By**: AssureX Engineering Team
**Next Review**: November 30, 2025
