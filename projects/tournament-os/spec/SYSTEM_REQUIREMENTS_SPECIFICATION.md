# System Requirements Specification

Project: Tournament Operating System  
Subsystem: TTLIVE Tournament OS  
Status: Phase 1 review draft  
Primary game: Golden Spatula  
Primary implementation direction: FastAPI + PostgreSQL

## 1. Purpose

Tournament Operating System is a web-backed system for running game tournaments from registration to final results.

The system should reduce manual work in spreadsheets, chat messages, screenshots, and repeated announcements while keeping tournament results transparent, auditable, and safe to show publicly.

This SRS defines the required Phase 1 capabilities before backend implementation starts.

## 2. Scope

### In Scope For Phase 1

- Solo Golden Spatula tournament management
- Tournament creation with ruleset/preset selection
- Fixed Points and Group Points Qualifier models
- Player registration
- Admin registration review
- Group/lobby generation
- Session-level check-in
- Score entry by placement
- Backend score calculation
- Score approval
- Leaderboard calculation
- Public-safe leaderboard
- Stream-safe live view for OBS/TikTok Live Studio Browser Source
- Disputes
- Evidence reference/URL
- Audit logs
- PostgreSQL schema foundation
- Event outbox
- Read-optimized dashboard/player/leaderboard summaries
- Basic Discord-ready data flow
- Excel export first

### Out Of Scope For Phase 1

- Team tournament workflow
- Payment
- Prize payout tracking
- SaaS multi-tenant management
- OCR as official scoring
- Full Discord command system
- Discord role sync automation
- Advanced OBS overlay editor
- Sponsor reports
- Advanced rule models as active choices: Lobby Shuffle, Bracket Knockout, Checkmate Final

## 3. System Principles

- PostgreSQL is the source of truth.
- FastAPI owns business logic.
- Web, Discord, plugins, and overlays must not calculate official state.
- Live/overlay surfaces must display approved backend data only.
- Public endpoints must not expose private player/contact/evidence data.
- Score calculation must come from locked rules, not manual point entry.
- Discord roles are helper/display/access roles only, not official permissions.
- Evidence images are proof/review material, not automatic official results.
- Important mutations must create audit logs and event records.

## 4. Users And Roles

### Roles

- Super Admin: full system access and final correction authority
- Tournament Admin: creates tournaments and manages assigned tournaments
- Score Admin: enters score results
- Referee: verifies scores and handles disputes
- Player: registers, checks status, checks in, views own results, files disputes
- Viewer: views public tournament information
- Caster: views public or stream-safe result data during live production

### Permission Source

Official permissions must come from backend users and tournament-scoped roles.

Discord roles may help with channel access and display, but they must not decide official permissions.

## 5. Functional Requirements

### FR-01 Tournament Creation

The system shall allow an admin to create a draft tournament with:

- Name
- Game
- Public slug
- Participant type
- Max participants
- Registration open/close time
- Expected tournament schedule

The system shall prevent registration from opening until required setup and rules are valid.

### FR-02 Ruleset Selection

The system shall provide a Create Tournament flow with:

1. Basic Info
2. Choose Ruleset
3. Configure Rules
4. Review Generated Structure
5. Validate And Lock Draft
6. Open Registration

Phase 1 shall support:

- Fixed Points
- Group Points Qualifier

The UI may show later models as disabled/coming later:

- Lobby Shuffle
- Bracket Knockout
- Checkmate Final

### FR-03 Rule Presets

The system shall provide Phase 1 presets:

- Golden Spatula 16 Player
- Golden Spatula 32 Player
- Golden Spatula Fixed Final

Each preset shall generate tournament structure, score formula, advancement rules, and check-in session expectations.

Rule presets shall be treated as template/master data.

When an admin selects a preset, the system shall copy the preset into a tournament-specific draft ruleset. The tournament-specific ruleset may be edited while the tournament is still draft.

Once locked, the tournament-specific ruleset and score formula shall become an immutable snapshot for that tournament.

### FR-04 Rule Validation And Lock

The system shall validate rules before lock.

Validation shall reject invalid configs, including:

- Placement points missing for expected placements
- Top N greater than players per lobby
- Max participants lower than min participants
- Invalid final stage configuration
- Public visibility exposing private data

Locked rules shall create immutable snapshots.

### FR-05 Registration

The system shall allow a player to submit one registration per tournament.

Required solo registration fields:

- Display name
- In-game name
- Game UID
- Contact method
- Contact value

The system shall enforce:

- Unique registration per tournament and user
- Unique game UID per tournament
- Private contact fields hidden from public endpoints

### FR-06 Registration Review

The system shall allow authorized admins to:

- Approve registration
- Reject registration with reason
- Waitlist registration
- Withdraw registration

