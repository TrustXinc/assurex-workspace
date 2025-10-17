---
name: deployment-coordination
description: Coordinate deployments across multiple AssureX repositories including sequencing, dependency management, migration coordination, environment synchronization, rollback procedures, and deployment verification.
---

# Deployment Coordination Skill

This skill helps coordinate deployments across all AssureX repositories with proper sequencing and verification.

## Deployment Strategy Overview

```
┌─────────────────────────────────────────────────────────┐
│            Deployment Sequence (Critical)                │
└─────────────────────────────────────────────────────────┘
                           │
                    ┌──────▼──────┐
                    │      1      │
                    │  Database   │
                    │ Migrations  │
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │      2      │
                    │  Backend    │
                    │     API     │
                    └──────┬──────┘
                           │
            ┌──────────────┼──────────────┐
            │                             │
       ┌────▼────┐                  ┌────▼────┐
       │    3a    │                  │   3b    │
       │Analytics│                  │  GraphQL│
       │ Engine  │                  │  Infra  │
       └────┬────┘                  └────┬────┘
            │                             │
            └──────────────┬──────────────┘
                           │
                    ┌──────▼──────┐
                    │      4      │
                    │  Frontend   │
                    │  (Last!)    │
                    └─────────────┘
```

---

## Environment-Specific Deployment

### Development Environment

**Location**: us-east-1
**Purpose**: Active development, frequent deployments
**Database**: assurex_dev

```bash
# 1. Database Migrations
cd assurex-infra/resources/database/lambda-schema-init
./deploy.sh dev
aws lambda invoke --function-name assurex-dev-schema-init --payload '{...}' response.json

# 2. Profile360 Backend API
cd profile-360-backend
serverless deploy --stage dev --region us-east-2

# 3a. Analytics Engine
cd assurex-insights-engine
npm run deploy:analytics:dev
npm run deploy:dormant-agent:dev

# 3b. Infrastructure/GraphQL
cd assurex-infra
npm run deploy:dev

# 4. Frontend
cd trustx
git push origin feature/my-branch  # Auto-creates preview
# Or merge to stg for staging deployment
```

### Staging/Preprod Environment

**Location**: us-east-2
**Purpose**: Pre-production testing
**Database**: assurex_preprod

```bash
# 1. Database Migrations
cd assurex-infra/resources/database/lambda-schema-init
./deploy.sh preprod
aws lambda invoke --function-name assurex-preprod-schema-init --payload '{...}' response.json

# 2. Profile360 Backend API
cd profile-360-backend
serverless deploy --stage staging --region us-east-2

# 3a. Analytics Engine
cd assurex-insights-engine
npm run deploy:analytics:preprod
npm run deploy:dormant-agent:preprod

# 3b. Infrastructure/GraphQL
cd assurex-infra
npm run deploy:preprod

# 4. Frontend
cd trustx
git checkout stg
git merge feature/my-branch
git push origin stg  # Auto-deploys to app-stg.trustx.cloud
```

### Production Environment

**Location**: us-east-1
**Purpose**: Production (not yet deployed)
**Database**: Not deployed

```bash
# Production deployment (when ready)
# Follow same sequence as staging, but:
# - Use --stage prod
# - Deploy to us-east-1
# - Merge to main branch for frontend
```

---

## Deployment Sequencing Rules

### Rule 1: Database First, Always

**Why**: Backend code depends on database schema

**Example**:
```bash
# ❌ Wrong - API deployed before migration
cd profile-360-backend
serverless deploy --stage dev  # New code expects new column
# → Error: column "department" does not exist

cd assurex-infra
./deploy.sh dev  # Migration adds column
# → Too late! API already failed

# ✅ Correct - Migration first
cd assurex-infra
./deploy.sh dev  # Migration adds column first

cd profile-360-backend
serverless deploy --stage dev  # API uses new column
# → Success!
```

### Rule 2: Backend Before Frontend

**Why**: Frontend calls backend APIs

