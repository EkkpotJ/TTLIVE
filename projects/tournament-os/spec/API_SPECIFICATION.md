# API Specification Draft

This is a backend boundary draft for a future FastAPI implementation.

## Principles

- API should enforce all business rules.
- Clients must not calculate official scores.
- Public endpoints must not leak private registration data.
- Admin endpoints should require role-based access control.
- Every important mutation should create an audit log entry.

## Public Endpoints

```text
GET /public/tournaments/{slug}
GET /public/tournaments/{slug}/leaderboard
GET /public/tournaments/{slug}/groups
GET /public/tournaments/{slug}/rounds
```

## Registration Endpoints

```text
POST /tournaments/{tournament_id}/registrations
GET /tournaments/{tournament_id}/registrations/me
PATCH /tournaments/{tournament_id}/registrations/me
POST /tournaments/{tournament_id}/registrations/me/withdraw
```

## Admin Registration Endpoints

```text
GET /admin/tournaments/{tournament_id}/registrations
POST /admin/registrations/{registration_id}/approve
POST /admin/registrations/{registration_id}/reject
POST /admin/registrations/{registration_id}/waitlist
```

## Tournament Setup Endpoints

```text
POST /admin/tournaments
GET /admin/tournaments
GET /admin/tournaments/{tournament_id}
PATCH /admin/tournaments/{tournament_id}
POST /admin/tournaments/{tournament_id}/open-registration
POST /admin/tournaments/{tournament_id}/close-registration
```

## Rule Configuration Endpoints

```text
POST /admin/tournaments/{tournament_id}/rule-set
GET /admin/tournaments/{tournament_id}/rule-set
PATCH /admin/tournaments/{tournament_id}/rule-set
POST /admin/tournaments/{tournament_id}/rule-set/recommend
POST /admin/tournaments/{tournament_id}/rule-set/validate
POST /admin/tournaments/{tournament_id}/rule-set/lock
```

Rules:

- Rule sets can be edited while tournament is Draft.
- Rule sets should be locked before registration closes.
- Locked rule sets must not change after the tournament starts except by Super Admin correction with audit note.
- The recommend endpoint should use participant count, time window, lobby size, and desired finalists to suggest a model.

## Group Management Endpoints

```text
POST /admin/tournaments/{tournament_id}/generate-groups
GET /admin/tournaments/{tournament_id}/groups
PATCH /admin/groups/{group_id}/participants
```

## Score Endpoints

```text
POST /admin/rounds/{round_id}/scores
GET /admin/rounds/{round_id}/scores
PATCH /admin/scores/{score_id}
POST /admin/scores/{score_id}/submit
POST /admin/scores/{score_id}/approve
POST /admin/scores/{score_id}/finalize
```

## Dispute Endpoints

```text
POST /scores/{score_id}/disputes
GET /tournaments/{tournament_id}/disputes/me
GET /admin/tournaments/{tournament_id}/disputes
POST /admin/disputes/{dispute_id}/review
POST /admin/disputes/{dispute_id}/accept
POST /admin/disputes/{dispute_id}/reject
```

## Export Endpoints

```text
GET /admin/tournaments/{tournament_id}/exports/leaderboard.xlsx
GET /admin/tournaments/{tournament_id}/exports/results.pdf
```

## Open API Decisions

- Authentication provider.
- Whether public registration is anonymous or login-based.
- File upload handling for evidence.
- Rate limits for public endpoints.
- Exact request and response schema for configurable rule sets.