Only approved registrations may be assigned to groups/lobbies.

### FR-07 Group And Lobby Generation

The system shall generate stages, groups, rounds, and optionally check-in sessions from the locked ruleset.

MVP grouping:

- Random approved players
- Admin-adjustable before lock
- Post-lock movement requires reason and audit log

### FR-08 Session-Level Check-In

The system shall support check-in per session, not tournament-wide check-in.

Check-in sessions may represent:

- One stage on one day
- One group/lobby start
- One round/game block

MVP default:

- Open 30 minutes before session start
- Close 5 minutes before session start
- Eligible players only
- Late check-in requires admin override and audit reason

### FR-09 Score Entry

The system shall allow Score Admins to enter match results by selecting placement, not by manually typing official total points.

For each round/game, the score entry UI shall:

- List assigned players
- Allow placement selection
- Prevent duplicate placements
- Allow optional evidence URI
- Allow penalty only with reason
- Preview calculated points

Official points must be calculated by FastAPI.

### FR-10 Score Calculation

The system shall calculate:

```text
total_points = placement_points + bonus_points + bye_points - penalty_points
```

For Phase 1:

- Placement points are enabled
- Bonus points are disabled by default
- Bye points default to 0
- Penalty is manual and requires reason
- Manual total override is hidden except privileged correction policy

Default Golden Spatula placement points:

| Placement | Points |
| :---: | ---: |
| 1 | 10 |
| 2 | 8 |
| 3 | 7 |
| 4 | 6 |
| 5 | 4 |
| 6 | 3 |
| 7 | 2 |
| 8 | 1 |

Placement points shall be loaded from the locked tournament score formula or ruleset snapshot.

FastAPI shall not hardcode the Golden Spatula placement table into the scoring service. The scoring service may use the default values only when creating a preset or seed data.

The scoring service shall support multiple placement point maps by reading the selected tournament's locked rule configuration.

### FR-11 Score Approval

The system shall support score states:

```text
Draft -> Submitted -> Pending Verification -> Approved -> Final
```

Approved scores shall affect leaderboard and advancement.

Pending scores shall not affect the public leaderboard by default.

Final scores shall be locked except for authorized correction with reason and audit log.

### FR-12 Leaderboard

The system shall calculate leaderboard rankings from approved/final scores and the locked ruleset.

The system shall support:

- Stage leaderboard
- Group/lobby leaderboard
- Public-safe leaderboard
- Stream-safe leaderboard later

Tie-break default:

1. Higher total points
2. More 1st place finishes
3. Better average placement
4. Higher latest game score
5. Better latest game placement
6. Admin decision with audit reason

### FR-13 Advancement

The system shall calculate advancement from approved scores according to the locked ruleset.

MVP default:

- Top N per lobby
- Default Top 4 per lobby
- Scores reset each stage unless ruleset says otherwise

For the Phase 1 Group Points Qualifier model, the backend shall:

- rank players inside each stage/lobby using approved or final scores only
- advance players where `rank <= top_n` for qualifier stages
- reset score totals between stages by default
- use the locked tie-break order when players have equal total points
- mark final-stage rank 1 as the winner

The detailed Group Points Qualifier scoring and advancement contract is defined in `spec/GROUP_POINTS_QUALIFIER_SPEC.md`.

### FR-14 Disputes

The system shall allow players to file disputes against scores.

Disputes shall include:

- Score reference
- Reason
- Optional evidence URI

Admins/referees shall be able to:

- Mark dispute under review
- Accept dispute
- Reject dispute with reason

Accepted disputes shall trigger score correction and audit log.

### FR-15 Evidence Reference

The system shall support evidence URI/reference on score and dispute records in Phase 1.

Evidence images shall be manually reviewed.

The system shall not treat OCR or image analysis as official score in Phase 1.

Evidence URI validation shall be implemented before accepting user-provided links.

Phase 1 shall define either:

- an allowed-domain list for evidence URLs, or
- a strict URL validation policy with admin review warnings.

Evidence URI validation should reject obviously unsafe values such as non-HTTP(S) schemes, malformed URLs, and private/internal network targets when practical.

### FR-16 Audit Log

The system shall record important mutations, including:

- Rule lock/change
- Registration approval/rejection/waitlist
- Group generation/movement
- Check-in override/no-show/replacement
- Score creation/edit/approval/finalization/correction
- Dispute resolution
- Export

Sensitive actions shall require a reason.

### FR-17 Event Outbox

The system shall create event records for important mutations.

Events shall support:

- Dashboard polling/realtime later
- Discord notification workers later
- Audit-adjacent activity feed
- Public/player status synchronization

### FR-18 Read Models

The system shall provide fast read models or read-optimized endpoints for:

