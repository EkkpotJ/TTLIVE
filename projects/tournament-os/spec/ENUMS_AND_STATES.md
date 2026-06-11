# Enums And States

Status: Backend contract draft.

Use this file as the shared vocabulary for database enums, API schemas, tests, and admin UI labels.

## Naming Rules

- Store enum values in lowercase snake case.
- Render user-facing labels separately.
- Never compare business logic against translated labels.

## User Roles

| Value | Meaning |
| :--- | :--- |
| `super_admin` | Full system access |
| `tournament_admin` | Manage assigned tournaments |
| `score_admin` | Enter and edit scores |
| `referee` | Verify scores and review disputes |
| `player` | Register and view own tournament data |
| `viewer` | Public read-only access |

MVP can start with global roles, but the schema should not block tournament-scoped roles later.

## Participant Type

| Value | Meaning |
| :--- | :--- |
| `solo` | One player |
| `duo` | Two players |
| `squad` | Small fixed team |
| `team` | Configurable team |

MVP uses `solo`.

## Tournament Status

| Value | Meaning |
| :--- | :--- |
| `draft` | Rules and setup are editable |
| `registration_open` | Players can register |
| `registration_closed` | Registration is closed |
| `grouping` | Admin is generating or editing groups |
| `ready` | Groups are locked and tournament can start |
| `live` | Tournament is in progress |
| `scoring` | Scores are being entered |
| `review` | Scores/results are under review |
| `finalized` | Official results are published |
| `archived` | Tournament is complete and hidden from active admin flow |

## Registration Status

| Value | Meaning |
| :--- | :--- |
| `draft` | Player started but has not submitted |
| `submitted` | Awaiting admin review |
| `approved` | Eligible for grouping |
| `rejected` | Not accepted |
| `waitlisted` | Accepted as reserve only |
| `withdrawn` | Player/team withdrew or was removed |

## Stage Status

| Value | Meaning |
| :--- | :--- |
| `draft` | Stage exists but is editable |
| `ready` | Groups and rounds are ready |
| `live` | Stage is running |
| `scoring` | Stage scores are being entered |
| `review` | Stage results are under review |
| `finalized` | Stage result is locked |

## Group Participant Status

| Value | Meaning |
| :--- | :--- |
| `assigned` | Participant is assigned to this group |
| `checked_in` | Participant manually checked in |
| `no_show` | Participant did not appear |
| `withdrawn` | Participant withdrew after assignment |
| `advanced` | Participant advanced from this group |
| `eliminated` | Participant did not advance |

## Round Status

| Value | Meaning |
| :--- | :--- |
| `scheduled` | Round is planned |
| `live` | Round is being played |
| `scoring` | Scores are being entered |
| `review` | Scores are awaiting verification |
| `finalized` | Round score is locked |
| `cancelled` | Round was cancelled |

## Check-In Session Status

| Value | Meaning |
| :--- | :--- |
| `draft` | Session exists but check-in is not open |
| `open` | Eligible players can check in |
| `closed` | Normal player check-in is closed |
| `locked` | Changes require admin correction reason |
| `archived` | Historical only |

## Check-In Status

| Value | Meaning |
| :--- | :--- |
| `not_required` | Player is not expected in this session |
| `pending` | Player is expected but has not checked in |
| `checked_in` | Player checked in during the open window |
| `late_checked_in` | Admin accepted a late check-in |
| `no_show_pending` | Player missed window and awaits admin decision |
| `no_show` | Player is treated as absent |
| `excused` | Admin marked absence as excused |
| `replaced` | Player was replaced by another participant |

## Score Status

| Value | Meaning |
| :--- | :--- |
| `draft` | Admin-only score draft |
| `submitted` | Score submitted for verification |
| `pending_verification` | Visible as pending if public setting allows |
| `approved` | Counts toward leaderboard |
| `disputed` | Player has opened a dispute |
| `corrected` | Score was corrected after review |
| `final` | Locked official score |

## Dispute Status

| Value | Meaning |
| :--- | :--- |
| `open` | Player submitted dispute |
| `under_review` | Admin/referee is reviewing |
| `accepted` | Dispute accepted and score should be corrected |
| `rejected` | Dispute rejected with reason |
| `cancelled` | Player withdrew or admin closed duplicate |

## Tournament Models

| Value | Meaning |
| :--- | :--- |
| `fixed_points` | One group or small set of games, highest total wins |
| `group_points_qualifier` | Multiple lobbies, top N advance |
| `lobby_shuffle` | Lobbies reshuffle based on score/rank |
| `bracket_knockout` | Elimination-style structure |
| `checkmate_final` | Threshold plus win condition final |

MVP supports `fixed_points` and `group_points_qualifier`.

## Score Reset Policy

| Value | Meaning |
| :--- | :--- |
| `reset_each_stage` | Previous stage scores do not carry forward |
| `carry_forward` | Scores carry into later stages |

MVP default: `reset_each_stage`.

## Advancement Type

| Value | Meaning |
| :--- | :--- |
| `top_n_per_lobby` | Advance top N players in each lobby/group |
| `top_n_overall` | Advance top N players across the stage |
| `threshold` | Advance players above a score/rank threshold |
| `admin_selection` | Admin manually selects with reason |

MVP default: `top_n_per_lobby`.

## Lobby Assignment Type

| Value | Meaning |
| :--- | :--- |
| `random` | Random assignment from approved players |
| `manual` | Admin assigns players |
| `seeded` | Use seed ranking |
| `snake_shuffle` | Distribute by snake seeding |
| `score_based_shuffle` | Reassign by score after games |

MVP default: `random`, with manual adjustment before lock.

## Bye Behavior

| Value | Meaning |
| :--- | :--- |
| `none` | No bye support |
| `advance_only` | Participant advances without points |
| `fixed_points` | Fixed points are awarded |
| `average_points` | Points based on an average formula |

MVP default: `advance_only`.

## Audit Actions

Initial action vocabulary:

- `create_tournament`
- `update_tournament`
- `lock_rule_set`
- `open_registration`
- `close_registration`
- `submit_registration`
- `approve_registration`
- `reject_registration`
- `waitlist_registration`
- `withdraw_registration`
- `generate_groups`
- `move_group_participant`
- `create_score`
- `update_score`
- `submit_score`
- `approve_score`
- `finalize_score`
- `open_dispute`
- `review_dispute`
- `accept_dispute`
- `reject_dispute`
- `export_results`
