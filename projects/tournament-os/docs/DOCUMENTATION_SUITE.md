# Tournament OS Documentation Suite

Status: Documentation planning index.

Purpose:
Define the full documentation set for Tournament Operating System so the project can move from requirements to architecture, implementation, testing, deployment, and operations without losing scope.

This file does not replace the SRS. It maps what documentation exists, what each document is responsible for, and what should be written next.

## Documentation Principle

The SRS defines what the system must do.

Other documents define how the system will be designed, tested, deployed, and operated.

Phase 1 should keep documentation practical and implementation-facing. Do not create large documents that are not needed to build the FastAPI + PostgreSQL backend foundation.

## 1. Requirements Documents

These documents define product behavior and business rules.

### System Requirements Specification

File:

- `spec/SYSTEM_REQUIREMENTS_SPECIFICATION.md`

Purpose:

- Main Phase 1 agreement for system scope.
- Defines users, roles, functional requirements, non-functional requirements, data requirements, external interfaces, acceptance criteria, and open decisions.

Current status:

- Draft exists.
- Includes tournament core, rulesets, registration, check-in, scoring, leaderboard, disputes, evidence, audit log, event outbox, read models, Discord-ready flow, export, and stream-safe live view for OBS/TikTok Live Studio.

Next action:

- Review and approve open decisions before backend code starts.

### MVP Rule And Business Rule Documents

Files:

- `spec/MVP_RULESET.md`
- `spec/GROUP_POINTS_QUALIFIER_SPEC.md`
- `spec/BUSINESS_RULES.md`
- `spec/COMPETITION_RULES_DRAFT.md`
- `spec/RULE_ENGINE_SPEC.md`
- `spec/RULE_CONFIG_EXAMPLES.md`
- `spec/RULESET_SELECTION_AND_CREATION_UI.md`

Purpose:

- Define Golden Spatula tournament assumptions.
- Define Group Points Qualifier scoring and advancement behavior.
- Define configurable ruleset behavior.
- Prevent hardcoded score logic.
- Explain rule preset to locked tournament snapshot flow.

Current status:

- Draft exists.

Next action:

- Confirm the first real event format: 16 or 32 players, solo only, placement points, games per stage, and tie-break order.

### State And Flow Documents

Files:

- `spec/ENUMS_AND_STATES.md`
- `spec/STATE_MACHINE.md`
- `spec/CHECK_IN_SPEC.md`
- `docs/BOT_WEB_FLOW_AND_DATA_SPEC.md`

Purpose:

- Define official statuses and transitions.
- Keep bot, web, and backend behavior consistent.
- Define per-session check-in instead of tournament-wide check-in.

Current status:

- Draft exists.

Next action:

- Use these statuses directly when designing API schemas and database constraints.

## 2. Architecture And Design Documents

These documents translate requirements into implementation design.

### System Architecture Design

Recommended file:

- `docs/SYSTEM_ARCHITECTURE_DESIGN.md`

Purpose:

- Define backend module boundaries.
- Define service layer structure.
- Define how FastAPI, PostgreSQL, read models, event outbox, Discord workers, public pages, and stream-safe overlays connect.
- Define which parts are Phase 1 and which are later.

Current status:

- Not yet written as a single architecture document.
- Partial architecture exists in `docs/POSTGRES_MODULE_FLOW_ANALYSIS.md`, `docs/WEB_APP_DESIGN_AND_INTEGRATION_SPEC.md`, and `spec/PHASE_1_IMPLEMENTATION_DECISIONS.md`.

Next action:

- Create this after SRS approval and before backend skeleton implementation.

Minimum Phase 1 content:

- Context diagram.
- Module diagram.
- Request flow for registration, check-in, score approval, leaderboard update, dispute correction, Discord notification, and stream overlay read.
- Service layer responsibilities.
- Read/write separation.
- Event outbox flow.
- Failure behavior when Discord or realtime is unavailable.

### Database Design Document

Existing files:

- `spec/DATABASE_SCHEMA.md`
- `spec/ER_DIAGRAM.md`
- `spec/IMPLEMENTATION_SCHEMA_PLAN.md`
- `docs/POSTGRES_MODULE_FLOW_ANALYSIS.md`

