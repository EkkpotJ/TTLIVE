# Group Points Qualifier Specification

Status: Phase 1 scoring and advancement contract.

Purpose:
Define the exact behavior for the Phase 1 Group Points Qualifier model so backend services can calculate scores, leaderboards, and advancement without hardcoded tournament assumptions.

This model is the primary Golden Spatula MVP format.

## Model Summary

Group Points Qualifier is used when players are split into multiple lobbies, play several games inside each lobby/stage, and the top players from each lobby advance.

Phase 1 defaults:

| Rule | Default |
| :--- | :--- |
| Participant type | Solo |
| Lobby size | 8 |
| Placement scoring | 1=10, 2=8, 3=7, 4=6, 5=4, 6=3, 7=2, 8=1 |
| Games per qualifier stage | 2 |
| Final games | 3 |
| Score reset policy | Reset each stage |
| Advancement type | Top N per lobby |
| Default Top N | 4 |
| Approved scores only | Yes |
| Manual score approval | Required |
| Dispute window | 15 minutes after score publication |

## Stage Plans

### 16 Players

```text
Round 1
  2 lobbies
  8 players per lobby
  2 games per lobby
  Top 4 per lobby advance

Final
  1 lobby
  8 players
  3 games
  Highest final-stage total wins
```

### 32 Players

```text
Round 1
  4 lobbies
  8 players per lobby
  2 games per lobby
  Top 4 per lobby advance

Semi Final
  2 lobbies
  8 players per lobby
  2 games per lobby
  Top 4 per lobby advance

Final
  1 lobby
  8 players
  3 games
  Highest final-stage total wins
```

### 64 Players

64-player structure is supported by data design but should not be the first real event unless 16-player and 32-player flows have already been tested.

```text
Round 1
  8 lobbies
  8 players per lobby
  2 games per lobby
  Top 4 per lobby advance

Round 2
  4 lobbies
  8 players per lobby
  2 games per lobby
  Top 4 per lobby advance

Semi Final
  2 lobbies
  8 players per lobby
  2 games per lobby
  Top 4 per lobby advance

Final
  1 lobby
  8 players
  3 games
  Highest final-stage total wins
```

## Score Formula

The backend calculates each player game result with:

```text
total_points = placement_points + bonus_points + bye_points - penalty_points
```

Phase 1 behavior:

- `placement_points` is required and comes from the locked tournament score formula.
- `bonus_points` is disabled by default and should be `0`.
- `bye_points` defaults to `0`.
- `penalty_points` is optional, manual, and requires a reason when greater than `0`.
- Manual total override is not part of normal flow.

Default Golden Spatula placement points:

| Placement | Points |
| :---: | ---: |
| 1 | 10 |
| 2 | 8 |
| 3 | 7 |
| 4 | 6 |
| 5 | 4 |
| 6 | 3 |
| 7 | 2 |
| 8 | 1 |

Implementation rule:

- The scoring service must read placement points from the locked tournament formula snapshot.
- The scoring service must not hardcode these default points except when seeding a preset.

## Stage Leaderboard Calculation

For each stage and lobby:

1. Load approved or final scores only.
2. Exclude draft, submitted, pending verification, rejected, or unresolved disputed scores unless an admin/private view explicitly asks for them.
3. Group scores by player registration.
4. Sum `total_points` across games in the current stage.
5. Count placement statistics needed for tie-breaks.
6. Rank players inside the stage/lobby.

Recommended leaderboard row fields:

- `rank`
- `registration_id`
- `display_name`
- `group_id`
- `games_played`
- `total_points`
- `first_place_count`
- `average_placement`
- `latest_game_points`
- `latest_game_placement`
- `qualification_status`
- `score_status`

## Advancement Calculation

For qualifier stages:

```text
advance players where rank <= top_n in each lobby
```

Default:

```text
top_n = 4
```

For final stage:

```text
winner = rank 1 by final-stage leaderboard
```

Score reset behavior:

- Scores reset each stage by default.
- Previous-stage scores decide who enters the next stage.
- Previous-stage scores do not add to final-stage totals unless a future ruleset explicitly enables carry score.

Advancement service inputs:

- locked tournament ruleset snapshot
- stage id
- approved/final scores
- current lobby assignments
- tie-break order

Advancement service outputs:

- leaderboard ranks
- `advancing`, `eliminated`, or `winner` qualification statuses
- audit/event records when advancement is published or corrected

## Tie-Break Order

Default tie-break order:

1. Higher total points in current stage
2. More 1st place finishes in current stage
3. Better average placement in current stage
4. Higher latest game score
5. Better latest game placement
6. Admin decision with audit reason

Admin decision may only be used when all automated tie-breakers still tie.

Admin decision must record:

- actor
- reason
- affected players
- previous rank/order
- final rank/order

## Score States And Public Visibility

Scores follow:

```text
Draft -> Submitted -> Pending Verification -> Approved -> Final
```

Public and stream-safe pages use approved/final scores by default.

Pending scores may appear only if the locked tournament public visibility setting explicitly allows pending score visibility.

Disputed approved scores may remain visible with a disputed label if the public visibility setting allows it.

## Validation Rules

Rule validation must reject a Group Points Qualifier config when:

- `lobby_size` is missing or less than 2.
- placement points do not cover every placement from 1 to `lobby_size`.
- a stage has `groups < 1`.
- a stage has `players_per_group` greater than `lobby_size`.
- `top_n` is greater than `players_per_group`.
- final stage does not produce a winner.
- `score_reset_policy` is missing.
- `tie_break_order` is empty.
- manual override is enabled without reason and audit requirements.
- public visibility exposes private contact, private evidence, admin notes, or audit payloads.

## Backend Services

The model should be implemented through separate services:

- `RuleValidationService`
- `GroupGenerationService`
- `ScoreCalculationService`
- `LeaderboardService`
- `AdvancementService`
- `AuditLogService`
- `EventOutboxService`

Service boundaries:

- Score calculation calculates game points.
- Leaderboard ranks players from approved/final scores.
- Advancement decides who qualifies from ranked results.
- Public/stream serializers expose safe read models only.

## Required Tests

Minimum tests for this model:

- 8 placements calculate 10/8/7/6/4/3/2/1 from locked formula.
- Duplicate placement in one game is rejected.
- Penalty requires reason.
- Pending scores do not affect public leaderboard.
- Approved scores update stage leaderboard.
- Top 4 per lobby advance for 16-player stage.
- Top 4 per lobby advance for 32-player Round 1 and Semi Final.
- Final rank 1 becomes winner.
- Tie-breaks are applied in the documented order.
- Admin tie-break decision requires reason and audit log.
- Scores reset between stages by default.
- Stream-safe leaderboard excludes private fields.
