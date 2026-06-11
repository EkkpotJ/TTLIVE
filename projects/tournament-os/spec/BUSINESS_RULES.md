# Business Rules

These rules define how Tournament Operating System should behave.

## Registration

- A participant may register only once per tournament.
- Registration may represent a solo player or a team.
- Required fields for a solo player:
  - Display name
  - In-game name
  - Game UID
  - Contact channel
- Required fields for a team:
  - Team name
  - Captain display name
  - Captain contact channel
  - Member list
  - Game UID or username for each required member
- Game UID should be unique within one tournament.
- Contact data must not be committed to Git.
- Registration status must be one of:
  - Draft
  - Submitted
  - Approved
  - Rejected
  - Waitlisted
  - Withdrawn
- Only approved participants can be assigned to tournament groups or brackets.
- Registration should close automatically when the approved participant limit is reached, unless admin override is enabled.

## Tournament Setup

- A tournament must define:
  - Game
  - Tournament name
  - Registration open and close time
  - Participant type: Solo, Duo, Squad, or Team
  - Maximum participant count
  - Format
  - Score formula
  - Tie-break rules
  - Public visibility
- MVP format should focus on group stage with cumulative points.
- Later formats may include:
  - Single elimination
  - Double elimination
  - Round robin
  - Swiss round
  - Battle royale points

## Group Assignment

- Admins can generate groups automatically.
- Admins can manually move participants between groups.
- Group size should be configurable.
- Seeding should be supported later to prevent strong participants from being placed in the same group.
- Group generation should not include rejected, withdrawn, or waitlisted participants.

## Scoring

- Scores are recorded per tournament, stage, group, round, and participant.
- Score formula must be configurable per tournament.
- A score entry may include:
  - Placement
  - Kill points or bonus points
  - Penalty points
  - Bye points
  - Total points
  - Evidence attachment reference
  - Note
- Total points should be calculated by the backend from the configured formula.
- Manual total override should require permission and an audit reason.
- A score must not become official until approved if tournament verification is enabled.

## Bye Wins

- Bye rules must be explicit per tournament.
- A bye can award fixed points.
- A bye can advance a participant without awarding points.
- The selected bye behavior must be visible to admins and players.

## Leaderboard

- Public leaderboard should show:
  - Rank
  - Player or team name
  - Group
  - Round totals
  - Total score
  - Qualification status
- Private fields such as contact information must never appear on public pages.
- Leaderboard should clearly mark pending or unverified results.

## Disputes

- Players can submit a score dispute.
- A dispute should include:
  - Tournament
  - Round or match
  - Participant
  - Explanation
  - Evidence reference when available
- Dispute status must be one of:
  - Open
  - Under Review
  - Accepted
  - Rejected
  - Cancelled
- Score changes from accepted disputes must create an audit log entry.

## Audit Log

- The system must record who changed important data and when.
- Audited actions include:
  - Registration approval or rejection
  - Group assignment changes
  - Score creation
  - Score edits
  - Score approval
  - Dispute resolution
  - Tournament format changes
- Audit log should include before and after values when practical.

## Permissions

- Super Admin can manage all tournaments and users.
- Tournament Admin can manage assigned tournaments.
- Score Admin can enter and edit scores for assigned tournaments.
- Referee can verify results for assigned rounds or groups.
- Player can manage their registration and view their own results.
- Viewer can view public results only.
