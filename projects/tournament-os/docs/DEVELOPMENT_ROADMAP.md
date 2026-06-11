# Development Roadmap

## Phase 0: Specification

Goal: make the system clear enough that Codex can implement without guessing.

Tasks:

- Review `PROJECT_CONTEXT.md`.
- Review `spec/BUSINESS_RULES.md`.
- Review `spec/STATE_MACHINE.md`.
- Review `spec/TOURNAMENT_FORMAT_SPECIFICATION.md`.
- Confirm MVP participant type.
- Confirm first score formula.
- Confirm whether check-in is MVP or later.

Exit criteria:

- Business rules are stable enough for database design.
- Open questions are either answered or explicitly deferred.

## Phase 1: Backend Foundation

Goal: create the backend core with database schema and tests.

Tasks:

- Create FastAPI project structure.
- Create SQLAlchemy models.
- Create Alembic migrations.
- Add registration service.
- Add tournament setup service.
- Add scoring service.
- Add leaderboard query service.
- Add audit log service.
- Add unit tests for score calculation and state transitions.

Exit criteria:

- Local backend can create a tournament, approve registrations, assign groups, enter scores, and return leaderboard data.

## Phase 2: Admin Workflow

Goal: make the system usable by an organizer.

Tasks:

- Add minimal admin pages or admin API workflow.
- Add CSV/Excel import or export.
- Add score approval flow.
- Add dispute review flow.

Exit criteria:

- Organizer can run a small tournament without manual spreadsheet calculations.

## Phase 3: Player and Public Pages

Goal: make results transparent for participants and viewers.

Tasks:

- Public tournament page.
- Public leaderboard.
- Player registration status page.
- Player dispute submission page.

Exit criteria:

- Players can check their own status and public results without asking the admin.

## Phase 4: Integrations

Goal: connect the tournament system to live operations.

Tasks:

- Discord notifications.
- Discord registration or check-in helper.
- OBS/TikTok overlay endpoint.
- OCR-assisted score evidence review.

Exit criteria:

- Live operations can show tournament results with less manual copying.

## Future

- Multiple tournaments at once.
- Ranking across tournaments.
- Prize tracking.
- Sponsor-facing reports.
- Payment workflow.
- SaaS multi-tenant support.