**Example**:
```bash
# ❌ Wrong - Frontend deployed first
cd trustx
git push origin main  # Frontend calls new endpoint
# → 404 errors, endpoint doesn't exist yet

cd profile-360-backend
serverless deploy --stage production  # Add endpoint
# → Too late! Users already seeing errors

# ✅ Correct - Backend first
cd profile-360-backend
serverless deploy --stage production  # Add endpoint

cd trustx
git push origin main  # Frontend calls endpoint
# → Success!
```

### Rule 3: Independent Services Can Deploy in Parallel

**Services that don't depend on each other**:
- Analytics Engine
- GraphQL Infrastructure

```bash
# Can deploy in parallel (different terminals)
# Terminal 1:
cd assurex-insights-engine && npm run deploy:analytics:dev

# Terminal 2:
cd assurex-infra && npm run deploy:dev
```

---

## Deployment Workflows

### Workflow 1: Hotfix Deployment

**Scenario**: Critical bug in production

```bash
# 1. Create hotfix branch from main
git checkout main
git pull origin main
git checkout -b hotfix/critical-bug

# 2. Fix bug and test locally

# 3. Deploy to dev for testing
cd profile-360-backend
serverless deploy --stage dev

# 4. Test in dev environment
curl https://api-dev.trustx.cloud/test-endpoint

# 5. Deploy to staging
serverless deploy --stage staging

# 6. Test in staging
curl https://api-stg.trustx.cloud/test-endpoint

# 7. Deploy to production (when ready)
serverless deploy --stage production

# 8. Merge hotfix to main
git checkout main
git merge hotfix/critical-bug
git push origin main

# 9. Merge main back to stg and dev branches
```

### Workflow 2: Feature Release

**Scenario**: New feature spanning multiple repos

```bash
# Phase 1: Dev Deployment (continuous during development)
# Deploy to dev after each commit
cd {repo} && npm run deploy:dev

# Phase 2: Staging Deployment (when feature complete)
# 1. Merge all feature branches to stg
cd assurex-infra && git checkout stg && git merge feature/my-feature && git push
cd profile-360-backend && git checkout stg && git merge feature/my-feature && git push
cd assurex-insights-engine && git checkout stg && git merge feature/my-feature && git push
cd trustx && git checkout stg && git merge feature/my-feature && git push

# 2. Deploy in sequence
cd assurex-infra/resources/database/lambda-schema-init && ./deploy.sh preprod
cd profile-360-backend && serverless deploy --stage staging
cd assurex-insights-engine && npm run deploy:preprod
cd assurex-infra && npm run deploy:preprod
# Frontend auto-deploys on push to stg

# 3. Test in staging environment

# Phase 3: Production Deployment (after staging verified)
# 1. Merge stg to main in all repos
# 2. Follow same deployment sequence for production
```

### Workflow 3: Database Schema Change

**Scenario**: Add new table or column

```bash
# 1. Create migration file
cd assurex-infra/resources/database/lambda-schema-init/migrations
vim V00X__add_new_feature.sql

# 2. Test migration locally
cd ../../../
./scripts/db-connect.sh
# Manually run migration SQL to test

# 3. Deploy migration Lambda to dev
cd resources/database/lambda-schema-init
./deploy.sh dev

# 4. Run migration
aws lambda invoke \
  --function-name assurex-dev-schema-init \
  --payload '{"RequestType":"Create","ResourceProperties":{...}}' \
  response.json

# 5. Verify migration
./scripts/db-connect.sh
SELECT * FROM schema_migrations ORDER BY version DESC LIMIT 5;

# 6. Deploy backend code that uses new schema
cd profile-360-backend
serverless deploy --stage dev

# 7. Repeat for staging and production
```

---

## Environment Synchronization

### Keeping Environments in Sync

**Environment Drift**: When environments have different configurations

