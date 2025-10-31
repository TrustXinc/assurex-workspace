# AssureX Workspace

**Unified development workspace for AssureX frontend and backend**

This workspace brings together three independent repositories for streamlined development:
- **trustx** - Frontend Next.js application
- **assurex-infra** - Backend AWS infrastructure and Lambda functions
- **profile-360-backend** - Profile360 FastAPI microservice (user analytics & Neo4j knowledge graph)

## 📁 Repository Structure

```
assurex/                              # Workspace root (NOT a git repo)
├── .vscode/
│   └── assurex.code-workspace        # VS Code multi-root workspace
├── trustx/                           # Frontend repo (independent git)
│   ├── .git/
│   ├── src/
│   ├── package.json
│   └── ...
├── assurex-infra/                    # Infrastructure repo (independent git)
│   ├── .git/
│   ├── resources/
│   ├── serverless.yml
│   └── ...
├── profile-360-backend/              # Profile360 API repo (independent git)
│   ├── .git/
│   ├── app/
│   │   ├── api/                      # FastAPI endpoints
│   │   ├── models/                   # Pydantic schemas
│   │   ├── services/                 # Business logic & Neo4j
│   │   └── queries/                  # SQL queries
│   ├── serverless.yml                # Lambda deployment config
│   ├── requirements.txt              # Python dependencies
│   └── ...
├── docker-compose.yml                # Local development environment
├── Makefile                          # Unified development commands
├── .gitignore                        # Workspace-level ignores
└── README.md                         # This file
```

## 🚀 Quick Start

### Prerequisites

- **Node.js** 18+ and npm
- **Python** 3.12+
- **Docker** and Docker Compose
- **AWS CLI** configured with credentials
- **Git** with SSH access to GitHub repositories

### Initial Setup

```bash
# If starting fresh (both repos not cloned yet)
cd /Users/ramakesani/Documents
mkdir assurex && cd assurex
make setup

# If repos already cloned (your current situation)
cd /Users/ramakesani/Documents/assurex
make install
```

### Open in VS Code

```bash
# Open the multi-root workspace
code .vscode/assurex.code-workspace
```

This will open both repositories in a single VS Code window with:
- Separate folder views for frontend and backend
- Unified search across both codebases
- Shared settings and extensions

## 🛠️ Development Commands

### Using Make (Recommended)

```bash
# Show all available commands
make help

# Start full development environment (frontend + postgres + localstack)
make dev

# Start services in background
make dev-bg

# Stop all services
make dev-stop

# Run frontend only
make dev-frontend

# Run backend services only (postgres + localstack)
make dev-backend

# Check status of both repos
make status

# Pull latest changes from both repos
make pull

# See current branch in both repos
make branches

# Clean all build artifacts
make clean
```

### Manual Commands

#### Frontend Development
```bash
cd trustx/
npm install
npm run dev          # http://localhost:3000
npm run build
npm run test
```

#### Backend Development (Infrastructure)
```bash
cd assurex-infra/resources/lambda-functions/integrations-configure/
npm install
serverless deploy --stage dev --region us-east-1
serverless invoke --function handler --stage dev
```

#### Backend Development (Profile360 API)
```bash
cd profile-360-backend/
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload  # http://localhost:8000
serverless deploy --stage dev --region us-east-1
```

## 🔄 Working with Independent Repositories

### Frontend-Only Changes

```bash
cd trustx/

# Make changes to React/Next.js code
vim src/components/Dashboard.tsx

# Commit and push to trustx repo
git add .
git commit -m "feat: update dashboard component"
git push origin main
```

### Backend Infrastructure Changes

```bash
cd assurex-infra/

# Make changes to Lambda functions or infrastructure
vim resources/lambda-functions/integrations-configure/lambda_function.py

# Commit and push to assurex-infra repo
git add .
git commit -m "feat: add new integration handler"
git push origin main
```

### Backend Profile360 Changes

```bash
cd profile-360-backend/

# Make changes to FastAPI endpoints or services
vim app/api/v1/endpoints/users.py

# Commit and push to profile-360-backend repo
git add .
git commit -m "feat: add user analytics endpoint"
git push origin dev
```

### Changes to Multiple Repositories

