# Evidence Images And Discord Role Analysis

Status: Architecture analysis draft.

This document answers two operational questions:

1. What should the system do with end-of-match screenshots?
2. How should Discord bot permissions, server roles, and Tournament OS permissions relate?

## Direct Answer

The system should support uploading end-of-match images, but images must be treated as evidence and processing input, not official results by themselves.

Discord roles can help with channel access and user experience, but Tournament OS should not trust Discord roles as the final permission source. The backend must own official permissions.

## End-Of-Match Image Flow

### What Users Upload

Accepted evidence types:

- End-of-match screenshot
- Scoreboard screenshot
- Replay/video link
- Caster/referee note
- Discord attachment
- External image link

MVP recommendation:

- Start with evidence reference text or URL.
- Add file upload after manual score flow works.
- Add OCR only after score approval workflow is stable.

## What The System Does With Images

### Phase 1: Store Evidence Reference

Purpose:

Let admins/referees review proof manually.

Flow:

```text
Player/admin uploads image or link
  -> FastAPI validates tournament/round/player
  -> stores attachment/evidence reference
  -> links evidence to score or dispute
  -> referee reviews manually
```

Official score still comes from admin/referee approval.

### Phase 2: Evidence Attachment Table

Recommended future table:

```text
attachments
  id
  tournament_id
  uploaded_by_user_id
  source
  storage_uri
  original_filename
  mime_type
  file_size_bytes
  checksum_sha256
  visibility
  status
  created_at
```

Recommended fields on `scores` or join table:

```text
score_evidence
  id
  score_id
  attachment_id
  evidence_type
  created_at
```

Recommended fields on `disputes` or join table:

```text
dispute_evidence
  id
  dispute_id
  attachment_id
  evidence_type
  created_at
```

Why a separate table:

- One score may have multiple images.
- One dispute may have multiple images.
- Files can come from web, Discord, or future storage.
- Visibility and retention rules are easier.

### Phase 3: OCR Suggestion

OCR should produce suggestions only.

Flow:

```text
Image uploaded
  -> attachment record created
  -> plugin_run created: ocr_score_reader
  -> OCR extracts possible player names/placements
  -> plugin_suggestion created
  -> admin/referee reviews
  -> accepted suggestion calls Score Service
  -> official score changes with audit log
```

The OCR plugin must not:

- Approve score directly
- Finalize score
- Advance players
- Replace referee decision

### Phase 4: Quality And Fraud Checks

Possible plugin outputs:

- Low image quality warning
- Duplicate image warning by checksum
- Mismatched tournament/stage warning
- Player name not found warning
- Placement confidence score
- Evidence conflict warning

These should appear as review hints on the admin/referee screen.

## Image Storage Policy

Recommended MVP:

- Store external URL or Discord attachment URL as evidence reference.
- Do not download/store files until upload flow is designed.

Recommended production:

- Store files in object storage.
- Store metadata in PostgreSQL.
- Use private storage by default.
- Public pages never expose private evidence links.

Visibility values:

- `private_admin`
- `player_private`
- `public_safe`

Status values:

- `pending_review`
- `accepted`
- `rejected`
- `archived`

## Evidence Review UI

Score Review page should show:

- Image preview
- Source: web, Discord, admin, player
- Uploaded by
- Upload time
- Linked stage/group/round
- OCR/plugin suggestion if available
- Confidence score if available
- Accept/reject evidence action
- Correct score action with reason

Dispute Review page should show:

- Disputed score
- Player explanation
- Evidence images
- Admin/referee resolution note
- Score correction workflow

## Discord Image Upload Flow

Player evidence flow:

```text
/dispute open
  -> bot asks for score/game
  -> player submits reason
  -> player attaches screenshot
  -> bot sends metadata to FastAPI
  -> FastAPI creates dispute and evidence reference
  -> admin web dispute queue updates
```

Admin/referee evidence flow:

```text
/score evidence
  -> referee selects round/group/player
  -> attaches screenshot
  -> FastAPI links evidence to score draft
```

Important:

Discord attachment URLs should not be treated as permanent storage without a storage policy. If long-term retention matters, the backend should copy the file into managed object storage later.

## Discord Permission Analysis

Discord has its own permission and role system. It includes guild-level role permissions and channel-level overwrites. Discord also has role hierarchy rules: a bot can only manage roles lower than its own highest role.

Implication:

The bot can lose the ability to assign/remove tournament roles if server admins move roles around or change channel overwrites.

## Backend Permissions vs Discord Roles

Use two separate concepts:

### Backend Permission

Owned by Tournament OS.

Examples:

- `super_admin`
- `tournament_admin`
- `score_admin`
- `referee`
- `player`
- `viewer`

Controls:

- Approve registrations
- Generate groups
- Enter scores
- Approve scores
- Resolve disputes
- Export data
- View private contact/evidence

