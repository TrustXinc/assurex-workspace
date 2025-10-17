---
name: cross-repo-workflows
description: Work across multiple AssureX repositories for end-to-end features. Covers cross-repository feature implementation, dependency management, testing strategies, and integration patterns for the complete platform.
---

# Cross-Repository Workflows Skill

This skill helps work efficiently across all AssureX repositories when implementing end-to-end features.

## Overview

AssureX platform consists of 4 independent repositories:
- **trustx**: React frontend (Cloudflare Pages)
- **assurex-infra**: AWS infrastructure (Serverless Framework)
- **profile-360-backend**: FastAPI REST API (AWS Lambda)
- **assurex-insights-engine**: Analytics & AI (AWS Lambda)

This skill provides workflows for features that span multiple repositories.

---

## Repository Relationships

### Architecture Diagram

```
┌────────────────────────────────────────────────────────────┐
│                     User/Browser                            │
└───────────────────────────┬────────────────────────────────┘
                            │
                    ┌───────▼───────┐
                    │     trustx     │ (React Frontend)
                    │  Cloudflare    │
                    └───────┬────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
   ┌────▼────┐        ┌─────▼─────┐      ┌────▼────┐
   │ AppSync │        │ Profile360│      │API      │
   │GraphQL  │        │  REST API │      │Gateway  │
   │(infra)  │        │(backend)  │      │         │
   └────┬────┘        └─────┬─────┘      └────┬────┘
        │                   │                  │
        └───────────────────┼──────────────────┘
                            │
                ┌───────────▼───────────┐
                │   PostgreSQL (RDS)    │
                │  Multi-tenant schemas │
                └───────────┬───────────┘
                            │
                ┌───────────▼───────────┐
                │  Insights Engine      │
                │  Analytics & AI       │
                └───────────────────────┘
```

### Data Flow

**User Activity Tracking Example**:
```
1. User logs in (trustx)
   ↓
2. Frontend calls Profile360 API (profile-360-backend)
   POST /api/user-activity
   ↓
3. API saves to PostgreSQL tenant schema
   INSERT INTO tenant_123456.user_activities
   ↓
4. API updates Neo4j knowledge graph
   CREATE (u:User)-[:LOGGED_IN]->(a:Application)
   ↓
5. S3 event triggers Insights Engine (assurex-insights-engine)
   Processes activity for analytics
   ↓
6. Frontend polls for updated analytics
   GET /api/dormant-users
```

---

## Common Cross-Repo Workflows

### Workflow 1: Adding a New Integration Type

**Example: Add Microsoft Teams integration**

**Affected Repositories**: All 4

**Steps**:

#### 1. Backend Infrastructure (assurex-infra)

```bash
cd assurex-infra

# Create feature branch
git checkout -b feature/add-teams-integration

# Add GraphQL schema
vim resources/appsync/schema.graphql
```

Add to schema:
```graphql
type TeamsIntegration {
  id: ID!
  tenant_id: String!
  team_name: String!
  webhook_url: String!
  status: IntegrationStatus!
}

input ConfigureTeamsInput {
  teamName: String!
  webhookUrl: String!
}

type Mutation {
  configureTeams(input: ConfigureTeamsInput!): IntegrationResponse!
}
```

```bash
# Add Lambda resolver
mkdir -p resources/lambda-functions/integrations-configure-teams
vim resources/lambda-functions/integrations-configure-teams/index.py

# Add to serverless.yml
vim serverless.yml  # Add teamsIntegration function

# Deploy to dev
npm run deploy:dev

# Test
aws lambda invoke \
  --function-name assurex-integrations-configure-teams-dev \
  --payload '{"teamName":"test","webhookUrl":"https://..."}' \
  response.json
```

#### 2. Analytics ETL (assurex-insights-engine)

```bash
cd ../assurex-insights-engine

# Create feature branch
git checkout -b feature/add-teams-integration

# Add Teams data extraction
vim functions/profile360-analytics/extractors/teams_extractor.py

# Add field mappings for AI ETL
vim functions/profile360-analytics/rag/teams_schema.py

# Deploy
npm run deploy:analytics:dev

# Test extraction
aws lambda invoke \
  --function-name assurex-profile360-analytics-dev \
  --payload '{"operation":"extract_teams","tenant_id":123456}' \
  response.json
```

#### 3. REST API (profile-360-backend)

```bash
cd ../profile-360-backend

# Create feature branch
git checkout -b feature/add-teams-integration

# Add Teams-specific analytics endpoints
vim app/routes/teams.py
```

```python
from fastapi import APIRouter

router = APIRouter(prefix="/api/teams", tags=["Teams"])

@router.get("/channels")
async def get_teams_channels():
    """Get Teams channels for tenant"""
    # Implementation
    pass

@router.get("/activity")
async def get_teams_activity():
    """Get Teams activity for user"""
    # Implementation
    pass
```

