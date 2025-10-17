# Dormant User Detection - Jira Subtasks

**Parent Story**: ATAP-XXX  
**Total Subtasks**: 17  
**Phases**: Phase A (Subtasks 1-5), Phase B (Subtasks 6-16), Wrap-up (Subtask 17)

---

## Phase A: Basic Dormant User Detection (Weeks 1-3)

### ATAP-XXX-1: Infra - Confirm tenant settings + indices

**Type**: Task  
**Story Points**: 2  
**Assignee**: Backend/Infra Team  
**Priority**: High  

**Description**:
Verify database schema has necessary tables and indices for Phase A dormant user detection.

**Tasks**:
- [ ] Check if `tenant_settings` table exists in tenant schemas
- [ ] Create migration for `tenant_settings` if missing
- [ ] Verify `user_profiles.last_active_at` column exists
- [ ] Create/verify index: `idx_user_profiles_last_active`
- [ ] Test query performance with 10k sample users
- [ ] Document table structure and usage

**Acceptance Criteria**:
- ✅ `tenant_settings` table present in all tenant schemas
- ✅ Default dormant threshold (30 days) inserted
- ✅ `last_active_at` index exists and is used by queries
- ✅ Query performance < 200ms for 10k users
- ✅ Documentation updated

**Repository**: `assurex-infra`  
**Files**:
- `resources/database/lambda-schema-init/migrations/V00X__tenant_settings.sql`
- `resources/database/lambda-schema-init/migrations/V00Y__user_profiles_index.sql`

**Definition of Done**:
- Migration tested in dev environment
- Performance benchmark recorded
- PR merged to main

---

### ATAP-XXX-2: Backend - Add dormant user endpoint

**Type**: Task  
**Story Points**: 5  
**Assignee**: Backend Team  
**Priority**: High  

**Description**:
Implement FastAPI endpoint for dormant user detection with configurable threshold.

**Tasks**:
- [ ] Create `app/services/insights_service.py` (if not exists)
- [ ] Implement `get_tenant_setting()` method
- [ ] Implement `get_dormant_users_basic()` query method
- [ ] Create `app/schemas/insights.py` with `DormantUserBasic` schema
- [ ] Add endpoint in `app/api/v1/endpoints/insights.py`
- [ ] Add JWT authentication dependency
- [ ] Add pagination (skip/limit)
- [ ] Write unit tests for service layer
- [ ] Write integration tests for endpoint
- [ ] Update API documentation

**Acceptance Criteria**:
- ✅ Endpoint: `GET /profile360/insights/dormant-users`
- ✅ Query params: `inactive_days`, `skip`, `limit`
- ✅ Returns list of dormant users with days_inactive
- ✅ Tenant-scoped queries (JWT validation)
- ✅ Pagination works correctly
- ✅ Unit test coverage > 80%
- ✅ API docs auto-generated (FastAPI)

**Repository**: `profile-360-backend`  
**Files**:
- `app/services/insights_service.py`
- `app/api/v1/endpoints/insights.py`
- `app/schemas/insights.py`
- `tests/services/test_insights_service.py`
- `tests/api/test_insights_endpoints.py`

**Technical Notes**:
```python
# Query logic
cutoff_date = datetime.now() - timedelta(days=inactive_days)
SELECT user_id, email, name, last_active_at,
       EXTRACT(DAY FROM (CURRENT_TIMESTAMP - last_active_at)) as days_inactive
FROM tenant_{id}.user_profiles
WHERE last_active_at < cutoff_date
ORDER BY days_inactive DESC
```

**Definition of Done**:
- All tests pass
- Code reviewed and approved
- PR merged to dev branch

---

### ATAP-XXX-3: Backend - Deploy & smoke-test dev

**Type**: Task  
**Story Points**: 1  
**Assignee**: DevOps/Backend Team  
**Priority**: High  

**Description**:
Deploy Phase A backend changes to dev environment and verify functionality.

**Tasks**:
- [ ] Deploy to dev: `serverless deploy --stage dev`
- [ ] Verify Lambda function deployed
- [ ] Test endpoint with Postman/curl
- [ ] Verify response structure
- [ ] Test with different threshold values
- [ ] Test pagination
- [ ] Verify tenant isolation (multiple tenants)
- [ ] Check CloudWatch logs
- [ ] Verify API response time < 2s

