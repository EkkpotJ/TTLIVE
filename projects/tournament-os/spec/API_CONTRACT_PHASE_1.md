# API Contract Phase 1

Status: Phase 1 implementation draft.

This file defines the initial FastAPI contract for Tournament OS.

## Principles

- FastAPI owns business logic.
- Clients never calculate official scores.
- Public endpoints never expose private data.
- Mutations return updated official state or current allowed actions.
- Every important mutation writes audit/event records.
- Discord commands call FastAPI instead of writing local bot state.

## Common Response Shapes

### Error

```json
{
  "error": {
    "code": "registration_duplicate",
    "message": "You already registered for this tournament.",
    "details": {}
  }
}
```

### Mutation Result

```json
{
  "data": {},
  "events": [
    {
      "name": "registration.submitted",
      "entity_type": "registration",
      "entity_id": "..."
    }
  ]
}
```

### Allowed Actions

```json
{
  "allowed_actions": [
    "view_status",
    "view_rules",
    "check_in"
  ]
}
```

## Admin Dashboard

### GET `/admin/tournaments/{tournament_id}/dashboard`

Returns admin dashboard summary.

Response:

```json
{
  "tournament": {
    "id": "...",
    "name": "Golden Spatula Weekly",
    "status": "registration_open"
  },
  "registration_counts": {
    "submitted": 12,
    "approved": 18,
    "waitlisted": 2,
    "rejected": 1,
    "withdrawn": 0
  },
  "current_stage": {
    "id": "...",
    "name": "Round 1",
    "status": "ready"
  },
  "current_check_in": {
    "session_id": "...",
    "status": "open",
    "checked_in": 14,
    "pending": 2,
    "no_show": 0
  },
  "pending_score_count": 3,
  "open_dispute_count": 1,
  "next_action": "review_scores",
  "discord_delivery": {
    "pending_jobs": 0,
    "failed_jobs": 0
  }
}
```

## Tournaments

### POST `/admin/tournaments`

Creates a draft tournament.

Required body:

```json
{
  "name": "Golden Spatula Weekly",
  "game": "Golden Spatula",
  "participant_type": "solo",
  "max_participants": 32,
  "registration_open_at": "2026-06-20T18:00:00+07:00",
  "registration_close_at": "2026-06-21T18:00:00+07:00",
  "public_slug": "golden-weekly-001"
}
```

### PATCH `/admin/tournaments/{tournament_id}`

Updates tournament while editable.

### POST `/admin/tournaments/{tournament_id}/open-registration`

Moves tournament to `registration_open`.

### POST `/admin/tournaments/{tournament_id}/close-registration`

Moves tournament to `registration_closed`.

## Rule Sets

### GET `/admin/rule-presets`

Returns available ruleset presets.

Presets are templates only. Selecting a preset copies its configuration into the tournament draft rule set and score formula.

### POST `/admin/tournaments/{tournament_id}/rule-set/validate`

Validates rule config without saving.

### POST `/admin/tournaments/{tournament_id}/rule-set`

Creates or replaces draft rule set.

Rules:

- May be created from a preset.
- Editing tournament draft rules must not mutate the preset.
- Score formula placement points must be stored in the tournament draft formula/snapshot.

### POST `/admin/tournaments/{tournament_id}/rule-set/lock`

Locks rule set and score formula.

Rules:

- Requires Tournament Admin or Super Admin.
- Writes immutable `config_snapshot_json`.
- Writes audit log.
- Emits `rule_set.locked`.

## Registration

### POST `/tournaments/{tournament_id}/registrations`

Player submits registration.

Body:

```json
{
  "display_name": "Player A",
  "in_game_name": "PlayerA",
  "game_uid": "123456789",
  "contact_method": "discord",
  "contact_value": "player_a"
}
```

Rules:

- Tournament must be registration open.
- One user can register once per tournament.
- `game_uid` must be unique per tournament.

