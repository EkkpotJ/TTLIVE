# Development Roadmap

## Phase 0: Specification

Goal: make the system clear enough that Codex can implement without guessing.

Tasks:

- Review `PROJECT_CONTEXT.md`.
- Review `spec/BUSINESS_RULES.md`.
- Review `spec/STATE_MACHINE.md`.
- Review `spec/TOURNAMENT_FORMAT_SPECIFICATION.md`.
- Review `spec/MVP_RULESET.md`.
- Review `spec/ENUMS_AND_STATES.md`.
- Review `spec/RULE_CONFIG_EXAMPLES.md`.
- Review `spec/ER_DIAGRAM.md`.
- Review `spec/IMPLEMENTATION_SCHEMA_PLAN.md`.
- Review `spec/API_CONTRACT_PHASE_1.md`.
- Review `docs/SPEC_GAP_ANALYSIS.md`.
- Review `docs/WEB_APP_DESIGN_AND_INTEGRATION_SPEC.md`.
- Review `docs/DISCORD_OPERATIONS_AND_PLUGIN_SPEC.md`.
- Review `docs/BOT_WEB_FLOW_AND_DATA_SPEC.md`.
- Review `docs/POSTGRES_MODULE_FLOW_ANALYSIS.md`.
- Review `docs/EVIDENCE_AND_DISCORD_ROLE_ANALYSIS.md`.
- Confirm MVP participant type.
- Confirm first score formula.
- Confirm first configurable rule set shape.
- Confirm whether check-in is MVP or later.
- Confirm check-in session generation per stage/day.

Exit criteria:

- Business rules are stable enough for database design.
- MVP ruleset is accepted or explicitly edited.
- Rule config shape is stable enough for backend tests.
- ER diagram is accepted as the implementation baseline.
- Phase 1 schema and API contract are accepted.
- Admin/public web surfaces and realtime boundaries are accepted.
- Discord notification, command, and plugin boundaries are accepted.
- Bot/web flow and read model strategy are accepted.
- PostgreSQL write model, read model, and event outbox strategy are accepted.
- Evidence image handling and Discord role permission boundaries are accepted.
- Open questions are either answered or explicitly deferred.

## Phase 1: Backend Foundation

Goal: create the backend core with database schema and tests.

Tasks:

- Create FastAPI project structure.
- Create SQLAlchemy models.
- Create Alembic migrations.
- Add registration service.
- Add tournament setup service.
- Add rule set validation service.
- Add scoring service.
- Add leaderboard query service.
- Add audit log service.
- Add public/private serializer separation.
- Add dashboard summary endpoint.
- Add polling or realtime event endpoint after core mutations work.
- Add backend event model for Discord delivery later.
- Add check-in session service if check-in is included in Phase 1.
- Add read-optimized dashboard/player/leaderboard endpoints.
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
- Plugin suggestion framework.
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