```bash
# Add to main.py
vim app/main.py  # app.include_router(teams.router)

# Deploy
serverless deploy --stage dev

# Test
curl -H "Authorization: Bearer $TOKEN" \
  https://api-dev.trustx.cloud/api/teams/channels
```

#### 4. Frontend (trustx)

```bash
cd ../trustx

# Create feature branch
git checkout -b feature/add-teams-integration

# Add Teams integration component
vim src/components/integrations/TeamsIntegration.js
```

```javascript
import React, { useState } from 'react';
import { useMutation } from '@apollo/client';
import { CONFIGURE_TEAMS } from 'graphql/integrations/mutations';

function TeamsIntegration() {
  const [configureTeams, { loading, error }] = useMutation(CONFIGURE_TEAMS);

  const handleConfigure = async (teamName, webhookUrl) => {
    const result = await configureTeams({
      variables: {
        input: { teamName, webhookUrl }
      }
    });
    console.log('Teams configured:', result);
  };

  return (
    // UI implementation
  );
}
```

```bash
# Add GraphQL mutation
vim src/graphql/integrations/mutations.js

# Add to integration list
vim src/pages/Integrations.js

# Test locally
npm start

# Deploy to staging
git push origin feature/add-teams-integration
# Then merge to stg branch
```

#### 5. Coordinated Testing

```bash
# Test end-to-end flow
1. Configure Teams in frontend
2. Check GraphQL API created integration record
3. Trigger sync
4. Verify data in database
5. Check analytics processed data
6. View analytics in frontend
```

#### 6. Coordinated Deployment

```bash
# Deploy in order:
1. Infrastructure (GraphQL + Lambda)
2. Analytics Engine
3. Profile360 API
4. Frontend
```

---

### Workflow 2: Adding User Profile Field

**Example: Add "department" field to user profiles**

**Affected Repositories**: 3 (infra, backend, frontend)

#### 1. Database Migration (assurex-infra)

```bash
cd assurex-infra

# Create migration
vim resources/database/lambda-schema-init/migrations/V006__add_user_department.sql
```

```sql
-- Add department column to template
ALTER TABLE template_schema.users
ADD COLUMN department VARCHAR(100);

-- Function to add column to existing tenant schemas
CREATE OR REPLACE FUNCTION add_department_to_tenants()
RETURNS void AS $$
DECLARE
    tenant_record RECORD;
BEGIN
    FOR tenant_record IN
        SELECT tenant_id FROM public.tenants WHERE status = 'active'
    LOOP
        EXECUTE format('ALTER TABLE tenant_%s.users ADD COLUMN IF NOT EXISTS department VARCHAR(100)',
                      tenant_record.tenant_id);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Execute migration
SELECT add_department_to_tenants();
```

```bash
# Deploy migration
cd resources/database/lambda-schema-init
./deploy.sh dev

# Verify
./scripts/db-connect.sh
SELECT department FROM tenant_123456.users LIMIT 1;
```

#### 2. REST API (profile-360-backend)

```bash
cd profile-360-backend

# Update Pydantic model
vim app/models/user.py
```

```python
from pydantic import BaseModel

class UserProfile(BaseModel):
    user_id: str
    email: str
    name: str
    department: Optional[str] = None  # New field
    first_seen: datetime
    last_active: datetime
```

```bash
# Update queries
vim app/queries/user_queries.py  # Add department to SELECT

# Deploy
serverless deploy --stage dev

# Test
curl -H "Authorization: Bearer $TOKEN" \
  https://api-dev.trustx.cloud/users/me
```

#### 3. Frontend (trustx)

```bash
cd trustx

# Update GraphQL query
vim src/graphql/profile360/queries.js
```

```graphql
query GetUserProfile($userId: String!) {
  getUserProfile(userId: $userId) {
    user_id
    email
    name
    department  # New field
    first_seen
    last_active
  }
}
```

```bash
# Update component
vim src/components/Profile360/UserProfile.js
```

```javascript
function UserProfile({ userId }) {
  const { data } = useGetUserProfile({ userId });

  return (
    <Card>
      <CardContent>
        <Typography>Email: {data?.getUserProfile?.email}</Typography>
        <Typography>Department: {data?.getUserProfile?.department || 'N/A'}</Typography>
      </CardContent>
    </Card>
  );
}
```

```bash
# Test and deploy
npm start
git push origin stg
```

---

### Workflow 3: Performance Optimization Across Stack

**Example: Optimize dormant user detection performance**

**Affected Repositories**: All 4

#### 1. Database Optimization (assurex-infra)

```bash
cd assurex-infra

# Add indexes for dormant user queries
vim resources/database/lambda-schema-init/migrations/V007__optimize_dormant_queries.sql
```

