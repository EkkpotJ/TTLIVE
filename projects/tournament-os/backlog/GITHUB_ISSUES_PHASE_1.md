# GitHub Issues Phase 1

Status: Ready-to-create issue draft.

Repository target:

- `https://github.com/Aalika-Ss1/TTLIVE.git`

Purpose:
Convert the approved Tournament OS SRS and supporting specs into GitHub Issues grouped by Epic.

Created issue backbone:

- `#1` `[Tournament OS] Phase 1 System Planning`
- `#2` `[Tournament OS][Epic] Documentation Freeze And Architecture`
- `#3` `[Tournament OS][Epic] Identity, Permissions, And Tokens`
- `#4` `[Tournament OS][Epic] Tournament Core And Rulesets`
- `#5` `[Tournament OS][Epic] Registration And Check-In`
- `#6` `[Tournament OS][Epic] Group Generation And Lobby Management`
- `#7` `[Tournament OS][Epic] Scoring, Leaderboard, Advancement, And Disputes`
- `#8` `[Tournament OS][Epic] Public Data, OBS/TikTok Live Studio, And Export`
- `#9` `[Tournament OS][Epic] Events, Audit, Realtime-Ready Flow, And Discord-Ready Flow`
- `#10` `[Tournament OS][Epic] Backend Foundation`

Use this file as the source list when adding child issues, labels, milestone, or follow-up comments.

## Labels To Create

- `tournament-os`
- `phase-1`
- `epic`
- `backend`
- `database`
- `api`
- `testing`
- `frontend`
- `public-data`
- `discord`
- `overlay`
- `docs`
- `security`
- `privacy`

## Milestone

Recommended milestone:

- `Tournament OS Phase 1`

## Main Tracking Issue

Title:

```text
[Tournament OS] Phase 1 System Planning
```

Labels:

- `tournament-os`
- `phase-1`
- `docs`

Body:

```md
## Goal

Track Tournament OS Phase 1 planning and backend-readiness work.

## Current Status

- SRS is approximately 95%+ ready.
- Group Points Qualifier scoring and advancement contract exists.
- Public and stream-safe OBS/TikTok Live Studio data boundaries are defined.
- GitHub issue template files exist.
- Phase 1 epics are ready to create.

## Scope

- FastAPI backend foundation
- PostgreSQL schema foundation
- ruleset snapshots
- registration and check-in
- scoring and disputes
- leaderboard and advancement
- public-safe and stream-safe read models
- audit and event outbox
- Excel export

## Out Of Scope

- payment
- SaaS multi-tenant management
- OCR as official scoring
- full Discord command system
- advanced overlay editor

## References

- `projects/tournament-os/spec/SYSTEM_REQUIREMENTS_SPECIFICATION.md`
- `projects/tournament-os/spec/GROUP_POINTS_QUALIFIER_SPEC.md`
- `projects/tournament-os/spec/API_CONTRACT_PHASE_1.md`
- `projects/tournament-os/backlog/GITHUB_ISSUES_PHASE_1.md`
```

## Issue Groups

### Epic: Documentation Freeze And Architecture

Issues:

- Review and approve Phase 1 SRS open decisions.
- Write `docs/SYSTEM_ARCHITECTURE_DESIGN.md`.
- Write `docs/TEST_PLAN_PHASE_1.md`.

Acceptance coverage:

- Golden Spatula confirmed as first game.
- Solo-only Phase 1 confirmed.
- 16 or 32 player first event confirmed.
- Group Points Qualifier and Fixed Points confirmed.
- OBS/TikTok Live Studio stream-safe view confirmed.
- Test plan covers scoring, privacy, concurrency, public data, and stream-safe endpoints.

References:

- `spec/SYSTEM_REQUIREMENTS_SPECIFICATION.md`
- `spec/MVP_RULESET.md`
- `spec/GROUP_POINTS_QUALIFIER_SPEC.md`
- `docs/DOCUMENTATION_SUITE.md`

### Epic: Identity, Permissions, And Tokens

Issues:

- Design users, roles, tournament roles, and token/session tables.
- Implement backend permission checks for admin/referee/player/public surfaces.

Acceptance coverage:

- Backend roles are official permission source.
- Discord roles are helper/display only.
- Supports Super Admin, Tournament Admin, Score Admin, Referee, Player, Viewer, and Caster.
- Tournament-scoped roles are represented.
- No secrets are committed.

References:

- `spec/SYSTEM_REQUIREMENTS_SPECIFICATION.md`
- `docs/EVIDENCE_AND_DISCORD_ROLE_ANALYSIS.md`

### Epic: Tournament Core And Rulesets

Issues:

- Implement tournament creation.
- Implement ruleset preset selection.
- Implement tournament-specific draft ruleset.
- Implement immutable ruleset and score formula lock.
- Implement rule validation.

Acceptance coverage:

- Admin can create draft tournament.
- Admin can select Fixed Points or Group Points Qualifier.
- Preset is copied into tournament-specific draft ruleset.
- Locked snapshot is used by score calculation.
- Rule lock creates audit and event outbox records.

