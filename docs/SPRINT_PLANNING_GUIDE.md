# Dormant User Detection - Sprint Planning Guide

**Feature**: Dormant User Detection & AI Insights  
**Parent Story**: ATAP-XXX  
**Total Duration**: 8 weeks (2 sprints for Phase A, 2.5 sprints for Phase B)

---

## Sprint Overview

### Sprint Structure
- **Sprint Duration**: 2 weeks
- **Total Sprints**: 4-5 sprints
- **Team Composition**: Backend (2), Frontend (2), DevOps (1), QA (1)

### Sprint Breakdown

| Sprint | Phase | Focus | Story Points | Key Deliverables |
|--------|-------|-------|--------------|------------------|
| **Sprint 1** | Phase A | Backend + DB | 7 pts | API endpoint, database setup |
| **Sprint 2** | Phase A | Frontend + QA | 9 pts | UI component, testing, preprod deployment |
| **Sprint 3** | Phase B | AI Foundation | 13 pts | pgvector, Bedrock, embeddings |
| **Sprint 4** | Phase B | RAG Engine | 13 pts | Analysis service, enhanced API |
| **Sprint 5** | Phase B | UI + Finalization | 13 pts | AI dashboard, testing, deployment |

**Total**: 55 story points across 5 sprints

---

## Sprint 1: Phase A Backend (Weeks 1-2)

### Sprint Goal
Implement backend infrastructure for basic dormant user detection with configurable threshold.

### Sprint Stories

#### ATAP-XXX-1: Infra - Confirm tenant settings + indices
- **Story Points**: 2
- **Assignee**: Backend Engineer
- **Priority**: Highest
- **Sprint Day 1-2**

**Tasks**:
- [ ] Day 1 AM: Verify `tenant_settings` table schema
- [ ] Day 1 PM: Create migration if needed
- [ ] Day 2 AM: Add index on `last_active_at`
- [ ] Day 2 PM: Performance test, documentation

**Dependencies**: None

**Done Criteria**: Migration tested in dev, index created, query < 200ms

---

#### ATAP-XXX-2: Backend - Add dormant user endpoint
- **Story Points**: 5
- **Assignee**: Backend Engineer
- **Priority**: Highest
- **Sprint Day 3-7**

**Tasks**:
- [ ] Day 3: Create service layer (`insights_service.py`)
- [ ] Day 4: Implement query logic
- [ ] Day 5: Create API endpoint + schemas
- [ ] Day 6: Write unit tests
- [ ] Day 7: Code review, merge

**Dependencies**: ATAP-XXX-1 (DB schema ready)

**Done Criteria**: Endpoint functional, tests pass (>80% coverage), code reviewed

---

#### ATAP-XXX-3: Backend - Deploy & smoke-test dev
- **Story Points**: 1 (carried to Sprint 2 if needed)
- **Assignee**: DevOps Engineer
- **Priority**: High
- **Sprint Day 8-9**

**Tasks**:
- [ ] Day 8 AM: Deploy to dev
- [ ] Day 8 PM: Smoke tests
- [ ] Day 9: Performance benchmark, document

**Dependencies**: ATAP-XXX-2 (endpoint code ready)

**Done Criteria**: Deployed, smoke tests passed, benchmarks recorded

---

### Sprint 1 Capacity Planning

| Team Member | Role | Capacity (pts/sprint) | Assigned |
|-------------|------|----------------------|----------|
| Engineer 1 | Backend | 8 pts | 7 pts (XXX-1, XXX-2) |
| Engineer 2 | Backend | 8 pts | 0 pts (available) |
| Engineer 3 | Frontend | 8 pts | 0 pts (not needed yet) |
| Engineer 4 | Frontend | 8 pts | 0 pts (not needed yet) |
| Engineer 5 | DevOps | 4 pts | 1 pt (XXX-3) |
| Engineer 6 | QA | 4 pts | 0 pts (not needed yet) |

**Total Assigned**: 8 pts  
**Total Capacity**: 40 pts  
**Utilization**: 20% (other work continues)

---

### Sprint 1 Ceremonies

**Sprint Planning** (Day 1, 1 hour)
- Review Phase A requirements
- Discuss technical approach
- Assign stories
- Identify risks

**Daily Standups** (15 min each day)
- What did you do yesterday?
- What will you do today?
- Any blockers?

**Mid-Sprint Check-in** (Day 5, 30 min)
- Review progress
- Adjust if needed
- Prepare for demo

**Sprint Review/Demo** (Day 10, 1 hour)
- Demo API endpoint
- Show database schema
- Review test results

