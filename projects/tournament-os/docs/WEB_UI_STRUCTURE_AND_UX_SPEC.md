# Web UI Structure And UX Spec

Project: Tournament Operating System  
Status: Phase 1 UX/UI structure draft

## Purpose

Define the screens, layout, and interaction model for Tournament OS.

This document focuses on what the web app should look and feel like for real tournament operations.

The UI must support fast admin work during live events while keeping public and stream-safe pages clean, readable, and private-data safe.

## Product Surfaces

Tournament OS should have four web surfaces:

1. Admin app
2. Player/public pages
3. Caster/stream-safe pages
4. Minimal operator status views

These surfaces may share frontend components, but they must not share the same data serializers.

## Design Direction

### Admin App

The admin app should feel:

- operational
- dense but readable
- fast
- table-first
- status-driven
- calm under pressure

Do not design it like a landing page.

The first screen after login should be the tournament control surface.

### Public Pages

Public pages should feel:

- esports-friendly
- clear
- mobile-readable
- focused on official status
- safe to share publicly

### Stream-Safe Pages

Stream-safe pages should feel:

- broadcast-ready
- large-text
- low-noise
- stable during refresh
- readable at 1080p
- usable as OBS Browser Source or TikTok Live Studio browser/web source

## Visual System

### Layout

Admin layout:

```text
Top bar
  - tournament switcher
  - current status
  - user/account menu

Left sidebar
  - Dashboard
  - Tournaments
  - Registrations
  - Groups
  - Check-In
  - Scores
  - Leaderboard
  - Disputes
  - Export
  - Audit
  - Settings

Main content
  - page header
  - key actions
  - filters
  - table/working area
  - side panel or modal for detail/edit
```

Public layout:

```text
Header
  - tournament name
  - status
  - nav links

Main content
  - rules summary
  - groups
  - leaderboard
  - player status
```

Stream layout:

```text
Fullscreen or fixed canvas
  - tournament title
  - current stage/lobby
  - leaderboard or group list
  - compact footer/status
```

### Color And Status

Use restrained colors. Status colors should mean the same thing everywhere.

| Status Meaning | Suggested Use |
| :--- | :--- |
| Draft / setup | neutral gray |
| Open / active | green |
| Waiting / pending | amber |
| Locked / final | blue |
| Error / rejected / disputed | red |
| Private/admin-only | muted label, not bright |

Do not rely on color alone. Pair status colors with text labels.

### Typography

Admin app:

- compact table text
- clear page titles
- readable button labels
- avoid oversized hero text

Stream-safe pages:

- large rank numbers
- large player names
- high contrast totals
- minimal secondary text

### Components

Use standard dashboard components:

- tables for registrations, scores, disputes, audit logs
- tabs for tournament detail sections
- side panels for row details
- modals for confirmations and audit reasons
- segmented controls for stage/lobby filters
- dropdowns for placement selection
- badges for statuses
- buttons with clear icons where useful
- toast notifications for quick result feedback

Avoid nested cards. Use cards only for repeated items, summary widgets, or stream-safe blocks.

## Admin Information Architecture

### 1. Login

Purpose:

Authenticate staff.

Required:

- login form or auth provider entry
- error state
- loading state

After login:

- route to Admin Dashboard

### 2. Admin Dashboard

Purpose:

Give a command center for the current tournament.

Layout:

```text
Header: Active tournament + status + next action

Summary row:
  Registrations | Check-In | Pending Scores | Open Disputes

Main work queue:
  - next action card
  - pending verification list
  - recent activity

Right column:
  - current stage/lobby
  - Discord delivery status later
  - stream-safe link quick copy
```

Primary actions:

- Create tournament
- Open/close registration
- Generate groups
- Open/close check-in
- Enter scores
- Review scores
- Publish/export

UX notes:

- The dashboard should always answer: "What needs action now?"
- Avoid showing too many historical charts in MVP.

### 3. Tournament Setup Wizard

Purpose:

Create a tournament without missing rule requirements.

Steps:

1. Basic Info
2. Choose Ruleset
3. Configure Rules
4. Review Structure
5. Validate And Lock
6. Open Registration

Important UI:

- stepper at top
- rule summary side panel
- validation checklist
- disabled lock button until valid
- confirmation modal for lock

Required fields:

- name
- game
- public slug
- participant type
- max participants
- registration open/close
- tournament model
- placement points
- stage plan
- tie-break order
- public visibility settings

### 4. Registration Management

Purpose:

Approve players quickly and safely.

Layout:

```text
Toolbar:
  search | status filter | bulk actions

Table:
  display name
  in-game name
  game UID
  status
  submitted time
  review note
  actions

Side panel:
  contact/private details
  history
  admin notes
```

Actions:

- approve
- reject with reason
- waitlist
- withdraw
- bulk approve selected

UX notes:

- Public/private fields must be visually separated.
- One-player approval should be possible in one click if no reason is required.

### 5. Group And Lobby Management

Purpose:

Generate and adjust lobbies.

MVP layout:

```text
Stage selector
Group generation button
Lock groups button

Lobby columns or table groups:
  Lobby A
  Lobby B
  ...

Side list:
  unassigned approved players
  waitlisted players
```

Actions:

- generate groups
- regenerate before lock
- move player before lock
- lock groups
- mark no-show
- replacement workflow later

UX notes:

- Drag/drop is optional.
- Table-based move controls are acceptable for MVP.
- Post-lock movement must open reason modal.

