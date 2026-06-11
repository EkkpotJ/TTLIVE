# MVP Ruleset

Status: Proposed baseline for first backend build.

This file narrows the Tournament Operating System into the smallest useful version that still matches the long-term architecture.

## Purpose

The MVP should let one organizer run a small Golden Spatula tournament without spreadsheet score calculation.

It should prove:

- Registration review
- Group generation
- Score entry
- Backend score calculation
- Manual score approval
- Public leaderboard
- Audit trail

It should not prove Discord automation, OCR, payments, SaaS tenancy, or advanced overlays.

## Locked MVP Defaults

These defaults are intentionally conservative.

| Area | MVP Decision |
| :--- | :--- |
| Game | Golden Spatula |
| Participant type | Solo |
| Target size | 16 or 32 players |
| Maximum size for MVP code path | 64 players |
| Lobby size | 8 players |
| Primary model | Group Points Qualifier |
| Secondary model | Fixed Points |
| Grouping | Random approved players, admin-adjustable before lock |
| Score formula | Placement points only by default |
| Placement points | 1st=10, 2nd=8, 3rd=7, 4th=6, 5th=4, 6th=3, 7th=2, 8th=1 |
| Bonus points | Disabled by default |
| Penalty points | Manual only, requires reason |
| Score reset policy | Reset each stage |
| Advancement | Top N per lobby |
| Default advancement | Top 4 per lobby |
| Check-in | Per stage/day session, stored in dedicated check-in records |
| Score approval | Manual approval required |
| Dispute window | 15 minutes after score publication |
| Public leaderboard | Approved scores only by default |
| Export priority | Excel first, PDF later |

## Supported MVP Tournament Shapes

### 16 Players

```text
Round 1
  2 lobbies
  8 players per lobby
  2 games per lobby
  Top 4 per lobby advance

Final
  1 lobby
  8 players
  3 games
  Highest final-stage total wins
```

### 32 Players

```text
Round 1
  4 lobbies
  8 players per lobby
  2 games per lobby
  Top 4 per lobby advance

Semi Final
  2 lobbies
  8 players per lobby
  2 games per lobby
  Top 4 per lobby advance

Final
  1 lobby
  8 players
  3 games
  Highest final-stage total wins
```

### 64 Players

64 players may be represented by the data model, but the first real event should avoid this unless 16 and 32 player flows are already tested.

```text
Round 1
  8 lobbies
  8 players per lobby
  2 games per lobby
  Top 4 per lobby advance

Round 2
  4 lobbies
  8 players per lobby
  2 games per lobby
  Top 4 per lobby advance

Semi Final
  2 lobbies
  8 players per lobby
  2 games per lobby
  Top 4 per lobby advance

Final
  1 lobby
  8 players
  3 games
  Highest final-stage total wins
```

## Business Rule Clarifications

### Registration

- One player can register once per tournament.
- `game_uid` must be unique inside the tournament.
- Only `Approved` registrations can be placed into groups.
- Waitlisted players are not grouped until promoted to `Approved`.
- Private contact fields must never appear in public responses.

### Group Lock

Admin may edit groups until the tournament enters `Ready`.

After `Ready`, moving a player requires:

- Tournament Admin or Super Admin permission
- Reason
- Audit log entry

After `Live`, moving a player should be allowed only for exceptional correction.

### Check-In

Check-in is not a one-time tournament status.

Players should check in once for every session they are expected to play. A session usually maps to one stage on one tournament day.

Examples:

- 16-player event: Round 1 check-in for all players, Final check-in again for finalists.
- 32-player two-day event: Day 1 Round 1 check-in, Day 2 Semi Final check-in, Day 2 Final check-in.
- 64-player multi-day event: each qualified stage/day requires a new check-in.

Default MVP behavior:

- Open check-in 30 minutes before session start.
- Close check-in 5 minutes before session start.
- Only eligible players for that session can check in.
- Late check-in requires admin override and audit reason.
- Missed check-in can become no-show or replacement decision by admin.
- Discord can submit check-in, but FastAPI decides whether it is valid.

### Score Calculation

The backend calculates:

```text
total_points = placement_points + bonus_points + bye_points - penalty_points
```

For MVP:

- `bonus_points` defaults to 0
- `bye_points` defaults to 0
- `penalty_points` defaults to 0 unless manually entered
- Manual total override is not part of normal MVP flow

### Score Approval

Score states should flow:

```text
Draft -> Submitted -> Pending Verification -> Approved -> Final
```

If a player disputes an approved score:

```text
Approved -> Disputed -> Corrected -> Approved -> Final
```

Approved scores count on leaderboard.

Final scores are locked except for Super Admin correction with audit reason.

### Advancement

For MVP, advancement is calculated from approved scores only.

Recommended tie-break order:

1. Higher total points in current stage
2. More 1st place finishes in current stage
3. Better average placement in current stage
4. Higher latest game score
5. Better latest game placement
6. Admin decision with audit reason

### Bye Handling

Default MVP bye behavior: advance-only.

Do not award bye points unless the tournament rules explicitly announce a fixed rule before registration closes.

### Disputes

Players can dispute their own score within the dispute window.

Disputes must reference:

- Tournament
- Stage or round
- Score
- Explanation
- Optional evidence reference

Accepted disputes must create:

- Score correction
- Audit log entry
- Resolution note

## Out Of MVP

- Team registration as a required first path
- Discord bot commands
- OCR result extraction
- Payments
- Prize payment tracking
- Public login
- Multi-tenant SaaS organization model
- Checkmate final
- Lobby shuffle
- Advanced sponsor reports

## Next Action

Use this ruleset to produce:

1. Final ER diagram
2. PostgreSQL schema
3. Rule engine interface
4. FastAPI service boundaries
5. Check-in session service boundaries
6. Score calculation and state transition tests