```bash
# 1. Commit frontend changes
cd trustx/
git add .
git commit -m "feat: add new API integration UI"
git push origin main

# 2. Commit backend infrastructure changes
cd ../assurex-infra/
git add .
git commit -m "feat: add new API integration endpoint"
git push origin main

# 3. Commit Profile360 changes
cd ../profile-360-backend/
git add .
git commit -m "feat: add user analytics endpoint"
git push origin dev
```

**Key Points:**
- ✅ Each repo maintains separate git history
- ✅ Each repo can be pushed independently
- ✅ No submodule complexity - just standard git clones
- ✅ All three repos available in one workspace for context
- ✅ Unified VS Code workspace for seamless switching

## 🐳 Docker Development Environment

### Services Included

```bash
# Start all services
docker-compose up

# Services available:
# - Frontend:   http://localhost:3000
# - PostgreSQL: localhost:5432 (user: postgres, db: assurex_dev)
# - LocalStack: http://localhost:4566 (AWS services emulation)
```

### Database Migrations

```bash
# Migrations run automatically when postgres starts
# Located in: assurex-infra/resources/database/lambda-schema-init/migrations/

# Connect to local database
docker-compose exec postgres psql -U postgres -d assurex_dev

# Run specific migration manually
docker-compose exec postgres psql -U postgres -d assurex_dev -f /docker-entrypoint-initdb.d/V001__initial_schema.sql
```

### LocalStack (AWS Services Locally)

```bash
# Test Lambda functions locally
aws --endpoint-url=http://localhost:4566 lambda list-functions

# Test S3 locally
aws --endpoint-url=http://localhost:4566 s3 ls

# Test Secrets Manager locally
aws --endpoint-url=http://localhost:4566 secretsmanager list-secrets
```

## 🚢 Deployment

### Development Environment

**Infrastructure (Integrations API)**:
```bash
cd assurex-infra/resources/lambda-functions/integrations-configure/
serverless deploy --stage dev --region us-east-1
```

**Profile360 API**:
```bash
cd profile-360-backend/
serverless deploy --stage dev --region us-east-1
# OR
npm run deploy:dev
```

### Preprod Environment

**Infrastructure**:
```bash
cd assurex-infra/resources/lambda-functions/integrations-configure/
serverless deploy --stage preprod --region us-east-2
```

**Profile360 API**:
```bash
cd profile-360-backend/
serverless deploy --stage preprod --region us-east-2
# OR
npm run deploy:preprod
```

### Production Environment

```bash
# Production deployments happen via GitHub Actions
# Push to main branch triggers automatic deployment for both repos
git push origin main
```

## 📊 Repository Status

**📋 For detailed cross-repo status, see [PROJECT_STATUS.md](./PROJECT_STATUS.md)**

### Quick Status Overview

| Repository | Status | Last Updated | Key Features |
|------------|--------|--------------|--------------|
| **trustx** | ✅ Active | 2025-10-08 | Frontend - Production ready |
| **assurex-infra** | ✅ Active | 2025-10-06 | Infrastructure - Dev+Preprod live |
| **profile-360-backend** | ✅ Active | 2025-10-08 | Profile360 API - Neo4j integrated |
| **assurex-insights-engine** | 🚧 In Dev | 2025-10-10 | Hybrid ETL - Testing complete |

### Check All Repos at Once

```bash
# Show git status for all repos
make status

# Check current branches
make branches

# Pull latest from all repos
make pull
```

### Example Output

```
Repository Status
=================

Frontend (trustx):
-------------------
M  src/components/Dashboard.tsx
?? src/utils/newHelper.ts

Backend Infrastructure (assurex-infra):
----------------------------------------
M  resources/lambda-functions/integrations-configure/lambda_function.py

Backend Profile360 (profile-360-backend):
------------------------------------------
M  app/api/v1/endpoints/users.py
?? app/queries/dormant_queries.py

Insights Engine (assurex-insights-engine):
-------------------------------------------
M  src/processors/hybrid_etl_processor.py
?? tests/test_hybrid_etl.py
```

## 🔍 VS Code Workspace Features

### Multi-Root Workspace Benefits

- **Unified Search**: Search across all three codebases simultaneously
- **Separate Git Views**: See frontend, infrastructure, and Profile360 changes separately
- **Shared Extensions**: ESLint, Prettier, Python extensions work across all repos
- **Launch Configurations**: Debug frontend and backend services from same window
- **Integrated Terminal**: Switch between repos using different terminal tabs

### Recommended Extensions