### GET `/tournaments/{tournament_id}/registrations/me`

Returns current player's registration status.

### POST `/tournaments/{tournament_id}/registrations/me/withdraw`

Withdraws player's registration if rules allow.

## Admin Registration

### GET `/admin/tournaments/{tournament_id}/registrations`

Query params:

- `status`
- `search`
- `page`
- `page_size`

Returns private/admin registration table.

### POST `/admin/registrations/{registration_id}/approve`

Approves player.

### POST `/admin/registrations/{registration_id}/reject`

Body:

```json
{
  "reason": "UID could not be verified."
}
```

### POST `/admin/registrations/{registration_id}/waitlist`

Moves player to waitlist.

## Groups

### POST `/admin/tournaments/{tournament_id}/generate-groups`

Generates stages, groups, rounds, and optionally check-in sessions from locked rule set.

Body:

```json
{
  "strategy": "random",
  "create_check_in_sessions": true
}
```

Rules:

- Tournament must be registration closed or grouping.
- Only approved registrations are grouped.
- Existing groups require confirmation/regeneration policy.

### GET `/admin/tournaments/{tournament_id}/groups`

Returns admin group view.

### PATCH `/admin/groups/{group_id}/participants`

Moves participants before lock or with audit reason after lock.

## Check-In

### POST `/admin/tournaments/{tournament_id}/check-in-sessions`

Creates check-in session.

Body:

```json
{
  "stage_id": "...",
  "group_id": null,
  "round_id": null,
  "name": "Day 1 - Round 1 Check-In",
  "session_type": "stage",
  "opens_at": "2026-06-22T18:30:00+07:00",
  "closes_at": "2026-06-22T18:55:00+07:00"
}
```

### POST `/admin/check-in-sessions/{session_id}/open`

Opens check-in.

### POST `/admin/check-in-sessions/{session_id}/close`

Closes check-in.

### POST `/tournaments/{tournament_id}/check-in/{session_id}`

Player check-in from web.

Rules:

- Session must be open.
- Player must be eligible.
- Duplicate check-in returns current status, not an error that breaks UX.

### POST `/discord/check-in/{session_id}`

Discord player check-in.

Body:

```json
{
  "discord_user_id": "1234567890"
}
```

Response includes current player status and allowed actions.

## Scores

### POST `/admin/rounds/{round_id}/scores`

Creates score draft/submission for a round.

Body:

```json
{
  "scores": [
    {
      "registration_id": "...",
      "placement": 1,
      "bonus_points": 0,
      "penalty_points": 0,
      "penalty_reason": null,
      "evidence_uri": null
    }
  ]
}
```

Rules:

- Placement must be unique within round/group.
- FastAPI calculates placement points and total points.
- Formula snapshot is saved with score.

### PATCH `/admin/scores/{score_id}`

Edits draft or correction-allowed score.

### POST `/admin/scores/{score_id}/submit`

Submits score for verification.

### POST `/admin/scores/{score_id}/approve`

Approves score.

Effects:

- Score counts toward leaderboard.
- Leaderboard snapshot is rebuilt.
- Event outbox records `score.approved` and `leaderboard.updated`.

### POST `/admin/scores/{score_id}/finalize`

Locks score.

## Leaderboard

### GET `/admin/tournaments/{tournament_id}/leaderboard`

Admin leaderboard.

Query params:

- `stage_id`
- `group_id`
- `include_pending`

### GET `/public/tournaments/{slug}/leaderboard`

Public-safe leaderboard from snapshot or read-optimized query.

Response must not include:

- contact data
- Discord ID
- private evidence
- admin notes

## Stream-Safe Live View

These endpoints support OBS Browser Source and TikTok Live Studio browser/web source.

They return public-safe, approved backend data only.

### GET `/public/tournaments/{slug}/stream/leaderboard`

Returns a stream-readable leaderboard snapshot.

Query params:

- `stage_id`
- `group_id`
- `limit`

Response:

```json
{
  "tournament": {
    "name": "Golden Spatula Weekly",
    "status": "live",
    "current_stage": "Round 1"
  },
  "overlay": {
    "refresh_after_seconds": 10,
    "safe_for_stream": true
  },
  "leaderboard": [
    {
      "rank": 1,
      "display_name": "Player A",
      "group_name": "Lobby A",
      "total_points": 28,
      "qualification_status": "advancing",
      "score_status": "approved"
    }
  ]
}
```

Rules:

- Uses approved/final scores only by default.
- Must not expose contact values, private evidence, Discord IDs, admin notes, or audit payloads.
- Must not calculate official ranking in the overlay client.

### GET `/public/tournaments/{slug}/stream/groups`

Returns stream-safe current group/lobby data.

Rules:

- Shows public player display names only.
- May show check-in/no-show labels only if tournament public visibility settings allow it.
- Must use read-optimized/public-safe backend serializers.

## Disputes

### POST `/scores/{score_id}/disputes`

Player opens dispute.

Body:

```json
{
  "reason": "My placement should be 2nd, not 3rd.",
  "evidence_uri": "https://example.com/image.png"
}
```

### GET `/admin/tournaments/{tournament_id}/disputes`

Admin dispute queue.

### POST `/admin/disputes/{dispute_id}/review`

Marks dispute under review.

### POST `/admin/disputes/{dispute_id}/accept`

Accepts dispute and triggers correction flow.

### POST `/admin/disputes/{dispute_id}/reject`

Rejects dispute with reason.

## Player Status

### GET `/players/me/status`

Web player status.

Query params:

- `tournament_id`

### GET `/discord/players/me/status`

Discord status by Discord user id.

Query params:

- `tournament_id`
- `discord_user_id`

Returns:

- registration status
- current group
- current check-in session
- check-in status
- latest score summary
- allowed actions

This powers dynamic Discord buttons.

## Discord Notifications

### GET `/admin/tournaments/{tournament_id}/discord/status`

Returns delivery status and configuration summary.

### POST `/admin/tournaments/{tournament_id}/discord/announce-groups`

Queues group announcement.

### POST `/admin/tournaments/{tournament_id}/discord/announce-leaderboard`

Queues leaderboard announcement.

## Evidence

### Phase 1 Evidence Reference

Use `evidence_uri` on scores/disputes first.

### Future Upload Endpoint

```text
POST /admin/tournaments/{tournament_id}/attachments
POST /tournaments/{tournament_id}/attachments
```

Rules:

- Uploaded evidence is private by default.
- OCR/plugin output is suggestion only.
- Public endpoints never expose private evidence.

## Audit Logs

### GET `/admin/tournaments/{tournament_id}/audit-logs`

Query params:

- `entity_type`
- `entity_id`
- `actor_user_id`
- `action`
- `page`
- `page_size`

Admin-only.

## Event Stream

### MVP Polling

Use:

```text
GET /admin/tournaments/{tournament_id}/dashboard
GET /public/tournaments/{slug}/leaderboard
```

### Later Realtime

```text
GET /admin/tournaments/{tournament_id}/events
WS  /admin/tournaments/{tournament_id}/ws
GET /public/tournaments/{slug}/events
```

## Phase 1 Test Coverage

Required tests:

- Duplicate registration is rejected.
- Duplicate game UID is rejected.
- Public registration response excludes contact values.
- Group generation excludes rejected/waitlisted/withdrawn registrations.
- Check-in is per session.
- Old Discord check-in button returns current status.
- Score totals match formula.
- Penalty requires reason.
- Approved score updates leaderboard snapshot.
- Pending score does not affect public leaderboard by default.
- Dispute acceptance creates score correction and audit log.
- Locked rule set cannot be edited without Super Admin correction.
- Event outbox rows are created for important mutations.
