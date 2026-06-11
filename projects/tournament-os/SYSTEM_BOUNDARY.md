# System Boundary

Tournament Operating System is a separate subsystem inside the TTLIVE repository.

It exists for the case where TTLIVE runs a game tournament and needs a proper system for registration, grouping, scoring, verification, leaderboard, and exports.

It is not part of the normal weekly live workflow.

## Why This Is Separate

Normal TTLIVE operations answer:

- What will we stream?
- When will we stream?
- What assets are needed?
- What clips and reports come after the live?

Tournament OS answers:

- Who registered for the tournament?
- Who is approved to play?
- Which group or bracket is each player in?
- What are the scores for each round?
- Which scores are verified?
- Who advances?
- What results can players and viewers inspect?

Because these questions require database state, permissions, score formulas, dispute handling, and audit logs, this system should be planned and built separately.

## Folder Ownership

All tournament-specific system planning belongs under:

```text
projects/tournament-os/
```

Do not mix Tournament OS business rules into the weekly live schedule, brand, asset, or SOP folders unless the file is only linking to this subsystem.

## Allowed Links To TTLIVE

Tournament OS may connect to TTLIVE through:

- Live schedule announcements
- Tournament stream overlays
- Public leaderboard shown during live
- Post-tournament reports
- Clip ideas from final matches
- Sponsor or prize notes later

## Not Shared With Normal TTLIVE Ops

Tournament OS should own its own:

- Registration rules
- Score formulas
- Tournament states
- Database schema
- API specification
- Admin permissions
- Player dispute rules
- Audit log rules
- Development backlog

## Handoff Rule

When this subsystem is ready to become a real application, copy or split `projects/tournament-os/` into its own repository and keep this folder as the source specification unless a new dedicated repo replaces it.
