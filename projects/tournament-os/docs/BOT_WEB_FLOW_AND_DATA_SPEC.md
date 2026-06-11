# Bot, Web Flow, And Data Spec

Status: Reality-check draft.

This document validates how Discord bot flows, web app flows, FastAPI, PostgreSQL, realtime updates, and player-facing messages should work together.

The goal is to avoid a common failure:

Discord shows one state, the admin web shows another state, and the database has a third state.

## Core Rule

Every user action must resolve through FastAPI and PostgreSQL before it becomes official.

```text
Discord button or command
  -> FastAPI
  -> PostgreSQL write transaction
  -> event/outbox record
  -> web dashboard refresh/realtime update
  -> Discord response or follow-up message
```

The same rule applies to web actions:

```text
Web admin action
  -> FastAPI
  -> PostgreSQL write transaction
  -> event/outbox record
  -> Discord notification job when needed
  -> public/player views update
```

## Reality Check Verdict

The planned system can work in real usage if these rules are implemented:

- Discord never decides official state by itself.
- Web app never calculates official score or advancement by itself.
- FastAPI returns the updated official state after every mutation.
- Realtime/polling updates are based on backend events.
- Public/player views use read-optimized endpoints, not raw admin tables.
- Discord buttons are treated as stale at any time and must be revalidated.

## User Identity Flow

Discord user identity:

```text
discord_user_id
  -> users.discord_id or user_identities.discord_id
  -> registrations where tournament_id = current tournament
  -> current allowed actions
```

The bot should never trust:

- Discord display name
- Server nickname
- Message text
- Button label

The bot can trust:

- Discord interaction user id
- Signed interaction payload from Discord
- FastAPI response after permission/state validation

## Player Registration Flow

### New Player Opens Tournament Message

Backend state:

```text
No registration exists for this discord_user_id and tournament_id.
Tournament status = registration_open.
Registration capacity not full.
```

Discord message should show:

```text
Golden Spatula Weekly
Registration is open.
Slots: 18 / 32

[Register] [Rules] [Leaderboard]
```

When player clicks `Register`:

```text
Discord interaction
  -> POST /discord/tournaments/{id}/registration/start
  -> FastAPI checks tournament status and existing registration
  -> FastAPI returns registration form/modal or registration URL
```

After submission:

```text
FastAPI creates registration: submitted
FastAPI emits registration.submitted
Admin dashboard registration count updates
Discord replies with submitted status
```

Player message:

```text
Registration submitted.
Status: Pending review

You will be notified after admin review.

[View Status] [Rules]
```

### Already Registered Player Opens Same Message

Backend state:

```text
registration.status in submitted, approved, waitlisted, rejected, withdrawn
```

Discord should not show `Register` unless the backend says resubmission is allowed.

Examples:

Submitted:

```text
You already registered.
Status: Pending review

[View Status] [Rules]
```

Approved:

```text
You are approved.
Next step: Wait for group assignment.

[My Group] [Rules] [Leaderboard]
```

Waitlisted:

```text
You are on the waitlist.
Admin will notify you if a slot opens.

[View Status] [Rules]
```

Rejected:

```text
Registration was not approved.
Reason: Contact admin for details.

[Contact Admin] [Rules]
```

Withdrawn:

```text
You withdrew from this tournament.

[View Status] [Contact Admin]
```

If resubmission is enabled, FastAPI can add:

```text
[Submit Again]
```

## Dynamic Button Rule

Buttons are display hints, not permission.

If a player clicks an old `Register` button after they already registered:

```text
FastAPI rejects duplicate registration.
Bot replies with latest status.
No duplicate record is created.
```

This requires:

- Unique registration per `tournament_id + user_id`.
- Unique `game_uid` per tournament.
- FastAPI validation before create.
- Discord interaction logs for debugging.

## Check-In Flow

Check-in is per session.

Example current session:

```text
Day 2 - Semi Final Check-In
status = open
eligible registrations = 16 semifinalists
```

Eligible player sees:

```text
Semi Final check-in is open.
Closes at 18:55.

[Check In] [My Group] [Rules]
```

After clicking:

```text
Discord interaction
  -> POST /discord/check-in/{session_id}
  -> FastAPI validates session is open
  -> FastAPI validates player is eligible
  -> FastAPI writes check_ins.status = checked_in
  -> FastAPI emits check_in.checked_in
  -> Admin dashboard updates checked-in count
  -> Bot replies success
```

Already checked-in player sees:

```text
You are already checked in.
Session: Day 2 - Semi Final
Checked in at: 18:31

[My Group]
```

