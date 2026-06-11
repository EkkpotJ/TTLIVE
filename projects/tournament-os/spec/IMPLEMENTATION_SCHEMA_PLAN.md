# Implementation Schema Plan

Status: Phase 1 implementation draft.

This file turns the planning schema into a practical PostgreSQL implementation plan for the first backend build.

## Scope

Phase 1 should support:

- Solo Golden Spatula tournaments
- Registration review
- Group generation
- Session-level check-in
- Score entry and approval
- Leaderboard calculation
- Public-safe leaderboard reads
- Audit logs
- Event outbox for future realtime/Discord workers

Phase 1 should not require:

- Full team workflow
- Payment
- OCR automation
- Discord role sync
- SaaS multi-tenancy
- Complex overlay editor

## Table Groups

Use four groups:

1. Identity and permissions
2. Official write model
3. Read/display model
4. Integration and operations

## Identity And Permissions

### users

Purpose:

Internal user account record for admins, referees, and players.

Columns:

- id
- display_name
- email nullable
- discord_id nullable
- role
- created_at
- updated_at

Phase 1 note:

Keep `discord_id` on `users` for speed, but do not design services so that Discord is required.

Constraints:

- Unique `email` when present
- Unique `discord_id` when present

Indexes:

- `users(discord_id)`
- `users(email)`

### user_identities

Purpose:

Future-safe identity mapping for Discord, web login, or other providers.

Phase 1:

Optional table. If skipped, keep the API boundary compatible with adding it later.

Columns:

- id
- user_id
- provider
- provider_user_id
- display_name
- created_at

Constraints:

- Unique `provider, provider_user_id`

### tournament_user_roles

Purpose:

Tournament-scoped permissions.

Phase 1:

Recommended if multiple admins/referees may work in one event. If solo-admin only, global `users.role` can be used temporarily.

Columns:

- id
- tournament_id
- user_id
- role
- created_by_user_id
- created_at

Constraints:

- Unique `tournament_id, user_id, role`

Indexes:

- `tournament_user_roles(tournament_id, user_id)`
- `tournament_user_roles(tournament_id, role)`

## Official Write Model

### tournaments

Columns:

- id
- name
- game
- status
- participant_type
- max_participants
- registration_open_at
- registration_close_at
- public_slug
- active_rule_set_id
- active_score_formula_id
- created_by_user_id
- created_at
- updated_at

Constraints:

- Unique `public_slug`

Indexes:

- `tournaments(status)`
- `tournaments(public_slug)`

### rule_sets

Columns:

- id
- tournament_id
- source_preset_id nullable
- name
- description
- model
- participant_type
- lobby_size
- max_participants
- min_participants
- games_per_stage
- final_games
- score_reset_policy
- advancement_policy_json
- lobby_assignment_policy_json
- verification_policy_json
- version
- status
- locked_at
- locked_by_user_id
- config_snapshot_json
- created_at
- updated_at

Rules:

- Editable while tournament is draft.
- Locked before tournament starts.
- Locked config should be treated as immutable except Super Admin correction.

Indexes:

- `rule_sets(tournament_id, status)`
- `rule_sets(source_preset_id)`

### score_formulas

Columns:

- id
- tournament_id
- rule_set_id
- name
- placement_points_json
- bonus_rules_json
- penalty_rules_json
- bye_rule_json
- tie_break_order_json
- manual_override_policy_json
- version
- status
- locked_at
- locked_by_user_id
- config_snapshot_json
- created_at
- updated_at

Indexes:

- `score_formulas(tournament_id, status)`

### rule_presets

Purpose:

Template/master data for common tournament rule configurations.

Phase 1 presets:

- Golden Spatula 16 Player
- Golden Spatula 32 Player
- Golden Spatula Fixed Final

Columns:

- id
- name
- description
- game
- model
- participant_type
- config_json
- is_active
- created_at
- updated_at

Rules:

- Presets are copied into tournament-specific `rule_sets` and `score_formulas`.
- Tournaments must use their own locked snapshot, not read live preset values during scoring.

### score_formula_placement_points

Purpose:

Optional normalized storage for placement points per formula.

Phase 1 can store placement points in `score_formulas.placement_points_json`, but the scoring service must be written so this can later be normalized without changing business logic.

Columns:

- id
- score_formula_id
- placement
- points
- created_at

Constraints:

- Unique `score_formula_id, placement`

Indexes:

- `score_formula_placement_points(score_formula_id, placement)`

### registrations

Columns:

