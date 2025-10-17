# AssureX Workspace Claude Skills

This directory contains workspace-level Claude Code skills that span all AssureX repositories. These skills help Claude work efficiently across the entire platform.

## Available Skills

### 1. cross-repo-workflows
**Purpose**: Work across multiple repositories for end-to-end features

**Use when you need to:**
- Add a new feature that spans frontend, backend, and infrastructure
- Coordinate changes across multiple repositories
- Understand data flow from frontend to database
- Implement end-to-end testing across services
- Migrate features between repositories

**Key features:**
- End-to-end feature implementation workflows
- Cross-repository dependency management
- Multi-repo testing strategies
- Common integration patterns

### 2. architecture-overview
**Purpose**: Understand the overall AssureX platform architecture

**Use when you need to:**
- Understand how repositories interact
- Design new features with proper architecture
- Debug issues that span multiple components
- Make architectural decisions
- Onboard to the project

**Key features:**
- System architecture diagrams
- Repository relationships
- Data flow patterns
- Technology stack overview
- Multi-tenant architecture explanation

### 3. deployment-coordination
**Purpose**: Coordinate deployments across multiple repositories

**Use when you need to:**
- Deploy changes that span multiple repos
- Manage deployment order and dependencies
- Handle database migrations across services
- Coordinate environment updates
- Perform rollbacks across services

**Key features:**
- Deployment sequencing
- Environment synchronization
- Database migration coordination
- Rollback procedures
- Deployment verification

### 4. debugging-full-stack
**Purpose**: Debug issues that span multiple components

**Use when you need to:**
- Trace issues from frontend to database
- Debug API integration problems
- Investigate multi-tenant issues
- Diagnose performance problems
- Resolve authentication/authorization failures

**Key features:**
- Full-stack tracing techniques
- Cross-repository log correlation
- End-to-end testing strategies
- Common issue patterns
- Systematic debugging workflows

---

## Repository Structure

```
assurex/ (workspace root)
├── trustx/                    # React frontend
│   └── .claude/skills/        # Frontend-specific skills
├── assurex-infra/             # AWS infrastructure
│   └── .claude/skills/        # Infrastructure-specific skills
├── profile-360-backend/       # FastAPI REST API
│   └── .claude/skills/        # API-specific skills
├── assurex-insights-engine/   # Analytics & AI
│   └── .claude/skills/        # Analytics-specific skills
└── .claude/skills/            # Workspace-level skills (this directory)
```

## How Repositories Work Together

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

### Data Flow Example: User Activity Tracking

```
1. User Action (trustx):
   User logs into application
   ↓
2. Frontend (trustx):
   Calls Profile360 API to record activity
   ↓
3. Profile360 API (profile-360-backend):
   Saves activity to PostgreSQL
   Updates Neo4j knowledge graph
   ↓
4. Insights Engine (assurex-insights-engine):
   Processes activity for analytics
   Generates risk scores and insights
   ↓
5. Frontend (trustx):
   Displays analytics dashboard
```

## Tech Stack Overview

| Component | Tech Stack | Location |
|-----------|------------|----------|
| **Frontend** | React 18, Apollo Client, Auth0, Material-UI | trustx/ |
| **Infrastructure** | Serverless Framework, AWS (Lambda, RDS, VPC) | assurex-infra/ |
| **REST API** | FastAPI, PostgreSQL, Neo4j Aura | profile-360-backend/ |
| **Analytics** | Python, AWS Lambda, Bedrock, pgvector | assurex-insights-engine/ |
| **Database** | PostgreSQL 17.4 (multi-tenant schemas) | Shared across services |
| **Graph DB** | Neo4j Aura (per-tenant instances) | profile-360-backend/ |
| **Auth** | Auth0 (JWT with custom claims) | All services |
| **Deployment** | Cloudflare Pages (frontend), AWS Lambda (backend) | All |

## Common Workflows

### Adding a New Feature

**Example: Add "User Risk Score" feature**

1. **Backend API** (profile-360-backend):
   - Add risk score endpoint
   - Update database schema
   - Deploy to dev

2. **Analytics** (assurex-insights-engine):
   - Implement risk calculation logic
   - Add Lambda function
   - Deploy to dev

3. **Infrastructure** (assurex-infra):
   - Add new Lambda functions
   - Update IAM policies
   - Deploy to dev

4. **Frontend** (trustx):
   - Add risk score component
   - Call new API endpoint
   - Deploy to staging

### Coordinated Deployment

**Order matters when deploying across repos:**

1. **Database Migrations** (assurex-infra):
   ```bash
   cd assurex-infra/resources/database/lambda-schema-init
   ./deploy.sh dev
   ```

2. **Backend API** (profile-360-backend):
   ```bash
   cd profile-360-backend
   serverless deploy --stage dev
   ```

3. **Analytics Functions** (assurex-insights-engine):
   ```bash
   cd assurex-insights-engine
   npm run deploy:analytics:dev
   ```

4. **Frontend** (trustx):
   ```bash
   cd trustx
   git push origin stg  # Auto-deploys to staging
   ```

### Full-Stack Debugging

**Example: "User activities not showing in dashboard"**

1. **Check Frontend** (trustx):
   ```javascript
   // Browser console
   console.log('API URL:', process.env.REACT_APP_PROFILE360_ENDPOINT);
   // Check network tab for API calls
   ```

