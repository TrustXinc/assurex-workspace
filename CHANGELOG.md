# AssureX Project Changelog

All notable changes across the AssureX project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2025-10-31] - Excessive Access Detection - Complete ✅

### profile-360-backend
#### Added
- **Excessive Access API Routes** (`app/routes/excessive_access.py`)
  - 6 new REST endpoints for excessive access analytics
  - Multi-tenant query isolation with tenant context
  - Z-score based statistical analysis
  - Integration with Lambda agent insights

#### Endpoints
- `GET /api/excessive-access/summary` - Overall statistics
- `GET /api/excessive-access/users` - User insights list with filtering
- `GET /api/excessive-access/users/{user_id}` - Individual user detail
- `GET /api/excessive-access/risk-distribution` - Risk level distribution
- `GET /api/excessive-access/insights` - Aggregated patterns
- `GET /api/excessive-access/heatmap` - Z-score heatmap data

#### Fixed
- Column name mismatch: `model_used` → `analysis_model`
- Cascading department fallback for meaningful labels (department → cohort → job_title → 'Unknown')
- Response data structure consistency

#### Documentation
- Created `docs/EXCESSIVE_ACCESS_FEATURE.md` - comprehensive feature documentation
- Updated README.md with new endpoints and features
- Updated recent updates section

### trustx
#### Added
- **ExcessiveAccessDashboard Component** (`src/components/Profile360/components/ExcessiveAccessDashboard.js`)
  - Summary cards (total users, risk breakdown by level)
  - User list table (sortable, filterable, paginated)
  - Z-Score heatmap (bubble chart by department/job title)
  - Risk distribution pie chart
  - Peer comparison bar chart
  - Cohort distribution bar chart

- **API Service Integration** (`src/components/Profile360/services/apiService.js`)
  - 6 new methods for excessive access endpoints
  - Proper error handling and loading states
  - Tenant-aware API calls

#### Fixed
- Double-wrapped response issue: `response.data` → `response.data.data`
- ExcessiveAccessDashboard data access paths (3 locations)
- AnalyticsDashboard excessive access count fetch
- User count discrepancy (removed "Users Analyzed" card)
- Removed "Recommendations" placeholder card
- Rebalanced grid layout from 7 to 5 cards (md={2} → md={2.4})

#### Changed
- Analytics Dashboard cleanup
  - Removed confusing "Users Analyzed" card (mixed data sources)
  - Removed non-functional "Recommendations" card
  - All cards now show consistent AI-powered insight counts

#### Documentation
- Updated CLAUDE.md with Excessive Access components
- Updated API endpoints list
- Added recent updates section for Oct 31, 2025

### assurex-insights-engine
#### Working
- Excessive Access Lambda Agent operational in dev environment
- Z-score calculation for group count and app count
- Peer cohort analysis (job_title or department strategy)
- AI-powered justification via AWS Bedrock Claude (Haiku)
- Risk level classification (critical, high, moderate, low)
- Integration with event router pipeline

---

### 🚀 Profile360 Insights Engine Redesign (ALL REPOS) - MAJOR INITIATIVE
**Status**: Design Phase Complete - Ready for Implementation
**Duration**: 12 weeks (6 phases)
**Feature Branch**: `feature/profile360-insights-redesign`

#### Planned - Phase 1 (Weeks 1-2): Foundation
- [ ] Database schema: 10 new tables (normalized data + insights)
- [ ] SQLAlchemy models for all tables
- [ ] Pydantic schemas for API
- [ ] FastAPI endpoint stubs
- [ ] Test framework setup

#### Planned - Phase 2 (Weeks 3-4): Data Ingestion
- [ ] Data ingestion pipeline (S3 → PostgreSQL)
- [ ] Source-specific mappers (Okta, Entra, GitHub, Jira)
- [ ] Duplicate detection and merging
- [ ] S3 event triggers
- [ ] Incremental update support