**Acceptance Criteria**:
- ✅ Deployment successful (no errors)
- ✅ Endpoint responds with 200 OK
- ✅ Sample data returns correct dormant users
- ✅ Performance < 2 seconds for 1000 users
- ✅ Logs show no errors
- ✅ Tenant isolation verified

**Repository**: `profile-360-backend`  
**Environment**: dev (us-east-1)

**Test Commands**:
```bash
# Deploy
cd profile-360-backend
npm run deploy:dev

# Test endpoint
curl -H "Authorization: Bearer $DEV_TOKEN" \
  "https://api-dev.trustx.cloud/profile360/insights/dormant-users?inactive_days=30"

# Check logs
aws logs tail /aws/lambda/assurex-profile360-dev-api --follow
```

**Definition of Done**:
- Smoke tests passed
- Response time benchmarked
- No errors in logs

---

### ATAP-XXX-4: Frontend - DormantUsers table component

**Type**: Task  
**Story Points**: 5  
**Assignee**: Frontend Team  
**Priority**: High  

**Description**:
Create React component to display dormant users with configurable threshold.

**Tasks**:
- [ ] Create `trustx/src/components/Profile360/DormantUsersTable.js`
- [ ] Add Material-UI Table with columns: Email, Name, Days Inactive, Last Active
- [ ] Add threshold input (TextField) with default 30 days
- [ ] Add Refresh button
- [ ] Implement sorting (especially by days_inactive)
- [ ] Add loading state
- [ ] Add error handling
- [ ] Update `trustx/src/services/apiService.js` with `getDormantUsers()` method
- [ ] Add component to Profile360 section routing
- [ ] Write Storybook story for component
- [ ] Write unit tests (Jest/React Testing Library)

**Acceptance Criteria**:
- ✅ Table displays dormant users correctly
- ✅ Threshold input updates query
- ✅ Refresh button triggers new API call
- ✅ Sorting works on all columns
- ✅ Loading spinner shown during API call
- ✅ Error messages displayed gracefully
- ✅ Responsive design (mobile-friendly)
- ✅ Unit tests pass

**Repository**: `trustx`  
**Files**:
- `src/components/Profile360/DormantUsersTable.js`
- `src/services/apiService.js`
- `src/components/Profile360/DormantUsersTable.stories.js`
- `src/components/Profile360/__tests__/DormantUsersTable.test.js`

**Design Reference**:
- Use existing Material-UI theme
- Follow Profile360 design patterns
- Table with alternating row colors
- Sortable column headers
- Clean, minimal design

**Definition of Done**:
- Component renders correctly in Storybook
- All tests pass
- Code reviewed and approved
- PR merged to stg branch

---

### ATAP-XXX-5: Phase A - QA & Documentation

**Type**: Task  
**Story Points**: 3  
**Assignee**: QA Lead + Tech Writer  
**Priority**: High  

**Description**:
Comprehensive testing of Phase A MVP and update all documentation.

**Tasks**:

**Testing**:
- [ ] Execute regression test suite
- [ ] Multi-tenant isolation testing (5+ tenants)
- [ ] Performance testing (10,000 users per tenant)
- [ ] Security testing (JWT validation, SQL injection)
- [ ] Browser compatibility testing (Chrome, Firefox, Safari, Edge)
- [ ] Mobile responsiveness testing
- [ ] API contract testing
- [ ] Load testing (50 concurrent users)

**Documentation**:
- [ ] Update `profile-360-backend/DEVELOPER_GUIDE.md`
- [ ] Update API documentation (FastAPI auto-docs)
- [ ] Update `trustx/README.md` with new component
- [ ] Create user guide for dormant user feature
- [ ] Update `assurex-infra/docs/RDS_*` if schema changed
- [ ] Create release notes for Phase A
- [ ] Update CHANGELOG files

**Deployment**:
- [ ] Deploy to preprod environment
- [ ] Verify preprod functionality
- [ ] Obtain stakeholder sign-off

**Acceptance Criteria**:
- ✅ All tests pass with zero critical/high bugs
- ✅ Performance benchmarks met (< 2s API, < 1s UI)
- ✅ Security audit clean
- ✅ Documentation complete and accurate
- ✅ Deployed to preprod successfully
- ✅ Stakeholder approval obtained