**Sprint Retrospective** (Day 10, 30 min)
- What went well?
- What didn't go well?
- Action items for next sprint

---

## Sprint 2: Phase A Frontend + QA (Weeks 2-3)

### Sprint Goal
Complete Phase A MVP with frontend UI and full testing, deploy to preprod.

### Sprint Stories

#### ATAP-XXX-4: Frontend - DormantUsers table component
- **Story Points**: 5
- **Assignee**: Frontend Engineer
- **Priority**: Highest
- **Sprint Day 1-6**

**Tasks**:
- [ ] Day 1-2: Create component structure
- [ ] Day 3-4: Implement table + controls
- [ ] Day 5: API integration
- [ ] Day 6: Testing, Storybook

**Dependencies**: ATAP-XXX-3 (API deployed)

**Done Criteria**: Component works, tests pass, Storybook story created

---

#### ATAP-XXX-5: Phase A - QA & Documentation
- **Story Points**: 3
- **Assignee**: QA Engineer + Tech Writer
- **Priority**: High
- **Sprint Day 7-10**

**Tasks**:
- [ ] Day 7: Regression testing
- [ ] Day 8: Multi-tenant + performance tests
- [ ] Day 9: Documentation updates
- [ ] Day 10: Preprod deployment, sign-off

**Dependencies**: ATAP-XXX-4 (UI ready)

**Done Criteria**: All tests passed, docs updated, preprod deployed, stakeholder sign-off

---

### Sprint 2 Capacity Planning

| Team Member | Role | Capacity (pts/sprint) | Assigned |
|-------------|------|----------------------|----------|
| Engineer 1 | Backend | 8 pts | 0 pts (support only) |
| Engineer 2 | Backend | 8 pts | 1 pt (XXX-5 support) |
| Engineer 3 | Frontend | 8 pts | 5 pts (XXX-4) |
| Engineer 4 | Frontend | 8 pts | 0 pts (available) |
| Engineer 5 | DevOps | 4 pts | 1 pt (XXX-5 deployment) |
| Engineer 6 | QA | 4 pts | 3 pts (XXX-5) |

**Total Assigned**: 10 pts  
**Total Capacity**: 40 pts  
**Utilization**: 25%

---

### Phase A Milestone Checkpoint

**By End of Sprint 2**:
- ✅ Working API endpoint in dev & preprod
- ✅ Functional UI component
- ✅ All tests passed
- ✅ Documentation updated
- ✅ Stakeholder sign-off obtained

**Go/No-Go Decision Point**:
- Proceed to Phase B if approved and budget confirmed
- OR stop here (Phase A MVP is production-ready)

---

## Sprint 3: Phase B AI Foundation (Weeks 4-5)

### Sprint Goal
Set up AI infrastructure: pgvector, Bedrock, embeddings pipeline.

### Sprint Stories

#### ATAP-XXX-6: Infra - pgvector & schema migrations
- **Story Points**: 5
- **Assignee**: Backend Engineer
- **Priority**: Highest
- **Sprint Day 1-5**

**Pre-requisites**: 
- ⚠️ AWS Bedrock model access requested (Week 1 of Phase A)

**Done Criteria**: pgvector enabled, tables created, tested

---

#### ATAP-XXX-7: Infra - Bedrock/IAM setup
- **Story Points**: 3
- **Assignee**: DevOps Engineer
- **Priority**: Highest
- **Sprint Day 1-3**

**Parallel with XXX-6**

**Done Criteria**: Bedrock access approved, IAM configured, monitoring set up

---

#### ATAP-XXX-8: Infra - EventBridge/S3 wiring
- **Story Points**: 2
- **Assignee**: DevOps Engineer
- **Priority**: Medium
- **Sprint Day 4-5**

**Done Criteria**: S3 events trigger Lambda

---

#### ATAP-XXX-9: Lambda layer updates
- **Story Points**: 3
- **Assignee**: Backend Engineer
- **Priority**: High
- **Sprint Day 6-7**

**Done Criteria**: Layer includes pgvector, deployed, tested

---

### Sprint 3 Capacity Planning

| Team Member | Role | Capacity (pts/sprint) | Assigned |
|-------------|------|----------------------|----------|
| Engineer 1 | Backend | 8 pts | 8 pts (XXX-6, XXX-9) |
| Engineer 2 | Backend | 8 pts | 0 pts (available) |
| Engineer 3 | Frontend | 8 pts | 0 pts (not needed yet) |
| Engineer 4 | Frontend | 8 pts | 0 pts (not needed yet) |
| Engineer 5 | DevOps | 4 pts | 5 pts (XXX-7, XXX-8) |
| Engineer 6 | QA | 4 pts | 0 pts (not needed yet) |

