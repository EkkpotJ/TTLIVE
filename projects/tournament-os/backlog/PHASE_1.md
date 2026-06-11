# Phase 1 Backlog

Phase 1 should start only after the MVP rules are reviewed.

## P0

- Confirm final MVP scope.
- Confirm solo-only or team support for first build.
- Confirm Golden Spatula score formula.
- Confirm tournament state transitions.
- Confirm registration state transitions.
- Confirm required database constraints.
- Create ER diagram.
- Create PostgreSQL schema draft.
- Create FastAPI project skeleton.
- Create SQLAlchemy models.
- Create Alembic initial migration.
- Add tests for score formula.
- Add tests for state transitions.

## P1

- Add admin registration approval API.
- Add group generation API.
- Add score entry API.
- Add leaderboard API.
- Add audit log recording.
- Add Excel export.

## P2

- Add PDF export.
- Add dispute flow.
- Add evidence attachment references.
- Add public leaderboard page.
- Add Discord notification design.
- Add overlay data endpoint design.

## Risks

- Score formula ambiguity can force database and service rewrites.
- Supporting teams too early may slow MVP.
- OCR before manual verification flow can create unreliable results.
- Discord-first design can accidentally move business logic outside the backend.
- Public pages can leak private registration contact data if serializers are not separated.