### 6. Check-In Console

Purpose:

Run check-in for a session/stage/day.

Layout:

```text
Session header:
  stage
  open/close time
  countdown
  checked-in count

Table:
  player
  lobby
  check-in status
  time
  actions
```

Actions:

- open session
- close session
- admin mark checked-in
- mark no-show
- override late check-in with reason

UX notes:

- Show countdown clearly.
- Duplicate check-in should not look like an error; show current state.

### 7. Score Entry

Purpose:

Enter one lobby game result quickly.

Layout:

```text
Context selector:
  tournament | stage | lobby | game

Score grid:
  player
  placement dropdown
  placement points
  penalty
  penalty reason
  evidence URI

Footer:
  calculated preview
  save draft
  submit for review
```

UX notes:

- Prevent duplicate placement.
- Highlight missing placement.
- Client preview is allowed, but official result must come from FastAPI response.
- Score entry for one 8-player lobby should take under 60 seconds.

### 8. Score Review

Purpose:

Let referee/admin verify score submissions.

Layout:

```text
Queue left:
  pending scores

Detail right:
  placements
  calculated points
  evidence
  changes
  approve/reject/correct actions
```

Actions:

- approve
- return to draft
- correct with reason
- finalize

UX notes:

- Correction and finalize require confirmation.
- Reason modal is required for sensitive actions.

### 9. Leaderboard Admin

Purpose:

Show complete ranking including admin-only status.

Required columns:

- rank
- player
- lobby/group
- game scores
- stage total
- tie-break detail
- qualification status
- score status
- dispute status

UX notes:

- Admin leaderboard may show pending/disputed info.
- Public leaderboard must use separate serializer.

### 10. Dispute Review

Purpose:

Resolve score disputes.

Layout:

```text
Dispute queue
  player
  score
  reason
  status
  opened time

Detail panel
  disputed score
  evidence
  admin notes
  audit history
```

Actions:

- mark under review
- accept
- reject
- correct score

Every resolution requires note.

### 11. Export

Purpose:

Generate after-event files.

MVP:

- leaderboard Excel
- registration summary Excel

UX notes:

- Export action should show generating/ready/error states.
- Export should create audit log.

### 12. Audit Log

Purpose:

Trace sensitive changes.

Filters:

- actor
- entity
- action
- time range
- tournament

UX notes:

- Audit log is admin-only.
- Do not show audit payload on public pages.

## Public / Player Pages

### Public Tournament Page

Content:

- tournament name
- game
- status
- registration status
- current stage
- public rules summary
- links to groups and leaderboard

### Public Registration Page

Content:

- display name
- in-game name
- game UID
- contact method
- contact value

After submit:

- show submitted status
- show next step
- do not expose other player private data

### Player Status Page

Content:

- registration status
- current group/lobby
- current check-in session
- check-in status
- latest approved score
- allowed actions

Primary actions:

- check in
- view group
- view leaderboard
- file dispute when allowed

### Public Groups Page

Content:

- stage selector
- lobby list
- approved player display names
- public-safe check-in/no-show only if allowed

### Public Leaderboard Page

Content:

- rank
- player name
- group/lobby
- game scores
- total points
- qualification status
- score status label

Default:

- approved/final scores only
- pending hidden unless public visibility allows it

## Caster / Stream-Safe Pages

### Stream Leaderboard

Purpose:

Show clean leaderboard on live stream.

Recommended canvas:

- 1920x1080 friendly
- also usable in cropped browser source

Layout:

```text
Top:
  tournament name | current stage

Main:
  rank | player | lobby | total | qualification

Footer:
  official / updated time
```

Rules:

- no admin controls
- no contact data
- no private evidence
- no audit data
- no draft scores
- stable layout on refresh

### Stream Groups

Purpose:

Show lobby assignments during live.

Layout:

```text
Stage title
Lobby A | Lobby B | Lobby C | Lobby D
player names
```

UX notes:

- Text must be readable on stream.
- Avoid dense admin table controls.

## Mobile Behavior

Admin mobile:

- usable for emergency review/check-in
- not optimized for full score-entry workflow first

Player mobile:

- registration
- check-in
- status
- leaderboard
- dispute submission

Public mobile:

- leaderboard should stack columns cleanly
- hide lower-priority columns before wrapping badly

## MVP Screen Priority

Build order:

1. Admin Dashboard
2. Tournament Setup Wizard
3. Registration Management
4. Group And Lobby Management
5. Check-In Console
6. Score Entry
7. Score Review
8. Admin Leaderboard
9. Public Tournament Page
10. Public Leaderboard
11. Player Status Page
12. Dispute Review
13. Export
14. Stream Leaderboard
15. Stream Groups

## Do Not Build First

- marketing landing page
- full overlay editor
- drag/drop if table controls are enough
- public account system unless registration auth requires it
- complex theme builder
- sponsor dashboard
- OCR review UI before manual evidence flow works

## UX Acceptance Criteria

The web UI structure is ready when:

- Admin and public surfaces are clearly separated.
- Score entry can be completed fast with minimal typing.
- Sensitive actions request reason.
- Public and stream-safe screens cannot expose private data.
- Stream-safe pages are readable in OBS/TikTok Live Studio.
- Dashboard always shows next required action.
- Every important mutation has loading/success/error states.
- UI never calculates official score, rank, advancement, or permission.