Purpose:

- Define PostgreSQL tables, relationships, indexes, constraints, and data ownership.
- Define immutable ruleset snapshots.
- Define event outbox and read model tables.

Current status:

- Draft exists.
- Data dictionary is not complete yet.

Next action:

- Convert schema plan into a full data dictionary before Alembic migrations.

Minimum Phase 1 content:

- Table name.
- Column name.
- Data type.
- Nullable or required.
- Default value.
- Unique constraints.
- Foreign keys.
- Indexes.
- Ownership module.
- Privacy classification.

### API Specification

Existing files:

- `spec/API_CONTRACT_PHASE_1.md`
- `spec/API_SPECIFICATION.md`

Purpose:

- Define FastAPI endpoints, request bodies, response bodies, error codes, public/private serializers, and stream-safe endpoints.

Current status:

- Phase 1 draft exists.
- Stream-safe endpoints for OBS/TikTok Live Studio are included.

Next action:

- Convert confirmed contract into FastAPI Pydantic schemas and OpenAPI docs during implementation.

Important rule:

- OpenAPI generated by FastAPI should become the live API reference, but the Markdown contract remains the planning source until code exists.

## 3. Quality Assurance And Testing Documents

These documents prove the implementation matches the SRS.

### Test Plan And Test Cases

Recommended file:

- `docs/TEST_PLAN_PHASE_1.md`

Purpose:

- Define test cases before or alongside backend implementation.
- Cover scoring, privacy, state transitions, concurrency, and public stream-safe data.

Current status:

- Not yet written as a standalone test plan.
- Required tests are listed in `spec/API_CONTRACT_PHASE_1.md` and SRS acceptance criteria.

Next action:

- Create before writing the main service layer.

Minimum Phase 1 test areas:

- Duplicate registration.
- Duplicate game UID.
- Capacity and waitlist behavior.
- Registration approval.
- Session-level check-in.
- Old Discord button/idempotent check-in.
- Placement duplicate rejection.
- Score calculation from locked ruleset snapshot.
- Penalty requires reason.
- Pending scores excluded from public leaderboard.
- Approved scores update leaderboard snapshot.
- Dispute acceptance creates correction and audit log.
- Public endpoints exclude private fields.
- Stream-safe overlay endpoints exclude private fields.
- Rule lock prevents normal edits.
- Event outbox records important mutations.
- Concurrency-sensitive operations use constraints/transactions.

## 4. DevOps And Deployment Documents

These documents explain how to run and recover the system.

### Deployment Guide

Recommended file:

- `docs/DEPLOYMENT_GUIDE.md`

Purpose:

- Explain local development, environment variables, Docker or server setup, database migration, and production process.

Current status:

- Not yet written.

Next action:

- Write after backend skeleton exists.

Minimum Phase 1 content:

- Local setup.
- Required environment variables without secret values.
- PostgreSQL setup.
- Alembic migration commands.
- FastAPI run command.
- Test command.
- Deployment target notes.
- Rollback notes.

### Backup And Recovery Plan

Recommended file:

- `docs/BACKUP_AND_RECOVERY_PLAN.md`

Purpose:

- Protect PostgreSQL as the source of truth during real tournaments.

Current status:

- Not yet written.

Next action:

- Write before first real live tournament.

Minimum Phase 1 content:

- Database backup frequency.
- Manual export fallback.
- Recovery time target.
- Recovery point target.
- What to do if server fails during a live round.
- What data must be preserved for audit.

## 5. User And Operations Manuals

These documents turn system behavior into practical instructions for people running the event.

### Tournament Admin And Referee Guide

Recommended file:

- `docs/ADMIN_REFEREE_GUIDE.md`

Purpose:

- Explain how admins create tournaments, lock rules, approve registrations, generate groups, open check-in, enter scores, approve scores, resolve disputes, and export results.

Current status:

- Not yet written.

Next action:

- Write after admin flow is implemented or mocked.

### Caster And Streamer Integration Guide