References:

- `spec/RULESET_SELECTION_AND_CREATION_UI.md`
- `spec/RULE_CONFIG_EXAMPLES.md`
- `spec/API_CONTRACT_PHASE_1.md`

### Epic: Registration And Check-In

Issues:

- Implement player registration.
- Implement admin registration review.
- Implement session-level check-in.
- Implement no-show/replacement representation.

Acceptance coverage:

- One player can register once per tournament.
- Game UID is unique per tournament.
- Admin can approve, reject, waitlist, or withdraw.
- Check-in opens/closes by session time window.
- Duplicate check-in returns current state.
- Late check-in requires admin override and audit reason.

References:

- `spec/CHECK_IN_SPEC.md`
- `spec/API_CONTRACT_PHASE_1.md`

### Epic: Group Generation And Lobby Management

Issues:

- Generate stages, groups, rounds, and check-in sessions from locked ruleset.
- Allow admin group adjustment before lock.
- Require audit reason for post-lock movement.

Acceptance coverage:

- Only approved players are grouped.
- Group generation follows locked stage plan.
- Existing groups use clear regeneration/idempotency policy.
- Group movement after lock creates audit log.

References:

- `spec/GROUP_POINTS_QUALIFIER_SPEC.md`
- `spec/API_CONTRACT_PHASE_1.md`

### Epic: Scoring, Leaderboard, Advancement, And Disputes

Issues:

- Implement placement-based score calculation.
- Implement score approval and finalization.
- Implement leaderboard snapshot updates.
- Implement Group Points Qualifier advancement.
- Implement dispute and score correction flow.

Acceptance coverage:

- Score Admin enters placements, not manual official totals.
- Duplicate placements in one game are rejected.
- Placement points come from locked formula snapshot.
- Pending scores do not affect public leaderboard by default.
- Top 4 per lobby advance by default.
- Scores reset each stage by default.
- Final stage rank 1 becomes winner.
- Accepted dispute creates score correction, audit log, and leaderboard rebuild.

References:

- `spec/GROUP_POINTS_QUALIFIER_SPEC.md`
- `spec/API_CONTRACT_PHASE_1.md`

### Epic: Public Data, OBS/TikTok Live Studio, And Export

Issues:

- Implement public tournament summary endpoint.
- Implement public groups endpoint.
- Implement public leaderboard endpoint.
- Implement stream-safe OBS/TikTok Live Studio leaderboard endpoint.
- Implement stream-safe OBS/TikTok Live Studio groups endpoint.
- Implement Excel export.

Acceptance coverage:

- Public endpoints exclude contact data, Discord IDs, private evidence, admin notes, and audit payloads.
- Stream-safe endpoints use approved/final scores by default.
- Overlay/client does not calculate score, rank, or advancement.
- Stream-safe reads target under 1 second for MVP scale.
- Excel export creates audit log.

References:

- `spec/SYSTEM_REQUIREMENTS_SPECIFICATION.md`
- `spec/API_CONTRACT_PHASE_1.md`
- `docs/WEB_APP_DESIGN_AND_INTEGRATION_SPEC.md`

### Epic: Events, Audit, Realtime-Ready Flow, And Discord-Ready Flow

Issues:

- Implement audit log service.
- Implement event outbox table/service.
- Define Discord-ready event names.
- Add dashboard/player/leaderboard read models.

Acceptance coverage:

- Important mutations create audit records.
- Important mutations create event outbox records.
- Event payloads do not leak private data.
- Dashboard polling can read updated state.
- Discord workers can be added later without changing core business logic.

References:

- `docs/DISCORD_OPERATIONS_AND_PLUGIN_SPEC.md`
- `docs/BOT_WEB_FLOW_AND_DATA_SPEC.md`
- `docs/POSTGRES_MODULE_FLOW_ANALYSIS.md`

### Epic: Backend Foundation

Issues:

- Create FastAPI backend skeleton.
- Create SQLAlchemy models.
- Create Alembic initial migration.
- Add test harness.

Acceptance coverage:

- FastAPI app runs locally.
- Health endpoint exists.
- Configuration loads from environment variables.
- SQLAlchemy models cover Phase 1 tables.
- Alembic initial migration exists.
- Duplicate registration and duplicate game UID are protected by constraints.
- Rule snapshots, event outbox, and read model tables are represented.

References:

- `spec/DATABASE_SCHEMA.md`
- `spec/IMPLEMENTATION_SCHEMA_PLAN.md`
- `spec/ER_DIAGRAM.md`

## Creation Notes

When GitHub access is available:

1. Add labels above if token permission allows it.
2. Add milestone `Tournament OS Phase 1` if token permission allows it.
3. Link `#2-#10` from main issue `#1`.
4. Create child issues from each issue group when backend implementation begins.
5. Link child issues back to the Epic.
6. Add all issues to the Phase 1 milestone.

Do not create implementation issues for payment, OCR official scoring, full Discord command system, SaaS tenancy, or advanced overlay editor in Phase 1.
