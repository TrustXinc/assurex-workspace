# Dormant User Detection - Implementation Checklist

**Feature**: Dormant User Detection & AI Insights  
**Parent Story**: ATAP-XXX  
**Start Date**: TBD  
**Target Completion**: 8 weeks from start

---

## Pre-Implementation Setup

### Week 0: Preparation

- [ ] **Stakeholder Alignment**
  - [ ] Product owner approves scope and timeline
  - [ ] Budget approved for Phase B ($800/month)
  - [ ] Security officer reviews security requirements
  - [ ] Dev team capacity confirmed (Backend, Frontend, DevOps)

- [ ] **AWS Bedrock Setup** (⏱️ 2-3 days lead time)
  - [ ] Request model access: Titan Embeddings G1
  - [ ] Request model access: Claude 3 Haiku
  - [ ] Request model access: Claude 3.5 Sonnet (optional)
  - [ ] Wait for approval email from AWS

- [ ] **Development Environment**
  - [ ] Verify dev RDS PostgreSQL accessible
  - [ ] Verify Profile360 API deployed and healthy
  - [ ] Verify TrustX frontend build pipeline working
  - [ ] Local development setup tested

- [ ] **Documentation Review**
  - [ ] Team reads `SOP_DORMANT_USER_RAG_ENGINE.md`
  - [ ] Team reads `DORMANT_USER_SUMMARY.md`
  - [ ] Team reviews architecture diagrams
  - [ ] Questions documented and answered

---

## Phase A: Basic Detection (Weeks 1-3)

### Week 1: Backend Foundation

#### ATAP-XXX-1: Database Setup
- [ ] Check `tenant_settings` table exists
- [ ] Create migration if needed: `V00X__tenant_settings.sql`
- [ ] Verify `user_profiles.last_active_at` column exists
- [ ] Create index: `idx_user_profiles_last_active`
- [ ] Test query: `EXPLAIN ANALYZE SELECT ... WHERE last_active_at < ...`
- [ ] Verify performance < 200ms for 10k users
- [ ] Deploy migration to dev
- [ ] Verify in all test tenant schemas
- [ ] Document table structure in README

#### ATAP-XXX-2: API Endpoint Development
- [ ] Create `app/services/insights_service.py`
  - [ ] Implement `get_tenant_setting(tenant_id, key)`
  - [ ] Implement `get_dormant_users_basic(tenant_id, inactive_days, skip, limit)`
- [ ] Create `app/schemas/insights.py`
  - [ ] Define `DormantUserBasic` Pydantic model
  - [ ] Add JSON schema examples
- [ ] Create `app/api/v1/endpoints/insights.py`
  - [ ] Implement `GET /profile360/insights/dormant-users`
  - [ ] Add JWT authentication dependency
  - [ ] Add pagination support
  - [ ] Add input validation
- [ ] Write unit tests:
  - [ ] `tests/services/test_insights_service.py`
  - [ ] `tests/api/test_insights_endpoints.py`
  - [ ] Achieve > 80% coverage
- [ ] Update `requirements.txt` if new dependencies added
- [ ] Run linter: `black app/ && flake8 app/`
- [ ] Create PR, request review
- [ ] Merge to dev branch

#### ATAP-XXX-3: Deploy & Test Dev
- [ ] Deploy to dev: `npm run deploy:dev`
- [ ] Verify Lambda deployment in AWS Console
- [ ] Get API endpoint URL from deployment output
- [ ] Test with curl:
  ```bash
  curl -H "Authorization: Bearer $DEV_TOKEN" \
    "https://api-dev.trustx.cloud/profile360/insights/dormant-users?inactive_days=30"
  ```
- [ ] Verify response structure matches schema
- [ ] Test different threshold values (30, 60, 90 days)
- [ ] Test pagination (skip=0, limit=10)
- [ ] Test with multiple tenant tokens
- [ ] Check CloudWatch logs for errors
- [ ] Benchmark response time (should be < 2s)
- [ ] Document any issues found

### Week 2: Frontend Development