Recommended file:

- `docs/CASTER_STREAMER_GUIDE.md`

Purpose:

- Explain how to use stream-safe leaderboard/group URLs in OBS Browser Source and TikTok Live Studio browser/web source.

Current status:

- Not yet written as a guide.
- Requirements and API endpoints exist in SRS and `spec/API_CONTRACT_PHASE_1.md`.

Next action:

- Write when the stream-safe page URL format is finalized.

Minimum content:

- Which URL to copy.
- OBS Browser Source setup.
- TikTok Live Studio browser/web source setup.
- Recommended width and height.
- Refresh behavior.
- What data is safe to show.
- What to do if the overlay does not update.

### Discord Operations Guide

Existing related file:

- `docs/DISCORD_OPERATIONS_AND_PLUGIN_SPEC.md`

Recommended future file:

- `docs/DISCORD_OPERATOR_GUIDE.md`

Purpose:

- Explain how Discord notifications, player status, and later bot commands should be used during operations.

Current status:

- Technical spec exists.
- User-facing guide not yet written.

Next action:

- Write after Discord integration is implemented.

## Recommended Documentation Build Order

1. Approve SRS and Phase 1 open decisions.
2. Write `docs/SYSTEM_ARCHITECTURE_DESIGN.md`.
3. Complete data dictionary in database design docs.
4. Finalize `spec/API_CONTRACT_PHASE_1.md`.
5. Write `docs/TEST_PLAN_PHASE_1.md`.
6. Start backend implementation.
7. Generate and maintain FastAPI OpenAPI docs.
8. Write deployment guide after the backend skeleton runs locally.
9. Write admin/referee and caster/streamer guides after usable screens or endpoints exist.
10. Write backup/recovery plan before the first real live tournament.

## Current Coverage Summary

| Documentation Area | Status | Main Files |
| :--- | :---: | :--- |
| SRS | Draft exists | `spec/SYSTEM_REQUIREMENTS_SPECIFICATION.md` |
| Business rules | Draft exists | `spec/MVP_RULESET.md`, `spec/BUSINESS_RULES.md`, `spec/RULE_ENGINE_SPEC.md` |
| State machines | Draft exists | `spec/ENUMS_AND_STATES.md`, `spec/STATE_MACHINE.md`, `spec/CHECK_IN_SPEC.md` |
| Database design | Partial draft | `spec/DATABASE_SCHEMA.md`, `spec/ER_DIAGRAM.md`, `spec/IMPLEMENTATION_SCHEMA_PLAN.md` |
| API contract | Draft exists | `spec/API_CONTRACT_PHASE_1.md` |
| Web design | Draft exists | `docs/WEB_APP_DESIGN_AND_INTEGRATION_SPEC.md` |
| Discord operations | Draft exists | `docs/DISCORD_OPERATIONS_AND_PLUGIN_SPEC.md` |
| Evidence and roles | Draft exists | `docs/EVIDENCE_AND_DISCORD_ROLE_ANALYSIS.md` |
| System architecture | Missing standalone doc | recommended `docs/SYSTEM_ARCHITECTURE_DESIGN.md` |
| Test plan | Missing standalone doc | recommended `docs/TEST_PLAN_PHASE_1.md` |
| Deployment guide | Missing | recommended `docs/DEPLOYMENT_GUIDE.md` |
| Backup/recovery | Missing | recommended `docs/BACKUP_AND_RECOVERY_PLAN.md` |
| Admin/referee manual | Missing | recommended `docs/ADMIN_REFEREE_GUIDE.md` |
| Caster/streamer guide | Missing | recommended `docs/CASTER_STREAMER_GUIDE.md` |

## Definition Of Done For Documentation Before Coding

Before backend code starts, these must be true:

- SRS open decisions are reviewed.
- Architecture boundaries are clear.
- Database tables and constraints are clear enough for Alembic migrations.
- API request/response contracts are clear enough for Pydantic schemas.
- Test plan covers scoring, privacy, state transitions, concurrency, and stream-safe public data.
- Remaining later-scope docs are listed, not treated as blockers.