The workspace recommends these extensions:
- ESLint
- Prettier
- Python
- Black Formatter
- YAML
- AWS Toolkit
- Docker

## 📝 Git Workflow

### Creating Feature Branches

```bash
# Frontend feature
cd trustx/
git checkout -b feature/new-dashboard
# ... make changes ...
git push origin feature/new-dashboard
# Create PR in trustx repo

# Backend infrastructure feature
cd assurex-infra/
git checkout -b feature/new-integration
# ... make changes ...
git push origin feature/new-integration
# Create PR in assurex-infra repo

# Profile360 feature
cd profile-360-backend/
git checkout -b feature/user-analytics
# ... make changes ...
git push origin feature/user-analytics
# Create PR in profile-360-backend repo
```

### Syncing with Main

```bash
# Sync all repos
make pull

# Or manually
cd trustx/ && git pull origin main
cd ../assurex-infra/ && git pull origin main
cd ../profile-360-backend/ && git pull origin dev
```

## 🔧 Troubleshooting

### Docker Issues

```bash
# Reset docker environment
make clean
docker-compose down -v
docker-compose up --build
```

### Dependency Issues

```bash
# Reinstall all dependencies
make clean
make install
```

### Port Conflicts

If ports 3000, 5432, or 4566 are in use:

```yaml
# Edit docker-compose.yml
services:
  frontend:
    ports:
      - "3001:3000"  # Change external port
```

### Profile360 API Issues

**Neo4j Connection Failures**:
```bash
# Check Lambda security group allows port 7687
aws ec2 describe-security-groups \
  --filters "Name=tag:Name,Values=Lambda-SG" \
  --query 'SecurityGroups[*].IpPermissionsEgress'

# Verify Neo4j credentials in Secrets Manager
aws secretsmanager get-secret-value \
  --secret-id "assurex/dev/tenant/758734/integrations" \
  | jq -r '.SecretString | fromjson | .neo4j'

# Test connectivity from Lambda
aws lambda invoke \
  --function-name assurex-profile360-dev-api \
  --payload '{"path":"/profile360/api/knowledge-graph/health"}' \
  /tmp/response.json
```

**Authentication Errors (401)**:
```bash
# Verify JWT token has required claims
# Required: https://trustx.cloud/claims/company
# Required: https://trustx.cloud/claims/user_id

# Check token at https://jwt.io
# Verify audience matches environment
```

**Database Schema Mismatches**:
```bash
# Connect to database and verify schema
psql -h <rds-endpoint> -U postgres -d assurex_dev

# Check tenant schema exists
\dn tenant_*

# Verify table structure
\d tenant_758734.user_profiles
\d tenant_758734.user_activities
```

## 📚 Documentation

### Frontend Documentation
- Main docs: `trustx/README.md`
- Component library: `trustx/docs/COMPONENTS.md`

### Backend Infrastructure Documentation
- Infrastructure: `assurex-infra/README.md`
- Database schema: `assurex-infra/docs/SCHEMA_MIGRATION_GUIDE.md`
- API documentation: `assurex-infra/docs/API.md`

### Profile360 Backend Documentation
- Main guide: `profile-360-backend/CLAUDE.md`
- API endpoints: See CLAUDE.md for complete endpoint reference
- Neo4j integration: Knowledge graph service documentation
- Database queries: `profile-360-backend/app/queries/`
- Authentication: JWT-based multi-tenant auth

## 🎯 Common Tasks

### Add New Integration Type

**Frontend:**
```bash
cd trustx/src/components/integrations/
# Create new integration component
# Update integration list
```

**Backend:**
```bash
cd assurex-infra/resources/lambda-functions/integrations-configure/handlers/
# Add new integration handler
# Update router
```

### Database Schema Changes

```bash
cd assurex-infra/resources/database/lambda-schema-init/migrations/
# Create new migration: VXXX__description.sql
# Test locally with docker-compose
# Deploy to dev/preprod
```

### Add New Profile360 API Endpoint

**Backend (FastAPI)**:
```bash
cd profile-360-backend/app/api/v1/endpoints/
# Create new endpoint file or update existing
# Example: users.py, activities.py, knowledge_graph.py

# Update router in app/api/v1/api.py
# Add Pydantic schemas in app/schemas/
# Add business logic in app/services/
# Add database queries in app/queries/

# Test locally
uvicorn app.main:app --reload

# Deploy
serverless deploy --stage dev
```

### Configure Neo4j for New Tenant

