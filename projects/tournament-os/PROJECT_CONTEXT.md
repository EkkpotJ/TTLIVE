# Project Context

Project name: Tournament Operating System

Primary game focus: Golden Spatula

Purpose:
Create a tournament management system for game competitions where admins can accept registrations, organize players into groups or brackets, record round scores, verify results, and publish leaderboards for players and viewers.

The system should reduce manual work in Excel, Google Forms, screenshots, and chat messages while keeping results transparent and auditable.

## Target Users

- Super Admin: manages the whole system
- Tournament Admin: creates tournaments and manages setup
- Score Admin: enters and edits scores
- Referee: verifies match results
- Player: registers, checks scores, and files disputes
- Viewer: sees public results and leaderboards
- Caster: uses public results or overlay data during live streams

## Architecture Direction

Planned implementation stack:

- FastAPI for backend and business logic
- PostgreSQL as source of truth
- SQLAlchemy for models
- Alembic for migrations
- Discord integration later as a frontend and notification channel
- OCR later as an assistive verification tool
- OBS/TikTok overlay later as presentation only

Architecture principles:

- PostgreSQL is the source of truth.
- FastAPI owns scoring, qualification, and permission rules.
- Discord must not calculate or store tournament state.
- Overlay must only display approved data.
- OCR suggestions must require admin or referee verification before becoming official.
- Every score edit should leave an audit trail.

## Current Phase

Specification phase.

The immediate goal is to convert the previous chat analysis into durable repository files so Codex can continue the project without rereading the whole conversation.

## Current Priorities

1. Lock business rules.
2. Lock participant and tournament states.
3. Define Golden Spatula tournament format.
4. Draft database entities.
5. Draft API boundaries.
6. Build backend foundation only after rules are reviewed.

## Main Product Modules

- Registration
- Tournament Setup
- Group and Bracket Management
- Score Management
- Public Results
- Score Verification and Disputes
- Export
- Audit Log

## Key Decisions From Chat

- Start with group-based tournaments plus cumulative points.
- Support score formulas that can be changed per tournament.
- Support bye wins for uneven brackets or groups.
- Support player-visible leaderboards.
- Support score dispute flow.
- Keep an edit log for score changes.
- Build MVP before advanced Discord, OCR, overlay, payment, or SaaS features.

## Open Questions

- Exact Golden Spatula scoring formula.
- Max participants for first real tournament.
- Whether registration starts as solo only or supports teams from day one.
- Whether check-in is required in MVP.
- Who can approve disputed scores.
- Whether public pages require login.
- Export format priority: Excel first or PDF first.