- id
- tournament_id
- user_id
- team_id nullable
- status
- display_name
- in_game_name
- game_uid
- contact_method
- contact_value
- review_note
- submitted_at
- reviewed_by_user_id
- reviewed_at
- created_at
- updated_at

Phase 1 privacy:

- `display_name`, `in_game_name` can be public-safe.
- `contact_method`, `contact_value`, `review_note` are private/admin-only.
- Consider encrypting `contact_value` later.

Constraints:

- Unique `tournament_id, user_id`
- Unique `tournament_id, game_uid` when `game_uid` is present

Indexes:

- `registrations(tournament_id, status)`
- `registrations(tournament_id, user_id)`
- `registrations(tournament_id, game_uid)`

### teams

Future support table.

Phase 1:

Keep draft only or omit from migrations if MVP is strictly solo.

Columns:

- id
- tournament_id
- name
- captain_user_id
- status
- created_at
- updated_at

### team_members

Future support table.

Phase 1:

Keep draft only or omit from migrations.

### stages

Columns:

- id
- tournament_id
- name
- sequence
- format
- status
- created_at
- updated_at

Constraints:

- Unique `tournament_id, sequence`

Indexes:

- `stages(tournament_id, sequence)`
- `stages(tournament_id, status)`

### groups

Columns:

- id
- tournament_id
- stage_id
- name
- sequence
- created_at
- updated_at

Constraints:

- Unique `stage_id, sequence`

Indexes:

- `groups(stage_id, sequence)`

### group_participants

Columns:

- id
- group_id
- registration_id
- seed
- status
- created_at
- updated_at

Constraints:

- Unique `group_id, registration_id`

Indexes:

- `group_participants(group_id, status)`
- `group_participants(registration_id)`

### rounds

Columns:

- id
- tournament_id
- stage_id
- group_id
- name
- sequence
- scheduled_at
- status
- created_at
- updated_at

Constraints:

- Unique `group_id, sequence`

Indexes:

- `rounds(group_id, sequence)`
- `rounds(tournament_id, status)`

### check_in_sessions

Columns:

- id
- tournament_id
- stage_id
- group_id nullable
- round_id nullable
- name
- session_type
- status
- opens_at
- closes_at
- locked_at
- created_by_user_id
- created_at
- updated_at

Indexes:

- `check_in_sessions(tournament_id, status)`
- `check_in_sessions(stage_id, opens_at)`

### check_ins

Columns:

- id
- check_in_session_id
- tournament_id
- registration_id
- group_participant_id nullable
- status
- checked_in_at
- checked_in_by_user_id nullable
- source
- note
- replaced_by_registration_id nullable
- created_at
- updated_at

Constraints:

- Unique `check_in_session_id, registration_id`

Indexes:

- `check_ins(check_in_session_id, status)`
- `check_ins(registration_id, status)`

### scores

Columns:

- id
- tournament_id
- stage_id
- group_id
- round_id
- registration_id
- placement
- placement_points
- bonus_points
- penalty_points
- bye_points
- total_points
- status
- evidence_uri nullable
- note
- submitted_by_user_id
- approved_by_user_id nullable
- approved_at nullable
- formula_snapshot_json
- created_at
- updated_at

Rules:

- FastAPI calculates total points.
- Client preview is not official.
- `formula_snapshot_json` stores the scoring config used for this score.
- Placement points are read from the locked tournament score formula or formula snapshot.
- Golden Spatula default points are seed/preset data, not hardcoded scoring logic.

Constraints:

- Unique `round_id, registration_id`

Indexes:

- `scores(tournament_id, stage_id, status)`
- `scores(round_id, registration_id)`
- `scores(registration_id, status)`

### disputes

Columns:

- id
- tournament_id
- score_id
- registration_id
- status
- reason
- evidence_uri nullable
- resolved_note
- opened_by_user_id
- resolved_by_user_id nullable
- created_at
- updated_at

Indexes:

- `disputes(tournament_id, status)`
- `disputes(registration_id, status)`
- `disputes(score_id)`

### audit_logs

Columns:

- id
- actor_user_id
- tournament_id nullable
- entity_type
- entity_id
- action
- before_json
- after_json
- reason
- created_at

Indexes:

- `audit_logs(tournament_id, created_at)`
- `audit_logs(entity_type, entity_id, created_at)`
- `audit_logs(actor_user_id, created_at)`

## Read/Display Model

### tournament_dashboard_summaries

Purpose:

Fast admin dashboard reads.

Columns:

- id
- tournament_id
- status
- registration_counts_json
- current_stage_id nullable
- current_check_in_session_id nullable
- current_check_in_counts_json
- pending_score_count
- open_dispute_count
- discord_delivery_status_json
- next_action
- updated_at

Constraints:

- Unique `tournament_id`

### leaderboard_snapshots

Purpose:

Fast public, Discord, and stream-safe leaderboard reads.

Columns:

- id
- tournament_id
- stage_id nullable
- group_id nullable
- version
- visibility
- snapshot_json
- generated_from_score_version
- created_at

Indexes:

- `leaderboard_snapshots(tournament_id, stage_id, group_id, version)`

### player_status_snapshots

Purpose:

Fast player and Discord command reads.

Columns:

- id
- tournament_id
- user_id
- registration_id nullable
- registration_status
- current_stage_id nullable
- current_group_id nullable
- current_check_in_session_id nullable
- check_in_status nullable
- latest_score_summary_json
- allowed_actions_json
- updated_at

Constraints:

- Unique `tournament_id, user_id`

Indexes:

- `player_status_snapshots(tournament_id, user_id)`
- `player_status_snapshots(registration_id)`

### public_tournament_summaries

Purpose:

Fast public tournament page reads without private data.

Columns:

- id
- tournament_id
- public_slug
- status
- display_json
- updated_at

Constraints:

- Unique `public_slug`

## Integration And Operations

### event_outbox

Purpose:

Single source of system events for realtime, Discord workers, and later integrations.

Columns:

- id
- tournament_id nullable
- event_name
- entity_type
- entity_id
- payload_json
- status
- created_at
- processed_at nullable

Indexes:

- `event_outbox(status, created_at)`
- `event_outbox(tournament_id, created_at)`

Rules:

- Write event rows in the same transaction as official state changes.
- Workers process events asynchronously.

### discord_message_jobs

Purpose:

Queue and track Discord notifications.

Columns:

- id
- tournament_id
- event_outbox_id nullable
- target_channel_id
- message_type
- payload_json
- idempotency_key
- status
- attempt_count
- last_error
- next_retry_at
- sent_at
- created_at

Constraints:

- Unique `idempotency_key`

Indexes:

- `discord_message_jobs(status, next_retry_at)`
- `discord_message_jobs(tournament_id, created_at)`

### attachments

Purpose:

Future managed evidence storage.

Phase 1:

Optional. Use `evidence_uri` first if uploads are not implemented.

Columns:

- id
- tournament_id
- uploaded_by_user_id
- source
- storage_uri
- original_filename
- mime_type
- file_size_bytes
- checksum_sha256
- visibility
- status
- created_at

Indexes:

- `attachments(tournament_id, created_at)`
- `attachments(checksum_sha256)`

### plugin_runs

Future support table for OCR and analysis helpers.

### plugin_suggestions

Future support table for plugin suggestions that require admin review.

## Required Enum Sets

Use enum values from `ENUMS_AND_STATES.md`.

Required Phase 1 enums:

- user role
- tournament status
- registration status
- stage status
- group participant status
- round status
- check-in session status
- check-in status
- score status
- dispute status
- tournament model
- score reset policy
- advancement type
- lobby assignment type
- bye behavior

## Transaction Rules

Every important mutation should do these together:

```text
1. Validate permission.
2. Validate state transition.
3. Write official table changes.
4. Write audit log when required.
5. Rebuild affected read snapshot when needed.
6. Write event_outbox record.
7. Return updated official response.
```

## Phase 1 Migration Order

Recommended Alembic migration order:

1. Identity tables
2. Tournament/rule tables
3. Registration tables
4. Stage/group/round tables
5. Check-in tables
6. Score/dispute/audit tables
7. Read snapshot tables
8. Event outbox
9. Discord message jobs
10. Optional attachments

## Open Decisions Before Coding

- Use global roles only or add `tournament_user_roles` now?
- Add `user_identities` now or defer?
- Store contact values plain first or encrypted?
- Implement snapshot tables immediately or compute read endpoints first?
- Use evidence URI only or add `attachments` in Phase 1?
- Generate check-in sessions automatically from stage plan or manually by admin?

## Recommendation

For first backend build:

- Implement `event_outbox` now.
- Implement `leaderboard_snapshots` now.
- Implement `tournament_dashboard_summaries` now.
- Implement `player_status_snapshots` if Discord commands are included early.
- Keep `attachments`, `plugin_runs`, and role sync tables as Phase 2 unless upload/OCR/role sync is required immediately.