```bash
# 1. Provision Neo4j Aura instance for tenant
# 2. Add credentials to Secrets Manager
aws secretsmanager update-secret \
  --secret-id "assurex/dev/tenant/{tenant_id}/integrations" \
  --secret-string '{
    "neo4j": {
      "uri": "neo4j+s://xxxxx.databases.neo4j.io",
      "user": "neo4j",
      "password": "xxxxx",
      "database": "neo4j"
    }
  }'

# 3. Test connectivity
curl -H "Authorization: Bearer $TOKEN" \
  https://api-dev.trustx.cloud/profile360/api/knowledge-graph/health
```

### Environment Variables

**Local Development:**
```bash
# Create .env.local in workspace root
cp .env.example .env.local
# docker-compose.yml will use these values
```

**AWS Deployment (Integrations API)**:
```bash
# Set in serverless.yml
cd assurex-infra/resources/lambda-functions/integrations-configure/
vim serverless.yml  # Update environment section
```

**AWS Deployment (Profile360 API)**:
```bash
# Set in serverless.yml
cd profile-360-backend/
vim serverless.yml  # Update environment section

# Required environment variables:
# - STAGE (dev/preprod/prod)
# - AUTH0_DOMAIN
# - AUTH0_AUDIENCE_DEV
# - AUTH0_AUDIENCE_PREPROD
# - AUTH0_AUDIENCE_PROD

# Secrets stored in AWS Secrets Manager:
# - Neo4j credentials: assurex/{stage}/tenant/{tenant_id}/integrations
# - Database credentials: Managed by RDS
```

## 🤝 Team Collaboration

### Frontend Team
- Works primarily in `trustx/` repository
- Can view backend code for API reference
- Commits and PRs go to TrustXinc/trustx

### Backend Infrastructure Team
- Works primarily in `assurex-infra/` repository
- Can view frontend code for integration context
- Commits and PRs go to TrustXinc/assurex-infra
- Manages: Lambda functions, database migrations, VPC, security groups

### Backend Profile360 Team
- Works primarily in `profile-360-backend/` repository
- Focuses on user analytics and knowledge graph features
- Commits and PRs go to TrustXinc/profile-360-backend
- Manages: FastAPI endpoints, Neo4j integration, user activity tracking

### Full-Stack Work
- All three repositories available in one workspace
- Switch between codebases seamlessly
- Maintain separate git histories
- Unified development environment

## 📞 Support

### Issues
- Frontend issues: https://github.com/TrustXinc/trustx/issues
- Backend infrastructure issues: https://github.com/TrustXinc/assurex-infra/issues
- Profile360 backend issues: https://github.com/TrustXinc/profile-360-backend/issues

### Questions
- Check repository-specific documentation first
  - Frontend: `trustx/README.md`
  - Infrastructure: `assurex-infra/README.md`
  - Profile360: `profile-360-backend/CLAUDE.md`
  - Insights Engine: `assurex-insights-engine/README.md`
- Ask in team Slack channel
- Tag appropriate team members

## 📋 Project Tracking & Documentation

### For AI Assistants & Developers
- **[CLAUDE.md](./CLAUDE.md)** - 🤖 **START HERE** - Complete project guide for AI assistants covering all 4 repositories, their roles, and how they interact
- **[ARCHITECTURE.md](./ARCHITECTURE.md)** - 🏗️ **NEW!** - Comprehensive system architecture with detailed diagrams (VPC, data flow, multi-tenant, security, API, AI/ML)

### Cross-Repo Status & Planning
- **[PROJECT_STATUS.md](./PROJECT_STATUS.md)** - 📊 Current status of all repositories, deployed services, and key metrics
- **[CHANGELOG.md](./CHANGELOG.md)** - 📝 Detailed changelog across all repositories with version history
- **[DEVELOPMENT_ROADMAP.md](./DEVELOPMENT_ROADMAP.md)** - 🗺️ Feature roadmap and quarterly planning
- **[docs/INDEX.md](./docs/INDEX.md)** - 📚 Complete documentation map across all repositories

### Quick Status Check
```bash
# View overall project status
cat PROJECT_STATUS.md

# View recent changes
cat CHANGELOG.md

# View upcoming features
cat DEVELOPMENT_ROADMAP.md

# Check git status across all repos
make status
```

---

**Last Updated:** October 31, 2025
**Maintained By:** AssureX Engineering Team
