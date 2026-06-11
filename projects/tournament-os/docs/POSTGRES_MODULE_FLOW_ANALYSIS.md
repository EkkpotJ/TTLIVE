# PostgreSQL Module Flow Analysis

Status: Architecture analysis draft.

This document analyzes the current PostgreSQL design, module connections, end-to-end system flow, and recommended improvements before implementation.

## Executive Assessment

The current Tournament OS design is directionally correct:

- PostgreSQL is the source of truth.
- FastAPI owns business logic.
- Web, Discord, plugins, and overlays are clients/helpers.
- Tournament state, registration, grouping, scores, disputes, and audit logs are already modeled.

However, the system needs several supporting data modules before implementation:

- Identity mapping for Discord/web users
- Tournament-scoped permissions
- Event outbox for web/Discord synchronization
- Read-optimized snapshots for fast dashboard/player/leaderboard views
- Notification delivery jobs
- Evidence/attachment references
- Immutable rule snapshots

Without these, the MVP can still work manually, but Discord, realtime dashboard, and fast public leaderboard will become fragile.

## PostgreSQL Role

PostgreSQL should hold three categories of data:

1. Official write model
2. Read/display model
3. Integration/operation model

### Official Write Model

This is normalized and transaction-safe.

Current core tables:

- `users`
- `tournaments`
- `rule_sets`
- `score_formulas`
- `registrations`
- `stages`
- `groups`
- `group_participants`
- `rounds`
- `check_in_sessions`
- `check_ins`
- `scores`
- `disputes`
- `audit_logs`

Purpose:

- Store official tournament truth.
- Enforce constraints.
- Support auditability.
- Let FastAPI calculate official state.

### Read/Display Model

These tables or materialized views should be optimized for fast reads.

Recommended:

- `tournament_dashboard_summaries`
- `leaderboard_snapshots`
- `player_status_snapshots`
- `public_tournament_summaries`

Purpose:

- Avoid expensive recalculation for every public request.
- Keep Discord commands fast.
- Keep admin dashboard responsive.
- Make realtime/polling simple.

### Integration/Operation Model

These tables support async workers and external systems.

Recommended:

- `event_outbox`
- `discord_message_jobs`
- `plugin_runs`
- `plugin_suggestions`
- `attachments`

Purpose:

- Decouple official writes from Discord/API latency.
- Track delivery status.
- Retry safely.
- Store suggestions before admin approval.
- Avoid losing evidence references.

## Current Data Model Strengths

The current schema is strong in these areas:

- Tournament hierarchy is clear: tournament -> stage -> group -> round -> score.
- Registration uniqueness is planned.
- Game UID uniqueness is planned.
- Check-in has been corrected into session-level storage.
- Scores are per round and registration.
- Disputes connect to score and registration.
- Audit logs exist as a generic mutation trail.
- Rule sets and score formulas are configurable.

## Current Data Model Gaps

### 1. Identity Is Too Simple

Current:

- `users.discord_id`
- `users.email`
- `users.role`

Problem:

- A user may later connect Discord, web login, Google, or manual admin account.
- Discord ID should not be the only identity model.
- Global `role` is too coarse for tournaments.

Recommendation:

Add later or design for:

```text
user_identities
  id
  user_id
  provider
  provider_user_id
  display_name
  created_at

tournament_user_roles
  id
  tournament_id
  user_id
  role
  created_by_user_id
  created_at
```

MVP can keep `users.discord_id`, but implementation should not block this future split.

### 2. Contact Data Needs Privacy Design

Current:

- `registrations.contact_method`

Problem:

- Contact method and value need separation.
- Public serializers must never expose contact value.
- Contact values may require encryption later.

Recommendation:

Change or extend to:

```text
contact_method
contact_value_encrypted or contact_value
```

At minimum, store contact value separately from public registration display fields.

### 3. Rule Lock Needs Immutable Snapshot

Current:

- `rule_sets`
- `score_formulas`

Problem:

- If rules are edited after scores exist, historical calculation becomes ambiguous.

Recommendation:

Add:

```text
locked_at
locked_by_user_id
version
config_snapshot_json
```

Rule and formula records used by scores should be immutable after lock except Super Admin correction with audit reason.

### 4. Event Outbox Is Missing

Problem:

Web dashboard, Discord notifications, public pages, and workers need consistent event flow.

Recommendation:

Add `event_outbox` in Phase 1:

```text
event_outbox
  id
  tournament_id
  event_name
  entity_type
  entity_id
  payload_json
  status
  created_at
  processed_at
```

FastAPI writes events in the same transaction as official state changes.

### 5. Read Snapshots Are Missing

Problem:

Leaderboard and dashboard endpoints may recalculate too much under live traffic.

Recommendation:

Add read snapshots before public/realtime scale:

```text
leaderboard_snapshots
player_status_snapshots
tournament_dashboard_summaries
```

