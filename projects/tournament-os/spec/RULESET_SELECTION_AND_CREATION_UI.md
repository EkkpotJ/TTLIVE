# Ruleset Selection And Tournament Creation UI

Status: Product and backend contract draft.

This document defines the tournament creation flow and the ruleset selection UI.

The system must support multiple tournament rule models, but MVP should expose only the safe models first.

## Existing Rule Models

The project already defines these structural models in `RULE_ENGINE_SPEC.md`:

| Model | Status | Purpose |
| :--- | :--- | :--- |
| `fixed_points` | Phase 1 | Small event, one lobby or simple total score |
| `group_points_qualifier` | Phase 1 default | Multiple lobbies, top N advance |
| `lobby_shuffle` | Phase 2 | Reassign lobbies based on score/rank |
| `bracket_knockout` | Later | Elimination-style structure |
| `checkmate_final` | Later | Threshold plus win condition final |

MVP should show:

- Fixed Points
- Group Points Qualifier

MVP should hide or disable:

- Lobby Shuffle
- Bracket Knockout
- Checkmate Final

## Tournament Creation Flow

Admin should create a tournament through a step-based flow:

```text
Step 1: Basic Info
Step 2: Choose Ruleset
Step 3: Configure Rules
Step 4: Review Generated Structure
Step 5: Validate And Lock Draft
Step 6: Open Registration
```

Do not allow registration to open until rules pass validation.

## Step 1: Basic Info

Fields:

- Tournament name
- Game
- Public slug
- Participant type
- Max participants
- Registration open time
- Registration close time
- Expected tournament date/time

MVP defaults:

- Game: Golden Spatula
- Participant type: Solo
- Max participants: 16 or 32 recommended

## Step 2: Choose Ruleset

Show ruleset cards.

### Fixed Points Card

Display:

```text
Fixed Points
Best for: 8 players or a simple final lobby
Structure: One lobby, multiple games, highest total wins
MVP: Supported
```

Primary settings:

- Lobby size
- Number of games
- Placement points
- Tie-break order

### Group Points Qualifier Card

Display:

```text
Group Points Qualifier
Best for: 16-64 players
Structure: Multiple lobbies, top N advance each stage
MVP: Recommended
```

Primary settings:

- Lobby size
- Games per qualifier stage
- Final games
- Top N per lobby
- Score reset policy
- Placement points
- Tie-break order

### Disabled Model Cards

Disabled cards should clearly say why they are unavailable.

Example:

```text
Lobby Shuffle
Coming later
Needs score-based regrouping and more tests.
```

## Step 3: Configure Rules

The UI should be generated from the selected model.

Common fields:

- Lobby size
- Max participants
- Minimum participants
- Placement points
- Penalty policy
- Bye behavior
- Tie-break order
- Score reset policy
- Evidence requirement
- Score approval requirement
- Dispute window

Group Points fields:

- Stage plan
- Games per stage
- Final games
- Top N per lobby
- Carry score toggle

Fixed Points fields:

- Total games
- Winner count
- Top N overall

## Rule Presets

MVP should include presets to reduce setup mistakes.

Rule presets are template/master data.

When an admin selects a preset, the system copies it into a tournament-specific draft ruleset and score formula. Editing the draft must not mutate the original preset.

When the tournament rules are locked, scoring must use the locked tournament snapshot, not the preset record.

### Golden Spatula 16 Player

```text
Model: Group Points Qualifier
Lobby size: 8
Round 1: 2 lobbies, 2 games, Top 4 advance
Final: 1 lobby, 3 games
Score: 10/8/7/6/4/3/2/1
Score reset: reset_each_stage
```

### Golden Spatula 32 Player

```text
Model: Group Points Qualifier
Lobby size: 8
Round 1: 4 lobbies, 2 games, Top 4 advance
Semi Final: 2 lobbies, 2 games, Top 4 advance
Final: 1 lobby, 3 games
Score: 10/8/7/6/4/3/2/1
Score reset: reset_each_stage
```

### Golden Spatula Fixed Final

```text
Model: Fixed Points
Lobby size: 8
Games: 3-5
Winner: highest total score
Score: 10/8/7/6/4/3/2/1
```

## Step 4: Review Generated Structure

Before saving/locking, show a generated preview:

- Number of stages
- Number of groups/lobbies per stage
- Number of games per group
- Number of players expected per lobby
- Advancement rule
- Final size
- Check-in sessions that will be created
- Estimated total games

Example:

```text
Round 1
  4 lobbies
  8 players per lobby
  2 games per lobby
  Top 4 advance

Semi Final
  2 lobbies
  8 players per lobby
  2 games per lobby
  Top 4 advance

Final
  1 lobby
  8 players
  3 games
```

## Step 5: Validate And Lock Draft

Validation should happen before lock.

Reject when:

- Placement points do not cover all placements from 1 to lobby size.
- Top N is greater than players per lobby.
- Max participants is lower than min participants.
- Stage plan cannot produce expected finalist count.
- Final games are missing for multi-stage tournament.
- Dispute window is missing when score approval is required.
- Public visibility includes private contact or evidence fields.

Lock behavior:

- Draft rules can be edited.
- Locked rules should not be edited after registration opens.
- Super Admin correction requires reason and audit log.
- Locked rules should create immutable snapshots.

## Step 6: Open Registration

After rule validation and draft lock, admin can open registration.

The registration page and Discord registration announcement should read from the locked ruleset summary.

Players should see:

- Tournament name
- Game
- Player limit
- Format summary
- Score summary
- Check-in summary
- Dispute window

Do not show internal JSON.

## UI Placement

Admin navigation should include:

- `Create Tournament`
- `Rules`
- `Rule Preview`

Inside a tournament:

- `Overview`
- `Rules`
- `Registrations`
- `Groups`
- `Check-In`
- `Scores`
- `Leaderboard`
- `Disputes`
- `Audit`
- `Export`

## Backend Endpoints

Use existing rule endpoints and make them concrete:

```text
GET  /admin/rule-presets
POST /admin/tournaments
POST /admin/tournaments/{tournament_id}/rule-set/recommend
POST /admin/tournaments/{tournament_id}/rule-set/validate
POST /admin/tournaments/{tournament_id}/rule-set
POST /admin/tournaments/{tournament_id}/rule-set/lock
GET  /admin/tournaments/{tournament_id}/rule-set/preview
```

## Required Response For Rule Preview

```json
{
  "model": "group_points_qualifier",
  "summary": "32 players, 4 lobbies, top 4 advance",
  "stage_plan": [],
  "score_formula_summary": "10/8/7/6/4/3/2/1",
  "validation_errors": [],
  "warnings": []
}
```

## Relationship To Score Calculation

Score entry UI must be generated from the locked score formula.

For MVP:

- Referee chooses placement.
- System calculates placement points from the locked score formula.
- Penalty is optional and requires reason.
- Bonus is disabled unless ruleset enables it.
- Manual total override is hidden unless role and policy allow it.

## Acceptance Checklist

Ruleset selection is ready when:

- Admin can choose Fixed Points or Group Points Qualifier.
- Admin can use Golden Spatula 16/32 presets.
- System previews generated stages/lobbies/games.
- System validates rules before registration opens.
- Locked rules create immutable snapshots.
- Score entry reads from locked rules, not hardcoded UI.
