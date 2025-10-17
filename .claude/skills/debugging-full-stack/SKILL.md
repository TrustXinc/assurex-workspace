---
name: debugging-full-stack
description: Debug issues that span multiple AssureX components including full-stack tracing, cross-repository log correlation, authentication failures, multi-tenant issues, performance problems, and end-to-end testing strategies.
---

# Full-Stack Debugging Skill

This skill helps systematically debug issues that span multiple AssureX repositories.

## Debugging Strategy

```
┌────────────────────────────────────────────────────────────────┐
│                  Debugging Flow (Top-Down)                      │
└────────────────────────────────────────────────────────────────┘
                              │
                       ┌──────▼──────┐
                       │  1. Frontend │
                       │ Browser/Logs │
                       └──────┬──────┘
                              │
                ┌─────────────┼─────────────┐
                │                           │
         ┌──────▼──────┐            ┌──────▼──────┐
         │  2a. GraphQL │            │  2b. REST   │
         │   AppSync    │            │  Profile360 │
         └──────┬───────┘            └──────┬──────┘
                │                           │
                └─────────────┬─────────────┘
                              │
                       ┌──────▼──────┐
                       │ 3. Database │
                       │ PostgreSQL  │
                       └──────┬──────┘
                              │
                       ┌──────▼──────┐
                       │ 4. Analytics│
                       │   Engine    │
                       └─────────────┘
```

---

## Common Issue Patterns

### Pattern 1: "Data Not Showing in Frontend"

**Full Stack Trace**:

**Step 1: Check Frontend**
```javascript
// Browser console (F12)
console.log('API URL:', process.env.REACT_APP_PROFILE360_ENDPOINT);
// Expected: https://api-dev.trustx.cloud/profile360

// Check network tab
// Look for API calls to /users/ endpoint
// Status code? 200, 401, 403, 404, 500?
```

**Step 2: Check API Response**
```bash
# Test API directly
TOKEN="your-jwt-token"
curl -H "Authorization: Bearer $TOKEN" \
  https://api-dev.trustx.cloud/users/

# Common issues:
# - 401: Token invalid/expired
# - 403: Tenant validation failed
# - 404: Wrong endpoint URL
# - 500: Backend error
```

**Step 3: Check API Lambda Logs**
```bash
cd profile-360-backend
aws logs tail /aws/lambda/profile-360-backend-dev-api --follow

# Look for:
# - "Tenant not found" → Tenant validation issue
# - "psycopg2.ProgrammingError" → SQL error
# - "Column does not exist" → Database schema mismatch
```

**Step 4: Check Database**
```bash
cd assurex-infra
./scripts/db-connect.sh

-- Check if tenant schema exists
SELECT schema_name FROM information_schema.schemata
WHERE schema_name LIKE 'tenant_%';

-- Check if data exists
SELECT * FROM tenant_123456.users LIMIT 10;

-- If no data: ETL didn't run or failed
```

**Step 5: Check Analytics/ETL**
```bash
cd assurex-insights-engine
aws logs tail /aws/lambda/assurex-insights-engine-dev --follow

# Look for:
# - "No S3 files found" → Data not uploaded
# - "FK resolution failed" → sso_users table empty
# - "Loaded 0 records" → Data mapping issue
```

---

### Pattern 2: "User Can't Log In"

**Full Stack Trace**:

**Step 1: Check Auth0 Logs**
```
1. Go to Auth0 Dashboard → Logs
2. Filter by user email
3. Look for:
   - "Failed Login" → Wrong credentials
   - "Success Login" → Login worked
   - No logs → User doesn't exist in Auth0
```

**Step 2: Check JWT Claims**
```javascript
// In browser console after login
const user = JSON.parse(localStorage.getItem('auth0.user'));
console.log('Claims:', user);

// Check for:
// - https://trustx.cloud/claims/company (must exist)
// - https://trustx.cloud/claims/role (must exist)
// - exp (expiration) not in past
```