#### ATAP-XXX-4: UI Component
- [ ] Create component file: `trustx/src/components/Profile360/DormantUsersTable.js`
- [ ] Implement table structure:
  - [ ] Material-UI Table component
  - [ ] Columns: Email, Name, Days Inactive, Last Active
  - [ ] Sortable headers (especially days_inactive)
- [ ] Add controls:
  - [ ] Threshold input (TextField, default 30)
  - [ ] Refresh button (triggers API call)
- [ ] Add state management:
  - [ ] `useState` for users, loading, threshold, error
  - [ ] `useEffect` to load data on mount and threshold change
- [ ] Implement API service:
  - [ ] Add `getDormantUsers()` to `src/services/apiService.js`
  - [ ] Handle authentication token
  - [ ] Handle errors gracefully
- [ ] Add loading state:
  - [ ] Show CircularProgress while loading
  - [ ] Disable controls during load
- [ ] Add error handling:
  - [ ] Display error message in Alert component
  - [ ] Retry button on error
- [ ] Add empty state:
  - [ ] Show message when no dormant users found
- [ ] Style component:
  - [ ] Use Material-UI theme
  - [ ] Responsive design (mobile-friendly)
  - [ ] Match Profile360 design patterns
- [ ] Create Storybook story:
  - [ ] `src/components/Profile360/DormantUsersTable.stories.js`
  - [ ] Mock API responses
  - [ ] Show loading/error/empty states
- [ ] Write tests:
  - [ ] `src/components/Profile360/__tests__/DormantUsersTable.test.js`
  - [ ] Test rendering
  - [ ] Test user interactions
  - [ ] Test API error handling
- [ ] Add to routing:
  - [ ] Update Profile360 section routes
  - [ ] Add navigation menu item
- [ ] Test locally: `npm start`
- [ ] Create PR, request review
- [ ] Merge to stg branch

### Week 3: Testing & Documentation

#### ATAP-XXX-5: QA & Docs
- [ ] **Regression Testing**
  - [ ] Test all existing Profile360 features still work
  - [ ] Verify no breaking changes to other endpoints
- [ ] **Multi-Tenant Testing**
  - [ ] Test with 5+ different tenant accounts
  - [ ] Verify data isolation (no cross-tenant leakage)
  - [ ] Test concurrent requests from different tenants
- [ ] **Performance Testing**
  - [ ] Load test with 10,000 users per tenant
  - [ ] Measure API response time (target: < 2s)
  - [ ] Measure UI render time (target: < 1s)
  - [ ] Document results
- [ ] **Security Testing**
  - [ ] Test JWT validation (expired token, invalid token)
  - [ ] Test SQL injection attempts
  - [ ] Test without authentication (should fail)
  - [ ] Verify tenant isolation
- [ ] **Browser Compatibility**
  - [ ] Test in Chrome
  - [ ] Test in Firefox
  - [ ] Test in Safari
  - [ ] Test in Edge
- [ ] **Mobile Responsiveness**
  - [ ] Test on iOS Safari
  - [ ] Test on Android Chrome
  - [ ] Verify table is readable on small screens
- [ ] **Documentation Updates**
  - [ ] Update `profile-360-backend/DEVELOPER_GUIDE.md`
    - [ ] Add new endpoint documentation
    - [ ] Add configuration instructions
  - [ ] Update `profile-360-backend/README.md`
    - [ ] Add API endpoint to list
  - [ ] Update `trustx/README.md`
    - [ ] Document new component
  - [ ] Create user guide: `docs/USER_GUIDE_DORMANT_USERS.md`
  - [ ] Update CHANGELOG files
  - [ ] Create release notes for Phase A
- [ ] **Preprod Deployment**
  - [ ] Deploy backend to preprod: `npm run deploy:preprod`
  - [ ] Deploy frontend to preprod: push to `stg` branch
  - [ ] Smoke test preprod environment
  - [ ] Run full test suite against preprod
- [ ] **Stakeholder Sign-Off**
  - [ ] Demo to product owner
  - [ ] Demo to security officer
  - [ ] Collect feedback
  - [ ] Obtain formal approval
  - [ ] Document sign-off