```sql
-- Add indexes to template
CREATE INDEX IF NOT EXISTS idx_users_last_active
ON template_schema.users (last_active DESC);

CREATE INDEX IF NOT EXISTS idx_user_activities_timestamp
ON template_schema.user_activities (activity_timestamp DESC);

-- Function to add indexes to existing tenants
CREATE OR REPLACE FUNCTION add_dormant_indexes_to_tenants()
RETURNS void AS $$
DECLARE
    tenant_record RECORD;
BEGIN
    FOR tenant_record IN
        SELECT tenant_id FROM public.tenants WHERE status = 'active'
    LOOP
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_users_last_active
                       ON tenant_%s.users (last_active DESC)',
                      tenant_record.tenant_id);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_user_activities_timestamp
                       ON tenant_%s.user_activities (activity_timestamp DESC)',
                      tenant_record.tenant_id);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT add_dormant_indexes_to_tenants();
```

#### 2. Analytics Optimization (assurex-insights-engine)

```bash
cd assurex-insights-engine

# Optimize vector search
vim functions/dormant-user-agent/vector_search.py
```

```python
# Use HNSW index for faster similarity search
# Batch processing for large datasets
# Cache embeddings to reduce Bedrock calls

def get_similar_users(user_embedding, limit=10):
    """Optimized vector similarity search"""
    # Use pgvector HNSW index
    query = """
    SELECT user_id, behavior_embedding <-> %s::vector AS distance
    FROM tenant_{tenant_id}.user_risk_scores
    WHERE behavior_embedding IS NOT NULL
    ORDER BY distance
    LIMIT %s
    """
    # Execute with index hint
    return execute_query(query, (user_embedding, limit))
```

```bash
# Increase Lambda memory for better performance
vim functions/dormant-user-agent/serverless.yml
```

```yaml
functions:
  dormantUserAgent:
    handler: handler.handler
    memorySize: 2048  # Increased from 1024
    timeout: 300
```

#### 3. API Optimization (profile-360-backend)

```bash
cd profile-360-backend

# Add caching for dormant users endpoint
vim app/routes/users.py
```

```python
from fastapi_cache import FastAPICache
from fastapi_cache.decorator import cache

@router.get("/dormant-users")
@cache(expire=300)  # Cache for 5 minutes
async def get_dormant_users(days_inactive: int = 30):
    """Get dormant users with caching"""
    # Implementation with caching
    pass
```

#### 4. Frontend Optimization (trustx)

```bash
cd trustx

# Add pagination for dormant users list
vim src/components/Profile360/DormantUsersList.js
```

```javascript
function DormantUsersList() {
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(25);

  const { data, loading } = useQuery(LIST_DORMANT_USERS, {
    variables: {
      skip: page * rowsPerPage,
      limit: rowsPerPage
    },
    // Enable Apollo caching
    fetchPolicy: 'cache-and-network'
  });

  return (
    <DataGrid
      rows={data?.listDormantUsers?.items || []}
      pagination
      page={page}
      pageSize={rowsPerPage}
      onPageChange={setPage}
    />
  );
}
```

---

## Cross-Repository Testing

### End-to-End Testing Strategy

**1. Local Development Testing**:
```bash
# Start all services locally
cd assurex
make start-all  # If Makefile configured

# Or manually:
# Terminal 1: Frontend
cd trustx && npm start

# Terminal 2: API (with local DB)
cd profile-360-backend && python main.py

# Terminal 3: Database tunnel
cd assurex-infra && ./scripts/db-tunnel.sh
```

**2. Integration Testing**:
```bash
# Test API endpoints
cd trustx
npm run test:integration

# Test GraphQL resolvers
cd assurex-infra
npm run test:graphql

# Test analytics functions
cd assurex-insights-engine
npm run test:analytics
```

**3. End-to-End Testing**:
```bash
# Use staging environment
# Test complete user flow:
1. User logs in (trustx staging)
2. Configure integration (GraphQL)
3. Sync data (Lambda)
4. View analytics (Profile360 API)
5. Verify in database
```

---

## Dependency Management

### Shared Dependencies

**Python Dependencies (Backend & Analytics)**:
- PostgreSQL: `psycopg2-binary==2.9.9`
- AWS SDK: `boto3==1.34.162`
- Database driver version must match across services

**Node Dependencies (Infrastructure)**:
- Serverless Framework: `^3.38.0`
- AWS SDK: `^3.600.0`

**Environment Variables**:
```bash
# Shared across services
AUTH0_DOMAIN=trustx.us.auth0.com
DB_SECRET_NAME={stage}/app_user
AWS_REGION={stage-specific}
```

### Version Compatibility Matrix