```bash
# Check configuration differences
# 1. Compare environment variables
diff assurex-infra/config/environments/dev.yml \
     assurex-infra/config/environments/preprod.yml

# 2. Compare serverless configs
diff profile-360-backend/serverless.yml \
     (if environment-specific configs exist)

# 3. Compare Lambda versions
aws lambda get-function --function-name profile-360-backend-dev-api \
  --query 'Configuration.Version'
aws lambda get-function --function-name profile-360-backend-staging-api \
  --query 'Configuration.Version'

# 4. Compare database schemas
./scripts/db-connect.sh
SELECT version FROM schema_migrations ORDER BY version DESC LIMIT 1;

# Switch to preprod
./scripts/db-connect-preprod.sh
SELECT version FROM schema_migrations ORDER BY version DESC LIMIT 1;
```

### Syncing Configuration

```bash
# Sync environment variables
cd assurex-infra

# 1. Copy from dev to preprod (carefully!)
# Edit config/environments/preprod.yml to match dev.yml
# BUT keep environment-specific values (region, domain, etc.)

# 2. Redeploy to apply changes
npm run deploy:preprod
```

---

## Dependency Management

### Lambda Layer Versioning

**Critical**: All Lambda functions using database must have same layer version

```bash
# Check current layer versions
aws lambda list-layer-versions \
  --layer-name assurex-db-connector-dev \
  --query 'LayerVersions[0].Version'

# Get functions using the layer
aws lambda list-functions \
  --query 'Functions[?contains(FunctionName, `assurex`)].FunctionName'

# Update all functions to same layer version
for func in profile-360-backend-dev-api assurex-insights-engine-dev; do
  aws lambda update-function-configuration \
    --function-name $func \
    --layers arn:aws:lambda:us-east-1:533267024692:layer:assurex-db-connector-dev:38
done
```

### Package Version Synchronization

```bash
# Check Python versions across repos
grep -r "python3" */serverless.yml

# Should all be python3.12
# profile-360-backend/serverless.yml: runtime: python3.12
# assurex-insights-engine/functions/*/serverless.yml: runtime: python3.12
# assurex-infra/resources/lambda-functions/*/serverless.yml: runtime: python3.12
```

---

## Rollback Procedures

### Rollback Strategy by Service

**Infrastructure (assurex-infra)**:
```bash
# Option 1: Redeploy previous version
git log --oneline  # Find previous commit
git checkout <previous-commit>
npm run deploy:dev
git checkout main  # Return to main

# Option 2: CloudFormation rollback
aws cloudformation update-stack \
  --stack-name assurex-dev \
  --use-previous-template
```

**Backend API (profile-360-backend)**:
```bash
# Option 1: Redeploy previous version
git log --oneline
git checkout <previous-commit>
serverless deploy --stage dev
git checkout main

# Option 2: Lambda version rollback
aws lambda update-alias \
  --function-name profile-360-backend-dev-api \
  --name live \
  --function-version <previous-version>
```

**Frontend (trustx)**:
```bash
# Option 1: Cloudflare dashboard rollback
# Go to Pages → Deployments → Previous deployment → Rollback

# Option 2: Git revert
git revert <bad-commit>
git push origin stg  # Auto-deploys reverted version
```

**Database (Rollback is complex!)**:
```bash
# For schema changes, must write reverse migration
# Or restore from backup

# Point-in-time recovery
aws rds restore-db-instance-to-point-in-time \
  --source-db-instance-identifier assurex-dev-postgres \
  --target-db-instance-identifier assurex-dev-postgres-restore \
  --restore-time 2025-10-17T10:00:00Z
```

### Coordinated Rollback

**Scenario**: Deployment failed, need to rollback all services

```bash
# Rollback in reverse order of deployment

# 1. Frontend (fastest)
cd trustx
# Cloudflare dashboard: Rollback to previous deployment

# 2. Infrastructure/GraphQL
cd assurex-infra
git checkout <previous-commit>
npm run deploy:dev

# 3. Analytics
cd assurex-insights-engine
git checkout <previous-commit>
npm run deploy:analytics:dev

# 4. Backend API
cd profile-360-backend
git checkout <previous-commit>
serverless deploy --stage dev

# 5. Database (only if schema changed - complex!)
# Restore from backup or run reverse migration
```