#### Planned - Phase 3 (Weeks 5-6): Rule-Based Calculations
- [ ] Dormant user detection
- [ ] Access velocity calculation
- [ ] Excessive access detection
- [ ] Behavioral anomaly detection
- [ ] Suspicious activity scoring
- [ ] Overall risk score calculation
- [ ] Daily calculation scheduling

#### Planned - Phase 4 (Weeks 7-8): API Implementation
- [ ] All insights endpoints implemented
- [ ] Query optimization
- [ ] Caching layer
- [ ] Frontend integration
- [ ] End-to-end testing

#### Planned - Phase 5 (Weeks 9-10): AI Integration
- [ ] AWS Bedrock integration
- [ ] Privilege creep detection (AI)
- [ ] Peer comparison (AI)
- [ ] Entitlement misalignment (AI)
- [ ] Compliance violation risk (AI)
- [ ] Cost optimization

#### Planned - Phase 6 (Weeks 11-12): Testing & Optimization
- [ ] Unit tests (>80% coverage)
- [ ] Integration tests
- [ ] Load testing
- [ ] Security audit
- [ ] Documentation
- [ ] Production readiness review

### assurex-insights-engine
- Set up S3 event notifications for auto-triggering
- Deploy to preprod environment
- Add CloudWatch dashboards
- Production deployment

### profile-360-backend
- GraphQL API implementation (separate from insights redesign)
- Comprehensive test suite

### assurex-infra
- Production environment deployment
- ElastiCache Redis deployment
- Advanced monitoring & alerting

### trustx
- Advanced dashboard widgets (non-insights)
- Mobile app development

## [2025-10-10] - Profile360 Insights Redesign - Design Phase Complete

### All Repositories - MAJOR INITIATIVE ✨
#### Added
- **Feature Branches Created** across all 4 repos: `feature/profile360-insights-redesign`
  - trustx: Feature branch ready
  - assurex-infra: Feature branch ready
  - profile-360-backend: Feature branch ready
  - assurex-insights-engine: Feature branch ready

- **Architecture Document**: `profile-360-backend/docs/PROFILE360_INSIGHTS_ARCHITECTURE.md`
  - Complete system architecture
  - 10 database tables (normalized data + insights)
  - Data ingestion pipeline design (S3 → ETL → PostgreSQL)
  - Rule-based calculation algorithms
  - AI-powered metrics design (AWS Bedrock)
  - Overall risk scoring model (0-100 scale)
  - FastAPI endpoint specifications

- **Implementation Plan**: `profile-360-backend/docs/PROFILE360_INSIGHTS_IMPLEMENTATION_PLAN.md`
  - 12-week timeline broken into 6 phases
  - 145+ actionable tasks with acceptance criteria
  - Testing strategy and success metrics
  - Security considerations
  - Performance targets

#### Scope
- **Duration**: 12 weeks (6 phases)
- **Database**: 10 new tables for normalized data and insights
- **Risk Scoring**: 5 rule-based components + 4 AI-powered metrics
- **API Endpoints**: 5 new FastAPI endpoints
- **Data Sources**: Okta, Entra, GitHub, Jira
- **Development Tenant**: trustxinc (758734) - emptied and ready

#### Architecture Highlights
- **Normalized Data Model**: Separate tables for users, activities, apps, groups, signins, permissions
- **Insights Tables**: user_risk_scores, user_insights, risk_score_history, calculation_runs
- **Calculation Engine**: Orchestrates rule-based + AI calculations
- **Risk Components**:
  - Dormant user detection
  - Access velocity (permission changes)
  - Excessive access (over-privileged)
  - Behavioral anomalies (off-hours, rapid signins)
  - Suspicious activities
- **AI Metrics** (AWS Bedrock):
  - Privilege creep detection
  - Peer comparison
  - Entitlement misalignment
  - Compliance violation risk

#### Next Steps
1. Phase 1: Create database migrations (3 migration files)
2. Phase 1: Set up SQLAlchemy models for 10 tables
3. Phase 1: Create Pydantic schemas for API

