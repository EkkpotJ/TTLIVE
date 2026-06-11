# Discord Operations And Plugin Spec

Status: Architecture and product draft.

This document defines how Discord should support Tournament OS without becoming the source of truth.

Discord should make tournament operations smoother. It should not own tournament state, calculate scores, decide advancement, or replace FastAPI.

## Operating Principle

```text
PostgreSQL = source of truth
FastAPI = business logic and permission checks
Web app = main admin control surface
Discord bot = notification and input helper
Plugins/workers = optional processing helpers
```

If Discord, the bot, or a plugin is offline, tournament admins must still be able to run the event from the web app.

## Discord Role In The System

Discord has three useful roles:

1. Announcements
2. Player self-service
3. Admin/referee shortcuts

MVP should start with announcements and light self-service only.

## Recommended Discord Features By Phase

### Phase 1: Notification Helper

Purpose:

Keep players and viewers informed.

Features:

- Announce registration open.
- Announce registration closed.
- Announce groups/lobbies published.
- Announce round start.
- Announce score approved.
- Announce leaderboard updated.
- Announce dispute window open/closing.
- Announce final results.

Best implementation:

- Use Discord webhook or bot send-message worker.
- Trigger messages from backend events.
- Store delivery status in the backend.

### Phase 2: Player Self-Service

Purpose:

Let players check status without asking admins.

Commands:

```text
/tournament status
/register-status
/my-group
/my-score
/leaderboard
/dispute
```

Rules:

- Commands call FastAPI.
- FastAPI validates user mapping and permissions.
- The bot returns only the response FastAPI allows.
- Private responses should be ephemeral where possible.
- Check-in commands must use the current eligible check-in session, not a tournament-wide status.
- A player who checked in for Round 1 still needs a new check-in for Semi Final or Final if they qualify.

### Phase 3: Admin And Referee Shortcuts

Purpose:

Let trusted operators perform quick actions during live operations.

Commands:

```text
/admin approve-player
/admin waitlist-player
/admin check-in-session
/admin no-show
/score submit
/score approve
/dispute review
/announce groups
/announce leaderboard
```

Rules:

- Every command must map Discord user to a backend user.
- Every sensitive action must call FastAPI.
- FastAPI must create audit logs.
- Discord role alone is not enough; backend permission must approve the action.
- Admin check-in actions should target a specific check-in session.

### Phase 4: Evidence And Plugin Helpers

Purpose:

Reduce manual admin work after core flows are stable.

Features:

- Evidence upload helper
- OCR suggestion helper
- Result screenshot parsing
- Duplicate player detection
- Suspicious score warning
- Auto-summary of final results

Rules:

- Plugin output is a suggestion.
- Admin/referee approval is required before changing official score.
- All accepted suggestions create audit logs.

## Command Design

Use a small command set. Avoid command sprawl.

Recommended top-level commands:

```text
/tournament
/register
/group
/score
/leaderboard
/dispute
/admin
```

Examples:

```text
/tournament status
/tournament rules
/register status
/group mine
/score mine
/leaderboard current
/dispute open
/admin announce_groups
/admin approve_score
```

Design notes:

- Use autocomplete for tournament, stage, group, and player options later.
- Use message components/buttons for confirm actions where useful.
- Keep player commands simple and safe.
- Keep admin commands scoped to tournament channels.

Discord application commands support slash commands and context-menu style commands, so the command model can fit player and admin workflows without message parsing.

## Channel Structure

Recommended Discord channels:

```text
#tournament-announcements
#tournament-rules
#tournament-check-in
#tournament-support
#tournament-results
#admin-tournament-control
#referee-score-review
```

MVP can start with:

```text
#tournament-announcements
#tournament-results
#admin-tournament-control
```

## User Identity Mapping

The system needs a safe way to map Discord users to registrations.

Recommended model:

- Store `discord_id` on `users` or a future `user_identities` table.
- Let player connect Discord during registration or admin review.
- Do not use display name as identity.
- Do not expose Discord IDs publicly by default.

Required checks:

- One Discord ID maps to one backend user.
- One backend user maps to one approved registration per tournament.
- If mapping is missing, commands should tell the user to register or contact admin.

## Bot Architecture

Recommended architecture:

```text
Discord
  -> Bot interaction handler
  -> FastAPI command endpoint
  -> PostgreSQL transaction
  -> Event emitted
  -> Notification worker posts message
  -> Delivery status saved
```

The bot should be thin:

- Parse command
- Send request to FastAPI
- Format response
- Respect Discord rate limits
- Retry delivery when allowed

The bot should not:

- Store tournament state locally
- Calculate scores
- Decide leaderboard rank
- Approve disputes without FastAPI
- Hold private player data longer than needed

## Backend Endpoints For Discord

Use backend endpoints that are explicit and auditable.

```text
GET  /discord/tournaments/{tournament_id}/status
GET  /discord/tournaments/{tournament_id}/leaderboard
GET  /discord/players/me/registration-status
GET  /discord/players/me/group
GET  /discord/players/me/scores
POST /discord/disputes

POST /admin/discord/tournaments/{tournament_id}/announce-registration-open
POST /admin/discord/tournaments/{tournament_id}/announce-groups
POST /admin/discord/tournaments/{tournament_id}/announce-leaderboard
POST /admin/discord/tournaments/{tournament_id}/announce-final-results
```

Admin/referee command endpoints can reuse admin APIs if auth is clean, but separate `/discord/...` endpoints make command behavior easier to audit and test.

## Event And Queue Model

Discord delivery should be asynchronous.

Do not block score approval or registration approval while waiting for Discord.

Recommended flow:

```text
1. Admin approves score in web app.
2. FastAPI writes score and leaderboard update.
3. FastAPI writes event: leaderboard.updated.
4. Worker picks event.
5. Worker sends Discord message.
6. Worker records delivery success or failure.
```

This keeps live operations smooth even if Discord is slow.

## Delivery Reliability

Store outgoing Discord jobs.

Suggested fields:

- id
- tournament_id
- event_name
- target_channel_id
- message_type
- payload_json
- status
- attempt_count
- last_error
- next_retry_at
- sent_at
- created_at

Delivery statuses:

- `queued`
- `sending`
- `sent`
- `failed_retryable`
- `failed_permanent`
- `cancelled`

Retry rules:

- Retry temporary network errors.
- Retry HTTP 429 after the Discord-provided retry delay.
- Do not retry permission errors forever.
- Do not send duplicate announcements without idempotency keys.

Discord rate limits are route-specific and global. The bot should not hardcode limits; it should read the rate-limit headers and use retry information returned by Discord.

## Plugin Processing Layer

Plugins are optional processors that improve admin work without controlling official state.

Recommended plugin categories:

### Score Evidence Plugins

Examples:

- OCR screenshot reader
- Image quality checker
- Evidence duplicate detector
- Score table parser

Output:

- Suggested placements
- Confidence score
- Evidence notes
- Warnings

Never directly approves score.

### Tournament Insight Plugins

Examples:

- Detect duplicate UID/name similarity
- Flag unusual score jumps
- Recommend lobby distribution
- Generate post-event summary

Output:

- Suggestions
- Risk flags
- Draft text

### Communication Plugins

Examples:

- Discord announcement formatter
- Thai/English message template generator
- Schedule announcement generator
- Result recap generator

Output:

- Draft announcements
- Preview messages

### Export Plugins

Examples:

- Excel export formatter
- PDF report generator
- Sponsor summary generator

Output:

- Files or file references

## Plugin Contract

Each plugin should follow the same contract:

```text
Input:
  tournament_id
  entity_type
  entity_id
  plugin_config
  source_payload

Output:
  status
  confidence
  result_json
  warnings
  errors
  requires_admin_review
```

Plugin statuses:

- `pending`
- `running`
- `completed`
- `failed`
- `cancelled`

Rules:

- Plugins must be idempotent where practical.
- Plugins must not write official scores directly.
- Plugins can write suggestion records.
- Admin/referee must accept suggestion before official mutation.
- Plugin runs should be traceable from audit or activity logs.

## Suggested Plugin Tables

These tables can be added after Phase 1 if needed:

```text
plugin_runs
  id
  tournament_id
  plugin_name
  entity_type
  entity_id
  status
  input_json
  result_json
  confidence
  warnings_json
  error_message
  started_at
  finished_at
  created_by_user_id
  created_at

plugin_suggestions
  id
  plugin_run_id
  tournament_id
  suggestion_type
  target_entity_type
  target_entity_id
  status
  suggestion_json
  reviewed_by_user_id
  reviewed_at
  review_note
  created_at
```

Suggestion statuses:

- `pending_review`
- `accepted`
- `rejected`
- `expired`

## Continuous Operation Requirements

The tournament should continue if any helper fails.

Failure handling:

- Discord offline: web app still works.
- Plugin failed: admin enters score manually.
- Realtime channel disconnected: dashboard falls back to refresh/polling.
- Notification failed: retry job and show status in admin dashboard.
- Bot permission missing: show actionable error in Discord settings page.
- Rate limited: queue and retry instead of spamming.

## Discord Admin Dashboard Widgets

Add a Discord panel later in admin web app:

- Bot connected status
- Configured guild
- Announcement channel
- Results channel
- Admin command channel
- Last successful message
- Failed notification count
- Pending notification jobs
- Test announcement button

## Minimum Permissions

Keep Discord permissions narrow.

Likely bot permissions:

- Send Messages
- Use Slash Commands
- Embed Links
- Attach Files later if evidence export is needed
- Manage Webhooks only if the app creates/manages webhooks

Avoid broad admin permissions.

Webhook-based announcements are useful because incoming webhooks can post to channels without needing a bot user, but bot commands still need the application/bot path.

## Performance Targets

Discord command response:

- Acknowledge command quickly.
- For slow backend operations, return a pending/processing response and follow up.

Notification delivery:

- Normal announcement: within 5 seconds.
- Leaderboard update: within 5 seconds after backend approval.
- Retryable failure visible on admin dashboard: within 10 seconds.

Plugin processing:

- Lightweight formatter: under 2 seconds.
- OCR/screenshot processing: async, visible as processing.
- Export generation: async if longer than 3 seconds.

## MVP Recommendation

Build in this order:

1. Backend event table or event emitter.
2. Discord notification job queue.
3. Announcement webhook/bot worker.
4. Delivery status dashboard.
5. `/leaderboard` and `/my-score` read-only commands.
6. `/dispute open` command.
7. Admin/referee commands.
8. Plugin suggestion framework.
9. OCR/evidence plugins.

## Do Not Build First

- Full Discord registration before backend registration is stable.
- Score approval only through Discord.
- OCR auto-approval.
- Large plugin marketplace.
- Discord role sync as the only permission system.
- Local bot database as tournament source of truth.

## Acceptance Checklist

Discord and plugins are ready to implement when:

- FastAPI command endpoints are defined.
- Discord user mapping is defined.
- Notification events are defined.
- Delivery job storage is defined.
- Retry and rate-limit behavior is defined.
- Admin can run tournament without Discord.
- Plugins produce suggestions, not official results.
- Every accepted plugin suggestion creates an audit trail.