2. **Check API** (profile-360-backend):
   ```bash
   # Check API logs
   aws logs tail /aws/lambda/profile-360-backend-dev-api --follow
   ```

3. **Check Database** (assurex-infra):
   ```bash
   # Connect to database
   ./scripts/db-connect.sh
   # Query activities
   SELECT * FROM tenant_123456.user_activities LIMIT 10;
   ```

4. **Check Analytics** (assurex-insights-engine):
   ```bash
   # Check if ETL processed data
   aws logs tail /aws/lambda/assurex-insights-engine-dev --follow
   ```

## Environment Mapping

| Environment | Frontend | Backend APIs | Database | Region |
|-------------|----------|--------------|----------|--------|
| **Development** | localhost:3000 | us-east-1 | us-east-1 | us-east-1 |
| **Staging** | app-stg.trustx.cloud | us-east-2 | us-east-2 | us-east-2 |
| **Production** | app.trustx.cloud | us-east-1 | Not deployed | us-east-1 |

**Important**: Staging uses us-east-2, development and production use us-east-1

## Multi-Tenant Architecture

All services share the same multi-tenant pattern:

**Database Isolation**:
```
Database: assurex_dev / assurex_preprod
├── public (shared)
│   └── tenants              # Tenant registry
│
├── tenant_118230 (trustx)   # Complete data isolation
│   ├── users
│   ├── user_activities
│   └── ... (100+ tables)
│
└── tenant_758734 (trustxinc)
    └── ... (same structure)
```

**Neo4j Isolation**:
- Separate Neo4j instance per tenant
- Credentials in Secrets Manager: `assurex/{stage}/neo4j/tenant_{id}`
- Complete graph isolation

**Tenant Context Flow**:
```
1. User authenticates → Auth0 JWT
2. JWT contains: https://trustx.cloud/claims/company = "trustx"
3. All services extract company claim
4. Query public.tenants for tenant_id
5. All operations scoped to tenant_{id} schema
```

## Repository-Specific Skills

Each repository has its own detailed skills:

**trustx** (Frontend):
- frontend-dev: React development
- deployment-ops: Cloudflare Pages
- frontend-troubleshoot: Frontend debugging

**assurex-infra** (Infrastructure):
- deploy-infra: Infrastructure deployment
- db-operations: Database management
- lambda-dev: Lambda development
- multi-tenant-ops: Tenant operations
- troubleshoot-infra: Infrastructure debugging

**profile-360-backend** (REST API):
- api-ops: FastAPI deployment and operations

**assurex-insights-engine** (Analytics):
- analytics-ops: Analytics functions
- dormant-user-ops: AI-powered insights
- insights-troubleshoot: Analytics debugging

## Best Practices for Cross-Repo Work

1. **Test Locally First** - Use local development environment before deploying
2. **Deploy in Order** - Database → Backend → Analytics → Frontend
3. **Use Staging** - Always test in staging before production
4. **Coordinate Migrations** - Database changes must deploy before API changes
5. **Version Lock Dependencies** - Ensure compatible versions across repos
6. **Document Cross-Repo Changes** - Update workspace-level documentation
7. **Use Feature Branches** - Create feature branches in all affected repos
8. **Tag Releases** - Use same version tags across related changes
9. **Monitor All Services** - Check logs for all affected services after deployment
10. **Rollback Strategy** - Know how to rollback each component independently

## Quick Commands Reference

### Workspace Status
```bash
# Check git status for all repos
make status

# Pull all repos
make pull

# View overall project status
cat PROJECT_STATUS.md
```

### Deploy All Services (Dev)
```bash
# Infrastructure
cd assurex-infra && npm run deploy:dev

# Backend API
cd ../profile-360-backend && serverless deploy --stage dev

# Analytics
cd ../assurex-insights-engine && npm run deploy:analytics:dev

# Frontend
cd ../trustx && git push origin stg
```

### Connect to Databases
```bash
# Dev database (PostgreSQL)
cd assurex-infra && ./scripts/db-connect.sh

# Preprod database
cd assurex-infra && ./scripts/db-connect-preprod.sh
```

### View All Logs
```bash
# Infrastructure logs
cd assurex-infra && npm run logs:dev

# Backend API logs
cd profile-360-backend && serverless logs -f api --stage dev --tail

# Analytics logs
cd assurex-insights-engine && npm run logs:analytics:dev
```

## Documentation Index

**Workspace-Level Docs**:
- `CLAUDE.md` - Complete project guide for Claude AI
- `README.md` - Workspace overview
- `PROJECT_STATUS.md` - Current status and roadmap
- `CHANGELOG.md` - Version history
- `DEVELOPMENT_ROADMAP.md` - Future plans
- `docs/INDEX.md` - Documentation map

**Repository-Specific Docs**:
- Each repo has its own README.md and CLAUDE.md
- Feature-specific docs in each repo's docs/ directory

## When to Use Workspace Skills

Use workspace-level skills when you need to:
- Work across multiple repositories
- Understand overall system architecture
- Coordinate deployments
- Debug full-stack issues
- Design cross-cutting features
- Onboard to the project
- Make architectural decisions

Use repository-specific skills when you need to:
- Work within a single repository
- Deploy a specific service
- Debug service-specific issues
- Add features to a single component

---

**Last Updated**: 2025-10-17
**Maintained By**: AssureX Engineering Team
**Workspace Location**: `/Users/ramakesani/Documents/assurex`
