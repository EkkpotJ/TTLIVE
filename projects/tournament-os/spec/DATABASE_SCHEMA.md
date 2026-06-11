# Database Schema Draft

This is a planning draft, not a final migration.

## Core Entities

### users

- id
- display_name
- email
- discord_id
- role
- created_at
- updated_at

### tournaments

- id
- name
- game
- status
- participant_type
- max_participants
- registration_open_at
- registration_close_at
- public_slug
- rule_set_id
- score_formula_id
- created_by_user_id
- created_at
- updated_at

### rule_sets

- id
- tournament_id
- name
- model
- participant_type
- lobby_size
- max_participants
- min_participants
- games_per_stage
- final_games
- score_reset_policy
- advancement_policy_json
- lobby_assignment_policy_json
- verification_policy_json
- created_at
- updated_at

### registrations

- id
- tournament_id
- user_id
- team_id
- status
- in_game_name
- game_uid
- contact_method
- review_note
- submitted_at
- reviewed_by_user_id
- reviewed_at
- created_at
- updated_at

### teams

- id
- tournament_id
- name
- captain_user_id
- status
- created_at
- updated_at

### team_members

- id
- team_id
- user_id
- in_game_name
- game_uid
- role
- created_at

### stages

- id
- tournament_id
- name
- sequence
- format
- status
- created_at
- updated_at

### groups

- id
- tournament_id
- stage_id
- name
- sequence
- created_at
- updated_at

### group_participants

- id
- group_id
- registration_id
- seed
- status
- created_at
- updated_at

### rounds

- id
- tournament_id
- stage_id
- group_id
- name
- sequence
- scheduled_at
- status
- created_at
- updated_at

### score_formulas

- id
- tournament_id
- rule_set_id
- name
- placement_points_json
- bonus_rules_json
- penalty_rules_json
- bye_rule_json
- tie_break_order_json
- manual_override_policy_json
- created_at
- updated_at

### scores

- id
- tournament_id
- stage_id
- group_id
- round_id
- registration_id
- placement
- placement_points
- bonus_points
- penalty_points
- bye_points
- total_points
- status
- evidence_uri
- note
- submitted_by_user_id
- approved_by_user_id
- approved_at
- created_at
- updated_at

### disputes

- id
- tournament_id
- score_id
- registration_id
- status
- reason
- evidence_uri
- resolved_note
- opened_by_user_id
- resolved_by_user_id
- created_at
- updated_at

### audit_logs

- id
- actor_user_id
- entity_type
- entity_id
- action
- before_json
- after_json
- reason
- created_at

## Important Constraints

- Unique tournament `public_slug`.
- A tournament should have one active `rule_set_id`.
- Unique registration per `tournament_id` and `user_id`.
- Unique `game_uid` per tournament when provided.
- Unique group participant per `group_id` and `registration_id`.
- Scores should be unique per `round_id` and `registration_id`.

## Open Schema Decisions

- Whether contact fields should be encrypted in the database.
- Whether evidence files are stored locally, S3-compatible storage, or external links.
- Whether role is global or tournament-scoped.
- Whether teams should exist in MVP or solo-only should come first.
