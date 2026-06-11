# Phase 1 Implementation Decisions

Status: Recommended decisions to unlock backend implementation.

This file converts the remaining open questions into practical Phase 1 decisions.

## Decision Summary

Tournament OS should support the important system advantages from the start, but in a controlled MVP shape.

The goal is not to build every advanced feature immediately. The goal is to design and implement the foundation so the system does not need a rewrite when Discord, realtime, evidence images, and dashboards become important.

## Decisions

### 1. Use `tournament_user_roles` In Phase 1

Decision:

Implement tournament-scoped roles from the first backend build.

Reason:

Discord roles can change outside the system. Backend roles must be the official permission source.

Phase 1 scope:

- `super_admin`
- `tournament_admin`
- `score_admin`
- `referee`
- `player`
- `viewer`

Do not rely on Discord role for official permissions.

### 2. Use `user_identities` In Phase 1

Decision:

Implement `user_identities` from the first backend build.

Reason:

Players may enter from web, Discord, or future providers. A separate identity table prevents Discord-specific logic from leaking into registration and permission code.

Phase 1 scope:

- provider: `discord`
- provider: `local` or `manual`

### 3. Implement Event Outbox In Phase 1

Decision:

Implement `event_outbox` immediately.

Reason:

Web dashboard, Discord notifications, workers, and future realtime must react to the same backend events.

Phase 1 scope:

- write event rows during important mutations
- no complex worker required at first
- polling/worker can be added after events exist

### 4. Implement Read Models In Phase 1

Decision:

Implement read-optimized summaries from the start.

Required:

- `tournament_dashboard_summaries`
- `leaderboard_snapshots`
- `player_status_snapshots`

Reason:

These are a core advantage of the system: fast dashboard, fast Discord status, fast public leaderboard.

Phase 1 scope:

- Update snapshots synchronously after core mutations when simple.
- Move to background worker later if needed.

### 5. Implement Immutable Rule Snapshots In Phase 1

Decision:

Implement rule/formula versioning and lock snapshots.

Required fields:

- `version`
- `status`
- `locked_at`
- `locked_by_user_id`
- `config_snapshot_json`

Reason:

Scores must remain auditable even if future tournaments use different rules.

### 6. Implement Check-In Sessions In Phase 1

Decision:

Implement `check_in_sessions` and `check_ins` in Phase 1.

Reason:

Multi-round and multi-day tournaments need per-session check-in. Tournament-wide check-in is not enough.

Phase 1 scope:

- session per stage/day
- web/admin check-in
- Discord check-in endpoint can be supported if bot is included

### 7. Use Evidence URI In Phase 1, Prepare Attachments

Decision:

Use `evidence_uri` in Phase 1, but keep `attachments` in the schema plan as the next upgrade.

Reason:

Manual score flow should not be blocked by file storage. But evidence images are important enough that the data model must already point toward attachments.

Phase 1 scope:

- evidence URL/reference on score/dispute
- no OCR auto-processing
- no official result from image alone

Phase 2:

- `attachments`
- `score_evidence`
- `dispute_evidence`
- OCR/plugin suggestion records

### 8. Discord Notification Jobs Are Phase 1 Foundation

Decision:

Implement `discord_message_jobs` table in Phase 1 if Discord notifications are built early. If not, keep the table in the first migration only when a worker exists.

Recommendation:

Add the table early because Discord is a major operating surface.

Reason:

Sending Discord messages directly during score approval or registration approval can slow or break live operations.

### 9. Realtime Starts As Polling, Event-Ready

Decision:

Start with polling endpoints, but make events available through `event_outbox`.

Reason:

Polling is simpler and reliable for MVP. Event outbox keeps the door open for WebSocket/SSE without changing business logic.

Phase 1:

- dashboard polling
- public leaderboard polling
- event_outbox writes

Phase 2:

- WebSocket or SSE

## What To Build First

Build in this order:

1. PostgreSQL schema and enums
2. SQLAlchemy models
3. Alembic migration
4. Permission and identity services
5. Event outbox service
6. Tournament and rule set services
7. Registration service
8. Group generation service
9. Check-in service
10. Score calculation service
11. Leaderboard snapshot service
12. Dashboard/player status snapshot service
13. Dispute service
14. Discord notification job service
15. Public-safe serializers

## What Not To Build First

- OCR auto-read as official score
- Full Discord role sync automation
- Payment
- Sponsor reports
- Overlay editor
- Team registration workflow
- SaaS multi-tenant admin

## Final Recommendation

Phase 1 should be more than a thin CRUD backend.

It should include the core architecture advantages:

- backend-owned permissions
- Discord-safe identity mapping
- event outbox
- read snapshots
- immutable rule snapshots
- session-level check-in
- audit logs
- public/private data separation

These are not extra polish. They are the foundation that makes Tournament OS reliable during a real live tournament.
