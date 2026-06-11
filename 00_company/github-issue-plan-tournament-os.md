# GitHub Issue Plan - Tournament OS

Status: Tournament OS exception to the main TTLIVE issue plan.

## Reason

The general TTLIVE operating system can use one main tracking issue with update comments.

Tournament OS is large enough to require multiple GitHub Issues because it has separate backend, database, API, scoring, check-in, public data, OBS/TikTok Live Studio, Discord-ready, audit, and testing work.

## Repository

```text
https://github.com/Aalika-Ss1/TTLIVE.git
```

## Issue Structure

Use:

- one main tracking issue for the subsystem
- one Epic issue per major Phase 1 area
- child task issues when implementation begins

Recommended main tracking issue:

```text
[Tournament OS] Phase 1 System Planning
```

Recommended milestone:

```text
Tournament OS Phase 1
```

## Templates

Issue templates live in:

```text
.github/ISSUE_TEMPLATE/
```

Templates:

- `ttlive-update.yml`
- `tournament-os-epic.yml`
- `tournament-os-task.yml`

## Source Files

Tournament OS issue source list:

```text
projects/tournament-os/backlog/GITHUB_ISSUES_PHASE_1.md
```

Latest update comment draft:

```text
projects/tournament-os/backlog/GITHUB_ISSUE_UPDATE_2026-06-12.md
```

## Labels

Create labels listed in:

```text
projects/tournament-os/backlog/GITHUB_ISSUES_PHASE_1.md
```

Minimum labels:

- `tournament-os`
- `phase-1`
- `epic`
- `backend`
- `database`
- `api`
- `testing`
- `public-data`
- `overlay`
- `discord`
- `docs`
- `security`
- `privacy`

## Creation Order

1. Create labels.
2. Create milestone `Tournament OS Phase 1`.
3. Create main tracking issue.
4. Post the update comment from `GITHUB_ISSUE_UPDATE_2026-06-12.md`.
5. Create Epic issues.
6. Create child task issues when implementation begins.
7. Link child issues to their Epic.

## Phase 1 Epic Set

- Documentation Freeze And Architecture
- Identity, Permissions, And Tokens
- Tournament Core And Rulesets
- Registration And Check-In
- Group Generation And Lobby Management
- Scoring, Leaderboard, Advancement, And Disputes
- Public Data, OBS/TikTok Live Studio, And Export
- Events, Audit, Realtime-Ready Flow, And Discord-Ready Flow
- Backend Foundation

## Rule

Do not create Phase 1 implementation issues for:

- payment
- SaaS multi-tenant management
- OCR as official scoring
- full Discord command system
- advanced overlay editor
