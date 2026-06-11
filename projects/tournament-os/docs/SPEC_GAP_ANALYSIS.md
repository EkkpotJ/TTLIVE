# Specification Gap Analysis

Status: Current planning assessment.

This document lists what is already strong, what is still missing, and what should happen before backend implementation.

## Direct Assessment

Tournament OS is structurally ready for final specification work, but not yet ready for full application development.

The strongest path is:

1. Lock MVP rules.
2. Convert rules into database and API contracts.
3. Build a narrow FastAPI backend.
4. Add integrations only after manual workflows work.

This fits TTLIVE because the main operating model is solo-first and should reduce manual spreadsheet work without creating a large platform too early.

## What Is Strong

- The subsystem boundary is clear.
- Tournament OS is isolated from normal weekly live operations.
- PostgreSQL is correctly defined as the source of truth.
- FastAPI is correctly assigned business logic ownership.
- Discord, OCR, and overlay are correctly delayed.
- State machines exist for registration, tournament, score, and dispute flows.
- Database and API drafts already cover the right main entities.
- Rule Engine thinking prevents hardcoded tournament assumptions.
- Roadmap and backlog are phase-based and conservative.

## Key Gaps Closed By This Pass

This pass adds:

- MVP ruleset baseline
- Shared enum/state vocabulary
- ER diagram draft
- Rule configuration JSON examples
- Focused specification gap analysis

These are the missing bridge between planning documents and backend implementation.

## Remaining Missing Specifications

### Authentication

Decision needed:

- Local admin accounts for MVP
- External auth provider
- Discord login later

Recommendation:

Use the simplest backend-compatible auth for MVP. Do not depend on Discord identity for core tournament state.

### Tournament-Scoped Permissions

Decision needed:

- Global roles only
- Tournament-scoped role assignments

Recommendation:

Start with global roles in MVP, but design so a `tournament_user_roles` table can be added later.

### Evidence Storage

Decision needed:

- External links only
- Local file upload
- Object storage

Recommendation:

Use text evidence references first. Add uploads later.

### Public API Serialization

Decision needed:

- Exact DTOs for public leaderboard and groups
- Which pending scores are visible

Recommendation:

Public serializers must be separate from admin serializers. Never reuse admin registration models publicly.

### Rule Set Immutability

Decision needed:

- Can a locked rule set be edited?
- Should locked rules be versioned?

Recommendation:

Locked rule sets should be immutable except Super Admin correction with audit reason. Store enough JSON snapshot data to reproduce scoring.

### Check-In

Decision needed:

- Whether sessions are generated from stage schedules or manually created by admin
- Whether Discord check-in is allowed in MVP or only web/admin check-in

Recommendation:

MVP should use dedicated check-in sessions and check-in records. A tournament-wide check-in is not enough because players may compete across multiple stages and days.

## Product Risks

### MVP Too Wide

Team support, Discord commands, OCR, and overlay data can make the first build too large.

Mitigation:

Ship solo manual workflow first.

### Score Formula Changes

Changing the score formula after services are written can cause rewrites.

Mitigation:

Use structured `score_formula` config and write score calculation tests before admin UI.

### Private Data Leakage

Contact data and evidence links can accidentally appear in public endpoints.

Mitigation:

Use separate public DTOs, response tests, and an explicit private field list.

### Business Logic In The Wrong Place

Discord or overlay integrations can accidentally calculate score or advancement.

Mitigation:

Integrations only call backend APIs and display backend results.

### Audit Trail Too Late

Adding audit logs after score correction flows can miss important mutations.

Mitigation:

Build audit logging into service methods from Phase 1.

## Recommended Phase 1 Backend Services

### Tournament Service

Owns:

- Create tournament
- Update draft tournament
- Open/close registration
- Move tournament state
- Lock rule set

### Registration Service

Owns:

- Submit registration
- Validate duplicate UID
- Approve/reject/waitlist
- Withdraw

### Rule Set Service

Owns:

- Validate rule config
- Recommend basic format
- Lock rules
- Provide immutable config to scoring and advancement

### Group Service

Owns:

- Generate groups from approved participants
- Manual group movement before lock
- Post-lock movement with audit reason

### Score Service

Owns:

- Enter scores
- Calculate total points
- Submit for verification
- Approve/finalize
- Correct after dispute

### Leaderboard Service

Owns:

- Stage leaderboard
- Group leaderboard
- Public leaderboard DTO
- Advancement ranking

### Dispute Service

Owns:

- Open dispute
- Review dispute
- Accept/reject dispute
- Trigger score correction workflow

### Audit Log Service

Owns:

- Standard mutation logging
- Before/after value capture
- Required reason validation for sensitive actions

## Recommended Test Plan

Start with tests before building any UI:

- Registration duplicate user rejected
- Registration duplicate game UID rejected
- Rejected/waitlisted/withdrawn players cannot be grouped
- Group generation creates expected lobby sizes
- Score formula returns correct totals for placements 1-8
- Penalty requires reason
- Approved scores count toward leaderboard
- Pending scores do not count by default
- Tie-break order works
- Final scores cannot be edited without Super Admin correction
- Accepted dispute creates corrected score and audit log
- Public leaderboard excludes contact data and private evidence

## Backend Readiness Verdict

Ready to start backend only after these decisions are confirmed:

- MVP is solo-only
- First real size is 16 or 32 players
- Placement score formula is accepted
- Check-in is stored per stage/day session
- Bye default is advance-only
- Export priority is Excel first

If those are accepted, Phase 1 backend can start with low rewrite risk.