MVP can compute initially, but endpoint contracts should be designed around summary responses.

### 6. Discord Delivery State Is Missing

Problem:

If Discord send fails, admins need to know.

Recommendation:

Add `discord_message_jobs`:

```text
discord_message_jobs
  id
  tournament_id
  event_outbox_id
  target_channel_id
  message_type
  payload_json
  idempotency_key
  status
  attempt_count
  last_error
  next_retry_at
  sent_at
  created_at
```

This prevents duplicate announcements and supports retry.

### 7. Evidence/Attachment Storage Is Too Thin

Current:

- `scores.evidence_uri`
- `disputes.evidence_uri`

Problem:

- Evidence may come from web upload, Discord attachment, external link, or OCR plugin.
- Private/public access needs control.

Recommendation:

Add later:

```text
attachments
  id
  tournament_id
  uploaded_by_user_id
  source
  storage_uri
  original_filename
  mime_type
  visibility
  created_at
```

Then scores/disputes reference attachment IDs or keep evidence URI for MVP.

## Module Map

### Tournament Module

Owns:

- Tournament setup
- Status transitions
- Rule lock
- Stage generation trigger

Reads:

- rule_sets
- score_formulas

Writes:

- tournaments
- rule_sets
- score_formulas
- audit_logs
- event_outbox

### Registration Module

Owns:

- Player registration
- Duplicate user/UID checks
- Approval/rejection/waitlist

Reads:

- tournaments
- users
- registrations

Writes:

- registrations
- audit_logs
- event_outbox
- player_status_snapshots
- tournament_dashboard_summaries

### Group Module

Owns:

- Generate groups from approved registrations
- Move players
- Lock groups
- Replacement handling with waitlist

Reads:

- registrations
- rule_sets
- stages

Writes:

- stages
- groups
- group_participants
- check_in_sessions when sessions are generated from stages
- audit_logs
- event_outbox

### Check-In Module

Owns:

- Create check-in sessions
- Open/close/lock sessions
- Player check-in
- No-show and replacement state

Reads:

- tournaments
- stages
- groups
- registrations
- group_participants

Writes:

- check_in_sessions
- check_ins
- group_participants when no-show/replaced affects assignment
- audit_logs
- event_outbox
- player_status_snapshots
- tournament_dashboard_summaries

### Score Module

Owns:

- Score entry
- Score calculation
- Submission
- Approval
- Finalization
- Correction after dispute

Reads:

- rule_sets
- score_formulas
- rounds
- registrations

Writes:

- scores
- audit_logs
- event_outbox
- leaderboard_snapshots
- player_status_snapshots
- tournament_dashboard_summaries

### Leaderboard Module

Owns:

- Ranking
- Tie-break
- Qualification status
- Public safe leaderboard output

Reads:

- approved/final scores
- rule_sets
- score_formulas
- stages
- groups

Writes:

- leaderboard_snapshots
- event_outbox for `leaderboard.updated`

### Dispute Module

Owns:

- Open dispute
- Review dispute
- Accept/reject
- Trigger score correction

Reads:

- scores
- registrations
- tournaments

Writes:

- disputes
- scores through score service when accepted
- audit_logs
- event_outbox
- player_status_snapshots
- tournament_dashboard_summaries

### Discord Module

Owns:

- Receive interactions
- Map Discord user to backend user
- Format response
- Queue/send notifications

Reads:

- users or user_identities
- player_status_snapshots
- leaderboard_snapshots
- discord_message_jobs

Writes:

- event requests through FastAPI services
- discord_message_jobs
- event_outbox for delivery status if needed

Does not write official tournament state directly.

### Plugin Module

Owns:

- OCR suggestions
- Duplicate detection
- Announcement formatting
- Export helpers

Reads:

- attachments
- scores
- registrations
- snapshots

Writes:

- plugin_runs
- plugin_suggestions

Does not write official score or advancement directly.

## End-To-End System Flow

### 1. Tournament Setup

```text
Admin web
  -> FastAPI Tournament Service
  -> writes tournaments, rule_sets, score_formulas
  -> audit_logs
  -> event_outbox: tournament.created/status_changed
  -> dashboard summary updates
```

### 2. Registration

```text
Player web or Discord
  -> FastAPI Registration Service
  -> validates tournament open and duplicate user/UID
  -> writes registrations
  -> event_outbox: registration.submitted
  -> dashboard summary/player status updates
```

Admin approval:

```text
Admin web
  -> approve registration
  -> writes registration.status = approved
  -> audit log
  -> player_status_snapshot updates
  -> dashboard summary updates
  -> optional Discord notification job
```

### 3. Group Generation

```text
Admin web
  -> FastAPI Group Service
  -> reads approved registrations and rule set
  -> creates stages/groups/group_participants
  -> creates check-in sessions if configured
  -> event_outbox: groups.generated
  -> player_status_snapshots update with current group
```

