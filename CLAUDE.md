# Claude AI Assistant Guide - AssureX Workspace

This guide helps Claude AI (and other AI assistants) understand the complete AssureX project across all repositories.

## 🎯 Project Overview

**AssureX** is a multi-tenant SaaS compliance and security management platform that combines traditional reliability with AI-powered intelligence for real-time insights, automated workflows, and seamless security integrations.

### Architecture - 4 Independent Repositories

```
┌─────────────────────────────────────────────────────────────────┐
│                        AssureX Platform                          │
└─────────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
   ┌────▼────┐          ┌────▼────┐          ┌────▼────┐
   │ trustx  │          │ assurex │          │profile- │
   │Frontend │◄────────►│  infra  │◄────────►│360 API  │
   └─────────┘          └────┬────┘          └─────────┘
                             │
                        ┌────▼────┐
                        │insights │
                        │ engine  │
                        └─────────┘
```

### Tech Stack Summary

| Component | Tech Stack | Purpose |
|-----------|------------|---------|
| **trustx** | Next.js 14, React, TailwindCSS | Frontend UI |
| **assurex-infra** | Serverless Framework, CloudFormation | AWS Infrastructure |
| **profile-360-backend** | FastAPI, PostgreSQL, Neo4j | User Analytics API |
| **assurex-insights-engine** | Python, AWS Lambda, Bedrock | ETL & AI Processing |

## 📁 Repository Roles

### 1. trustx (Frontend)

