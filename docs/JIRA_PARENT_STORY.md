# ATAP-XXX: Dormant User Detection & AI Insights Feature

**Epic**: ATAP Dormant User Program  
**Story Type**: Feature  
**Priority**: High  
**Components**: Profile360, Integrations, TrustX Frontend  
**Labels**: `dormant-users`, `ai-insights`, `phase-a`, `phase-b`, `bedrock`, `rag`

---

## Story Summary

Implement two-phase dormant user detection feature: Phase A delivers immediate SQL-based detection with configurable thresholds (3 weeks, $0 cost); Phase B adds AI-powered insights using AWS Bedrock, pgvector, and RAG analysis (5 weeks, ~$8/tenant/month).

---

## Business Context

**Problem**: Security and compliance teams lack visibility into inactive user accounts, creating risk exposure and audit gaps.

**Solution**: 
- **Phase A (MVP)**: Simple dormant user detection via configurable SQL queries
- **Phase B (Enhancement)**: AI-powered risk assessment, recommendations, and pattern analysis

**User Value**:
- Proactive security risk mitigation
- Automated compliance reporting
- Resource optimization (license management)
- AI-driven actionable insights

---

## Business Requirements

**From Requirements Doc**: https://trustx.atlassian.net/wiki/spaces/TRUSTX/pages/64160155/Business+Logic+User+Insights

**Logic**: `if last_login_date >= {configurable_days}` (default: 30 days)

**Configurable Variables**:
- Dormant threshold days (per tenant, default: 30)
- Risk scoring thresholds (Phase B)
- Analysis frequency (Phase B)

---

## Acceptance Criteria

### Phase A - Basic Detection (MVP)

✅ **AC1: Configuration**
- Tenant settings table stores configurable `dormant_user_threshold_days`
- Default value: 30 days
- Can be updated via UI or API per tenant
- Setting persists across sessions

✅ **AC2: API Endpoint**
- `GET /profile360/insights/dormant-users` returns dormant users
- Query params: `inactive_days` (optional override), `skip`, `limit`
- Response includes: `user_id`, `email`, `name`, `last_active_at`, `days_inactive`
- Scoped to authenticated tenant (JWT validation)
- Pagination works correctly (skip/limit)
- Performance: < 2 seconds for 10,000 users

✅ **AC3: Multi-Tenant Isolation**
- Queries only return data for authenticated tenant
- No cross-tenant data leakage
- Security audit verification complete
- Tested with multiple concurrent tenant requests

✅ **AC4: Frontend UI**
- Dormant users table displays in Profile360 section
- Shows: Email, Name, Days Inactive, Last Active Date
- Configurable threshold input (updates query)
- Refresh button triggers new query
- Sortable columns (especially days_inactive)
- Clean, responsive Material-UI design

✅ **AC5: Deployment**
- Deployed to dev environment (us-east-1)
- Deployed to preprod environment (us-east-2)
- Smoke tests passed in both environments
- Documentation updated (API docs, developer guide)

---

### Phase B - AI-Powered Insights (Enhancement)

✅ **AC6: Vector Database Setup**
- pgvector extension enabled per tenant schema
- `user_embeddings` table created with vector(1536) column
- `user_insights` table created with AI fields
- `rag_analysis_history` table for audit trail
- IVFFlat indexes configured for fast similarity search
- Migration runbook documented

✅ **AC7: Bedrock Integration**
- AWS Bedrock model access approved (Titan, Claude)
- IAM roles configured with least-privilege access
- Embedding generation Lambda functional
- RAG analysis Lambda/Step Function deployed
- Error handling and retry logic implemented
- Cost monitoring alerts configured (~$8/tenant/month target)

✅ **AC8: Embedding Pipeline**
- S3 events trigger embedding generation
- User context combined (profile + activity + permissions)
- Bedrock Titan generates 1536-dim embeddings
- Embeddings stored in `user_embeddings` table
- Batch processing for efficiency
- Handles 100+ tenants concurrently

✅ **AC9: RAG Analysis**
- Dormant user detection triggers AI analysis
- Vector similarity search finds related users
- Context retrieved from S3 and database
- Bedrock Claude generates insights
- Risk score calculated (0.0-1.0)
- Recommendations provided
- Results stored in `user_insights` table
- Analysis completes in < 5 seconds per user

✅ **AC10: Enhanced API**
- `GET /profile360/insights/dormant-users` returns AI insights
- Response includes: `risk_level`, `risk_score`, `ai_summary`, `recommendations`
- `GET /profile360/insights/dormant-users/{user_id}` for detailed view
- `POST /profile360/insights/dormant-users/refresh` triggers async analysis
- Filter by risk level (low/medium/high/critical)
- Cached responses (5 min TTL)

