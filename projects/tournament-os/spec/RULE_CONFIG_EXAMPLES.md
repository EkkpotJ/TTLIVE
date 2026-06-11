# Rule Config Examples

Status: Backend contract draft.

These examples show how tournament rules can be stored as structured configuration without hardcoding Golden Spatula assumptions into services.

The exact JSON shape can change during implementation, but score calculation, group generation, advancement, and leaderboard tests should all be able to use equivalent data.

## Fixed Points Example

Use when every player can play in one lobby or when a small tournament only needs total points.

```json
{
  "tournament_format": {
    "model": "fixed_points",
    "participant_type": "solo",
    "lobby_size": 8,
    "max_participants": 8,
    "min_participants": 4,
    "games_per_stage": 5,
    "final_games": 0,
    "score_reset_policy": "reset_each_stage"
  },
  "score_formula": {
    "placement_points": {
      "1": 10,
      "2": 8,
      "3": 7,
      "4": 6,
      "5": 4,
      "6": 3,
      "7": 2,
      "8": 1
    },
    "bonus_rules": [],
    "penalty_rules": [
      {
        "code": "manual_penalty",
        "label": "Manual penalty",
        "min_points": 1,
        "max_points": 5,
        "requires_reason": true
      }
    ],
    "bye_rule": {
      "behavior": "none",
      "points": 0
    },
    "manual_override_policy": {
      "allowed": false,
      "allowed_roles": ["super_admin"]
    }
  },
  "advancement_rule": {
    "type": "top_n_overall",
    "top_n": 1,
    "carry_score": false,
    "tie_break_order": [
      "total_points",
      "first_place_count",
      "average_placement",
      "latest_game_points",
      "latest_game_placement",
      "admin_decision"
    ]
  },
  "lobby_assignment_rule": {
    "type": "random",
    "allow_manual_adjustment_before_lock": true
  },
  "verification_rule": {
    "require_evidence": false,
    "require_approval": true,
    "dispute_window_minutes": 15,
    "public_pending_scores": false,
    "lock_after_final": true
  }
}
```

## Group Points Qualifier Example

Use for the recommended Golden Spatula MVP.

```json
{
  "tournament_format": {
    "model": "group_points_qualifier",
    "participant_type": "solo",
    "lobby_size": 8,
    "max_participants": 32,
    "min_participants": 16,
    "games_per_stage": 2,
    "final_games": 3,
    "score_reset_policy": "reset_each_stage",
    "stage_plan": [
      {
        "name": "Round 1",
        "sequence": 1,
        "groups": 4,
        "players_per_group": 8,
        "games": 2,
        "advancement": {
          "type": "top_n_per_lobby",
          "top_n": 4
        }
      },
      {
        "name": "Semi Final",
        "sequence": 2,
        "groups": 2,
        "players_per_group": 8,
        "games": 2,
        "advancement": {
          "type": "top_n_per_lobby",
          "top_n": 4
        }
      },
      {
        "name": "Final",
        "sequence": 3,
        "groups": 1,
        "players_per_group": 8,
        "games": 3,
        "advancement": {
          "type": "top_n_overall",
          "top_n": 1
        }
      }
    ]
  },
  "score_formula": {
    "placement_points": {
      "1": 10,
      "2": 8,
      "3": 7,
      "4": 6,
      "5": 4,
      "6": 3,
      "7": 2,
      "8": 1
    },
    "bonus_rules": [],
    "penalty_rules": [
      {
        "code": "rule_violation",
        "label": "Rule violation",
        "min_points": 1,
        "max_points": 5,
        "requires_reason": true
      }
    ],
    "bye_rule": {
      "behavior": "advance_only",
      "points": 0
    },
    "manual_override_policy": {
      "allowed": true,
      "allowed_roles": ["super_admin"],
      "requires_reason": true,
      "creates_audit_log": true
    }
  },
  "advancement_rule": {
    "type": "top_n_per_lobby",
    "top_n": 4,
    "carry_score": false,
    "tie_break_order": [
      "total_points",
      "first_place_count",
      "average_placement",
      "latest_game_points",
      "latest_game_placement",
      "admin_decision"
    ]
  },
  "lobby_assignment_rule": {
    "type": "random",
    "allow_manual_adjustment_before_lock": true,
    "lock_status": "ready"
  },
  "verification_rule": {
    "require_evidence": false,
    "require_approval": true,
    "dispute_window_minutes": 15,
    "public_pending_scores": false,
    "lock_after_final": true
  },
  "public_visibility": {
    "show_registration_count": true,
    "show_groups": true,
    "show_approved_scores": true,
    "show_pending_scores": false,
    "hide_private_contact": true,
    "hide_private_evidence": true
  }
}
```

## Validation Rules

The backend rule validation service should reject configs when:

- `participant_type` is not supported by the current build.
- `max_participants` is less than `min_participants`.
- `lobby_size` is less than 2.
- Placement points do not cover all expected placements from 1 to `lobby_size`.
- `top_n` is greater than `players_per_group`.
- `final_games` is 0 for a multi-stage tournament with final stage.
- `manual_override_policy.allowed` is true without `requires_reason`.
- Public visibility allows private contact fields or private evidence links.

## Services That Use This Config

- Rule set validation service
- Group generation service
- Score calculation service
- Leaderboard service
- Advancement service
- Public serialization layer
- Export service