#### Phase A Deliverables
- [ ] ✅ Working dormant user detection in dev & preprod
- [ ] ✅ Test report (all tests passed)
- [ ] ✅ Performance benchmarks documented
- [ ] ✅ Security audit complete
- [ ] ✅ Documentation updated
- [ ] ✅ Stakeholder sign-off obtained

---

## Phase B: AI-Powered Insights (Weeks 4-8)

### Week 4: AI Foundation Setup

#### ATAP-XXX-6: Database Migrations
- [ ] Create migration: `V00X__enable_pgvector.sql`
  - [ ] Enable pgvector extension per tenant schema
  - [ ] Add error handling for already-exists
- [ ] Create migration: `V00Y__ai_insights_tables.sql`
  - [ ] Create `user_embeddings` table
  - [ ] Create `user_insights` table
  - [ ] Create `rag_analysis_history` table
  - [ ] Create IVFFlat indexes
- [ ] Create migration runbook:
  - [ ] Document steps for existing tenants
  - [ ] Include rollback procedures
  - [ ] Add validation queries
- [ ] Test migrations in dev:
  - [ ] Apply migrations to 3+ test tenant schemas
  - [ ] Verify tables created correctly
  - [ ] Test vector operations
  - [ ] Benchmark vector similarity queries (< 500ms)
- [ ] Document table structures in README
- [ ] Create PR, get DBA review
- [ ] Deploy to dev
- [ ] Verify in CloudWatch logs

#### ATAP-XXX-7: Bedrock Setup
- [ ] **Verify Model Access**
  - [ ] Check AWS Bedrock console for approved models
  - [ ] Test Titan Embeddings invocation
  - [ ] Test Claude 3 Haiku invocation
- [ ] **IAM Configuration**
  - [ ] Create `resources/iam/bedrock-policy.json`
  - [ ] Attach policy to Lambda execution roles
  - [ ] Test permissions (should succeed)
- [ ] **Secrets Manager** (if needed)
  - [ ] Store any Bedrock-specific credentials
  - [ ] Document secret structure
- [ ] **Monitoring Setup**
  - [ ] Create CloudWatch budget: $800/month threshold
  - [ ] Create alarm: Bedrock API errors
  - [ ] Create alarm: High token usage
  - [ ] Create dashboard: Bedrock metrics
- [ ] **Cost Tracking**
  - [ ] Tag all Bedrock resources
  - [ ] Set up Cost Explorer filter
  - [ ] Create daily cost report
- [ ] Document IAM policies in `docs/IAM_BEDROCK_SETUP.md`

#### ATAP-XXX-8: EventBridge Configuration
- [ ] **EventBridge Rule**
  - [ ] Create rule for S3 PUT events
  - [ ] Add event pattern filter:
    ```json
    {
      "source": ["aws.s3"],
      "detail-type": ["Object Created"],
      "detail": {
        "bucket": {"name": ["assurex-integrations-dev"]},
        "object": {
          "key": [{
            "prefix": "tenant_"
          }, {
            "suffix": "/users/"
          }]
        }
      }
    }
    ```
  - [ ] Set target: `generate-user-embeddings` Lambda
- [ ] **Testing**
  - [ ] Upload test file to S3
  - [ ] Verify EventBridge rule triggered
  - [ ] Check Lambda invocation logs
  - [ ] Verify embedding generated
- [ ] Document event patterns in `docs/EVENTBRIDGE_S3_INTEGRATION.md`

#### ATAP-XXX-9: Lambda Layer Update
- [ ] Update `requirements.txt`:
  ```
  psycopg2-binary==2.9.10
  pgvector==0.3.6
  boto3==1.35.94
  ```
- [ ] Create `assurex_db/vector_ops.py`:
  - [ ] Helper functions for vector operations
  - [ ] Similarity search queries
- [ ] Rebuild layer:
  ```bash
  cd resources/lambda-layers/db-connector
  ./build-layer.sh
  ```
- [ ] Deploy layer to dev:
  ```bash
  aws lambda publish-layer-version \
    --layer-name assurex-db-connector-dev \
    --zip-file fileb://layer.zip \
    --compatible-runtimes python3.12
  ```