**Step 3: Check Tenant Validation**
```javascript
// Frontend calls getTenantStatus query
// Check network tab for this GraphQL request
// Response should be:
{
  "data": {
    "getTenantStatus": {
      "tenant_id": "123456",
      "tenant_name": "trustx",
      "status": "active"
    }
  }
}

// If null or error: Tenant doesn't exist or inactive
```

**Step 4: Check Database Tenant**
```bash
cd assurex-infra
./scripts/db-connect.sh

-- Check tenant exists and is active
SELECT * FROM public.tenants WHERE tenant_name = 'trustx';

-- Should return:
-- tenant_id | tenant_name | status | created_at
-- 123456    | trustx      | active | ...
```

**Step 5: Check Lambda Authorizer**
```bash
# Check AppSync authorizer logs
aws logs tail /aws/lambda/assurex-dev-graphql-authorizer --follow

# Look for:
# - "Token validation failed" → Invalid JWT
# - "Company claim missing" → JWT missing custom claim
# - "Tenant not found" → Tenant doesn't exist in database
```

---

### Pattern 3: "Sync Not Working"

**Full Stack Trace**:

**Step 1: Check Frontend Sync Trigger**
```javascript
// Browser console - check mutation was called
// Network tab → Look for syncIntegration mutation
// Should return execution_id
```

**Step 2: Check GraphQL Sync Lambda**
```bash
cd assurex-infra
aws logs tail /aws/lambda/assurex-integrations-sync-dev --follow

# Look for:
# - "Starting sync for integration {id}"
# - "Fetched {n} items from {integration}"
# - "Uploaded to S3: s3://bucket/tenants/{id}/..."
# - "Sync completed successfully"

# Errors:
# - "Invalid token" → Integration token expired
# - "Rate limit exceeded" → Too many API calls
# - "S3 upload failed" → Permissions issue
```

**Step 3: Check S3 Data**
```bash
# Verify data was uploaded
aws s3 ls s3://assurex-dev-raw-data/tenants/123456/github/ --recursive

# Should see files like:
# tenants/123456/github/users_20251017.json
# tenants/123456/github/repos_20251017.json
```

**Step 4: Check ETL Processing**
```bash
cd assurex-insights-engine
aws logs tail /aws/lambda/assurex-insights-engine-dev --follow

# Look for:
# - "S3 event received: {bucket}/{key}"
# - "Processing file: tenants/123456/github/users_20251017.json"
# - "Loaded {n} records into database"

# Errors:
# - "File not found" → S3 event didn't trigger
# - "Schema mapping failed" → RAG couldn't map fields
# - "FK resolution failed" → Parent records missing
```

**Step 5: Check Database Records**
```bash
./scripts/db-connect.sh

-- Check sync execution record
SELECT * FROM tenant_123456.sync_executions
ORDER BY start_time DESC LIMIT 5;

-- Check data was loaded
SELECT COUNT(*) FROM tenant_123456.sso_users;
SELECT COUNT(*) FROM tenant_123456.group_memberships;
```

---

## Cross-Repository Log Correlation

### Using Correlation IDs

**Frontend → Backend → Database**:

```javascript
// Frontend (trustx)
const correlationId = uuidv4();
console.log('Correlation ID:', correlationId);

// Include in API call headers
fetch(apiUrl, {
  headers: {
    'Authorization': `Bearer ${token}`,
    'X-Correlation-ID': correlationId
  }
});
```

```python
# Backend (profile-360-backend)
correlation_id = request.headers.get('X-Correlation-ID')
logger.info(f"Processing request", extra={
    'correlation_id': correlation_id,
    'tenant_id': tenant_id,
    'user_id': user_id
})
```

```bash
# Search logs by correlation ID
aws logs filter-log-events \
  --log-group-name /aws/lambda/profile-360-backend-dev-api \
  --filter-pattern "abc-123-xyz"  # Your correlation ID
```

### Tracing Through Multiple Services

**Example: Trace a user activity record**