---

## Deployment Verification

### Post-Deployment Checklist

**Infrastructure**:
```bash
# 1. Check CloudFormation stack status
aws cloudformation describe-stacks \
  --stack-name assurex-dev-main \
  --query 'Stacks[0].StackStatus'
# Should be: UPDATE_COMPLETE or CREATE_COMPLETE

# 2. Check Lambda functions
aws lambda list-functions \
  --query 'Functions[?contains(FunctionName, `assurex-dev`)].FunctionName'

# 3. Test GraphQL endpoint
curl -X POST https://ttylf2win0.execute-api.us-east-1.amazonaws.com/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ __typename }"}'
```

**Backend API**:
```bash
# 1. Check Lambda function status
aws lambda get-function \
  --function-name profile-360-backend-dev-api \
  --query 'Configuration.State'
# Should be: Active

# 2. Test health endpoint
curl https://api-dev.trustx.cloud/health

# 3. Test authenticated endpoint
curl -H "Authorization: Bearer $TOKEN" \
  https://api-dev.trustx.cloud/users/
```

**Analytics Engine**:
```bash
# 1. Check function status
aws lambda get-function \
  --function-name assurex-profile360-analytics-dev \
  --query 'Configuration.State'

# 2. Test invocation
aws lambda invoke \
  --function-name assurex-profile360-analytics-dev \
  --payload '{"operation":"health_check"}' \
  response.json
```

**Frontend**:
```bash
# 1. Check deployment status
# Cloudflare Pages → Deployments → Latest should be "Success"

# 2. Test website loads
curl -I https://app-stg.trustx.cloud
# Should return: HTTP/2 200

# 3. Test in browser
# - Login works
# - Integration list loads
# - Profile360 dashboard loads
# - No console errors
```

---

## Monitoring During Deployment

### Real-Time Log Monitoring

```bash
# Terminal 1: Infrastructure logs
cd assurex-infra
aws logs tail /aws/lambda/assurex-dev-schema-init --follow

# Terminal 2: Backend API logs
cd profile-360-backend
serverless logs -f api --stage dev --tail

# Terminal 3: Analytics logs
cd assurex-insights-engine
npm run logs:analytics:dev

# Watch for errors during deployment
```

### CloudWatch Alarms

```bash
# Set up alarms before deployment
aws cloudwatch put-metric-alarm \
  --alarm-name profile-360-api-errors \
  --metric-name Errors \
  --namespace AWS/Lambda \
  --statistic Sum \
  --period 300 \
  --evaluation-periods 1 \
  --threshold 10 \
  --comparison-operator GreaterThanThreshold \
  --dimensions Name=FunctionName,Value=profile-360-backend-dev-api

# Check alarms after deployment
aws cloudwatch describe-alarms \
  --alarm-names profile-360-api-errors \
  --query 'MetricAlarms[0].StateValue'
# Should be: OK
```

---

## Best Practices

1. **Always Deploy to Dev First** - Never skip dev environment
2. **Test in Staging** - Staging should be production-like
3. **Deploy During Off-Hours** - Minimize user impact (production)
4. **Coordinate with Team** - Use Slack/chat for deployment notifications
5. **Use Feature Flags** - Enable gradual rollout
6. **Tag Releases** - Use git tags for production releases
7. **Document Changes** - Update CHANGELOG.md
8. **Monitor Metrics** - Watch CloudWatch during deployment
9. **Have Rollback Plan** - Know how to quickly revert
10. **Verify Each Step** - Don't proceed if previous step failed

---

## When to Use This Skill

Invoke this skill when you need to:
- Deploy changes across multiple repositories
- Coordinate deployments with proper sequencing
- Handle database migrations with API changes
- Rollback failed deployments
- Synchronize environments
- Verify deployments completed successfully
- Plan production releases
- Coordinate with team on deployments