- [ ] Create test Lambda function:
  ```python
  from pgvector.psycopg2 import register_vector
  # Test import and basic operations
  ```
- [ ] Verify layer works
- [ ] Update layer version in `serverless.yml`
- [ ] Document layer contents

### Week 5: Embedding Pipeline

#### ATAP-XXX-10: Embedding Generation Lambda
- [ ] **Create Lambda Function**
  - [ ] File structure:
    ```
    resources/lambda-functions/generate-user-embeddings/
    ├── lambda_function.py
    ├── services/
    │   ├── bedrock_service.py
    │   ├── s3_service.py
    │   └── embedding_service.py
    ├── requirements.txt
    └── tests/
    ```
- [ ] **Implement Services**
  - [ ] `bedrock_service.py`:
    - [ ] Initialize Bedrock client
    - [ ] `generate_embedding(text: str) -> list[float]`
    - [ ] Error handling for throttling
    - [ ] Retry logic with exponential backoff
  - [ ] `s3_service.py`:
    - [ ] `read_user_data(bucket, key) -> dict`
    - [ ] Parse JSON from S3
    - [ ] Handle missing files gracefully
  - [ ] `embedding_service.py`:
    - [ ] `combine_user_context(user_data) -> str`
    - [ ] Build text for embedding (profile + activity)
    - [ ] Sanitize PII
- [ ] **Lambda Handler**
  - [ ] Parse S3 event
  - [ ] Extract tenant_id from S3 key
  - [ ] Read user data
  - [ ] Generate embedding
  - [ ] Store in `user_embeddings` table
  - [ ] Handle batch of 10 users
  - [ ] Log metrics (time, tokens)
- [ ] **Testing**
  - [ ] Unit tests with mocked Bedrock
  - [ ] Unit tests with mocked S3
  - [ ] Integration test with real services (dev)
- [ ] **Deployment**
  - [ ] Add to `serverless.yml`:
    ```yaml
    functions:
      generateEmbeddings:
        handler: lambda_function.handler
        runtime: python3.12
        memorySize: 512
        timeout: 30
        layers:
          - ${cf:assurex-db-connector-dev.LayerVersionArn}
        environment:
          BEDROCK_REGION: us-east-1
        events:
          - eventBridge:
              pattern:
                source: [aws.s3]
                detail-type: [Object Created]
    ```
  - [ ] Deploy: `sls deploy function -f generateEmbeddings`
  - [ ] Test with real S3 upload
  - [ ] Verify embedding in database
- [ ] Document function behavior

### Week 6: RAG Analysis Engine

#### ATAP-XXX-11: RAG Analysis Lambda
- [ ] **Create Lambda Function**
  - [ ] File structure:
    ```
    resources/lambda-functions/detect-dormant-users/
    ├── lambda_function.py
    ├── services/
    │   ├── rag_service.py
    │   ├── vector_search.py
    │   └── prompt_builder.py
    └── tests/
    ```
- [ ] **Implement Vector Search**
  - [ ] `vector_search.py`:
    - [ ] `find_similar_users(embedding, tenant_id, limit=10) -> list`
    - [ ] Use pgvector cosine similarity
    - [ ] Query: `SELECT ... ORDER BY embedding <=> %s LIMIT 10`
- [ ] **Implement Prompt Builder**
  - [ ] `prompt_builder.py`:
    - [ ] `build_dormant_analysis_prompt(user, similar_users, context) -> str`
    - [ ] Sanitize PII (redact emails, names)
    - [ ] Structure prompt for Claude
    - [ ] Include expected JSON response format
- [ ] **Implement RAG Service**
  - [ ] `rag_service.py`:
    - [ ] `analyze_dormant_user(user_id, tenant_id) -> dict`
    - [ ] Steps:
      1. Get user embedding
      2. Find similar users
      3. Retrieve context (S3 + DB)
      4. Build prompt
      5. Invoke Bedrock Claude
      6. Parse response
      7. Store insights
    - [ ] Error handling
    - [ ] Metrics logging
