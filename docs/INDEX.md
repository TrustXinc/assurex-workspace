# AssureX Documentation Index

**Last Updated**: October 10, 2025

This index provides a complete map of all documentation across the AssureX workspace.

## 📁 Documentation Structure

```
assurex/ (workspace root)
├── docs/                                    # Cross-repo project docs
│   ├── INDEX.md                            # This file
│   ├── JIRA_PARENT_STORY.md                # Jira stories
│   ├── JIRA_SUBTASKS.md                    # Jira subtasks
│   ├── SPRINT_PLANNING_GUIDE.md            # Sprint planning
│   └── IMPLEMENTATION_CHECKLIST.md         # Implementation tracking
│
├── CLAUDE.md                               # 🤖 AI assistant guide (START HERE)
├── PROJECT_STATUS.md                        # Overall project status
├── CHANGELOG.md                            # Cross-repo changelog
├── DEVELOPMENT_ROADMAP.md                  # Feature roadmap
└── README.md                               # Workspace guide

assurex-infra/
├── README.md                               # Infrastructure overview
├── docs/                                   # Infrastructure docs
│   ├── ARCHITECTURE.md
│   ├── NETWORK_DESIGN.md
│   ├── DEPLOYMENT_GUIDE.md
│   ├── RDS_IMPLEMENTATION_PLAN.md
│   └── ... (20+ documentation files)
└── CLAUDE.md                               # AI assistant guide

assurex-insights-engine/
├── README.md                               # Insights engine overview
└── docs/                                   # ETL & AI docs
    ├── insights-engine-event-patterns.md
    └── insights-engine-multitenant-analysis.md

profile-360-backend/
├── README.md                               # Profile360 API guide
├── CLAUDE.md                               # AI assistant guide
└── docs/                                   # Feature docs
    ├── DORMANT_USER_PHASE_A_CHECKPOINT.md
    ├── DORMANT_USERS_CHECKPOINT.md
    ├── DORMANT_USER_SUMMARY.md
    ├── DORMANT_USER_ENHANCEMENTS_TODO.md
    ├── DORMANT_USER_TESTING_GUIDE.md
    ├── SOP_DORMANT_USER_RAG_ENGINE.md
    ├── PHASE_A_IMPLEMENTATION_CHECKLIST.md
    ├── PROFILE360_NEO4J_CHECKPOINT.md
    ├── SESSION_COMPLETE_SUMMARY.md
    └── test-dormant-users.sh

trustx/
├── README.md                               # Frontend overview
└── docs/                                   # Frontend docs
    └── COMPONENTS.md                       # Component library
```

## 📊 Documentation by Category

### Workspace-Level Documentation

**Location**: `/Users/ramakesani/Documents/assurex/`

| Document | Description |
|----------|-------------|
| [CLAUDE.md](../CLAUDE.md) | 🤖 **START HERE** - Complete AI assistant guide covering all 4 repos |
| [PROJECT_STATUS.md](../PROJECT_STATUS.md) | Overall status of all repos, deployments, metrics |
| [CHANGELOG.md](../CHANGELOG.md) | Version history and changes across all repos |
| [DEVELOPMENT_ROADMAP.md](../DEVELOPMENT_ROADMAP.md) | Quarterly roadmap and feature planning |
| [README.md](../README.md) | Workspace guide and getting started |
| [CHECKPOINT_PROFILE360_VECTORIZATION.md](../CHECKPOINT_PROFILE360_VECTORIZATION.md) | 🔖 Profile360 vectorization investigation checkpoint (Oct 10, 2025) |

### Project Management

**Location**: `/Users/ramakesani/Documents/assurex/docs/`

| Document | Description |
|----------|-------------|
| JIRA_PARENT_STORY.md | Jira parent stories and epics |
| JIRA_SUBTASKS.md | Detailed Jira subtasks |
| SPRINT_PLANNING_GUIDE.md | Sprint planning procedures |
| IMPLEMENTATION_CHECKLIST.md | Implementation tracking |

### Infrastructure Documentation

**Location**: `assurex-infra/`

- [README.md](../assurex-infra/README.md) - Quick start and overview
- [CLAUDE.md](../assurex-infra/CLAUDE.md) - AI assistant guide
- [docs/](../assurex-infra/docs/) - Comprehensive infrastructure docs (20+ files)
  - Architecture, networking, deployment, database, security, etc.
  - [PROFILE360_EXECUTION_ORDER.md](../assurex-infra/docs/PROFILE360_EXECUTION_ORDER.md) - 📘 Profile360 function execution guide (NEW)
  - [PROFILE360_README.md](../assurex-infra/docs/PROFILE360_README.md) - Profile360 quick reference (NEW)

### Insights Engine Documentation

**Location**: `assurex-insights-engine/`

- [README.md](../assurex-insights-engine/README.md) - ETL & AI insights overview
- [docs/insights-engine-event-patterns.md](../assurex-insights-engine/docs/insights-engine-event-patterns.md) - Event handling
- [docs/insights-engine-multitenant-analysis.md](../assurex-insights-engine/docs/insights-engine-multitenant-analysis.md) - Multi-tenant architecture

### Profile360 Backend Documentation

**Location**: `profile-360-backend/`

- [README.md](../profile-360-backend/README.md) - API overview and setup
- [CLAUDE.md](../profile-360-backend/CLAUDE.md) - AI assistant guide
- [docs/](../profile-360-backend/docs/) - Feature documentation
  - Dormant user detection
  - Neo4j knowledge graph
  - Testing guides
  - Session checkpoints