---

## [2025-10-10] - Hybrid ETL Phase 4 Complete

### assurex-insights-engine - MAJOR UPDATE ✨
#### Added
- **Hybrid ETL Phase 4** - Complete implementation
  - AI field mapping + traditional business logic
  - FK resolution for relationship data (user lookups)
  - Multi-source data extraction (groups + per_group + per_user)
- Group memberships ETL working (35 records processed)
- App assignments ETL framework (awaiting test data)

#### Changed
- Updated tenant configuration (tenant_id: 118230, schema: tenant_118230)
- Improved sso_users table handling (removed `source` column)
- Enhanced error handling for database operations

#### Fixed
- Fixed sso_users schema mismatch
- Corrected tenant_id from 251967 to 118230
- Fixed S3 bucket access permissions

### Testing Results
- ✅ 9 test users inserted into sso_users
- ✅ 35 group memberships loaded successfully
- ✅ FK resolution working correctly
- ✅ Multi-source data extraction verified

## [2025-10-08] - Neo4j Integration Complete

### profile-360-backend - MAJOR UPDATE ✨
#### Added
- **Neo4j Multi-Tenant Integration**
  - Separate Neo4j Aura instance per tenant
  - Knowledge graph query endpoint
  - Graph statistics endpoint
  - Health check for Neo4j connectivity
- Unified secrets architecture (all tenant credentials in one secret)

#### Changed
- Updated Lambda security group (added port 7687 for Neo4j Bolt)
- Migrated to unified secrets pattern: `assurex/{stage}/tenant/{tenant_id}/integrations`
- Deployed to both dev (us-east-1) and preprod (us-east-2)

#### Tenants Configured
- **Dev**: trustx (118230), trustxinc (758734)
- **Preprod**: trustx (168838), trustxinc (328684)

### assurex-infra
#### Changed
- Updated Lambda security group egress rules (port 7687)
- Deployed infrastructure updates to dev + preprod

## [2025-10-06] - Tenant Validation & Access Control

### assurex-infra
#### Added
- **getTenantStatus Query** - Validates tenant exists and is active
- **TenantGuard Component** - Frontend app-level access control
- HTTP status check before GraphQL parsing
- Race condition prevention in validation

#### Changed
- Enhanced error handling for 403 authorization failures
- Improved user experience with clean error pages

### trustx
#### Added
- TenantGuard component for app-wide tenant validation
- Error boundary for blocked tenant access
- User-friendly error messages

## [2025-10-05] - Sync Status Polling

### assurex-infra
#### Added
- **getSyncStatus Query** - Real-time sync status polling support
- ISO 8601 datetime formatting with Z suffix
- Non-nullable response handling
- Sync execution lifecycle tracking

#### Changed
- Enhanced syncIntegration mutation to track sync execution
- Updated sync_executions table with execution_id, duration, records_processed
- Deployed to both dev and preprod with complete parity

### trustx
#### Added
- Real-time sync status polling (2-second intervals, 2-minute max)
- User feedback for sync progress and completion
- Handling for RUNNING, COMPLETED, FAILED, and timeout states

## [2025-10-05] - Dev-Preprod Environment Parity

### assurex-infra
#### Added
- Comprehensive environment comparison and synchronization
- Configuration report documenting parity

#### Changed
- Deployed exact dev Lambda packages to preprod
- Synchronized all 9 Lambda functions byte-for-byte
- Verified all AppSync datasources and resolvers identical

#### Verified
- ✅ All 9 datasources identical
- ✅ All queries/mutations identical
- ✅ All 9 Lambda functions identical
- ✅ All IAM permissions synchronized

## [2025-10-04] - IDP Integration with Async Sync