✅ **AC11: Enhanced Frontend**
- AI insights dashboard with risk visualization
- Risk level chips with color coding
- AI summary displayed per user
- Recommendations shown as actionable chips
- Detail modal for deep-dive analysis
- Filter by risk level dropdown
- Manual refresh triggers background analysis
- Loading states and error handling

✅ **AC12: Security & Compliance**
- Tenant isolation enforced (PostgreSQL roles)
- Prompt sanitization prevents data leakage
- PII redaction in Bedrock prompts
- All AI queries logged for audit
- Data retention policy documented
- GDPR/CCPA compliance verified

✅ **AC13: Observability**
- CloudWatch metrics for Bedrock usage
- Token consumption tracking
- Cost per tenant monitoring
- Latency dashboards
- Error rate alerts
- Budget alerts configured

✅ **AC14: Testing**
- Unit tests: > 80% coverage
- Integration tests: End-to-end flow verified
- Load tests: 100 tenants concurrent
- Security tests: Tenant isolation validated
- Performance tests: < 3s AI analysis
- UAT sign-off obtained

✅ **AC15: Documentation**
- SOP updated with actual implementation
- API documentation complete
- Runbooks for operations
- Cost analysis documented
- Rollback procedures defined
- Training materials created

---

## Technical Approach

### Architecture Overview

```
Frontend (trustx) → Profile360 API (FastAPI) → RDS PostgreSQL (pgvector)
                                             ↓
                                    AWS Bedrock (Titan + Claude)
                                             ↓
                                    S3 Integration Data
```

### Technology Stack

**Phase A**:
- PostgreSQL 17.4 (existing RDS)
- FastAPI (profile-360-backend)
- React + Material-UI (trustx)
- AWS Lambda (existing)

**Phase B**:
- pgvector extension
- AWS Bedrock (Titan Embeddings, Claude 3 Haiku)
- EventBridge (S3 event routing)
- Step Functions (optional, for orchestration)
- Redis (caching)

### Database Schema

**New Tables** (tenant schema):
- `tenant_settings` - Configuration storage
- `user_embeddings` - Vector storage (1536 dims)
- `user_insights` - AI analysis results
- `rag_analysis_history` - Audit trail

**Indexes**:
- `idx_user_profiles_last_active` - Fast dormancy queries
- `idx_user_insights_embedding` - IVFFlat for similarity
- `idx_user_insights_risk` - Filter by risk level

### API Endpoints

**Phase A**:
- `GET /profile360/insights/dormant-users`
- Query params: `inactive_days`, `skip`, `limit`

**Phase B Additions**:
- `GET /profile360/insights/dormant-users/{user_id}` - Detail view
- `POST /profile360/insights/dormant-users/refresh` - Trigger analysis
- Filter: `?risk_level=high`

---

## Dependencies

### Upstream Dependencies
- ✅ RDS PostgreSQL 17.4 deployed (assurex-infra)
- ✅ Profile360 FastAPI service deployed
- ✅ S3 integration data sync active
- ✅ Auth0 JWT authentication working
- ⚠️ AWS Bedrock model access (Phase B) - **Request required**
- ⚠️ pgvector extension enabled - **Migration needed**

### Cross-Repository Changes
1. **assurex-infra**: Database migrations, Lambda layers
2. **profile-360-backend**: API endpoints, services, models
3. **trustx**: Frontend components, API integration

### External Services
- AWS Bedrock (us-east-1 for dev, us-east-2 for preprod)
- AWS Secrets Manager (credentials)
- AWS EventBridge (event routing)
- CloudWatch (monitoring)

---

## Cost Estimation

### Phase A (MVP)
| Component | Monthly Cost |
|-----------|--------------|
| Database queries | $0 (existing RDS) |
| API Lambda | $0 (existing) |
| Frontend | $0 (existing) |
| **Total** | **$0** |

### Phase B (AI Enhancement)
| Component | Per Tenant | 100 Tenants |
|-----------|------------|-------------|
| Bedrock Embeddings | $0.015 | $1.50 |
| Bedrock Analysis | $7.50 | $750 |
| Lambda execution | $0.35 | $35 |
| Database storage | negligible | negligible |
| **Total** | **~$8** | **~$800** |

**Assumptions**:
- 1,000 users per tenant
- Daily analysis
- 10% users dormant (~100 analyzed/day)
- Claude Haiku for cost efficiency

---

## Timeline

### Phase A - Basic Detection (3 weeks)

**Week 1**: Backend Development
- Database schema updates
- API endpoint implementation
- Service layer logic
- Unit tests

