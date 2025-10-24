# GraphRAG Missing Users Issue

**Date**: October 23, 2025
**Status**: ⚠️ **ROOT CAUSE IDENTIFIED**
**Severity**: Blocking GraphRAG functionality

## Problem Summary

GraphRAG `/api/graphrag/ask` endpoint returns:
> "I couldn't find any relevant information in the knowledge graph to answer this question."

## Root Cause

**Users don't have embeddings in the database.**

The GraphRAG pipeline requires:
1. Users in PostgreSQL `profile360_users` table
2. Each user must have `profile_embedding` column populated (1536-dim vector)
3. Neo4j sync reads embeddings from PostgreSQL and stores in Neo4j
4. Vector search queries Neo4j for similar embeddings

**Current State**:
- ✅ Vector index exists in Neo4j (`userEmbeddingIndex`)
- ✅ IAM permissions allow Bedrock access
- ❌ **Users have NO embeddings** (empty arrays in Neo4j)
- ❌ Vector search finds 0 matches

## Investigation Timeline

### 1. Vectorization Lambda Invoked (tenant 118230)

```json
{
  "statusCode": 200,
  "results": {
    "profile_embeddings": {
      "processed": 0,  ← No users processed
      "errors": 0,
      "batches": 1
    }
  }
}
```

**Lambda Log**:
```
[INFO] Generating profile embeddings (all batches)...
[INFO] No users need profile embeddings  ← Found 0 users with NULL embeddings
[INFO] Profile embeddings complete: 0 users processed in 1 batches
```

### 2. Vectorization Lambda Query

The Lambda queries:
```sql
SELECT user_id, email, display_name, job_title, department, manager_id, raw_data
FROM profile360_users
WHERE profile_embedding IS NULL
LIMIT 10
```

**Result**: 0 rows returned

**This means EITHER**:
1. All users already have embeddings (unlikely), OR
2. **The `profile360_users` table is empty or doesn't exist** (most likely)

### 3. Neo4j Sync Results

Neo4j sync Lambda successfully synced:
- Tenant 118230 (trustx): 47 users
- Tenant 758734 (trustxinc): 21 users

**But with empty embeddings** (from line 166 of neo4j_sync_processor.py):
```python
'embedding': profile_embedding if profile_embedding else [],  ← Empty array if NULL
```

## The Missing Link

### Expected Flow (Not Working)

```
1. Users exist in database
   ↓
2. Vectorization Lambda generates embeddings  ← **BREAKS HERE**
   ↓
3. Neo4j sync reads embeddings from database
   ↓
4. Vector search finds similar users
   ↓
5. GraphRAG returns natural language answer
```

### Actual Flow (Current State)

```
1. Users may exist somewhere
   ↓
2. Vectorization Lambda finds 0 users  ← **ISSUE**
   ↓
3. Neo4j sync syncs users with empty embeddings
   ↓
4. Vector search finds 0 matches (empty embeddings)
   ↓
5. GraphRAG returns "no relevant information"
```

## Questions to Resolve

### Q1: Where are the Profile360 users actually stored?

**Expected**: `tenant_118230.profile360_users` table

**Possibilities**:
- Table doesn't exist yet
- Users are in a different table
- Users haven't been loaded/migrated yet

### Q2: How do users get into profile360_users table?

**Options**:
1. **ETL from insights engine** (assurex-insights-engine repo)
2. **API endpoint** (POST /users/)
3. **Migration script** (one-time data load)
4. **Manual insertion** (for testing)

### Q3: What's the expected data pipeline?

```
IDP Data (Okta/Entra)
  → Insights Engine ETL
  → PostgreSQL (profile360_users)
  → Vectorization Lambda
  → Neo4j Sync
  → GraphRAG Query
```

## Temporary Workaround (For Testing)

To test GraphRAG, we need to:

### Option 1: Manual Test Data Insertion

Create sample users with embeddings directly in PostgreSQL:

```sql
-- Insert test user
INSERT INTO tenant_118230.profile360_users (
  user_id, email, display_name, job_title, department
) VALUES (
  'test-user-1', 'john@test.com', 'John Smith', 'Engineer', 'Engineering'
);

-- Generate embedding using Bedrock Titan (would need Lambda or script)
-- Then update:
UPDATE tenant_118230.profile360_users
SET profile_embedding = <1536-dim vector>
WHERE user_id = 'test-user-1';
```

### Option 2: Check if Users Exist in Different Table

Look for users in other tables:
```sql
-- Check insights engine tables
SELECT * FROM tenant_118230.sso_users LIMIT 5;

-- Check if users table has different name
\dt tenant_118230.*;
```

### Option 3: Run Full ETL Pipeline

If users come from insights engine:
1. Trigger ETL from IDP (Okta/Entra)
2. Load users into profile360_users
3. Run vectorization Lambda
4. Run Neo4j sync
5. Test GraphRAG

## Next Steps

**PRIORITY 1**: Determine where Profile360 users should come from

**Action Items**:
1. [ ] Check if `tenant_118230.profile360_users` table exists and has data
2. [ ] Identify correct ETL pipeline for loading users
3. [ ] Run ETL to populate users (if needed)
4. [ ] Generate embeddings via vectorization Lambda
5. [ ] Re-sync to Neo4j with embeddings
6. [ ] Test GraphRAG endpoint again

**PRIORITY 2**: If table doesn't exist, create it

**Check table schema**:
```sql
\d tenant_118230.profile360_users
```

## Impact Assessment

### What's Working ✅
- Vector index created in Neo4j
- IAM permissions configured
- Neo4j sync Lambda functional
- Vectorization Lambda functional (but no users to process)
- Frontend UI ready
- Backend API endpoints deployed

### What's Broken ❌
- **Users don't have embeddings**
- Vector search returns 0 results
- GraphRAG can't answer any questions
- All testing blocked

### Estimated Fix Time

- **If users exist in different table**: 30 minutes (find table, update vectorization Lambda query)
- **If users need to be loaded**: 1-2 hours (run ETL, generate embeddings, sync)
- **If table doesn't exist**: 2-4 hours (create table, load data, embeddings, sync)

## Files Involved

### Vectorization Lambda
- **File**: `assurex-infra/resources/lambda-functions/profile360-vectorization/vectorization_processor.py`
- **Line 178**: Query that finds 0 users
- **Expected Table**: `profile360_users`

### Neo4j Sync Lambda
- **File**: `assurex-infra/resources/lambda-functions/profile360-neo4j-sync/neo4j_sync_processor.py`
- **Line 139**: Reads from `profile360_users`
- **Line 166**: Syncs empty embeddings if NULL

### Profile360 Backend
- **Repo**: `profile-360-backend/`
- **Endpoints**: `/users/`, `/users/{user_id}`
- **Expected to provide user data**

## Recommendations

1. **Immediate**: Identify user data source (ETL vs API vs manual)
2. **Short-term**: Generate embeddings for existing users
3. **Long-term**: Automate embedding generation on user creation/update

---

**Status**: ⏸️ Testing blocked until users have embeddings
**Created**: October 23, 2025
**Next Review**: After user data source identified