```bash
# 1. Frontend: User clicks "Record Activity"
# Browser console shows: "Activity recorded with ID: act_12345"

# 2. Profile360 API: Check if received
cd profile-360-backend
aws logs filter-log-events \
  --log-group-name /aws/lambda/profile-360-backend-dev-api \
  --filter-pattern "act_12345"

# 3. Database: Check if saved
./scripts/db-connect.sh
SELECT * FROM tenant_123456.user_activities
WHERE activity_id = 'act_12345';

# 4. Analytics: Check if processed
cd assurex-insights-engine
aws logs filter-log-events \
  --log-group-name /aws/lambda/assurex-profile360-analytics-dev \
  --filter-pattern "act_12345"
```

---

## Multi-Tenant Debugging

### Issue: "Data Leaking Between Tenants"

**Diagnosis**:

```bash
# 1. Check which tenant schema is being used
cd profile-360-backend
aws logs filter-log-events \
  --log-group-name /aws/lambda/profile-360-backend-dev-api \
  --filter-pattern "tenant_" | grep "SELECT"

# Look for queries like:
# "SELECT * FROM tenant_123456.users"  ← Correct
# "SELECT * FROM users"  ← WRONG! Missing tenant prefix

# 2. Check tenant resolution
# Search logs for: "Resolved tenant"
aws logs filter-log-events \
  --log-group-name /aws/lambda/profile-360-backend-dev-api \
  --filter-pattern "Resolved tenant"

# Should see: "Resolved tenant: trustx → 123456"
```

**Fix**:

```python
# Ensure all queries use tenant schema
def get_users(tenant_id: str):
    # ❌ Wrong
    query = "SELECT * FROM users"

    # ✅ Correct
    query = f"SELECT * FROM tenant_{tenant_id}.users"

    return execute_query(query)
```

### Issue: "Tenant Not Found"

**Diagnosis**:

```bash
# 1. Check JWT claims
# In browser console:
const user = JSON.parse(localStorage.getItem('auth0.user'));
console.log('Company:', user['https://trustx.cloud/claims/company']);
# Should not be undefined, null, or "N/A"

# 2. Check database
./scripts/db-connect.sh
SELECT * FROM public.tenants WHERE tenant_name = 'trustx';
# Must return a row with status = 'active'

# 3. Check Lambda logs for tenant lookup
aws logs filter-log-events \
  --log-group-name /aws/lambda/profile-360-backend-dev-api \
  --filter-pattern "get_tenant_id"
```

---

## Performance Debugging

### Issue: "Slow API Response"

**Diagnosis**:

```bash
# 1. Measure response time
time curl -H "Authorization: Bearer $TOKEN" \
  https://api-dev.trustx.cloud/users/

# If > 2 seconds, investigate:

# 2. Check Lambda duration
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Duration \
  --dimensions Name=FunctionName,Value=profile-360-backend-dev-api \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average,Maximum

# 3. Check database query performance
./scripts/db-connect.sh
EXPLAIN ANALYZE SELECT * FROM tenant_123456.users;

# Look for:
# - Sequential scan → Need index
# - High execution time → Query optimization needed

# 4. Check Lambda cold start
aws logs filter-log-events \
  --log-group-name /aws/lambda/profile-360-backend-dev-api \
  --filter-pattern "REPORT"

# Look for "Init Duration" > 1000ms → Cold start penalty
```

**Fix**:

```sql
-- Add indexes for frequently queried columns
CREATE INDEX idx_users_last_active
ON tenant_123456.users (last_active DESC);

CREATE INDEX idx_user_activities_timestamp
ON tenant_123456.user_activities (activity_timestamp DESC);
```

### Issue: "High Bedrock Costs"

**Diagnosis**:

```bash
# 1. Check how many Bedrock calls
aws logs filter-log-events \
  --log-group-name /aws/lambda/assurex-dormant-user-agent-dev \
  --filter-pattern "bedrock.invoke_model"

# Count invocations

# 2. Check which model is being used
aws logs filter-log-events \
  --log-group-name /aws/lambda/assurex-dormant-user-agent-dev \
  --filter-pattern "modelId"

# Should see: "anthropic.claude-3-haiku-20240307-v1:0" (cheap)
# Not: "anthropic.claude-3-sonnet-20240229-v1:0" (expensive)

# 3. Check token usage
aws logs filter-log-events \
  --log-group-name /aws/lambda/assurex-dormant-user-agent-dev \
  --filter-pattern "input_tokens"
```