**Total Assigned**: 13 pts  
**Total Capacity**: 40 pts  
**Utilization**: 32.5%

---

## Sprint 4: Phase B RAG Engine (Weeks 5-7)

### Sprint Goal
Implement embedding generation and RAG analysis engine with Bedrock Claude.

### Sprint Stories

#### ATAP-XXX-10: Backend - Embedding pipeline
- **Story Points**: 5
- **Assignee**: Backend Engineer
- **Priority**: Highest
- **Sprint Day 1-5**

**Done Criteria**: Embeddings generated from S3 data, stored in DB

---

#### ATAP-XXX-11: Backend - Dormant/RAG analysis service
- **Story Points**: 8
- **Assignee**: Backend Engineer (both engineers)
- **Priority**: Highest
- **Sprint Day 3-10**

**Parallel with XXX-10 after Day 3**

**Done Criteria**: RAG analysis working, insights stored, < 5s per user

---

### Sprint 4 Capacity Planning

| Team Member | Role | Capacity (pts/sprint) | Assigned |
|-------------|------|----------------------|----------|
| Engineer 1 | Backend | 8 pts | 5 pts (XXX-10) |
| Engineer 2 | Backend | 8 pts | 8 pts (XXX-11) |
| Engineer 3 | Frontend | 8 pts | 0 pts (planning for Sprint 5) |
| Engineer 4 | Frontend | 8 pts | 0 pts (planning for Sprint 5) |
| Engineer 5 | DevOps | 4 pts | 0 pts (support only) |
| Engineer 6 | QA | 4 pts | 0 pts (planning for Sprint 5) |

**Total Assigned**: 13 pts  
**Total Capacity**: 40 pts  
**Utilization**: 32.5%

---

## Sprint 5: Phase B UI + Finalization (Weeks 7-8)

### Sprint Goal
Complete AI dashboard UI, comprehensive testing, deploy to preprod, obtain sign-off.

### Sprint Stories

#### ATAP-XXX-12: Backend - API enhancements
- **Story Points**: 5
- **Assignee**: Backend Engineer
- **Priority**: Highest
- **Sprint Day 1-4**

**Done Criteria**: Enhanced API endpoints deployed

---

#### ATAP-XXX-13: Frontend - AI dashboard
- **Story Points**: 8
- **Assignee**: Frontend Engineers (both)
- **Priority**: Highest
- **Sprint Day 1-7**

**Parallel with XXX-12**

**Done Criteria**: AI dashboard functional, all features working

---

#### ATAP-XXX-14: Cost & performance validation
- **Story Points**: 3
- **Assignee**: Backend + DevOps
- **Priority**: High
- **Sprint Day 5-7**

**Done Criteria**: Cost < $10/tenant, performance benchmarks met

---

#### ATAP-XXX-15: Security & compliance review
- **Story Points**: 3
- **Assignee**: Security Engineer + QA
- **Priority**: High
- **Sprint Day 6-8**

**Done Criteria**: Security audit passed, compliance verified

---

#### ATAP-XXX-16: Phase B - QA, docs, deployment
- **Story Points**: 5
- **Assignee**: QA + Tech Writer + DevOps
- **Priority**: Highest
- **Sprint Day 8-10**

**Done Criteria**: All tests passed, docs updated, preprod deployed, UAT sign-off

---

### Sprint 5 Capacity Planning

| Team Member | Role | Capacity (pts/sprint) | Assigned |
|-------------|------|----------------------|----------|
| Engineer 1 | Backend | 8 pts | 6 pts (XXX-12, XXX-14) |
| Engineer 2 | Backend | 8 pts | 2 pts (XXX-14 support) |
| Engineer 3 | Frontend | 8 pts | 8 pts (XXX-13) |
| Engineer 4 | Frontend | 8 pts | 0 pts (XXX-13 support) |
| Engineer 5 | DevOps | 4 pts | 3 pts (XXX-14, XXX-16) |
| Engineer 6 | QA | 4 pts | 5 pts (XXX-15, XXX-16) |

**Total Assigned**: 24 pts  
**Total Capacity**: 40 pts  
**Utilization**: 60%

---

## Post-Sprint 5: Production Preparation