- [ ] **Lambda Handler**
  - [ ] Scheduled trigger: daily 2 AM
  - [ ] Or manual invocation via API
  - [ ] Query dormant users
  - [ ] Process in batches (100 per Lambda)
  - [ ] Parallel processing (10 concurrent)
  - [ ] Store results in `user_insights` table
  - [ ] Store history in `rag_analysis_history` table
- [ ] **Optional: Step Function**
  - [ ] Create state machine if needed
  - [ ] Orchestrate: Detect → Embed → Analyze → Store
  - [ ] Handle retries and errors
- [ ] **Testing**
  - [ ] Unit tests with mocked services
  - [ ] Integration test end-to-end
  - [ ] Test with real dormant users
  - [ ] Verify insights quality
- [ ] **Deployment**
  - [ ] Add to `serverless.yml`
  - [ ] Deploy
  - [ ] Manual test invocation
  - [ ] Verify insights stored
- [ ] Document RAG flow

### Week 7: API & Frontend Enhancements

#### ATAP-XXX-12: Enhanced API Endpoints
- [ ] **Update Existing Endpoint**
  - [ ] Modify `GET /profile360/insights/dormant-users`
  - [ ] Join `user_insights` table
  - [ ] Include AI fields in response
  - [ ] Maintain backward compatibility
- [ ] **Add Detail Endpoint**
  - [ ] Implement `GET /profile360/insights/dormant-users/{user_id}`
  - [ ] Return full AI analysis
  - [ ] Include similar users
  - [ ] Include recommendations
- [ ] **Add Refresh Endpoint**
  - [ ] Implement `POST /profile360/insights/dormant-users/refresh`
  - [ ] Trigger async Lambda invocation
  - [ ] Return job ID or status
- [ ] **Update Schemas**
  - [ ] Create `DormantUserInsight` model
  - [ ] Create `AIRecommendation` model
  - [ ] Create `RiskLevel` enum
  - [ ] Update API docs
- [ ] **Add Filtering**
  - [ ] Support `?risk_level=high` query param
  - [ ] Support `?confidence_min=0.8`
- [ ] **Add Caching**
  - [ ] Implement Redis caching (5 min TTL)
  - [ ] Cache key: `dormant_users:{tenant_id}:{params}`
  - [ ] Invalidate on refresh
- [ ] **Testing**
  - [ ] Unit tests for all endpoints
  - [ ] Integration tests
  - [ ] Test caching behavior
- [ ] **Deployment**
  - [ ] Deploy to dev
  - [ ] Smoke test
  - [ ] Document API changes

#### ATAP-XXX-13: AI Dashboard UI
- [ ] **Create Dashboard Component**
  - [ ] File: `src/components/Profile360/DormantUsersDashboard.js`
  - [ ] Replace Phase A table component
- [ ] **Implement Risk Visualization**
  - [ ] Risk level chips:
    - Critical: Red with Error icon
    - High: Orange with Warning icon
    - Medium: Blue with Info icon
    - Low: Green with CheckCircle icon
  - [ ] Color-coded rows
- [ ] **Display AI Insights**
  - [ ] Show AI summary (truncated, expandable)
  - [ ] Show top 2 recommendations as chips
  - [ ] "View Details" button per user
- [ ] **Add Filtering**
  - [ ] Risk level dropdown (All/Critical/High/Medium/Low)
  - [ ] Real-time filter on selection
- [ ] **Create Detail Modal**
  - [ ] File: `src/components/Profile360/DormantUserDetailModal.js`
  - [ ] Show full AI analysis
  - [ ] Show all recommendations with priority
  - [ ] Show similar users section
  - [ ] Show activity timeline
  - [ ] Close button
- [ ] **Add Charts** (optional)
  - [ ] Risk distribution pie chart
  - [ ] Dormancy trend over time
  - [ ] Use recharts or Material-UI X Charts
- [ ] **Implement Manual Refresh**
  - [ ] Refresh button triggers API
  - [ ] Show progress/loading state
  - [ ] Show "Analysis in progress" message
  - [ ] Poll for completion (optional)
- [ ] **Update API Service**
  - [ ] Add enhanced methods to `apiService.js`
  - [ ] `getDormantUsersWithAI()`
  - [ ] `getDormantUserDetail(userId)`
  - [ ] `refreshDormantAnalysis()`
