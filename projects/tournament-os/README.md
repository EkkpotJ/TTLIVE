# Tournament Operating System

Tournament Operating System is the planned web system for running game competitions from registration to final results.

The system should help a solo organizer or small team manage:

- Player or team registration
- Admin approval
- Tournament setup
- Group and bracket generation
- Per-round score entry
- Automatic point totals
- Public leaderboards
- Score verification and disputes
- Exportable results

Current phase: specification.

Do not start full application development until the core rules in `spec/BUSINESS_RULES.md`, `spec/STATE_MACHINE.md`, and `spec/TOURNAMENT_FORMAT_SPECIFICATION.md` are reviewed.

## Suggested Reading Order

1. `PROJECT_CONTEXT.md`
2. `spec/BUSINESS_RULES.md`
3. `spec/STATE_MACHINE.md`
4. `spec/TOURNAMENT_FORMAT_SPECIFICATION.md`
5. `spec/DATABASE_SCHEMA.md`
6. `spec/API_SPECIFICATION.md`
7. `docs/DEVELOPMENT_ROADMAP.md`
8. `backlog/PHASE_1.md`

## MVP Scope

- Register players or teams
- Approve or reject registrations
- Create one tournament
- Divide participants into groups
- Record scores per round
- Calculate total score automatically
- Publish leaderboard
- Export results to Excel or PDF

## Not In Scope Yet

- Payment
- Mobile app
- SaaS multi-tenant platform
- Complex sponsor workflow
- Full Discord bot automation
- Full OCR automation
- Advanced OBS overlay control