- Admin dashboard summary
- Player status summary
- Leaderboard snapshot
- Public tournament summary

The implementation may update read models synchronously in Phase 1 and move to workers later.

Write services and read/query services shall remain separated at the service layer, even if read models are updated synchronously in Phase 1.

This separation is required so leaderboard, dashboard, and player status updates can later move to background workers without rewriting scoring or registration business logic.

### FR-19 Public Pages

The system shall provide public-safe data for:

- Tournament summary
- Groups/lobbies
- Leaderboard
- Stream-safe live view

Public data must not include:

- Contact value
- Email
- Phone
- Discord ID unless explicitly public
- Private evidence link
- Admin notes
- Audit payloads

### FR-20 Live Stream Overlay And Stream-Safe View

The system shall provide a stream-safe view that can be used as an OBS Browser Source or TikTok Live Studio browser/web source.

Phase 1 shall support a basic live production view, not a full overlay editor.

The stream-safe view shall display only backend-approved public data, including:

- Tournament name and current stage
- Current group/lobby when selected
- Approved leaderboard
- Qualification status
- Score status labels when safe to show
- Basic auto-refresh or polling

The stream-safe view shall not display:

- Contact data
- Discord IDs unless explicitly public
- Private evidence links
- Admin notes
- Audit payloads
- Draft or pending scores unless the tournament setting explicitly allows public pending visibility

The stream-safe view shall be designed for live readability:

- Large readable text
- Minimal navigation
- No admin controls
- Stable layout that does not jump during updates
- Transparent or chroma-friendly background option later

FastAPI shall provide stream-safe endpoints or public page data that overlays can consume.

The overlay shall not calculate scores, decide advancement, or read admin/private APIs.

### FR-21 Discord-Ready Flow

The system shall expose backend data/actions that can support Discord later:

- Player status
- Registration status
- Current group
- Current check-in session
- Score summary
- Leaderboard
- Dispute submission

Discord buttons and commands must call FastAPI and revalidate current state.

### FR-22 Export

The system shall support Excel export first.

PDF export is later scope.

## 6. Non-Functional Requirements

### NFR-01 Performance

Target response times:

- Common mutation feedback: under 1 second
- Backend score calculation: under 500 ms
- Admin dashboard summary: under 300 ms for MVP scale
- Public leaderboard: under 300 ms normally, under 1 second during viewer spike
- Stream-safe live view refresh/read: under 1 second during MVP live use
- Discord notification after event: target under 5 seconds when worker exists

### NFR-02 Reliability

The system must continue operating if:

- Discord is offline
- Discord role sync fails
- Plugin/OCR fails
- Realtime connection fails

The web admin flow must remain usable.

### NFR-03 Security And Privacy

The system shall:

- Enforce backend permissions
- Separate admin/private serializers from public serializers
- Protect contact and evidence fields
- Avoid storing secrets in Git
- Avoid relying on Discord role as official permission

### NFR-04 Auditability

The system shall preserve enough data to explain:

- Who changed important data
- When it changed
- Why it changed
- What changed before/after when practical
- Which locked rules/formula were used for scoring

### NFR-05 Maintainability

The system shall keep modules separated:

- Tournament setup
- Ruleset validation
- Registration
- Group generation
- Check-in
- Score calculation
- Leaderboard
- Disputes
- Audit
- Event outbox
- Discord delivery
- Stream-safe overlay/public live view

### NFR-06 Concurrency And Race Conditions

The system shall protect important state transitions from race conditions.

Concurrency-sensitive operations include:

- registration submission when capacity is almost full
- registration approval and waitlist promotion
- check-in during an open session
- no-show and replacement decisions
- group generation/regeneration
- score approval and correction
- leaderboard snapshot rebuild

Implementation shall use database constraints and transactions first.

When needed, PostgreSQL row-level locking such as `SELECT ... FOR UPDATE` should be used for operations that reserve capacity, replace players, or update the same tournament/session state.

Duplicate requests, old Discord buttons, or repeated browser submissions shall return the current official state rather than creating duplicate records.

## 7. Data Requirements

### Official Write Model

Required table groups:

- Identity and permissions
- Tournaments and rules
- Registrations
- Stages/groups/rounds
- Check-in sessions
- Scores
- Disputes
- Audit logs

### Read Model

Required or planned:

- `tournament_dashboard_summaries`
- `leaderboard_snapshots`
- `player_status_snapshots`
- `public_tournament_summaries`
- `stream_overlay_snapshots` or equivalent stream-safe response

### Integration Model

Required or planned:

- `event_outbox`
- `discord_message_jobs`
- `attachments` later
- `plugin_runs` later
- `plugin_suggestions` later

## 8. External Interfaces

### Web Admin