- [ ] **Styling**
  - [ ] Match Material-UI theme
  - [ ] Responsive design
  - [ ] Smooth transitions
- [ ] **Testing**
  - [ ] Storybook stories for all states
  - [ ] Unit tests for components
  - [ ] Integration tests with API
- [ ] **Deployment**
  - [ ] Test locally
  - [ ] Deploy to stg
  - [ ] Smoke test

### Week 8: Testing & Deployment

#### ATAP-XXX-14: Performance & Cost Validation
- [ ] **Load Testing**
  - [ ] Simulate 100 tenants
  - [ ] 1,000 users per tenant
  - [ ] Trigger daily analysis for all
  - [ ] Monitor:
    - [ ] Lambda execution time
    - [ ] Bedrock API calls
    - [ ] Database query performance
    - [ ] Vector search latency
- [ ] **Cost Tracking**
  - [ ] Monitor AWS Cost Explorer
  - [ ] Calculate cost per tenant
  - [ ] Verify < $10/tenant/month
  - [ ] Document breakdown:
    - Bedrock embeddings: $X
    - Bedrock Claude: $Y
    - Lambda: $Z
    - Database: $W
- [ ] **Optimization**
  - [ ] Tune Lambda memory settings
  - [ ] Adjust batch sizes
  - [ ] Optimize vector index parameters
  - [ ] Implement more aggressive caching
- [ ] **Throttling Test**
  - [ ] Test Bedrock rate limits
  - [ ] Verify retry logic works
  - [ ] Adjust concurrency if needed
- [ ] **Report**
  - [ ] Create load test report
  - [ ] Create cost analysis spreadsheet
  - [ ] Document optimization recommendations

#### ATAP-XXX-15: Security Review
- [ ] **Tenant Isolation Audit**
  - [ ] Test cross-tenant queries (should fail)
  - [ ] Verify PostgreSQL roles work
  - [ ] Test with multiple concurrent tenants
- [ ] **Prompt Sanitization**
  - [ ] Review `prompt_sanitizer.py` code
  - [ ] Test with PII data (should be redacted)
  - [ ] Verify no email/name in Bedrock logs
- [ ] **SQL Injection Testing**
  - [ ] Test endpoints with malicious input
  - [ ] Verify parameterized queries used
- [ ] **IAM Policy Review**
  - [ ] Verify least privilege
  - [ ] No overly broad permissions
  - [ ] Document each permission's purpose
- [ ] **Audit Logging**
  - [ ] Verify all AI queries logged
  - [ ] Check log retention settings
  - [ ] Ensure logs include tenant_id
- [ ] **Data Retention**
  - [ ] Document policy:
    - Embeddings: keep 90 days
    - Insights: keep 1 year
    - History: keep 6 months
  - [ ] Implement cleanup Lambda (if needed)
- [ ] **Compliance Verification**
  - [ ] GDPR: Right to be forgotten
  - [ ] CCPA: Data deletion requests
  - [ ] Document compliance procedures
- [ ] **Security Sign-Off**
  - [ ] Security officer review
  - [ ] Penetration test (if required)
  - [ ] Formal approval

#### ATAP-XXX-16: Final QA & Deployment
- [ ] **End-to-End Testing**
  - [ ] Upload S3 data → triggers embeddings
  - [ ] Dormant user detected → triggers RAG
  - [ ] Insights stored in database
  - [ ] API returns insights
  - [ ] UI displays insights correctly
- [ ] **Regression Testing**
  - [ ] Phase A still works
  - [ ] All other Profile360 features work
  - [ ] No breaking changes
- [ ] **Multi-Tenant Testing**
  - [ ] Test 10+ tenants
  - [ ] Verify isolation
  - [ ] Test concurrent access
- [ ] **Performance Benchmarking**
  - [ ] API response: < 3s with AI
  - [ ] Vector search: < 500ms
  - [ ] UI render: < 1s
  - [ ] Document all benchmarks
- [ ] **Browser & Mobile Testing**
  - [ ] Test all major browsers
  - [ ] Test on iOS and Android
  - [ ] Verify responsive design