**Deliverables**:
- Test report
- Performance benchmark report
- Updated documentation
- Sign-off document

**Definition of Done**:
- Phase A ready for production deployment
- All documentation merged
- Sign-off email sent

---

## Phase B: AI-Powered Insights (Weeks 4-8)

### ATAP-XXX-6: Infra - pgvector & schema migrations

**Type**: Task  
**Story Points**: 5  
**Assignee**: Backend/Infra Team  
**Priority**: High  
**Blocked By**: ATAP-XXX-5 (Phase A complete)

**Description**:
Enable pgvector extension and create new tables for AI embeddings and insights.

**Tasks**:
- [ ] Create migration: `V00X__enable_pgvector.sql`
- [ ] Enable pgvector extension per tenant schema
- [ ] Create `user_embeddings` table with vector(1536) column
- [ ] Create `user_insights` table with AI fields
- [ ] Create `rag_analysis_history` table for audit
- [ ] Create IVFFlat indexes for vector similarity
- [ ] Write migration runbook for existing tenants
- [ ] Test migration in dev environment
- [ ] Verify vector operations work
- [ ] Document table structures

**Acceptance Criteria**:
- ✅ pgvector extension enabled in all tenant schemas
- ✅ All three tables created successfully
- ✅ Vector indexes functional
- ✅ Vector similarity queries work (< 500ms)
- ✅ Migration runbook documented
- ✅ Rollback procedure tested

**Repository**: `assurex-infra`  
**Files**:
- `resources/database/lambda-schema-init/migrations/V00X__enable_pgvector.sql`
- `resources/database/lambda-schema-init/migrations/V00Y__ai_insights_tables.sql`
- `docs/migrations/PGVECTOR_MIGRATION_RUNBOOK.md`

**SQL Schema**:
```sql
CREATE EXTENSION IF NOT EXISTS vector SCHEMA tenant_{id};

CREATE TABLE tenant_{id}.user_embeddings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id VARCHAR(255) UNIQUE NOT NULL,
    embedding vector(1536) NOT NULL,
    source_data JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_embeddings_embedding 
ON tenant_{id}.user_embeddings 
USING ivfflat (embedding vector_cosine_ops) 
WITH (lists = 100);
```

**Definition of Done**:
- Migration applied to dev
- Vector queries benchmarked
- Documentation complete

---

### ATAP-XXX-7: Infra - Bedrock/IAM setup

**Type**: Task  
**Story Points**: 3  
**Assignee**: DevOps/Security Team  
**Priority**: High  

**Description**:
Configure AWS Bedrock access, IAM roles, and monitoring for AI workloads.

**Tasks**:
- [ ] Request AWS Bedrock model access (Titan Embeddings, Claude Haiku)
- [ ] Wait for model access approval (~2-3 days)
- [ ] Create/update IAM policy for Bedrock access
- [ ] Attach policy to Lambda execution roles
- [ ] Store Bedrock credentials in Secrets Manager (if needed)
- [ ] Create CloudWatch budget alerts ($800/month threshold)
- [ ] Create CloudWatch alarms for Bedrock errors
- [ ] Set up cost monitoring dashboard
- [ ] Document IAM policies

**Acceptance Criteria**:
- ✅ Bedrock model access approved
- ✅ IAM roles have bedrock:InvokeModel permission
- ✅ Budget alerts configured
- ✅ Error alarms active
- ✅ Cost dashboard created
- ✅ Security audit approved IAM policies

**Repository**: `assurex-infra`  
**Files**:
- `resources/iam/bedrock-policy.json`
- `resources/monitoring/bedrock-alarms.yml`
- `docs/IAM_BEDROCK_SETUP.md`

