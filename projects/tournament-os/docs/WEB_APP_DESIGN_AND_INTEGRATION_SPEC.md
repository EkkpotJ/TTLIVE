# Web App Design And Integration Spec

Status: Product and architecture draft.

This document defines what the Tournament OS web app should contain, how the public and admin sides should behave, and how it should connect to FastAPI, Discord, and later overlay systems.

The key principle is simple:

FastAPI owns tournament truth. The web app, Discord bot, and overlays only submit requests or display approved backend data.

## Product Shape

Tournament OS should have two web surfaces:

1. Admin web app for organizers, admins, score admins, and referees.
2. Public web pages for players, viewers, casters, and live stream use.

They may share the same frontend codebase later, but they must not share the same data serializers. Public pages need separate responses that cannot expose private contact data, private evidence links, admin notes, or audit internals.

## Design Direction

Use an operational dashboard style.

The admin app should feel:

- Fast
- Dense but readable
- Calm under pressure
- Table-first
- Status-driven
- Optimized for repeated actions

The public pages should feel:

- Clear
- Esports-friendly
- Mobile-readable
- Safe to share on stream
- Focused on rankings, groups, and official status

Avoid a marketing-style landing page for MVP. The first screen after login should be the actual tournament control surface.

## Core Navigation

Admin navigation should be stable across the app:

- Dashboard
- Tournaments
- Registrations
- Groups
- Scores
- Leaderboard
- Disputes
- Exports
- Audit Log
- Settings

For a single tournament view, use tabs:

- Overview
- Rules
- Registrations
- Groups
- Rounds
- Scores
- Leaderboard
- Disputes
- Audit
- Export

## Admin Pages

### Admin Dashboard

Purpose:

Give the organizer a quick command center.

Required widgets:

- Active tournament card
- Current tournament status
- Registration count by status
- Approved player count
- Current stage and group count
- Pending scores
- Open disputes
- Next required action
- Recent audit events

Primary actions:

- Create tournament
- Open registration
- Close registration
- Generate groups
- Start tournament
- Enter scores
- Review scores
- Publish leaderboard
- Export results

Realtime:

- Registration count updates
- Score pending count updates
- Dispute count updates
- Tournament status updates

### Tournament Setup

Purpose:

Create and lock the event configuration.

Required controls:

- Game
- Tournament name
- Public slug
- Participant type
- Max participants
- Registration open/close time
- Tournament model
- Lobby size
- Games per stage
- Final games
- Advancement rule
- Placement points
- Tie-break order
- Bye behavior
- Verification policy
- Public visibility settings

Important UX:

- Tournament setup should use a step-based flow: Basic Info, Choose Ruleset, Configure Rules, Review Structure, Validate/Lock, Open Registration.
- Ruleset choices should come from `RULESET_SELECTION_AND_CREATION_UI.md`.
- Show validation errors before lock.
- Show a readable rule summary before lock.
- Locking rules should require confirmation.
- After lock, edits should be disabled except Super Admin correction with reason.

### Registration Management

Purpose:

Review and approve players quickly.

Required table columns:

- Display name
- In-game name
- Game UID
- Status
- Submitted time
- Review note
- Admin action

Private/admin-only columns:

- Contact method
- Contact value
- Internal notes

Required actions:

- Approve
- Reject
- Waitlist
- Withdraw
- Bulk approve selected
- Search by name or UID
- Filter by status

Speed target:

Approving or rejecting one player should take one click plus optional reason when required.

### Group / Lobby Management

Purpose:

Assign approved players into lobbies and lock groups before play.

Required views:

- Lobby cards or columns
- Player list per lobby
- Unassigned approved players
- Waitlisted players
- Group generation preview
- Lock group action

Required actions:

- Generate groups
- Regenerate groups before lock
- Move player between lobbies before lock
- Mark no-show
- Mark checked-in for the current check-in session
- Lock groups

Realtime:

- Group lock state updates
- Session-level check-in/no-show updates

MVP can use buttons and tables. Drag/drop is optional and should not block the first build.

### Score Entry

Purpose:

Let admins enter one lobby game result with minimal friction.

Recommended layout:

- Tournament selector or current tournament context
- Stage selector
- Lobby selector
- Game number selector
- 8 player rows
- Placement dropdown per row
- Auto-calculated placement points
- Penalty input with required reason
- Evidence reference field
- Save draft
- Submit for review

Important UX:

- Prevent duplicate placements in one game.
- Warn if a player is missing a placement.
- Calculate points instantly on the client for preview only.
- Official calculation must come from FastAPI response.
- Show differences if backend calculation returns different totals.

Speed target:

Entering one 8-player game should take under 60 seconds after the admin knows the placements.

### Score Review

Purpose:

Let referees/admins verify submitted scores.

Required views:

- Pending verification queue
- Score evidence reference
- Placement and point summary
- Changed fields since previous version
- Approve action
- Reject/request correction action
- Open dispute marker

Required actions:

- Approve score
- Return to draft
- Correct with reason
- Finalize score