### Discord Role

Owned by Discord server.

Examples:

- Tournament Player
- Checked In
- Qualified
- Referee
- Tournament Admin

Controls:

- Channel visibility
- Ping groups
- Cosmetic display
- Discord command access hints

Must not solely control:

- Official score approval
- Dispute resolution
- Registration approval
- Export access
- Private data access

## Should Role Assignment Be Bot Or User?

Recommended:

- Backend decides who should have a tournament-related role.
- Bot applies or removes Discord roles as a convenience.
- Human server admins may manually adjust roles in Discord, but Tournament OS should detect drift.

For official permissions:

- Use backend `tournament_user_roles`.
- Do not depend on Discord roles alone.

For Discord access:

- Bot can assign `Tournament Player`, `Checked In`, or `Qualified` roles if permissions allow.
- If bot cannot assign a role, tournament can continue through web app.

## Role Drift Problem

Role drift happens when:

- Server admin manually adds/removes a role.
- Bot role is moved lower in the role list.
- Channel overwrite changes.
- Role ID changes after role recreation.
- User leaves and rejoins server.
- Bot loses `Manage Roles` permission.

Potential result:

- Discord shows a user as Referee, but backend does not.
- Backend says user is approved player, but Discord role is missing.
- Bot tries to assign role and fails.

## Drift-Safe Design

Add a role sync table later:

```text
discord_role_links
  id
  tournament_id
  guild_id
  role_type
  role_id
  role_name_snapshot
  managed_by_bot
  created_at
  updated_at
```

Add role assignment records:

```text
discord_role_assignments
  id
  tournament_id
  user_id
  discord_user_id
  role_type
  desired_role_id
  last_known_has_role
  sync_status
  last_error
  last_checked_at
  updated_at
```

Sync statuses:

- `in_sync`
- `pending_apply`
- `pending_remove`
- `failed_permission`
- `failed_role_missing`
- `manual_override_detected`

## Role Sync Flow

```text
Backend event: registration.approved
  -> desired Discord role = Tournament Player
  -> discord_role_assignment upserted
  -> worker asks Discord API to add role
  -> success/failure saved
  -> admin dashboard shows role sync status
```

On role drift check:

```text
Worker fetches member roles
  -> compares actual Discord roles with desired backend roles
  -> marks in_sync or drifted
  -> does not change official backend permission
```

## Bot Permission Requirements

Minimum permissions for notification-only:

- Send Messages
- Embed Links
- Use Slash Commands

For evidence upload:

- Attach Files if bot needs to upload files
- Read Message History if reading message attachments in channels

For role assignment:

- Manage Roles
- Bot role must be above managed roles

Avoid:

- Administrator permission
- Manage Guild unless absolutely needed
- Broad moderation permissions for tournament flow

## Command Permission Strategy

For player commands:

- Allow broad Discord command visibility.
- Backend returns only actions allowed for that user.
- Private responses should be ephemeral.

For admin/referee commands:

- Restrict command availability by Discord channel/role where possible.
- Still validate backend role before action.

Reason:

Discord command permission is a convenience filter. Backend permission is final.

## If Discord Role Changes Manually

The bot may be "confused" only if the system treats Discord roles as truth.

In the recommended design:

- Backend remains correct.
- Bot may fail to apply/remove Discord role.
- Admin dashboard shows role sync warning.
- User can still use web flow if backend permission allows.
- Discord command can call backend and show correct official status.

Example:

```text
User lost Discord Tournament Player role manually.
Backend registration.status = approved.

/my-group still works because backend recognizes the player.
Admin dashboard shows Discord role drift.
Bot attempts re-sync if configured.
```

## Web Admin Discord Settings

Add later:

- Guild connected status
- Bot highest role check
- Managed role list
- Channel list
- Test message button
- Role sync status
- Failed role assignments
- Drift detected count
- Permission warning checklist

## Recommended MVP

For first build:

1. Evidence: store URL/reference only.
2. Images: manual review only.
3. OCR: not official, later plugin.
4. Discord roles: notification/access helper only.
5. Backend roles: official permission source.
6. Bot role assignment: optional after registration/check-in flows work.
7. Role drift: track later, do not block MVP.

## Improvements To Existing Specs

Add before implementation:

- `attachments` table decision.
- Evidence linking strategy for score/dispute.
- Discord role sync strategy.
- Backend `tournament_user_roles` strategy.
- Discord settings dashboard.
- Role drift warning behavior.

## Acceptance Checklist

Evidence and Discord roles are safe to implement when:

- Evidence image never becomes official score automatically.
- OCR/plugin output requires admin/referee approval.
- Private evidence is never exposed publicly.
- Backend roles control official permissions.
- Discord roles only help channel access/display.
- Bot can continue without Administrator permission.
- Role drift is detected or at least does not corrupt backend state.