**Week 2**: Frontend Development
- React component (table)
- API integration
- UI/UX polish
- Component tests

**Week 3**: Testing & Deployment
- Integration testing
- Performance testing
- Security audit
- Deploy to dev & preprod

**Deliverable**: Working dormant user detection, $0 cost

---

### Phase B - AI Enhancement (5 weeks)

**Week 4-5**: AI Foundation
- pgvector setup
- Bedrock configuration
- Embedding pipeline
- IAM & security

**Week 6-7**: RAG Engine
- RAG analysis service
- Claude integration
- API enhancements
- Frontend AI dashboard

**Week 8**: Testing & Deployment
- End-to-end testing
- Cost validation
- Security review
- Deploy to preprod
- UAT & sign-off

**Deliverable**: AI-powered insights, monitored cost

---

## Risks & Mitigation

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **Bedrock model access delay** | High | Medium | Request access Week 1, fallback to simpler models |
| **Cost overrun (Phase B)** | High | Medium | Implement caching, batch processing, strict alerts |
| **Performance degradation** | Medium | Low | Index optimization, load testing, query tuning |
| **AI insights inaccurate** | Medium | Medium | Human review loop, confidence thresholds, feedback |
| **Cross-tenant data leak** | Critical | Low | Extensive security testing, code review, PostgreSQL roles |
| **Lambda timeout (RAG)** | Medium | Medium | Step Functions orchestration, async processing |
| **pgvector installation issues** | Medium | Low | Pre-test in dev, migration runbook, rollback plan |

---

## Non-Functional Requirements

### Performance
- API response: < 2s (Phase A), < 3s (Phase B)
- Vector search: < 500ms
- Support 10,000+ users per tenant
- Handle 100+ concurrent tenants

### Security
- Tenant data isolation (schema-level)
- JWT authentication required
- PII redaction in AI prompts
- Audit logging for all AI queries
- Encrypted at rest and in transit

### Scalability
- Horizontal scaling via Lambda
- Database connection pooling
- Bedrock request batching
- Redis caching for hot data

### Reliability
- 99.9% uptime target
- Graceful degradation (AI failures)
- Retry logic with exponential backoff
- Health checks and monitoring

---

## Success Metrics

### Phase A
- ✅ 100% of dormant users detected correctly
- ✅ API response < 2 seconds (p95)
- ✅ Zero tenant data leaks in testing
- ✅ UI renders in < 1 second
- ✅ Configuration works per tenant

### Phase B
- ✅ AI insights confidence > 85%
- ✅ Risk scores align with manual review (>90% accuracy)
- ✅ Cost per tenant < $10/month
- ✅ Vector search < 500ms (p95)
- ✅ End-to-end analysis < 5s (p95)
- ✅ User satisfaction score > 4/5

---

## Rollback Plan

### Phase A
- Revert serverless deployment: `serverless rollback`
- Remove API endpoint from routing
- Hide UI component via feature flag

### Phase B
- Disable Bedrock API calls (env variable)
- Fall back to Phase A (basic detection)
- Keep embeddings/insights tables (no data loss)
- Restore previous Lambda versions

---

## Related Documentation

- **SOP**: `SOP_DORMANT_USER_RAG_ENGINE.md`
- **Summary**: `DORMANT_USER_SUMMARY.md`
- **Risks**: `dormant-user/risks-and-guardrails.md`
- **Phase Plan**: `dormant-user/phase-plan.md`
- **Architecture**: `assurex-infra/docs/ARCHITECTURE.md`
- **Profile360 Guide**: `profile-360-backend/DEVELOPER_GUIDE.md`

---

## Definition of Done

- [ ] All acceptance criteria met
- [ ] Code reviewed and approved
- [ ] Unit tests pass (>80% coverage)
- [ ] Integration tests pass
- [ ] Security audit complete
- [ ] Performance benchmarks met
- [ ] Deployed to dev and preprod
- [ ] Documentation updated
- [ ] Stakeholder sign-off obtained
- [ ] Monitoring dashboards live
- [ ] Runbooks created
- [ ] Training materials ready

---

## Stakeholders

- **Product Owner**: [Name]
- **Tech Lead**: [Name]
- **Security Officer**: [Name]
- **QA Lead**: [Name]
- **DevOps**: [Name]

---

## Notes

- Phase A can ship independently (MVP)
- Phase B requires stakeholder budget approval
- AWS Bedrock access request: 2-3 days lead time
- pgvector migration: coordinate with DBA
- Cost monitoring critical for Phase B

---

**Created**: 2025-10-08  
**Last Updated**: 2025-10-08  
**Jira Project**: ATAP  
**Status**: Ready for Sprint Planning
