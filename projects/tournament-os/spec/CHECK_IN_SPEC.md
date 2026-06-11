# Check-In Specification

Status: MVP behavior draft.

Check-in must be tracked per tournament session, not once per whole tournament.

Reason:

A player can compete across multiple stages, lobbies, and days. A check-in from Day 1 must not automatically mean the player is present for Day 2, Semi Final, or Final.

## Core Rule

Check-in is required per scheduled competition session.

A session can represent:

- One tournament day
- One stage on a day
- One group/lobby start
- One round/game block

MVP recommendation:

Use one check-in session per stage per tournament day.

Example:

```text
Day 1 - Round 1 check-in
Day 2 - Semi Final check-in
Day 2 - Final check-in
```

For a same-day tournament, separate check-ins are still useful when there is a long break before Final.

## Recommended MVP Policy

| Area | Decision |
| :--- | :--- |
| Check-in level | Stage session |
| Who must check in | Players assigned to that stage/session |
| Default open time | 30 minutes before session start |
| Default close time | 5 minutes before session start |
| Missed check-in | Mark as `no_show_pending` or `no_show` based on admin decision |
| Admin override | Allowed with reason and audit log |
| Replacement | Waitlisted player may replace before lobby starts |
| Public visibility | Optional; default admin-only |

## How Many Times Should A Player Check In?

A player should check in once for every session they are expected to play.

### 16 Player One-Day Event

```text
Round 1 session: all 16 players check in.
Final session: only 8 finalists check in again.
```

Total check-ins:

- Eliminated player: 1
- Finalist: 2

### 32 Player Two-Day Event

```text
Day 1 Round 1 session: all 32 players check in.
Day 2 Semi Final session: 16 qualified players check in.
Day 2 Final session: 8 finalists check in.
```

Total check-ins:

- Eliminated in Round 1: 1
- Eliminated in Semi Final: 2
- Finalist: 3

### 64 Player Multi-Day Event

```text
Day 1 Round 1 session: all 64 players check in.
Day 2 Round 2 session: 32 qualified players check in.
Day 3 Semi Final session: 16 qualified players check in.
Day 3 Final session: 8 finalists check in.
```

Total check-ins depend on how far the player advances.

## Check-In Session Lifecycle

```text
Draft
  -> Open
  -> Closed
  -> Locked
  -> Archived
```

Rules:

- `Draft`: admins can edit time and target participants.
- `Open`: players/admins can check in eligible participants.
- `Closed`: normal player check-in is disabled.
- `Locked`: no changes except admin override with audit reason.
- `Archived`: historical only.

## Player Check-In Status

```text
Not Required
  -> Pending
  -> Checked In
  -> Late Checked In
  -> No Show Pending
  -> No Show
  -> Excused
  -> Replaced
```

| Status | Meaning |
| :--- | :--- |
| `not_required` | Player is not expected in this session |
| `pending` | Player is expected but has not checked in |
| `checked_in` | Player checked in during open window |
| `late_checked_in` | Player checked in after close by admin override |
| `no_show_pending` | Player missed window; admin has not finalized action |
| `no_show` | Player is treated as absent |
| `excused` | Admin marked player excused |
| `replaced` | Player was replaced by another participant |

## Database Entities

### check_in_sessions

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

### check_ins

- id
- check_in_session_id
- tournament_id
- registration_id
- group_participant_id nullable
- status
- checked_in_at
- checked_in_by_user_id
- source
- note
- replaced_by_registration_id nullable
- created_at
- updated_at

`source` values:

- `web_player`
- `web_admin`
- `discord_player`
- `discord_admin`
- `system`

## Constraints

- Unique `check_ins(check_in_session_id, registration_id)`.
- A player can have many check-ins across different sessions.
- A player cannot check into a session where they are not eligible.
- A closed session requires admin override for new check-ins.
- A locked session requires Super Admin or Tournament Admin correction with reason.

## Eligibility Rules

For Round 1:

- Approved registrations assigned to Round 1 groups are eligible.

For later stages:

- Only advanced/qualified participants are eligible.

For Final:

- Only finalists are eligible.

Waitlisted players:

- Not eligible unless promoted or used as replacement.

Withdrawn/rejected players:

- Not eligible.

## Discord Behavior

Discord can show a `Check in` button only when:

- The player is mapped to a backend user.
- The player has an eligible registration.
- The current check-in session is `Open`.
- The player status is `pending`.

If the player already checked in, Discord should show:

```text
You are checked in for Day 1 - Round 1.
```

If the player tries to press an old button:

- Bot sends request to FastAPI.
- FastAPI rejects duplicate check-in.
- Bot responds with current status.

## Web Admin Behavior

Admin check-in page should show:

- Session name
- Open/close time
- Eligible players
- Checked-in count
- Pending count
- No-show pending count
- No-show count
- Replacement actions

Admin actions:

- Open session
- Close session
- Mark checked in
- Mark no-show pending
- Mark no-show
- Mark excused
- Replace with waitlisted player
- Lock session

Sensitive actions require reason:

- Late check-in
- Mark no-show after close
- Replace player
- Edit locked session

## Advancement Impact

Check-in does not directly decide score.

Check-in affects operational eligibility:

- A player who does not check in may be marked no-show.
- A no-show player may be removed or replaced before the lobby starts.
- If the player is removed, group assignment and advancement inputs should update through backend service rules.

The backend must create audit logs for no-show, replacement, and admin override.

## Public Visibility

Default MVP:

- Do not show check-in status publicly.

Optional later:

- Public group page can show `Ready` or `Not checked in` only if rules allow.
- Never show private contact details or admin notes.

## API Draft

```text
POST /admin/tournaments/{tournament_id}/check-in-sessions
GET  /admin/tournaments/{tournament_id}/check-in-sessions
GET  /admin/check-in-sessions/{session_id}
POST /admin/check-in-sessions/{session_id}/open
POST /admin/check-in-sessions/{session_id}/close
POST /admin/check-in-sessions/{session_id}/lock
POST /admin/check-in-sessions/{session_id}/check-ins/{registration_id}/mark
POST /admin/check-in-sessions/{session_id}/replace

GET  /tournaments/{tournament_id}/check-in/me
POST /tournaments/{tournament_id}/check-in/{session_id}

POST /discord/check-in/{session_id}
GET  /discord/check-in/me
```

## MVP Decision

For first implementation:

- Store check-in as dedicated `check_in_sessions` and `check_ins` tables.
- Create sessions per stage/day.
- Let Discord and web call the same FastAPI check-in logic.
- Keep manual admin override.
- Do not let Discord directly decide no-shows or replacements.