### ATAP-XXX-17: Rollout readiness & production plan
- **Story Points**: 2
- **Duration**: 1 week (outside sprint cycle)
- **Assignees**: Tech Lead + Product Owner

**Tasks**:
- Create production deployment plan
- Schedule deployment window
- Prepare rollback procedures
- Coordinate with ops team

**Done Criteria**: Ready for production deployment

---

## Sprint Planning Tips

### For Each Sprint

**Week Before Sprint**:
- [ ] Groom stories with team
- [ ] Clarify acceptance criteria
- [ ] Identify dependencies
- [ ] Estimate story points (planning poker)

**Sprint Planning Meeting**:
- [ ] Review sprint goal
- [ ] Assign stories to team members
- [ ] Break down stories into tasks
- [ ] Identify risks and blockers
- [ ] Confirm team capacity

**During Sprint**:
- [ ] Daily standups (15 min)
- [ ] Update story status daily
- [ ] Raise blockers immediately
- [ ] Pair program on complex tasks
- [ ] Code review within 1 day

**End of Sprint**:
- [ ] Demo working software
- [ ] Retrospective (what to improve)
- [ ] Close completed stories
- [ ] Move incomplete to next sprint

---

## Risk Management

### High-Risk Items

**Sprint 1-2 (Phase A)**:
- ⚠️ Database performance issues → Mitigation: Load test early
- ⚠️ Tenant isolation bugs → Mitigation: Security testing in Sprint 2

**Sprint 3 (Phase B Foundation)**:
- ⚠️ Bedrock model access delayed → Mitigation: Request in Sprint 1
- ⚠️ pgvector installation issues → Mitigation: Test in dev early

**Sprint 4 (RAG Engine)**:
- ⚠️ AI insights quality poor → Mitigation: Human review loop, tuning
- ⚠️ Performance < 5s target → Mitigation: Optimization, caching

**Sprint 5 (Finalization)**:
- ⚠️ Cost overruns → Mitigation: Strict monitoring, batching
- ⚠️ Security issues found late → Mitigation: Security review in Sprint 5

---

## Definition of Done (DoD)

### For Each Story

- [ ] Code complete and follows standards
- [ ] Unit tests written (>80% coverage)
- [ ] Integration tests pass
- [ ] Code reviewed and approved
- [ ] Documentation updated
- [ ] Deployed to dev environment
- [ ] Smoke tested in dev
- [ ] Acceptance criteria met
- [ ] Product owner approved

### For Each Sprint

- [ ] All stories meet DoD
- [ ] Sprint goal achieved
- [ ] Demo completed
- [ ] Retrospective held
- [ ] Next sprint planned

---

## Communication Plan

### Daily
- **Standup**: 9 AM, 15 min
- **Slack**: #atap-dormant-user channel

### Weekly
- **Sprint Review**: Friday 3 PM
- **Sprint Planning**: Monday 10 AM (every 2 weeks)
- **Retrospective**: Friday 4 PM (every 2 weeks)

### Ad-Hoc
- **Technical Discussions**: As needed (schedule in Slack)
- **Blocker Resolution**: Escalate to tech lead immediately

---

## Success Metrics

### Velocity Tracking

| Sprint | Planned Points | Completed Points | Velocity |
|--------|----------------|------------------|----------|
| Sprint 1 | 8 | TBD | TBD |
| Sprint 2 | 8 | TBD | TBD |
| Sprint 3 | 13 | TBD | TBD |
| Sprint 4 | 13 | TBD | TBD |
| Sprint 5 | 13 | TBD | TBD |

**Target Average Velocity**: 11 points/sprint

### Quality Metrics

- **Bug Count**: Target < 5 bugs per sprint
- **Test Coverage**: Target > 80%
- **Code Review Time**: Target < 24 hours
- **Build Success Rate**: Target > 95%

---

## Appendix: Story Point Reference

**1 Point**: < 4 hours
- Simple config change
- Documentation update
- Minor bug fix

**2 Points**: 4-8 hours
- Small feature
- Database index
- Simple Lambda function

**3 Points**: 1-1.5 days
- Medium feature
- API endpoint with tests
- UI component

**5 Points**: 2-3 days
- Complex feature
- Multiple files/services
- Comprehensive testing

**8 Points**: 3-5 days
- Very complex feature
- Cross-cutting changes
- Multiple integrations

**13 Points**: 1-2 weeks
- Epic-level work
- Should be broken down further

---

**Created**: 2025-10-08  
**Last Updated**: 2025-10-08  
**Owner**: Engineering Team  
**Status**: Ready for Sprint Planning