Primary control surface for admins/referees.

### Public Web

Public-safe tournament information and leaderboard.

### Live Stream Overlay

Stream-safe public view or endpoint for OBS Browser Source and TikTok Live Studio browser/web source.

Overlay data must come from public-safe/read-optimized backend responses.

Advanced overlay editing, scene control, and OBS automation are later scope.

### Discord

Notification and input helper only.

### Evidence Image Storage

Phase 1 uses evidence URI/reference. Managed upload/storage is later.

## 9. Phase 1 Acceptance Criteria

Phase 1 is acceptable when:

- Admin can create a tournament with ruleset/preset.
- Rules validate and lock before registration opens.
- Player can register once.
- Admin can approve players.
- Admin can generate groups.
- Check-in works per session.
- Score Admin can enter placements.
- FastAPI calculates score correctly.
- Referee/admin can approve scores.
- Leaderboard updates from approved scores.
- Player can file dispute.
- Accepted dispute corrects score with audit log.
- Public leaderboard excludes private data.
- Stream-safe view can show approved leaderboard/current group without private data.
- Event outbox records important mutations.
- Concurrency-sensitive operations are protected by constraints/transactions.
- Evidence URI input is validated or flagged according to the selected policy.
- Read and write services are separated in code structure.
- Basic tests cover score, state transitions, privacy, rule lock, and duplicate registration.

## 10. Open Decisions Before Coding

These must be confirmed before implementation:

- Golden Spatula remains first game.
- Phase 1 is solo-only.
- First real event size is 16 or 32 players.
- Placement score formula is accepted.
- Fixed Points and Group Points Qualifier are the only active Phase 1 models.
- Check-in sessions are generated per stage/day.
- Evidence uses URI/reference only in Phase 1.
- Excel export comes before PDF.
- Polling is acceptable before WebSocket/SSE.
- Basic stream-safe OBS/TikTok Live Studio browser view is required, while advanced overlay editor is later.
- Discord command system is not required for first backend milestone.
- Evidence URL policy uses allowed domains or strict validation.

## 11. GitHub Issue Breakdown

Recommended Phase 1 GitHub issues:

### Epic: Tournament Core And Ruleset Validation

Related requirements:

- FR-01 Tournament Creation
- FR-02 Ruleset Selection
- FR-03 Rule Presets
- FR-04 Rule Validation And Lock

Deliverables:

- tournament tables
- rule set/formula tables
- immutable rule snapshot
- Create Tournament API
- rule validation tests

### Epic: Registration And Check-In System

Related requirements:

- FR-05 Registration
- FR-06 Registration Review
- FR-08 Session-Level Check-In

Deliverables:

- registration APIs
- duplicate user/UID checks
- admin review APIs
- check-in sessions
- check-in concurrency tests

### Epic: Scoring And Leaderboard Engine

Related requirements:

- FR-09 Score Entry
- FR-10 Score Calculation
- FR-11 Score Approval
- FR-12 Leaderboard
- FR-13 Advancement

Deliverables:

- ScoreCalculationService
- placement-based score entry
- score approval flow
- leaderboard snapshot
- tie-break tests

### Epic: Disputes, Evidence, And Audit

Related requirements:

- FR-14 Disputes
- FR-15 Evidence Reference
- FR-16 Audit Log

Deliverables:

- dispute APIs
- evidence URI validation
- score correction workflow
- audit log service

### Epic: Read Models, Events, And Public Data

Related requirements:

- FR-17 Event Outbox
- FR-18 Read Models
- FR-19 Public Pages
- FR-20 Live Stream Overlay And Stream-Safe View
- FR-21 Discord-Ready Flow
- FR-22 Export

Deliverables:

- event_outbox table/service
- dashboard summary
- player status summary
- public leaderboard DTO
- stream-safe leaderboard/current group DTO
- Excel export

## 12. References

- `spec/MVP_RULESET.md`
- `spec/GROUP_POINTS_QUALIFIER_SPEC.md`
- `spec/RULESET_SELECTION_AND_CREATION_UI.md`
- `spec/RULE_CONFIG_EXAMPLES.md`
- `spec/IMPLEMENTATION_SCHEMA_PLAN.md`
- `spec/API_CONTRACT_PHASE_1.md`
- `spec/PHASE_1_IMPLEMENTATION_DECISIONS.md`
- `spec/CHECK_IN_SPEC.md`
- `docs/WEB_APP_DESIGN_AND_INTEGRATION_SPEC.md`
- `docs/BOT_WEB_FLOW_AND_DATA_SPEC.md`
- `docs/POSTGRES_MODULE_FLOW_ANALYSIS.md`
- `docs/EVIDENCE_AND_DISCORD_ROLE_ANALYSIS.md`