### Frontend Documentation

**Location**: `trustx/`

- [README.md](../trustx/README.md) - Frontend overview
- [docs/COMPONENTS.md](../trustx/docs/COMPONENTS.md) - Component library

## 🔍 Finding Documentation

### By Topic

**Getting Started**:
- Workspace setup: [README.md](../README.md)
- Infrastructure: [assurex-infra/README.md](../assurex-infra/README.md)
- Profile360 API: [profile-360-backend/README.md](../profile-360-backend/README.md)
- Insights Engine: [assurex-insights-engine/README.md](../assurex-insights-engine/README.md)

**Architecture**:
- System architecture: [assurex-infra/docs/ARCHITECTURE.md](../assurex-infra/docs/ARCHITECTURE.md)
- Network design: [assurex-infra/docs/NETWORK_DESIGN.md](../assurex-infra/docs/NETWORK_DESIGN.md)
- Database schema: [assurex-infra/docs/RDS_IMPLEMENTATION_PLAN.md](../assurex-infra/docs/RDS_IMPLEMENTATION_PLAN.md)

**Features**:
- **Profile360 Pipeline**: [assurex-infra/docs/PROFILE360_EXECUTION_ORDER.md](../assurex-infra/docs/PROFILE360_EXECUTION_ORDER.md) - Complete execution guide
- Dormant users: [profile-360-backend/docs/DORMANT_USER_PHASE_A_CHECKPOINT.md](../profile-360-backend/docs/DORMANT_USER_PHASE_A_CHECKPOINT.md)
- Neo4j integration: [profile-360-backend/docs/PROFILE360_NEO4J_CHECKPOINT.md](../profile-360-backend/docs/PROFILE360_NEO4J_CHECKPOINT.md)
- Hybrid ETL: [assurex-insights-engine/README.md](../assurex-insights-engine/README.md)

**Deployment**:
- Infrastructure deployment: [assurex-infra/docs/DEPLOYMENT_GUIDE.md](../assurex-infra/docs/DEPLOYMENT_GUIDE.md)
- Database setup: [assurex-infra/docs/RDS_DEPLOYMENT_INSTRUCTIONS.md](../assurex-infra/docs/RDS_DEPLOYMENT_INSTRUCTIONS.md)

**Testing**:
- Dormant user testing: [profile-360-backend/docs/DORMANT_USER_TESTING_GUIDE.md](../profile-360-backend/docs/DORMANT_USER_TESTING_GUIDE.md)
- ETL testing: Check [assurex-insights-engine/README.md](../assurex-insights-engine/README.md)

### By Repository

```bash
# View all infrastructure docs
ls -la assurex-infra/docs/

# View Profile360 docs
ls -la profile-360-backend/docs/

# View Insights Engine docs
ls -la assurex-insights-engine/docs/

# View workspace docs
ls -la docs/
```

## 📝 Documentation Standards

### File Naming
- Use descriptive names: `FEATURE_NAME_TYPE.md`
- Use UPPERCASE for major docs: `README.md`, `CHANGELOG.md`
- Use snake_case or kebab-case for feature docs

### Location Guidelines
- **Workspace root**: Cross-repo documentation only
- **Repository root**: README.md, CLAUDE.md (AI guide)
- **Repository docs/**: Feature-specific documentation
- **Workspace docs/**: Project management and cross-cutting concerns

### Update Frequency
- **PROJECT_STATUS.md**: Update after major milestones
- **CHANGELOG.md**: Update with each significant change
- **DEVELOPMENT_ROADMAP.md**: Review monthly
- **Feature docs**: Update as features evolve

## 🔄 Recent Updates

### October 10, 2025 - Profile360 Vectorization Documentation

**New Documentation Added**:
- **CHECKPOINT_PROFILE360_VECTORIZATION.md** - Workspace-level checkpoint for vectorization investigation
- **assurex-infra/docs/PROFILE360_EXECUTION_ORDER.md** - Complete guide for Profile360 function execution (20+ pages)
- **assurex-infra/docs/PROFILE360_README.md** - Profile360 quick reference guide
- Investigation summary and automation scripts

**What was accomplished**:
- Investigated and fixed vectorization Lambda issue (embeddings weren't being generated)
- Documented complete 3-step pipeline: ETL → Vectorization → Analytics
- Created automation scripts for pipeline execution
- Verified all 5 users have real AWS Bedrock Titan embeddings
- Tested analytics pipeline - working correctly

### October 10, 2025 - Documentation Reorganization

Reorganized documentation for better structure:

**Moved to profile-360-backend/docs/**:
- All dormant user documentation
- Neo4j checkpoint documents
- Session summaries
- Test scripts

**Moved to assurex-insights-engine/docs/**:
- Insights engine event patterns
- Multi-tenant architecture analysis

**Moved to workspace docs/**:
- Jira stories and subtasks
- Sprint planning guides
- Cross-repo implementation checklists

**Archived**:
- `dormant-user/` directory (README points to new locations)

## 🆘 Help

- **Can't find a document?** Check this index or search across repos
- **Need to add documentation?** Follow location guidelines above
- **Documentation outdated?** Create an issue in the relevant repository

---

**Maintained By**: AssureX Engineering Team
**Last Updated**: October 10, 2025