### assurex-infra
#### Added
- **Multi-IDP Support**: GitHub, Jira, Entra ID, Okta
- **Async Lambda Pattern**: Self-invocation for long-running sync operations
- **S3 Storage**: Raw IDP data with tenant isolation
- **Database Tracking**: Comprehensive sync execution tracking
- **Sensitive Data Masking**: Automatic redaction in CloudWatch logs

#### Security
- Masking of API tokens, secrets, passwords, auth headers
- Applied to all configure and sync Lambda functions

### GraphQL API Status
- 6 Mutations operational: configureGitHub, configureJira, configureEntra, configureOkta, deleteIntegration, syncIntegration
- 4 Queries operational: listIntegrations, getIntegration, getSyncStatus, getTenantStatus

## [2025-09-30] - Phase 2.5: Database Layer Complete

### assurex-infra
#### Added
- **RDS PostgreSQL 17.4** deployment
- Multi-tenant schema architecture
- Automated schema provisioning
- Database migrations (V001-V004)
- Secrets Manager integration
- VPC Flow Logs

#### Infrastructure
- VPC: 10.0.0.0/16 (us-east-1)
- Public subnets: 10.0.1.0/24, 10.0.2.0/24
- Private subnets: 10.0.11.0/24, 10.0.12.0/24
- NAT Gateway, Internet Gateway
- 7 Security Groups

## Version History

### Repository Versions

| Date | assurex-infra | assurex-insights-engine | profile-360-backend | trustx |
|------|---------------|-------------------------|---------------------|--------|
| 2025-10-10 | Phase 3.6 | Phase 4 Complete ✨ | v1.2.0 | v2.3.0 |
| 2025-10-08 | Phase 3.6 | Phase 3 | v1.2.0 (Neo4j) ✨ | v2.3.0 |
| 2025-10-06 | Phase 3.6 ✨ | Phase 3 | v1.1.0 | v2.3.0 ✨ |
| 2025-10-05 | Phase 3.5 | Phase 3 | v1.1.0 | v2.2.0 |
| 2025-10-04 | Phase 3 ✨ | Phase 2 | v1.0.0 | v2.1.0 |
| 2025-09-30 | Phase 2.5 ✨ | - | - | v2.0.0 |

## Breaking Changes

### 2025-10-10
- **assurex-insights-engine**: Tenant ID changed from 251967 to 118230
- **assurex-insights-engine**: sso_users schema changed (removed `source` column)

### 2025-10-08
- **profile-360-backend**: Secrets Manager structure changed to unified format
- **assurex-infra**: Lambda security group updated (added port 7687)

### 2025-10-06
- **trustx**: TenantGuard now blocks entire app for invalid tenants (not just routes)

## Migration Guides

### Upgrading to Hybrid ETL (2025-10-10)
1. Verify tenant_id is correct (use 118230 for trustx in dev)
2. Check sso_users table schema (no `source` column)
3. Upload test data to S3 in proper structure
4. Run manual Lambda invocation to test
5. Verify data in database (tenant_118230 schema)

### Upgrading to Neo4j Integration (2025-10-08)
1. Provision Neo4j Aura instance
2. Update secrets in AWS Secrets Manager:
   ```bash
   aws secretsmanager update-secret \
     --secret-id "assurex/{stage}/tenant/{tenant_id}/integrations" \
     --secret-string '{
       "neo4j": {
         "uri": "neo4j+s://xxxxx.databases.neo4j.io",
         "user": "neo4j",
         "password": "xxxxx",
         "database": "neo4j"
       }
     }'
   ```
3. Update Lambda security group (add port 7687 egress)
4. Deploy profile-360-backend
5. Test connectivity: `/profile360/api/knowledge-graph/health`

---

## Legend
- ✨ Major feature or milestone
- 🐛 Bug fix
- 🔧 Configuration change
- 📝 Documentation update
- ⚡ Performance improvement
- 🔒 Security update

## Notes
- All dates in YYYY-MM-DD format
- Major updates marked with ✨
- Breaking changes clearly documented
- Migration guides provided for major changes

**Last Updated**: 2025-10-10