Not eligible player sees:

```text
You are not required to check in for this session.

Reason: You are not assigned to this stage.
```

Closed session:

```text
Check-in is closed.
Please contact admin if this is a mistake.
```

Web relation:

- Admin check-in page updates checked-in count.
- Player row changes from `pending` to `checked_in`.
- Event feed shows who checked in and source = `discord_player`.

## Group Assignment Flow

Admin web action:

```text
Admin clicks Generate Groups
  -> FastAPI reads approved registrations
  -> FastAPI creates groups and group_participants
  -> FastAPI emits groups.generated
  -> Web admin shows generated lobbies
  -> Discord notification job announces groups
```

Player Discord command:

```text
/group mine
  -> FastAPI maps discord_user_id
  -> FastAPI finds registration and current group
  -> Bot replies with lobby, stage, and scheduled time
```

Player message:

```text
Your group
Stage: Round 1
Lobby: A
Players: 8
Check-in: Opens at 18:30

[Check In] [Rules]
```

## Score And Leaderboard Flow

Admin web action:

```text
Score Admin enters placements
  -> frontend previews points
  -> FastAPI calculates official totals
  -> score.status = submitted
  -> event score.submitted
```

Referee/admin approves:

```text
POST /admin/scores/{score_id}/approve
  -> FastAPI validates role
  -> FastAPI marks score approved
  -> FastAPI recalculates leaderboard read model
  -> FastAPI emits score.approved and leaderboard.updated
  -> Web leaderboard updates
  -> Discord notification job can announce leaderboard
```

Player `/my-score`:

```text
Round 1 - Lobby A
Game 1: 2nd place, 8 pts
Game 2: 5th place, 4 pts
Total: 12 pts
Status: Approved

[Leaderboard] [Dispute]
```

Public leaderboard:

```text
Rank  Player      G1  G2  Total  Status
1     Player A    10  8   18     Qualified
2     Player B    8   7   15     Qualified
```

## Dispute Flow

Player opens dispute from Discord:

```text
/dispute open
  -> Bot asks score/game selection
  -> Player submits reason
  -> FastAPI creates dispute.status = open
  -> event dispute.opened
  -> Admin dispute queue updates
```

Player message:

```text
Dispute submitted.
Score: Round 1 Lobby A Game 2
Status: Open

Admin/referee will review before results are finalized.
```

Admin web:

- Dispute count increases.
- Score row shows disputed marker.
- Referee can accept/reject with reason.

If accepted:

```text
FastAPI corrects score
audit_logs record correction
leaderboard read model updates
Discord can notify player privately
```

## Data Storage Layers

Separate data by usage pattern.

### Write Model

Tables that represent official state:

- users
- tournaments
- registrations
- stages
- groups
- group_participants
- rounds
- check_in_sessions
- check_ins
- scores
- disputes
- audit_logs

These are normalized and transaction-safe.

### Read Model

Tables or cached views optimized for fast display:

- tournament_dashboard_summaries
- leaderboard_snapshots
- public_tournament_summaries
- player_status_snapshots
- discord_message_jobs
- event_outbox

MVP can calculate some read models on demand, but leaderboard and dashboard should become cached/snapshotted once realtime updates are added.

### Event/Outbox Model

Use an event table so web, Discord, and workers read the same changes.

Suggested table:

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

Events:

- `registration.submitted`
- `registration.approved`
- `groups.generated`
- `check_in.checked_in`
- `check_in.no_show`
- `score.submitted`
- `score.approved`
- `leaderboard.updated`
- `dispute.opened`
- `discord.notification_failed`

## Fast Data Retrieval

Fast reads need purpose-built endpoints.

### Admin Dashboard Endpoint

```text
GET /admin/tournaments/{id}/dashboard
```

Should return:

- tournament status
- registration counts
- check-in counts for current session
- pending score count
- open dispute count
- current stage
- next action
- last events
- Discord delivery health

Target:

- Under 300 ms for MVP data size.

### Player Status Endpoint

```text
GET /discord/players/me/status?tournament_id=...
```

Should return:

- registration status
- allowed actions
- current group
- current check-in session
- check-in status
- latest score summary
- dispute status

This endpoint powers dynamic Discord buttons.

### Public Leaderboard Endpoint

```text
GET /public/tournaments/{slug}/leaderboard
```

Should return from `leaderboard_snapshots` or a read-optimized query.

Target:

- Under 300 ms for normal requests.
- Under 1 second during live viewer spikes.

## Suggested Read Tables

### leaderboard_snapshots