### Leaderboard Admin

Purpose:

Show complete ranking state, including unofficial statuses.

Required columns:

- Rank
- Player
- Lobby/group
- Game scores
- Stage total
- Tie-break details
- Qualification status
- Score status
- Dispute status

Required filters:

- Stage
- Group
- Score status
- Qualification status

Realtime:

- Approved score updates
- Rank changes
- Qualification changes
- Dispute status changes

### Dispute Review

Purpose:

Resolve player score disputes with an audit trail.

Required columns:

- Player
- Tournament
- Stage
- Round/game
- Score being disputed
- Reason
- Evidence reference
- Status
- Opened time

Required actions:

- Mark under review
- Accept
- Reject
- Cancel duplicate
- Correct score after accepted dispute

Every resolution needs a note.

### Audit Log

Purpose:

Make sensitive changes traceable.

Required filters:

- Actor
- Entity type
- Action
- Time range
- Tournament

Required data:

- Actor
- Action
- Entity
- Before value when practical
- After value when practical
- Reason
- Timestamp

### Export Page

Purpose:

Generate files for reporting and after-event review.

MVP exports:

- Leaderboard Excel
- Registration summary Excel

Later exports:

- PDF result report
- Public recap report
- Sponsor report

## Public Pages

### Public Tournament Page

Required content:

- Tournament name
- Game
- Status
- Registration status
- Current stage
- Public rules summary
- Groups link
- Leaderboard link

Must not show:

- Contact data
- Admin notes
- Private evidence links
- Internal audit log

### Public Registration Page

MVP options:

- Public form if anonymous/player auth is chosen
- External form link if registration is still manual

Recommended fields for solo MVP:

- Display name
- In-game name
- Game UID
- Contact method
- Contact value

After submission:

- Show submitted status
- Tell player to wait for approval
- Do not expose other players private information

### Public Groups Page

Required content:

- Stage
- Lobby/group
- Approved players
- Session-level check-in/no-show status only if public rules allow it

### Public Leaderboard Page

Required content:

- Rank
- Player name
- Group/lobby
- Game scores
- Total
- Qualification status
- Score status label

Default:

- Show approved scores only.
- Hide pending scores unless tournament setting allows public pending visibility.
- Mark disputed scores clearly if visible.

### Stream-Safe View

Purpose:

Let the caster or OBS browser source show clean tournament data.

MVP can be a public page variant:

- No admin controls
- Large readable leaderboard
- Auto-refresh or realtime update
- Minimal navigation
- No private data

Later this can become a dedicated overlay endpoint.

## Realtime Dashboard Requirements

Realtime should be useful, not everywhere.

Use realtime for:

- Tournament status changes
- Registration counts
- Group lock and session-level check-in state
- Score submission/approval
- Leaderboard changes
- Dispute status changes
- Export job status
- Discord notification delivery status

Do not use realtime for:

- Static rule pages
- Historical audit browsing
- Draft setup forms before save

## Realtime Transport

Recommended approach:

- Use WebSocket for authenticated admin dashboard updates.
- Use Server-Sent Events or polling for public pages if WebSocket adds complexity.
- Use normal REST for mutations.

MVP fallback:

- Admin dashboard polls every 5-10 seconds.
- Public leaderboard polls every 10-15 seconds.

Later:

- WebSocket channels per tournament.
- Event stream for score and leaderboard updates.

## Event Model

Backend should publish internal events after important mutations.

Initial event names:

- `tournament.status_changed`
- `registration.submitted`
- `registration.approved`
- `registration.rejected`
- `registration.waitlisted`
- `groups.generated`
- `groups.locked`
- `score.submitted`
- `score.approved`
- `score.corrected`
- `score.finalized`
- `leaderboard.updated`
- `dispute.opened`
- `dispute.reviewed`
- `dispute.accepted`
- `dispute.rejected`
- `export.ready`
- `discord.notification_sent`
- `discord.notification_failed`

These events can feed:

- Admin realtime dashboard
- Discord notification worker
- Overlay/public update channels
- Audit-adjacent operational activity feed

## FastAPI Boundary

FastAPI should own:

- Authentication and authorization checks
- Registration state transitions
- Rule validation and lock
- Group generation
- Score calculation
- Score approval
- Leaderboard ranking
- Advancement calculation
- Dispute resolution
- Audit log creation
- Public/private serializer separation
- Realtime event emission

Frontend should own:

- Form state
- Input validation hints
- Sorting and filtering already-loaded tables
- Preview display
- Optimistic loading states
- Human-friendly status labels

Frontend must not own:

- Official score calculation
- Official ranking
- Advancement decisions
- Permission decisions
- Private/public data filtering

Discord bot must not own:

- Tournament state
- Score calculation
- Leaderboard ranking
- Dispute decisions

## Discord Integration

There are two possible Discord roles:

1. Notification channel
2. Input helper

MVP recommendation:

Start with Discord notifications only.

Notification examples:

