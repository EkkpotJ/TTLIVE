# TTLIVE Agent Guide

Project name: TTLIVE

Primary goal:
Build a repeatable operating system for TikTok Live content, tournaments, assets, reporting, and automation.

How to work in this repository:

- Read `DASHBOARD.md` first.
- Read `00_company/system-master-plan.md` and `00_company/current-priorities.md` before changing operating rules.
- Keep new work organized under the existing numbered folders.
- Put experimental or game-specific initiatives under `projects/`.
- Do not store passwords, stream keys, tokens, payment details, or private player contact data in Git.
- Prefer Markdown specifications and small data files before building code.
- Keep automation scripts simple and documented.

Tournament OS focus:

- The tournament management system lives under `projects/tournament-os/`.
- Treat Tournament OS as a separate subsystem for tournament cases, not as part of the default weekly live workflow.
- Read `projects/tournament-os/SYSTEM_BOUNDARY.md` before deciding where tournament-related work belongs.
- Read `projects/tournament-os/PROJECT_CONTEXT.md` before editing tournament files.
- Read all files under `projects/tournament-os/spec/` before proposing schema, API, Discord, OCR, or overlay work.
- Do not implement UI, Discord, OCR, payment, or SaaS features until the MVP backend specification is stable.
- PostgreSQL should be treated as the source of truth when implementation starts.
- FastAPI should contain business logic when implementation starts.
- Discord, OBS overlay, and public pages should only present or submit data through the backend.

Definition of done for planning changes:

- The reason for the change is written down.
- The next action is clear.
- Risks or missing decisions are captured.
- Git status is clean after commit and push when the user asks to upload to Git.