**IAM Policy** (least privilege):
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "bedrock:InvokeModel"
      ],
      "Resource": [
        "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v1",
        "arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-3-haiku-20240307-v1:0"
      ]
    }
  ]
}
```

**Definition of Done**:
- IAM policies deployed
- Monitoring active
- Test Bedrock call successful

---

### ATAP-XXX-8: Infra - EventBridge/S3 wiring

**Type**: Task  
**Story Points**: 2  
**Assignee**: DevOps Team  
**Priority**: Medium  

**Description**:
Configure S3 event notifications to trigger embedding generation when new integration data arrives.

**Tasks**:
- [ ] Create EventBridge rule for S3 PUT events
- [ ] Filter events: `tenant_*/entra/users/*` and `tenant_*/okta/users/*`
- [ ] Configure rule to invoke embedding Lambda
- [ ] Test event flow with sample S3 upload
- [ ] Add CloudWatch logging for events
- [ ] Document event patterns

**Acceptance Criteria**:
- ✅ EventBridge rule created
- ✅ S3 notifications configured
- ✅ Test upload triggers Lambda
- ✅ Event filtering works correctly
- ✅ Logs show successful invocations

**Repository**: `assurex-infra`  
**Files**:
- `serverless.yml` (add EventBridge rule)
- `docs/EVENTBRIDGE_S3_INTEGRATION.md`

**Definition of Done**:
- Event flow tested end-to-end
- Documentation complete

---

### ATAP-XXX-9: Lambda layer updates

**Type**: Task  
**Story Points**: 3  
**Assignee**: Backend Team  
**Priority**: High  

**Description**:
Update Lambda layer with pgvector bindings for Python 3.12.

**Tasks**:
- [ ] Update `requirements.txt` in layer: add `pgvector==0.3.6`
- [ ] Rebuild layer with Docker (Python 3.12 runtime)
- [ ] Verify psycopg2 + pgvector compatibility
- [ ] Add vector operation helpers in `assurex_db/vector_ops.py`
- [ ] Deploy updated layer to dev
- [ ] Test layer in Lambda function
- [ ] Verify vector queries work
- [ ] Update layer version references in serverless.yml

**Acceptance Criteria**:
- ✅ Layer includes pgvector bindings
- ✅ Compiled for Python 3.12
- ✅ Test Lambda can import pgvector
- ✅ Vector operations functional
- ✅ Layer deployed to dev and preprod

**Repository**: `assurex-infra`  
**Files**:
- `resources/lambda-layers/db-connector/requirements.txt`
- `resources/lambda-layers/db-connector/assurex_db/vector_ops.py`
- `resources/lambda-layers/db-connector/build-layer.sh`

**Build Command**:
```bash
cd resources/lambda-layers/db-connector
./build-layer.sh
aws lambda publish-layer-version \
  --layer-name assurex-db-connector-dev \
  --zip-file fileb://layer.zip \
  --compatible-runtimes python3.12
```

**Definition of Done**:
- Layer deployed
- Test function verified
- Documentation updated

---

### ATAP-XXX-10: Backend - Embedding pipeline

**Type**: Task  
**Story Points**: 5  
**Assignee**: Backend Team  
**Priority**: High  

**Description**:
Implement Lambda function to generate embeddings from user data using Bedrock Titan.

**Tasks**:
- [ ] Create `generate-user-embeddings` Lambda function
- [ ] Implement S3 data reading (user profiles, activity logs)
- [ ] Combine user context (profile + activity + permissions)
- [ ] Integrate Bedrock Titan Embeddings API
- [ ] Store embeddings in `user_embeddings` table
- [ ] Implement batch processing (10 users per invocation)
- [ ] Add error handling and retries
- [ ] Add CloudWatch logging
- [ ] Write unit tests with mocked Bedrock
- [ ] Write integration tests

**Acceptance Criteria**:
- ✅ Lambda reads S3 data correctly
- ✅ Bedrock generates 1536-dim embeddings
- ✅ Embeddings stored in database
- ✅ Batch processing works efficiently
- ✅ Error handling catches Bedrock throttling
- ✅ Logs show successful operations
- ✅ Unit tests pass

**Repository**: `assurex-infra`  
**Files**:
- `resources/lambda-functions/generate-user-embeddings/lambda_function.py`
- `resources/lambda-functions/generate-user-embeddings/services/bedrock_service.py`
- `resources/lambda-functions/generate-user-embeddings/services/s3_service.py`
- `resources/lambda-functions/generate-user-embeddings/tests/`

**Bedrock Integration**:
```python
import boto3
import json

bedrock = boto3.client('bedrock-runtime', region_name='us-east-1')

def generate_embedding(text: str) -> list:
    response = bedrock.invoke_model(
        modelId='amazon.titan-embed-text-v1',
        body=json.dumps({'inputText': text})
    )
    result = json.loads(response['body'].read())
    return result['embedding']
```

**Definition of Done**:
- Lambda deployed to dev
- End-to-end test successful
- Monitoring active

---

### ATAP-XXX-11: Backend - Dormant/RAG analysis service

**Type**: Task  
**Story Points**: 8  
**Assignee**: Backend Team  
**Priority**: High  

**Description**:
Implement core RAG analysis engine using vector similarity and Bedrock Claude.

**Tasks**:
- [ ] Create `detect-dormant-users` Lambda function
- [ ] Query dormant users (reuse Phase A logic)
- [ ] Implement vector similarity search
- [ ] Retrieve context from S3 and database
- [ ] Build sanitized prompts for Bedrock Claude
- [ ] Invoke Bedrock Claude for analysis
- [ ] Parse AI response (risk score, insights, recommendations)
- [ ] Store results in `user_insights` table
- [ ] Store history in `rag_analysis_history` table
- [ ] Implement caching strategy (Redis)
- [ ] Add Step Function orchestration (optional)
- [ ] Add CloudWatch metrics (tokens, latency, errors)
- [ ] Write comprehensive tests

**Acceptance Criteria**:
- ✅ Dormant users detected correctly
- ✅ Vector similarity returns relevant users (similarity > 0.8)
- ✅ Prompts sanitized (no PII leakage)
- ✅ Bedrock Claude generates quality insights
- ✅ Risk scores assigned (0.0-1.0)
- ✅ Recommendations actionable
- ✅ Analysis completes in < 5 seconds per user
- ✅ Results stored correctly
- ✅ Step Function handles retries (if used)
- ✅ Metrics tracked in CloudWatch

**Repository**: Multiple
- `assurex-infra`: Lambda function
- `profile-360-backend`: Service/query layer

**Files**:
- `assurex-infra/resources/lambda-functions/detect-dormant-users/`
- `profile-360-backend/app/services/rag_service.py`
- `profile-360-backend/app/services/bedrock_service.py`
- `profile-360-backend/app/services/prompt_sanitizer.py`

**RAG Flow**:
1. Detect dormant users (SQL query)
2. Get user embedding from database
3. Vector similarity search (find 10 similar users)
4. Retrieve context (S3 + DB)
5. Build sanitized prompt
6. Invoke Bedrock Claude
7. Parse response
8. Store insights

**Definition of Done**:
- Lambda deployed
- End-to-end test successful
- Metrics dashboard created

---

### ATAP-XXX-12: Backend - API enhancements

**Type**: Task  
**Story Points**: 5  
**Assignee**: Backend Team  
**Priority**: High  

**Description**:
Extend Phase A API with AI insights endpoints and enhanced schemas.

**Tasks**:
- [ ] Update `GET /profile360/insights/dormant-users` to include AI fields
- [ ] Add `GET /profile360/insights/dormant-users/{user_id}` for detail view
- [ ] Add `POST /profile360/insights/dormant-users/refresh` for manual trigger
- [ ] Create `DormantUserInsight` Pydantic schema
- [ ] Add risk level filtering (`?risk_level=high`)
- [ ] Implement Redis caching (5 min TTL)
- [ ] Add async Lambda invocation for refresh
- [ ] Update API documentation
- [ ] Write integration tests

**Acceptance Criteria**:
- ✅ Enhanced endpoint returns AI insights
- ✅ Detail endpoint shows full analysis
- ✅ Refresh endpoint triggers async analysis
- ✅ Risk filtering works correctly
- ✅ Caching improves response time
- ✅ API docs updated
- ✅ Tests pass

**Repository**: `profile-360-backend`  
**Files**:
- `app/api/v1/endpoints/insights.py`
- `app/schemas/insights.py`
- `app/services/insights_service.py`
- `tests/api/test_insights_enhanced.py`

**Enhanced Schema**:
```python
class DormantUserInsight(BaseModel):
    id: str
    user_id: str
    user_email: str
    risk_level: RiskLevel  # Enum: low, medium, high, critical
    risk_score: float
    days_inactive: int
    ai_summary: str
    ai_insights: List[str]
    recommendations: List[AIRecommendation]
    similar_users: Optional[List[SimilarUserPattern]]
    last_analyzed_at: datetime
```

**Definition of Done**:
- All endpoints functional
- Tests pass
- Deployed to dev

---

### ATAP-XXX-13: Frontend - AI dashboard

**Type**: Task  
**Story Points**: 8  
**Assignee**: Frontend Team  
**Priority**: High  

**Description**:
Build enhanced UI dashboard with AI insights, risk visualization, and recommendations.

**Tasks**:
- [ ] Create `DormantUsersDashboard.js` component (replace Phase A table)
- [ ] Add risk level chips with color coding (red/yellow/blue/green)
- [ ] Display AI summary per user
- [ ] Show recommendations as actionable chips
- [ ] Add risk level filter dropdown
- [ ] Create detail modal with full AI analysis
- [ ] Add charts/visualizations (risk distribution, trends)
- [ ] Implement manual refresh (triggers async analysis)
- [ ] Add loading states and progress indicators
- [ ] Add error handling and retry logic
- [ ] Update API service with new endpoints
- [ ] Write Storybook stories
- [ ] Write component tests

**Acceptance Criteria**:
- ✅ Dashboard shows AI insights clearly
- ✅ Risk levels color-coded correctly
- ✅ Recommendations displayed
- ✅ Detail modal shows full context
- ✅ Filtering works smoothly
- ✅ Manual refresh triggers backend analysis
- ✅ Loading/error states handled
- ✅ Responsive design (mobile-friendly)
- ✅ Tests pass

**Repository**: `trustx`  
**Files**:
- `src/components/Profile360/DormantUsersDashboard.js`
- `src/components/Profile360/DormantUserDetailModal.js`
- `src/components/Profile360/RiskDistributionChart.js`
- `src/services/apiService.js`
- `src/components/Profile360/__tests__/`

**UI Components**:
- Risk chip: `<Chip icon={<Warning />} label="HIGH" color="error" />`
- AI summary: Truncated text with "Read more" button
- Recommendations: Chip array with priority indicators
- Detail modal: Full user context, timeline, similar users

**Definition of Done**:
- Component renders correctly
- All tests pass
- Deployed to stg

---

### ATAP-XXX-14: Cost & performance validation

**Type**: Task  
**Story Points**: 3  
**Assignee**: Backend + DevOps Team  
**Priority**: High  

**Description**:
Load test the AI pipeline and validate costs stay within budget.

**Tasks**:
- [ ] Load test: 100 concurrent tenants
- [ ] Measure Bedrock API throughput
- [ ] Calculate actual cost per tenant
- [ ] Verify cost stays under $10/tenant/month target
- [ ] Test Bedrock throttling/backoff logic
- [ ] Optimize batching and concurrency settings
- [ ] Tune caching strategy
- [ ] Create cost projection model
- [ ] Document optimization strategies

**Acceptance Criteria**:
- ✅ System handles 100+ tenants concurrently
- ✅ Cost per tenant < $10/month
- ✅ No Bedrock throttling errors (or handled gracefully)
- ✅ Performance: < 5s end-to-end analysis
- ✅ Optimization recommendations documented

**Tests**:
- Simulate 100 tenants with 1000 users each
- Trigger daily analysis for all tenants
- Monitor Bedrock API calls and costs
- Measure Lambda execution time and memory

**Deliverables**:
- Load test report
- Cost analysis spreadsheet
- Optimization guide

**Definition of Done**:
- Load tests passed
- Cost validated
- Report delivered

---

### ATAP-XXX-15: Security & compliance review

**Type**: Task  
**Story Points**: 3  
**Assignee**: Security Team  
**Priority**: High  

**Description**:
Comprehensive security audit of AI pipeline, especially tenant isolation and data handling.

**Tasks**:
- [ ] Audit tenant isolation (PostgreSQL roles, schema access)
- [ ] Review prompt sanitization logic
- [ ] Verify PII redaction in Bedrock prompts
- [ ] Test for SQL injection vulnerabilities
- [ ] Review IAM policies (least privilege)
- [ ] Audit logging and monitoring
- [ ] Document data retention policy
- [ ] Verify GDPR/CCPA compliance
- [ ] Penetration testing (if required)
- [ ] Security sign-off

**Acceptance Criteria**:
- ✅ No cross-tenant data leakage
- ✅ Prompts contain no PII
- ✅ SQL injection tests passed
- ✅ IAM policies follow least privilege
- ✅ All AI queries logged
- ✅ Data retention documented
- ✅ Compliance verified
- ✅ Security officer approval obtained

**Security Checklist**:
- [ ] Tenant isolation verified
- [ ] Prompt sanitization tested
- [ ] IAM audit completed
- [ ] Logging verified
- [ ] Data retention defined
- [ ] Compliance docs updated

**Deliverables**:
- Security audit report
- Compliance documentation
- Sign-off document

**Definition of Done**:
- Security audit passed
- Compliance verified
- Sign-off obtained

---

### ATAP-XXX-16: Phase B - QA, docs, deployment

**Type**: Task  
**Story Points**: 5  
**Assignee**: QA + Tech Writer + DevOps  
**Priority**: High  

**Description**:
Final testing, documentation, and deployment of Phase B to preprod.

**Tasks**:

**Testing**:
- [ ] End-to-end testing (S3 → embeddings → RAG → UI)
- [ ] Regression testing (ensure Phase A still works)
- [ ] Multi-tenant testing (10+ tenants)
- [ ] Performance benchmarking
- [ ] Security re-verification
- [ ] Browser compatibility testing
- [ ] Mobile testing
- [ ] UAT with stakeholders

**Documentation**:
- [ ] Update `SOP_DORMANT_USER_RAG_ENGINE.md` with actual implementation
- [ ] Create operational runbooks
- [ ] Update monitoring dashboard docs
- [ ] Create troubleshooting guide
- [ ] Update API documentation
- [ ] Create user training materials
- [ ] Update release notes

**Deployment**:
- [ ] Deploy to preprod (us-east-2)
- [ ] Smoke test preprod
- [ ] Verify monitoring and alerts
- [ ] Conduct UAT session
- [ ] Obtain stakeholder sign-off
- [ ] Prepare production deployment plan

**Acceptance Criteria**:
- ✅ All tests passed (zero critical bugs)
- ✅ Documentation complete and accurate
- ✅ Deployed to preprod successfully
- ✅ UAT sign-off obtained
- ✅ Production deployment plan ready

**Deliverables**:
- Test report
- Updated documentation
- UAT sign-off
- Production checklist

**Definition of Done**:
- Phase B ready for production
- All docs merged
- Sign-off obtained

---

## Wrap-up

### ATAP-XXX-17: Rollout readiness & production plan

**Type**: Task  
**Story Points**: 2  
**Assignee**: Tech Lead + Product Owner  
**Priority**: Medium  

**Description**:
Finalize production deployment plan and ensure operational readiness.

**Tasks**:
- [ ] Consolidate learnings from dev/preprod
- [ ] Create production deployment checklist
- [ ] Define rollback procedures
- [ ] Create communication templates (users, stakeholders)
- [ ] Schedule production deployment window
- [ ] Coordinate with ops team
- [ ] Prepare monitoring dashboards
- [ ] Create incident response plan
- [ ] Schedule post-deployment review

**Acceptance Criteria**:
- ✅ Production checklist complete
- ✅ Rollback plan documented
- ✅ Communications drafted
- ✅ Deployment scheduled
- ✅ Ops team briefed
- ✅ Monitoring ready

**Deliverables**:
- Production deployment plan
- Rollback procedures
- Communication templates
- Incident response guide

**Definition of Done**:
- All stakeholders aligned
- Production deployment approved
- Ready to go live

---

## Summary

**Total Story Points**: 69  
**Estimated Duration**: 8 weeks  
**Teams Involved**: Backend, Frontend, DevOps, QA, Security  
**Repositories**: assurex-infra, profile-360-backend, trustx

**Phase Breakdown**:
- Phase A (Subtasks 1-5): 16 story points, 3 weeks
- Phase B (Subtasks 6-16): 51 story points, 5 weeks
- Wrap-up (Subtask 17): 2 story points, ongoing

**Dependencies**:
- Phase B blocked until Phase A complete
- AWS Bedrock access required for Phase B
- pgvector migration must complete before embeddings work

**Risk Areas**:
- Bedrock model access approval time
- Cost overruns (needs monitoring)
- Performance at scale (load testing critical)
- AI insight quality (requires human validation)

---

**Created**: 2025-10-08  
**Last Updated**: 2025-10-08  
**Ready for**: Sprint Planning & Assignment