- [ ] **Documentation Updates**
  - [ ] Update `SOP_DORMANT_USER_RAG_ENGINE.md` with actual implementation
  - [ ] Create operational runbooks:
    - [ ] How to monitor costs
    - [ ] How to troubleshoot errors
    - [ ] How to scale up/down
  - [ ] Update monitoring docs
  - [ ] Create troubleshooting guide
  - [ ] Update API documentation
  - [ ] Create user training guide
  - [ ] Update CHANGELOG
  - [ ] Create Phase B release notes
- [ ] **Preprod Deployment**
  - [ ] Deploy all services to preprod
  - [ ] Apply database migrations
  - [ ] Configure environment variables
  - [ ] Smoke test preprod
  - [ ] Full test suite against preprod
- [ ] **UAT Session**
  - [ ] Schedule with stakeholders
  - [ ] Demo all Phase B features
  - [ ] Collect feedback
  - [ ] Document any issues
  - [ ] Implement fixes if needed
- [ ] **Stakeholder Sign-Off**
  - [ ] Product owner approval
  - [ ] Security officer approval
  - [ ] Tech lead approval
  - [ ] Budget owner approval
  - [ ] Document all approvals

#### Phase B Deliverables
- [ ] ✅ AI-powered dormant user insights working
- [ ] ✅ Deployed to preprod and tested
- [ ] ✅ Cost validated (< $10/tenant/month)
- [ ] ✅ Performance benchmarks met
- [ ] ✅ Security audit passed
- [ ] ✅ Documentation complete
- [ ] ✅ UAT sign-off obtained

---

## Post-Implementation

### ATAP-XXX-17: Production Readiness

- [ ] **Production Deployment Plan**
  - [ ] Create detailed checklist
  - [ ] Define maintenance window
  - [ ] Coordinate with ops team
  - [ ] Notify stakeholders
  - [ ] Prepare rollback plan

- [ ] **Communication Templates**
  - [ ] User announcement email
  - [ ] Stakeholder update email
  - [ ] Support team training materials

- [ ] **Monitoring Setup**
  - [ ] Verify all CloudWatch dashboards
  - [ ] Test all alarms
  - [ ] Set up on-call rotation

- [ ] **Incident Response**
  - [ ] Create incident response playbook
  - [ ] Define escalation path
  - [ ] Document rollback procedures

- [ ] **Post-Deployment Review**
  - [ ] Schedule 1 week after deployment
  - [ ] Review metrics and feedback
  - [ ] Document lessons learned
  - [ ] Plan future improvements

---

## Success Criteria

### Phase A Success
- ✅ Dormant users detected correctly (100% accuracy)
- ✅ API response < 2 seconds (p95)
- ✅ UI loads < 1 second
- ✅ Zero tenant data leaks
- ✅ Configurable threshold works
- ✅ Deployed to dev & preprod
- ✅ Documentation complete
- ✅ Stakeholder approval

### Phase B Success
- ✅ AI insights generated with > 85% confidence
- ✅ Risk levels accurate (validated by manual review)
- ✅ Cost < $10/tenant/month
- ✅ Vector search < 500ms (p95)
- ✅ End-to-end analysis < 5s (p95)
- ✅ Security audit passed
- ✅ Tenant isolation verified
- ✅ Deployed to preprod
- ✅ UAT sign-off obtained
- ✅ Ready for production

---

## Risk Mitigation Checklist

- [ ] AWS Bedrock model access requested Week 1
- [ ] Cost monitoring alerts configured before Phase B
- [ ] Performance benchmarks done before preprod
- [ ] Security audit completed before preprod
- [ ] Rollback procedures tested
- [ ] On-call rotation established
- [ ] Incident response plan documented

---

## Notes

- This checklist should be used alongside Jira subtasks
- Mark items complete as you go
- Document any deviations or issues
- Update dates and owners as needed
- Review weekly in standup
- Escalate blockers immediately

---

**Created**: 2025-10-08  
**Last Updated**: 2025-10-08  
**Owner**: Engineering Team  
**Status**: Ready for Use