- Registration opened
- Registration closed
- Groups published
- Round started
- Scores approved
- Leaderboard updated
- Dispute window opened/closed

Input helper examples for later:

- Player check-in for the current session
- Registration shortcut
- Score evidence submission
- Dispute submission

Discord architecture:

```text
Discord Bot
  -> calls FastAPI endpoints
  -> receives success/failure
  -> posts message to Discord

FastAPI
  -> validates permissions/rules
  -> writes PostgreSQL
  -> emits events
  -> returns official result
```

Discord should use bot/service credentials with scoped permissions.

## Performance Targets

These targets are practical for a small tournament system.

### Click And Navigation

- Page navigation after login: under 500 ms after first load when cached.
- Button action feedback: under 100 ms visual response.
- Mutation completion feedback: under 1 second for common actions.
- Table search/filter on loaded data: under 100 ms.

### Score Entry

- Placement change preview: immediate.
- Backend score calculation response: under 500 ms target.
- Save draft: under 1 second.
- Submit score: under 1 second.
- Approve score and leaderboard refresh: under 1-2 seconds.

### Realtime

- Admin dashboard update after backend mutation: under 2 seconds.
- Public leaderboard update after approval: under 3 seconds.
- Discord notification after important event: under 5 seconds.

### Data Volume Assumptions

MVP scale:

- 1 active tournament
- 16-64 players
- 1-8 lobbies per stage
- 2-3 games per stage
- Low concurrent admin count
- Public viewers can spike during live

Design for this first. Do not overbuild SaaS scale.

## UI State Patterns

Every important action should show:

- Loading state
- Success state
- Error state
- Permission-denied state when relevant
- Audit reason prompt for sensitive changes

Use confirmation dialogs for:

- Lock rule set
- Close registration
- Generate/regenerate groups after previous groups exist
- Lock groups
- Finalize scores
- Correct final score
- Archive tournament

Avoid confirmation dialogs for:

- Normal save draft
- Filtering
- Searching
- Opening detail panels

## Tables And Data Loading

Admin tables should support:

- Search
- Status filters
- Sorting
- Pagination or virtual scrolling later
- Row-level actions
- Bulk actions where safe

Initial tables:

- Tournaments
- Registrations
- Groups/participants
- Scores
- Disputes
- Audit logs

For MVP data size, backend pagination is still recommended because it keeps API contracts clean.

## Security And Privacy

Public pages must never expose:

- Contact method values
- Discord IDs unless explicitly public
- Email
- Phone
- Line ID
- Private evidence links
- Admin review notes
- Audit log before/after payloads

Admin pages must protect:

- Score correction
- Rule lock/unlock
- Group movement after lock
- Export downloads
- Evidence references
- Audit log access

## Recommended Frontend Stack

This is a recommendation, not a locked decision.

Good fit:

- React or Next.js frontend
- TanStack Query for API state
- TanStack Table for admin tables
- WebSocket or SSE client for realtime updates
- Component library with restrained dashboard styling

If keeping it simpler:

- Server-rendered admin pages can work early
- Use polling before WebSocket
- Add richer frontend only after API is stable

The key is not the framework. The key is keeping FastAPI as the business logic owner.

## MVP Screen Priority

Build in this order:

1. Admin tournament overview
2. Tournament setup/rule summary
3. Registration management
4. Group generation and lock
5. Score entry
6. Score review
7. Admin leaderboard
8. Public leaderboard
9. Dispute review
10. Excel export
11. Discord notification status
12. Stream-safe leaderboard view

## Do Not Build First

- Full Discord command system
- OCR upload and parsing
- Complex overlay editor
- Payment flow
- Sponsor dashboard
- Mobile app
- Public account system unless registration requires it
- Drag/drop group manager if tables are enough

## Backend Endpoints To Add Later

Realtime:

```text
GET /admin/tournaments/{tournament_id}/events
WS  /admin/tournaments/{tournament_id}/ws
GET /public/tournaments/{slug}/events
```

Operational summary:

```text
GET /admin/tournaments/{tournament_id}/dashboard
GET /admin/tournaments/{tournament_id}/activity
```

Discord:

```text
GET /admin/tournaments/{tournament_id}/discord/status
POST /admin/tournaments/{tournament_id}/discord/announce-registration-open
POST /admin/tournaments/{tournament_id}/discord/announce-groups
POST /admin/tournaments/{tournament_id}/discord/announce-leaderboard
```

Overlay or stream-safe data:

```text
GET /public/tournaments/{slug}/stream/leaderboard
GET /public/tournaments/{slug}/stream/groups
```

## Acceptance Checklist

The web app design is ready for implementation when:

- Admin and public surfaces are separated.
- Public data contracts exclude private fields.
- All official calculations come from FastAPI.
- Score entry can be completed quickly.
- Leaderboard updates after approval.
- Dashboard shows current action needed.
- Discord is treated as notification/input layer only.
- Realtime has a polling fallback.
- Audit reasons are required for sensitive changes.
- MVP screens are prioritized before advanced integrations.
