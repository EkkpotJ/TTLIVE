# GitHub Issue Update - 2026-06-12

Use this as the first update comment for the TTLIVE main issue or Tournament OS tracking epic.

## Update: 2026-06-12

### Summary

- Tournament OS SRS is now approximately 95%+ ready for Phase 1 backend planning.
- Added explicit stream-safe OBS/TikTok Live Studio requirements and API endpoints.
- Added Group Points Qualifier scoring and advancement contract.
- Added documentation suite map for SRS, architecture, database design, API contract, test plan, deployment, backup/recovery, and user manuals.
- Added Phase 1 GitHub issue draft grouped by Epic.
- Added GitHub issue templates for TTLIVE updates, Tournament OS epics, and Tournament OS tasks.

### Major Decisions

- PostgreSQL remains the source of truth.
- FastAPI owns business logic, scoring, advancement, permissions, and public/private serialization.
- Discord, OBS/TikTok Live Studio overlays, public pages, and plugins are clients/helpers only.
- Phase 1 supports Solo Golden Spatula with Fixed Points and Group Points Qualifier.
- Group Points Qualifier uses locked ruleset snapshots, approved/final scores only, Top 4 per lobby by default, and score reset per stage.
- Stream-safe OBS/TikTok Live Studio endpoints are Phase 1; advanced overlay editor is later scope.

### Changed Files

- `.github/ISSUE_TEMPLATE/ttlive-update.yml`
- `.github/ISSUE_TEMPLATE/tournament-os-epic.yml`
- `.github/ISSUE_TEMPLATE/tournament-os-task.yml`
- `.github/ISSUE_TEMPLATE/config.yml`
- `projects/tournament-os/spec/SYSTEM_REQUIREMENTS_SPECIFICATION.md`
- `projects/tournament-os/spec/GROUP_POINTS_QUALIFIER_SPEC.md`
- `projects/tournament-os/spec/API_CONTRACT_PHASE_1.md`
- `projects/tournament-os/docs/DOCUMENTATION_SUITE.md`
- `projects/tournament-os/backlog/GITHUB_ISSUES_PHASE_1.md`
- `projects/tournament-os/backlog/PHASE_1.md`
- `projects/tournament-os/README.md`
- `projects/tournament-os/NEXT_HANDOFF.md`

### Issues To Create / Update

- Main tracking issue: `[Tournament OS] Phase 1 System Planning`
- Epic: Documentation Freeze And Architecture
- Epic: Identity, Permissions, And Tokens
- Epic: Tournament Core And Rulesets
- Epic: Registration And Check-In
- Epic: Group Generation And Lobby Management
- Epic: Scoring, Leaderboard, Advancement, And Disputes
- Epic: Public Data, OBS/TikTok Live Studio, And Export
- Epic: Events, Audit, Realtime-Ready Flow, And Discord-Ready Flow
- Epic: Backend Foundation

### Next

- [ ] Create labels from `projects/tournament-os/backlog/GITHUB_ISSUES_PHASE_1.md`.
- [ ] Create milestone `Tournament OS Phase 1`.
- [ ] Create main tracking issue.
- [ ] Create Epic issues.
- [ ] Create child issues or keep child issues grouped in Epic body until backend implementation starts.
- [ ] Link the first backend build to `SYSTEM_ARCHITECTURE_DESIGN.md` and `TEST_PLAN_PHASE_1.md`.