- id
- tournament_id
- stage_id
- group_id nullable
- version
- visibility
- snapshot_json
- generated_from_score_version
- created_at

Use:

- Public leaderboard
- Discord `/leaderboard`
- Stream-safe view

### player_status_snapshots

- id
- tournament_id
- user_id
- registration_id
- registration_status
- current_stage_id
- current_group_id
- current_check_in_session_id
- check_in_status
- latest_score_summary_json
- allowed_actions_json
- updated_at

Use:

- Discord dynamic buttons
- Player status page
- `/register-status`
- `/my-group`
- `/my-score`

### tournament_dashboard_summaries

- id
- tournament_id
- status
- registration_counts_json
- current_stage_id
- current_check_in_counts_json
- pending_score_count
- open_dispute_count
- discord_delivery_status_json
- next_action
- updated_at

Use:

- Admin dashboard
- Realtime dashboard refresh

## Data Flow For Display Consistency

After every mutation:

```text
1. Write official state.
2. Write audit log if required.
3. Rebuild affected read snapshot.
4. Insert event_outbox row.
5. Return updated state to caller.
6. Web dashboard refreshes or receives event.
7. Discord worker sends any notification.
```

This keeps Discord and web synchronized.

## Player-Facing Message Design

Messages should be short, status-first, and action-focused.

### Message Structure

```text
Title
Status line
Important details
Next action
Buttons
```

### Registration Open

```text
Golden Spatula Weekly
Registration is open.
Slots: 18 / 32

Use your real in-game name and UID.

[Register] [Rules] [Leaderboard]
```

### Registration Submitted

```text
Registration submitted.
Status: Pending review

Admin will review your registration.

[View Status] [Rules]
```

### Approved

```text
Registration approved.
You are in the tournament.

Next step: Wait for group assignment.

[My Group] [Rules]
```

### Check-In Open

```text
Check-in is open.
Session: Day 1 - Round 1
Closes: 18:55

[Check In] [My Group] [Rules]
```

### Checked In

```text
Checked in.
Session: Day 1 - Round 1
Status: Ready

[My Group]
```

### Leaderboard Updated

```text
Leaderboard updated.
Stage: Round 1

Top 4 from each lobby advance.

[View Leaderboard]
```

## Form Data Collection

Registration form fields:

- display_name
- in_game_name
- game_uid
- contact_method
- contact_value
- discord_user_id if from Discord

Storage:

- Public-safe identity: display_name, in_game_name
- Private contact: contact_method, contact_value
- Discord identity: users.discord_id or user_identities table

Privacy:

- Public pages show display_name or in_game_name only.
- Discord ID and contact fields stay private.
- Admin pages can see contact fields based on permission.

## Design Recommendations

### Discord Messages

Use:

- One clear title
- One status line
- 2-4 short detail lines
- Maximum 3-4 buttons
- Private/ephemeral responses for player-specific status

Avoid:

- Long rule text in messages
- Publicly posting private status
- Too many buttons
- Asking players to type complex data in channel chat

### Web Admin

Use:

- Tables for registration, scores, disputes
- Status badges
- Sticky action bar on score entry
- Current session card for check-in
- Realtime/polling counters

### Public Web

Use:

- Mobile-readable leaderboard
- Clear stage tabs
- Large rank and point values
- Minimal personal data
- Stream-safe display mode

## What Has Been Calculated To This Point

Already covered in the specification set:

- Tournament MVP rules
- Registration states
- Score calculation formula
- Advancement model
- Check-in session model
- Discord role and plugin boundaries
- Web app page list
- Realtime event names
- Database core entities

Added by this document:

- End-to-end Discord-to-web flow
- Dynamic button behavior
- Player message design
- Read/write data separation
- Read snapshot tables
- Display consistency rules
- Fast retrieval endpoint targets

## Remaining Implementation Decisions

Before coding:

- Choose whether registration form opens inside Discord modal or web page.
- Decide if `player_status_snapshots` is a physical table in Phase 1 or computed endpoint first.
- Decide whether leaderboard snapshots are rebuilt on every score approval or by background worker.
- Choose polling first or WebSocket/SSE first for admin dashboard.
- Decide auth strategy for mapping web users and Discord users.

## Acceptance Checklist

This flow is implementation-ready when:

- Every Discord button maps to one FastAPI endpoint.
- Every endpoint returns updated allowed actions.
- Old Discord buttons are safely rejected or converted to current status.
- Web dashboard updates from the same events as Discord.
- Public/player endpoints use private-safe serializers.
- Leaderboard reads do not require expensive recalculation on every public request.
- Admin can still operate tournament if Discord is down.