**Location**: `trustx/`
**Role**: User-facing web application
**Tech**: Next.js 14, React, TypeScript, TailwindCSS
**Deployment**: Vercel (https://app.trustx.cloud)

**Key Features**:
- User authentication (Auth0)
- Integration management UI (GitHub, Jira, Okta, Entra)
- Profile360 dashboard (user analytics)
- Tenant validation & access control
- Real-time sync status polling

**API Consumption**:
- Integrations API (AppSync GraphQL)
- Profile360 API (REST)

**Documentation**: `trustx/README.md`

### 2. assurex-infra (Infrastructure)

**Location**: `assurex-infra/`
**Role**: AWS infrastructure and backend services
**Tech**: Serverless Framework, AWS (Lambda, AppSync, RDS, VPC)
**Deployment**: AWS (us-east-1 dev, us-east-2 preprod)

**Key Components**:
- **VPC & Networking**: Multi-AZ, NAT Gateway, private subnets
- **Database**: PostgreSQL 17.4 (multi-tenant schemas)
- **Lambda Functions**: Integration handlers, sync operations
- **AppSync GraphQL**: Integrations API
- **Security**: 7 security groups, VPC Flow Logs, IAM policies
- **Secrets Management**: AWS Secrets Manager

**Environments**:
- Dev: us-east-1 (10.0.0.0/16)
- Preprod: us-east-2 (10.1.0.0/16)
- Prod: us-east-1 (10.2.0.0/16) - Not deployed

**Documentation**:
- `assurex-infra/README.md` - Quick start
- `assurex-infra/CLAUDE.md` - Detailed guide
- `assurex-infra/docs/` - 20+ documentation files

### 3. profile-360-backend (User Analytics API)

**Location**: `profile-360-backend/`
**Role**: User analytics, activity tracking, knowledge graph
**Tech**: FastAPI, PostgreSQL, Neo4j Aura, AWS Lambda
**Deployment**: AWS Lambda + API Gateway

**Key Features**:
- User profile management (CRUD)
- Activity tracking and analytics
- Dormant user detection (AI-powered)
- Privilege creep detection (AI-powered, Bedrock Claude)
- Neo4j knowledge graph (multi-tenant)
- JWT-based authentication (Auth0)
- Event router orchestration

**Endpoints**: `/profile360/*`
- `/profile360/users/` - User management
- `/profile360/users/{user_id}/activities` - Activity history
- `/profile360/users/dormant` - Dormant users
- `/profile360/api/knowledge-graph/*` - Graph operations
- `/profile360/api/privilege-creep/*` - Privilege creep analytics
- `/profile360/api/analytics/*` - User analytics and insights

**Multi-Tenant Pattern**:
- Separate Neo4j instance per tenant
- Database schema isolation (tenant_123456)
- JWT claims for tenant context

**Environments**:
- Dev: https://api-dev.trustx.cloud/profile360 (API Gateway endpoint)
- Preprod: https://api-stg.trustx.cloud/profile360
- Prod: Not deployed

**Documentation**:
- `profile-360-backend/README.md` - Quick start
- `profile-360-backend/CLAUDE.md` - Detailed guide
- `profile-360-backend/docs/` - Feature documentation

### 4. assurex-insights-engine (ETL & AI)

**Location**: `assurex-insights-engine/`
**Role**: Data processing, ETL, AI-powered insights
**Tech**: Python, AWS Lambda, Bedrock (Claude + Titan), pgvector
**Deployment**: AWS Lambda (event-driven)

**Key Features**:
- **Traditional ETL**: Simple, reliable data loads (users, groups, signins)
- **AI ETL**: RAG-based field mapping for flexible schemas
- **Hybrid ETL**: AI + Traditional for complex multi-source data
- **Multi-Tenant**: Complete data isolation per tenant
- **Event-Driven**: S3 uploads, EventBridge schedules, manual actions

**ETL Types**:
1. **Traditional ETL**: Predefined mappings, fast, reliable
2. **AI ETL**: RAG for schema discovery, flexible, intelligent
3. **Hybrid ETL**: Best of both - AI mapping + traditional business logic

**Current Status** (Oct 10, 2025):
- ✅ Phase 4 Complete: Hybrid ETL tested and working
- ✅ 9 users inserted, 35 group memberships loaded
- ✅ FK resolution working (sso_users lookup)
- ✅ Multi-source extraction verified

**Documentation**:
- `assurex-insights-engine/README.md` - Overview & status
- `assurex-insights-engine/docs/` - ETL architecture

## 🔄 How Repositories Interact

### Event Router Orchestration (New!)

**Event Router** is the central orchestration Lambda that manages the complete data processing pipeline:

```
┌─────────────────────────────────────────────────────────────┐
│                    Event Router Lambda                       │
│               (assurex-insights-engine)                      │
└─────────────────┬───────────────────────────────────────────┘
                  │ Receives: sync_completed trigger
                  │
      ┌───────────┼───────────┬───────────┬───────────┐
      │           │           │           │           │
      ▼           ▼           ▼           ▼           ▼
  ┌──────┐   ┌────────┐  ┌────────┐ ┌─────────┐ ┌─────────┐
  │ ETL  │   │Vector- │  │ Neo4j  │ │Analytics│ │Privilege│
  │      │   │ization │  │  Sync  │ │         │ │  Creep  │
  └──────┘   └────────┘  └────────┘ └─────────┘ └─────────┘
     202         202         202        202          202
  (async)     (async)     (async)    (async)      (async)
```

**Pipeline Flow**:
1. Integration sync completes → Event router triggered
2. Router invokes 6 Lambda functions asynchronously (all return 202)
3. Each component processes independently in parallel
4. Results stored in PostgreSQL and Neo4j

**Components**:
- **ETL**: Extract raw data, load into database
- **Vectorization**: Generate embeddings for semantic search
- **Neo4j Sync**: Build knowledge graph (users, apps, groups)
- **Analytics**: Calculate user metrics and statistics
- **Dormant User Agent**: Detect inactive users (AI-powered)
- **Privilege Creep Agent**: Identify excessive permissions (AI-powered)

### User Journey Example: GitHub Integration Sync

```
1. User Action (trustx):
   User clicks "Sync" on GitHub integration
   ↓
2. Frontend (trustx):
   Calls GraphQL mutation: syncIntegration
   ↓
3. Integrations API (assurex-infra):
   AppSync → Lambda → S3 (stores raw data)
   ↓
4. Event Router (assurex-insights-engine):
   S3 event → Triggers complete pipeline (6 Lambda functions)
   ↓
5. ETL Processing (assurex-insights-engine):
   Processes data → Loads into PostgreSQL
   ↓
6. AI Agents (assurex-insights-engine):
   Dormant detection + Privilege creep analysis
   ↓
7. Profile360 API (profile-360-backend):
   Provides analytics on processed data
   ↓
8. Frontend (trustx):
   Polls sync status, displays results
```

### Data Flow Architecture

```
┌──────────┐
│  User    │
└────┬─────┘
     │
     ▼
┌──────────────────────────────────────┐
│  Frontend (trustx)                   │
│  - Next.js app                       │
│  - Auth0 JWT                         │
└──────┬───────────────────────────────┘
       │
       ├──────────────────────────────────┐
       │                                  │
       ▼                                  ▼
┌──────────────────┐            ┌──────────────────┐
│ Integrations API │            │ Profile360 API   │
│ (assurex-infra)  │            │ (profile-360)    │
│ - AppSync        │            │ - FastAPI        │
│ - Lambda         │            │ - Neo4j          │
└─────┬────────────┘            └──────┬───────────┘
      │                                │
      │                                │
      ▼                                ▼
┌──────────────────────────────────────┐
│  Shared Database (PostgreSQL)        │
│  - Multi-tenant schemas              │
│  - tenant_123456, tenant_789012      │
└──────┬───────────────────────────────┘
       │
       ▼
┌──────────────────┐
│ Insights Engine  │
│ - ETL processing │
│ - AI insights    │
└──────────────────┘
```

## 🗂️ Finding Information Quickly

### "Where do I find...?"

| What | Where | File |
|------|-------|------|
| **Overall project status** | Workspace root | `PROJECT_STATUS.md` |
| **Version history** | Workspace root | `CHANGELOG.md` |
| **Feature roadmap** | Workspace root | `DEVELOPMENT_ROADMAP.md` |
| **Documentation map** | Workspace docs | `docs/INDEX.md` |
| **Infrastructure details** | assurex-infra | `CLAUDE.md`, `docs/` |
| **API endpoints** | profile-360-backend | `README.md` |
| **ETL architecture** | assurex-insights-engine | `README.md` |
| **Event router** | assurex-insights-engine | `functions/event-router/` |
| **Privilege creep** | assurex-insights-engine | `functions/privilege-creep-agent/` |
| **Frontend components** | trustx | `README.md`, `docs/COMPONENTS.md` |
| **Dormant user feature** | profile-360-backend | `docs/DORMANT_USER_*.md` |
| **Neo4j integration** | profile-360-backend | `docs/PROFILE360_NEO4J_CHECKPOINT.md` |
| **Database schema** | assurex-infra | `docs/RDS_IMPLEMENTATION_PLAN.md` |
| **Deployment guides** | Each repo | `README.md`, `CLAUDE.md` |

### Common Commands by Repository

#### Workspace Commands
```bash
# View overall status
cat PROJECT_STATUS.md

# View documentation index
cat docs/INDEX.md

# Check all repos git status
make status

# Pull all repos
make pull
```

#### Frontend (trustx)
```bash
cd trustx/
npm run dev              # Start dev server
npm run build            # Production build
npm run deploy           # Deploy to Vercel
```

#### Infrastructure (assurex-infra)
```bash
cd assurex-infra/
npm run deploy:dev       # Deploy to dev
npm run deploy:preprod   # Deploy to preprod
serverless info --stage dev
```

#### Profile360 API (profile-360-backend)
```bash
cd profile-360-backend/
serverless deploy --stage dev
serverless logs -f api --stage dev --tail
```

#### Insights Engine (assurex-insights-engine)
```bash
cd assurex-insights-engine/
serverless deploy --stage dev
aws lambda invoke --function-name assurex-insights-engine-dev ...
```

## 🔐 Multi-Tenant Architecture

### Database Isolation

**Pattern**: Schema-based multi-tenancy

```sql
Database: assurex_dev / assurex_preprod
├── public (shared)
│   ├── tenants              -- Tenant registry
│   ├── frameworks           -- SOC2, NIST, ISO 27001
│   └── controls             -- TX-* control codes
│
├── tenant_118230 (trustx - isolated)
│   ├── users
│   ├── user_activities
│   ├── sso_users            -- IDP users
│   ├── group_memberships
│   ├── app_assignments
│   └── ... (100+ tables)
│
└── tenant_758734 (trustxinc - isolated)
    └── ... (same structure)
```

### Tenant Resolution Flow

```
1. User authenticates → Auth0 JWT
2. JWT contains claim: https://trustx.cloud/claims/company = "trustx"
3. Backend validates JWT
4. Query public.tenants WHERE tenant_name = "trustx"
5. Get tenant_id = 118230
6. All queries scoped to tenant_118230 schema
```

## 🚀 Deployment Strategy

### Environments

| Environment | Frontend | Backend APIs | Database | Status |
|-------------|----------|--------------|----------|--------|
| **Development** | localhost:3000 | us-east-1 | us-east-1 | ✅ Active |
| **Preprod** | app-stg.trustx.cloud | us-east-2 | us-east-2 | ✅ Active |
| **Production** | app.trustx.cloud | us-east-1 | Not deployed | ❌ Pending |

### Deployment Process

**Frontend (trustx)**:
- Push to `main` → Vercel auto-deploys to production
- Push to `dev` → Vercel auto-deploys to staging

**Infrastructure (assurex-infra)**:
- Manual: `serverless deploy --stage {stage}`
- CI/CD: GitHub Actions on push to specific branches

**Profile360 API (profile-360-backend)**:
- Manual: `serverless deploy --stage {stage}`
- CI/CD: GitHub Actions on push to `main` or `preprod`

**Insights Engine (assurex-insights-engine)**:
- Manual: `serverless deploy --stage {stage}`
- Planned: GitHub Actions automation

## 🧩 Common Cross-Repo Workflows

### Adding a New Feature

**Example: Adding a new integration type (e.g., Azure AD)**

1. **Backend (assurex-infra)**:
   ```bash
   cd assurex-infra/resources/lambda-functions/integrations-configure/
   # Add new handler for Azure AD
   # Update GraphQL schema
   # Deploy
   serverless deploy --stage dev
   ```

2. **ETL (assurex-insights-engine)**:
   ```bash
   cd assurex-insights-engine/
   # Add Azure AD data extraction
   # Add field mappings
   # Test ETL
   ```

3. **Frontend (trustx)**:
   ```bash
   cd trustx/
   # Add Azure AD integration component
   # Update integration list
   # Test UI flow
   npm run dev
   ```

4. **Profile360 (if analytics needed)**:
   ```bash
   cd profile-360-backend/
   # Add Azure AD-specific analytics if needed
   ```

### Debugging Issues Across Repos

**Scenario: User can't see their data after sync**

1. **Check Frontend** (trustx):
   - Browser console errors?
   - JWT token valid?
   - Tenant claim present?

2. **Check Integrations API** (assurex-infra):
   - Did sync complete successfully?
   - Check CloudWatch logs
   - Verify S3 data uploaded

3. **Check ETL** (assurex-insights-engine):
   - Did ETL process the data?
   - Check Lambda logs
   - Verify database records

4. **Check Profile360 API** (profile-360-backend):
   - Query returns data?
   - Tenant context correct?
   - Database connection working?

## 📊 Current Status (Oct 31, 2025)

### What's Working ✅

| Component | Status | Notes |
|-----------|--------|-------|
| Frontend (trustx) | ✅ Production | Live at app.trustx.cloud |
| Infrastructure (assurex-infra) | ✅ Dev + Preprod | Phase 3.6 complete |
| Profile360 API | ✅ Dev + Preprod | Neo4j + Privilege Creep |
| Insights Engine | ✅ Dev + Preprod | Event Router + AI Agents |
| Event Router | ✅ Dev + Preprod | Orchestrating 6-step pipeline |
| Privilege Creep Agent | ✅ Dev + Preprod | AI-powered detection |
| Dormant User Agent | ✅ Dev + Preprod | AI-powered detection |

### What's Pending ⏳

- Production infrastructure deployment
- Production database setup
- Production Neo4j instances
- S3 event notifications for auto-triggering
- Advanced monitoring & alerting
- GraphRAG integration (Phase 5+)

### Recent Milestones 🎉

- **Oct 31**: Preprod privilege creep deployed & operational
- **Oct 31**: Event router orchestration working in dev + preprod
- **Oct 30**: Privilege creep API routes registered & tested
- **Oct 30**: Neo4j sync triggered for preprod (45 users, 252 relationships)
- **Oct 10**: Hybrid ETL Phase 4 complete (35 group memberships loaded)
- **Oct 8**: Neo4j multi-tenant integration live
- **Oct 6**: Tenant validation & access control

## 🔧 Development Best Practices

### Working Across Repos

1. **Keep context**: Use VS Code multi-root workspace
2. **Branch naming**: `feature/description`, `bugfix/description`
3. **Commit messages**: Use conventional commits
4. **Testing**: Test locally before deploying
5. **Documentation**: Update relevant CLAUDE.md and README.md

### Repository-Specific Patterns

**assurex-infra**:
- ALL database Lambda functions MUST use Python 3.12
- Lambda layers: `assurex-db-connector-{stage}`
- VPC: Lambda functions in private subnets

**profile-360-backend**:
- FastAPI for REST endpoints
- Multi-tenant via schema isolation
- Neo4j per tenant (separate instances)

**assurex-insights-engine**:
- Choose ETL type based on data complexity
- Traditional ETL: Simple, predefined mappings
- AI ETL: Complex, flexible schemas
- Hybrid ETL: Multi-source, FK resolution

**trustx**:
- Next.js 14 app router
- TypeScript strict mode
- TailwindCSS for styling

## 🆘 Troubleshooting

### Common Issues

**Issue**: "ImportModuleError: No module named 'psycopg2._psycopg'"
- **Cause**: Lambda runtime ≠ layer Python version
- **Fix**: Ensure `runtime: python3.12` in serverless.yml
- **Docs**: `assurex-infra/docs/LAMBDA_LAYER_PATTERN.md`

**Issue**: "Neo4j connection failed"
- **Cause**: Lambda security group missing port 7687
- **Fix**: Add egress rule for port 7687
- **Docs**: `profile-360-backend/CLAUDE.md`

**Issue**: "Invalid tenant" / 401 errors
- **Cause**: JWT missing company claim or tenant inactive
- **Fix**: Verify JWT claims and tenant status
- **Docs**: `assurex-infra/CLAUDE.md`

**Issue**: "ETL loaded 0 records"
- **Cause**: FK resolution failed (empty sso_users table)
- **Fix**: Verify tenant_id and populate sso_users
- **Docs**: `assurex-insights-engine/README.md`

## 📞 Getting Help

### Documentation Hierarchy

1. **Start here**: This file (workspace CLAUDE.md)
2. **Repo overview**: Each repo's README.md
3. **Detailed guide**: Each repo's CLAUDE.md (if exists)
4. **Feature docs**: Repo's docs/ directory
5. **API reference**: OpenAPI/GraphQL schema files

### Key Documentation Files

**Workspace Level**:
- `CLAUDE.md` (this file) - Complete project guide
- `PROJECT_STATUS.md` - Current status
- `CHANGELOG.md` - Version history
- `DEVELOPMENT_ROADMAP.md` - Future plans
- `docs/INDEX.md` - Documentation map

**Repository Level**:
- Each repo has README.md for quick start
- Some repos have CLAUDE.md for detailed guide
- Feature-specific docs in docs/ directories

## 🎯 Quick Decision Guide

### "Which repo do I modify?"

| Task | Repository |
|------|------------|
| Frontend UI changes | trustx |
| GraphQL API changes | assurex-infra |
| User analytics | profile-360-backend |
| ETL processing | assurex-insights-engine |
| Infrastructure changes | assurex-infra |
| Database schema | assurex-infra (migrations) |
| Neo4j queries | profile-360-backend |

### "Which documentation do I update?"

| Change | Update |
|--------|--------|
| Feature complete | CHANGELOG.md + repo README |
| New feature started | DEVELOPMENT_ROADMAP.md |
| Status changed | PROJECT_STATUS.md |
| Architecture change | Repo CLAUDE.md + docs/ |
| Cross-repo change | Workspace CLAUDE.md |

---

## 📚 Additional Resources

### Repository-Specific Guides
- **assurex-infra**: `assurex-infra/CLAUDE.md` - Detailed infrastructure guide
- **profile-360-backend**: `profile-360-backend/CLAUDE.md` - API & Neo4j guide
- **trustx**: `trustx/README.md` - Frontend development
- **assurex-insights-engine**: `assurex-insights-engine/README.md` - ETL guide

### AWS Resources
- **AWS Account**: 533267024692
- **AWS Profile**: `assurex`
- **Regions**: us-east-1 (dev/prod), us-east-2 (preprod)

### External Services
- **Auth0**: trustx.us.auth0.com
- **Neo4j**: Aura cloud instances (multi-tenant)
- **GitHub**: TrustXinc organization
- **Vercel**: Frontend deployment

---

**Last Updated**: October 31, 2025
**Maintained By**: AssureX Engineering Team
**Workspace Location**: `/Users/ramakesani/Documents/assurex`

## Version

**Workspace CLAUDE.md Version**: 1.1.0
**Last Comprehensive Update**: October 31, 2025
**Major Updates**: Event Router orchestration, Privilege Creep AI agent, Preprod deployment complete
**Next Review**: November 15, 2025