| Service | Python | Node | PostgreSQL | Neo4j Driver |
|---------|--------|------|------------|--------------|
| infra | - | 18.x | Client: 17.x | - |
| profile-360-backend | 3.12 | - | 17.4 | 5.28.1 |
| insights-engine | 3.12 | 18.x (dev) | 17.4 | - |
| trustx | - | 18.x | - | 5.28.1 |

### Keeping Dependencies in Sync

```bash
# Check versions across repos
cd assurex

# Python
grep -r "psycopg2" */requirements.txt

# Node
grep -r "aws-sdk" */package.json

# Update all at once
# Create PR in each repo with same dependency update
```

---

## Common Integration Patterns

### Pattern 1: GraphQL + REST API

**Use Case**: Frontend needs both GraphQL (integrations) and REST (Profile360)

**Implementation**:
```javascript
// In trustx
import { useQuery as useGraphQLQuery } from '@apollo/client';
import apiService from 'services/apiService';

function MyComponent() {
  // GraphQL for integrations
  const { data: integrations } = useGraphQLQuery(LIST_INTEGRATIONS);

  // REST for Profile360
  const [users, setUsers] = useState([]);
  useEffect(() => {
    apiService.get('/users/').then(setUsers);
  }, []);

  return (
    <div>
      <IntegrationsList data={integrations} />
      <UsersList data={users} />
    </div>
  );
}
```

### Pattern 2: Event-Driven Processing

**Use Case**: S3 upload triggers analytics processing

**Implementation**:
```yaml
# In assurex-insights-engine/serverless.yml
functions:
  processS3Upload:
    handler: handler.handler
    events:
      - s3:
          bucket: assurex-${self:provider.stage}-raw-data
          event: s3:ObjectCreated:*
          rules:
            - prefix: tenants/
            - suffix: .json
```

### Pattern 3: Shared Database with Tenant Isolation

**Use Case**: All services access same database with tenant isolation

**Implementation**:
```python
# In profile-360-backend and insights-engine
from assurex_db import get_tenant_id, execute_query

def get_users(company_name: str):
    tenant_id = get_tenant_id(company_name)
    query = f"SELECT * FROM tenant_{tenant_id}.users"
    return execute_query(query)
```

---

## Troubleshooting Cross-Repo Issues

### Issue: Frontend can't call Backend API

**Diagnosis Steps**:
```bash
# 1. Check frontend environment variables
cd trustx
grep REACT_APP_API_URL .env.staging

# 2. Check API is deployed
cd ../profile-360-backend
aws lambda get-function --function-name profile-360-backend-dev-api

# 3. Check API Gateway
aws apigatewayv2 get-apis --query 'Items[?Name==`profile-360-backend-dev`]'

# 4. Test API directly
curl https://api-dev.trustx.cloud/health

# 5. Check CORS headers
curl -I -X OPTIONS https://api-dev.trustx.cloud/users/
```

### Issue: Data not syncing between services

**Diagnosis Steps**:
```bash
# 1. Check Lambda logs
aws logs tail /aws/lambda/assurex-integrations-sync-dev --follow

# 2. Check S3 bucket
aws s3 ls s3://assurex-dev-raw-data/tenants/123456/

# 3. Check database
cd assurex-infra && ./scripts/db-connect.sh
SELECT * FROM tenant_123456.integrations;

# 4. Check EventBridge rules
aws events list-rules --name-prefix assurex-dev
```

### Issue: Version mismatch causing errors

**Diagnosis Steps**:
```bash
# Check Python version in Lambda
aws lambda get-function-configuration \
  --function-name profile-360-backend-dev-api \
  --query 'Runtime'

# Check Lambda layer version
aws lambda get-function-configuration \
  --function-name profile-360-backend-dev-api \
  --query 'Layers[].Arn'

# Check if versions match
# Runtime: python3.12
# Layer: arn:aws:lambda:us-east-1:xxx:layer:assurex-db-connector-dev:38
```

---

## Best Practices

1. **Feature Branches**: Create same-named feature branch in all affected repos
2. **Atomic Commits**: Commit related changes together (but in separate repos)
3. **Cross-Reference PRs**: Link PRs across repos in descriptions
4. **Deploy Order**: Always deploy in correct order (DB → Backend → Frontend)
5. **Test Staging**: Test all repos in staging before production
6. **Version Tagging**: Use same version tags for related releases
7. **Documentation**: Update workspace-level docs for cross-repo changes
8. **Communication**: Document dependencies in PR descriptions
9. **Rollback Plan**: Know how to rollback each repo independently
10. **Monitoring**: Monitor logs for all affected services after deployment

## When to Use This Skill

Invoke this skill when you need to:
- Add features that span multiple repositories
- Coordinate changes across frontend, backend, and infrastructure
- Understand data flow between services
- Implement end-to-end testing
- Debug issues that cross repository boundaries
- Plan cross-repository deployments
- Manage dependencies between services
- Design new features with proper architecture