---

## End-to-End Testing

### Manual E2E Test: User Activity Tracking

```bash
# 1. Frontend: Log in as user
open https://app-stg.trustx.cloud
# Login with test user

# 2. Frontend: Trigger activity
# Click around, access different pages
# Check console for: "Activity recorded"

# 3. Check Profile360 API received it
cd profile-360-backend
aws logs tail /aws/lambda/profile-360-backend-dev-api --follow | grep "user_activity"

# 4. Check database
./scripts/db-connect.sh
SELECT * FROM tenant_123456.user_activities
WHERE user_email = 'test@company.com'
ORDER BY activity_timestamp DESC
LIMIT 5;

# 5. Check analytics processed it
cd assurex-insights-engine
aws logs tail /aws/lambda/assurex-profile360-analytics-dev --follow

# 6. Check frontend shows updated analytics
# Refresh Profile360 dashboard
# Should see latest activity
```

### Automated E2E Test Script

```bash
#!/bin/bash
# test-e2e.sh

set -e

echo "=== E2E Test: User Activity Tracking ==="

# 1. Get auth token
TOKEN=$(curl -s -X POST https://trustx.us.auth0.com/oauth/token \
  -H "Content-Type: application/json" \
  -d '{...}' | jq -r '.access_token')

# 2. Record activity via API
ACTIVITY_ID=$(curl -s -X POST https://api-dev.trustx.cloud/api/user-activity \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "user_email": "test@company.com",
    "activity_type": "signin",
    "application_name": "Test App"
  }' | jq -r '.activity_id')

echo "Activity recorded: $ACTIVITY_ID"

# 3. Wait for processing
sleep 5

# 4. Verify in database
psql -h localhost -p 5432 -U app_user -d assurex_dev \
  -c "SELECT * FROM tenant_123456.user_activities WHERE activity_id = '$ACTIVITY_ID';"

# 5. Verify analytics
curl -s -H "Authorization: Bearer $TOKEN" \
  https://api-dev.trustx.cloud/api/users/test@company.com/activities | jq .

echo "=== E2E Test Passed ==="
```

---

## Debugging Tools

### CloudWatch Insights Queries

```sql
-- Find all errors in last hour
fields @timestamp, @message
| filter @message like /ERROR|Exception/
| sort @timestamp desc
| limit 20

-- Find slow requests (> 2 seconds)
fields @timestamp, @duration
| filter @type = "REPORT" and @duration > 2000
| sort @duration desc

-- Count errors by type
fields @message
| filter @message like /ERROR/
| stats count() by @message

-- Trace specific user activity
fields @timestamp, @message
| filter @message like /user@company.com/
| sort @timestamp asc
```

### Database Diagnostic Queries

```sql
-- Check active connections
SELECT count(*), state
FROM pg_stat_activity
WHERE datname = current_database()
GROUP BY state;

-- Check slow queries
SELECT query, mean_exec_time, calls
FROM pg_stat_statements
WHERE mean_exec_time > 100  -- > 100ms
ORDER BY mean_exec_time DESC
LIMIT 10;

-- Check table sizes
SELECT schemaname, tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname LIKE 'tenant_%'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC
LIMIT 10;

-- Check missing indexes
SELECT schemaname, tablename, attname
FROM pg_stats
WHERE schemaname LIKE 'tenant_%'
  AND n_distinct > 100  -- High cardinality
  AND correlation < 0.1  -- Random order
  AND tablename NOT IN (
    SELECT tablename FROM pg_indexes
    WHERE schemaname = pg_stats.schemaname
  );
```

---

## When to Use This Skill

Invoke this skill when you need to:
- Debug issues that span multiple repositories
- Trace data flow from frontend to database
- Diagnose authentication/authorization failures
- Investigate multi-tenant data isolation issues
- Optimize performance across the stack
- Correlate logs across services
- Perform end-to-end testing
- Debug sync and ETL issues