### 4. Check-In

```text
Discord button or web action
  -> FastAPI Check-In Service
  -> validates eligible session
  -> writes check_ins
  -> event_outbox: check_in.checked_in
  -> dashboard summary updates
  -> player_status_snapshot updates
```

### 5. Score Entry And Approval

```text
Admin web
  -> FastAPI Score Service
  -> calculates points from locked score formula
  -> writes scores
  -> event_outbox: score.submitted
```

Approval:

```text
Referee/Admin
  -> approve score
  -> score.status = approved
  -> Leaderboard Service recalculates affected snapshot
  -> event_outbox: score.approved, leaderboard.updated
  -> public leaderboard and Discord read from snapshot
```

### 6. Dispute

```text
Player web or Discord
  -> FastAPI Dispute Service
  -> writes disputes.status = open
  -> event_outbox: dispute.opened
  -> admin dashboard updates
```

Accepted dispute:

```text
Referee/Admin
  -> accept dispute
  -> Score Service creates correction
  -> audit log records before/after
  -> leaderboard snapshot updates
  -> player status updates
```

### 7. Export

```text
Admin export request
  -> Export Service reads snapshots and official data
  -> generates Excel first
  -> event_outbox: export.ready
```

## Data Speed Strategy

### Fast Write Path

For user/admin actions:

- Validate input.
- Write official state.
- Write audit/event in same transaction.
- Return updated official response quickly.
- Do async work after response.

Do not wait for:

- Discord delivery
- OCR
- PDF generation
- Heavy report generation

### Fast Read Path

Use different read paths by page:

| Surface | Read Strategy |
| :--- | :--- |
| Admin dashboard | `tournament_dashboard_summaries` |
| Public leaderboard | `leaderboard_snapshots` |
| Discord player commands | `player_status_snapshots` |
| Audit log | indexed query with pagination |
| Score entry page | direct normalized query for current round/group |
| Admin registration table | indexed query with filters |

### Index Priorities

Add these early:

- `registrations(tournament_id, status)`
- `registrations(tournament_id, user_id)` unique
- `registrations(tournament_id, game_uid)` unique when game_uid is present
- `group_participants(group_id, registration_id)` unique
- `check_ins(check_in_session_id, registration_id)` unique
- `scores(round_id, registration_id)` unique
- `scores(tournament_id, stage_id, status)`
- `disputes(tournament_id, status)`
- `event_outbox(status, created_at)`
- `discord_message_jobs(status, next_retry_at)`
- `audit_logs(entity_type, entity_id, created_at)`

## Recommended Improvements

### P0 Before Backend Coding

- Add identity model decision: simple `users.discord_id` now, `user_identities` later.
- Add tournament-scoped permission strategy.
- Add event outbox table to schema draft.
- Add dashboard/player/leaderboard read model decision.
- Add immutable locked rule config fields.
- Add contact value privacy design.
- Add evidence/attachment decision.

### P1 During Backend Foundation

- Implement write services with audit/event hooks.
- Implement score calculation tests from locked formula.
- Implement check-in session tests.
- Implement public/private serializers.
- Implement dashboard summary endpoint.
- Implement player status endpoint for Discord.
- Implement leaderboard snapshot or read-optimized query.
- Implement event outbox records for major mutations.

### P2 After Manual Flow Works

- Add Discord notification worker.
- Add Discord command endpoints.
- Add plugin suggestion tables.
- Add evidence upload/attachment table.
- Add WebSocket/SSE after polling proves data contracts.
- Add export job table if exports become async.

## Main Risks

### State Drift

Risk:

Discord, web, and public pages show different states.

Fix:

All clients read from FastAPI, snapshots, or events generated by the same PostgreSQL transaction.

### Slow Leaderboard

Risk:

Public leaderboard recalculates from raw scores on every request.

Fix:

Use `leaderboard_snapshots` after every score approval.

### Permission Leaks

Risk:

Discord role or public endpoint exposes admin/private data.

Fix:

Backend permission checks and separate public DTOs.

### Rule Mutation After Scores

Risk:

Scores cannot be reproduced if formula changes.

Fix:

Immutable locked rule/formula snapshots.

### Contact Data Exposure

Risk:

Public pages leak Discord ID, Line ID, email, or phone.

Fix:

Split contact value from public fields and restrict serializers.

## Overall Verdict

The system architecture is ready for backend planning, but the database schema should be upgraded before implementation.

The most important change is to treat PostgreSQL not only as normalized storage, but as the coordination layer for:

- Official state
- Read snapshots
- Event outbox
- Discord delivery
- Plugin suggestions
- Auditability

Once those pieces are specified, FastAPI can connect all modules cleanly and the web/Discord experience will stay synchronized under real tournament use.
