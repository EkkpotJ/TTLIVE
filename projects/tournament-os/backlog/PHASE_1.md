# Phase 1 Backlog

Phase 1 should start only after the MVP rules are reviewed.

## P0

- Confirm final MVP scope.
- Confirm solo-only first build.
- Confirm Golden Spatula score formula.
- Confirm first supported tournament models: Group Points Qualifier and Fixed Points.
- Confirm configurable rule set fields.
- Confirm tournament state transitions.
- Confirm registration state transitions.
- Confirm required database constraints.
- Review `spec/MVP_RULESET.md`.
- Review `spec/SYSTEM_REQUIREMENTS_SPECIFICATION.md`.
- Review `spec/GROUP_POINTS_QUALIFIER_SPEC.md`.
- Review `spec/ENUMS_AND_STATES.md`.
- Review `spec/RULE_CONFIG_EXAMPLES.md`.
- Review `spec/ER_DIAGRAM.md`.
- Review `spec/RULESET_SELECTION_AND_CREATION_UI.md`.
- Review `spec/IMPLEMENTATION_SCHEMA_PLAN.md`.
- Review `spec/API_CONTRACT_PHASE_1.md`.
- Review `spec/PHASE_1_IMPLEMENTATION_DECISIONS.md`.
- Review `docs/WEB_APP_DESIGN_AND_INTEGRATION_SPEC.md`.
- Review `docs/DISCORD_OPERATIONS_AND_PLUGIN_SPEC.md`.
- Review `docs/BOT_WEB_FLOW_AND_DATA_SPEC.md`.
- Review `docs/POSTGRES_MODULE_FLOW_ANALYSIS.md`.
- Review `docs/EVIDENCE_AND_DISCORD_ROLE_ANALYSIS.md`.
- Finalize PostgreSQL schema draft.
- Finalize Rule Engine draft interface.
- Define public response schemas that exclude private data.
- Define Create Tournament ruleset/preset selection flow.
- Define admin dashboard summary response.
- Define realtime/polling MVP strategy.
- Define backend event names for future Discord delivery.
- Define check-in session generation rules.
- Define player status and leaderboard read model strategy.
- Define event outbox and Discord delivery job schema.
- Define immutable rule snapshot fields.
- Define identity and tournament-scoped permission strategy.
- Define evidence attachment/reference strategy.
- Define evidence URL validation or allowed-domain policy.
- Define Discord role as helper, not permission source.
- Define concurrency strategy for check-in, registration capacity, score approval, and group replacement.
- Define stream-safe OBS/TikTok Live Studio endpoint behavior.
- Review `backlog/GITHUB_ISSUES_PHASE_1.md`.
- Create FastAPI project skeleton.
- Create SQLAlchemy models.
- Create Alembic initial migration.
- Add tests for score formula.
- Add tests for state transitions.
- Add tests for public/private serializer separation.
- Add tests for duplicate/old button idempotency.
- Add tests for concurrency-sensitive mutations.

## P1

- Add admin registration approval API.
- Add group generation API.
- Add score entry API.
- Add leaderboard API.
- Add rule set validation API.
- Add audit log recording.
- Add Excel export.
- Add leaderboard advancement calculation.
- Add public leaderboard polling support.
- Add event records for score/leaderboard/registration changes.
- Add check-in session API if included in Phase 1.
- Add admin dashboard summary API.
- Add player status summary API.
- Add leaderboard snapshot or read-optimized query.
- Add evidence URI validation.
- Add stream-safe leaderboard/groups API for OBS/TikTok Live Studio.

## P2

- Add PDF export.
- Add dispute flow.
- Add evidence attachment references.
- Add public leaderboard page.
- Add Discord notification design.
- Add overlay data endpoint design.
- Add plugin suggestion design.
- Add evidence image and Discord role sync design.

## Risks

- Score formula ambiguity can force database and service rewrites.
- Supporting teams too early may slow MVP.
- OCR before manual verification flow can create unreliable results.
- Discord-first design can accidentally move business logic outside the backend.
- Public pages can leak private registration contact data if serializers are not separated.
- Rule sets can become hard to audit if locked configs are mutable.
