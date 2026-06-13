# Cute Single Page Web UI Spec

Status: UI direction draft.

This document defines a cute, friendly, and beautiful single-page web interface for Tournament OS.

The goal is to keep Tournament OS usable during real tournament operations while making the interface feel softer, more approachable, and more fun than a plain admin dashboard.

## Design Goal

Tournament OS should feel like:

- A cute esports control room
- A friendly tournament dashboard
- Easy for a solo organizer to use
- Clear enough for live-event pressure
- Fun enough for players, casters, and community use

The interface should not feel like a corporate ERP screen.

## Product Mood

Keywords:

- Cute
- Soft
- Friendly
- Pastel esports
- Rounded
- Clean
- Playful
- Calm
- Stream-friendly
- Easy to scan

Avoid:

- Heavy black enterprise dashboard
- Overly aggressive cyberpunk style
- Too many sharp corners
- Dense CRUD-only screens
- Plain tables without visual grouping

## Visual Theme

Recommended theme name:

`Pastel Arena Command Center`

### Color Palette

Use a dark-soft background with pastel accents.

```text
Background: #0F1020
Surface: #181A2F
Soft Card: rgba(255, 255, 255, 0.07)
Card Border: rgba(255, 255, 255, 0.12)
Primary Pink: #FF8ACD
Primary Purple: #B794F6
Sky Blue: #7DD3FC
Mint Green: #86EFAC
Lemon Yellow: #FDE68A
Soft Red: #FDA4AF
Text Main: #F8FAFC
Text Muted: #CBD5E1
Text Soft: #94A3B8
```

### Optional Light Cute Theme

For public pages or future user preference:

```text
Background: #FFF7FB
Surface: #FFFFFF
Soft Card: #FFF0F7
Primary Pink: #F472B6
Primary Purple: #A78BFA
Sky Blue: #38BDF8
Mint Green: #4ADE80
Text Main: #1F2937
Text Muted: #64748B
```

MVP can start with dark-soft pastel only.

## Typography

Recommended fonts:

- Kanit for Thai-friendly headings
- Prompt for Thai body text
- Inter for numbers and dashboard data

Typography direction:

- Big friendly headings
- Rounded feeling
- Clear numbers
- Avoid tiny text
- Use enough spacing for mobile

## Layout: Single Page Command Center

The admin app should use one main page for active tournament operation.

```text
┌────────────────────────────────────────────────────────────┐
│ Top Bar                                                    │
├───────────────┬──────────────────────────────┬─────────────┤
│ Left Workflow │ Center Work Area             │ Right Panel │
│ Panel         │                              │             │
└───────────────┴──────────────────────────────┴─────────────┘
```

The page must not feel like many separate admin pages. It should feel like one cute control room.

## Top Bar

Purpose:

Show current tournament context and global actions.

Required elements:

- Tournament selector
- Cute tournament avatar/icon
- Tournament status pill
- Current stage label
- Discord sync status
- Public visibility status
- Admin profile/menu

Example:

```text
🌸 Golden Spatula Mini Cup  [Live] [Group Stage]    Discord Synced ✨
```

Design notes:

- Use rounded pill badges
- Use small icons or emoji carefully
- Keep status readable, not childish
- Important status must use color plus text

## Left Workflow Panel

Purpose:

Let the organizer move through tournament work from top to bottom.

Items:

```text
🏠 Overview
💌 Discord Signups
👥 Players / Teams
🍡 Groups / Lobbies
🎮 Matches / Rounds
🧮 Score Entry
✅ Score Review
🏆 Leaderboard
🌈 Bracket
🗣️ Announcements
⚠️ Disputes
📦 Export
🧾 Audit Log
```

Design notes:

- Use rounded navigation buttons
- Active item should glow softly
- Each item can show a small count badge
- Example: `💌 Discord Signups 12`

## Center Work Area

Purpose:

Main working space. Content changes based on the selected workflow, but the user remains on the same page.

General requirements:

- Use card sections
- Use tabs inside panels only when necessary
- Keep action buttons visible
- Avoid hiding important actions deep inside modals
- Use cute empty states
- Use clear loading and error states

## Right Quick Action Panel

Purpose:

Always show what needs attention next.

Widgets:

- Next required action
- Pending Discord signups
- Scores waiting for review
- Today matches
- Recent updates
- Quick publish controls
- Discord sync log

Example:

```text
✨ Next Action
Approve 5 Discord signups

💌 Pending Signups: 5
🧮 Scores to Review: 2
🎮 Matches Today: 8
⚠️ Open Disputes: 0
```

Design notes:

- Should feel like a cute assistant panel
- Use soft cards stacked vertically
- Keep critical alerts visually stronger

## Cute Component System

### Cards

Cards should be rounded, soft, and layered.

Style:

```text
border-radius: 24px
background: rgba(255,255,255,0.07)
border: 1px solid rgba(255,255,255,0.12)
box-shadow: soft shadow only
```

### Buttons

Primary button:

- Pink to purple gradient
- Rounded full pill or large radius
- Soft glow on hover

Secondary button:

- Transparent glass
- Thin border
- Soft hover background

Danger button:

- Soft red
- Require confirmation when destructive

### Badges

Use pill badges for every status.

Tournament status:

- Draft: Gray
- Registration Open: Mint
- Registration Closed: Yellow
- Live: Pink/Purple
- Completed: Sky Blue
- Cancelled: Soft Red

Registration status:

- Submitted: Sky Blue
- Pending Review: Yellow
- Approved: Mint
- Rejected: Soft Red
- Duplicate: Purple
- Incomplete: Gray

Score status:

- Draft: Gray
- Submitted: Yellow
- Approved: Mint
- Finalized: Sky Blue
- Disputed: Soft Red

## Page Panels

## 1. Overview Panel

Purpose:

The first screen after login. It must show real work, not marketing content.

Sections:

- Active tournament summary
- Progress timeline
- Key numbers
- Next action card
- Recent audit/events
- Public page preview link

Cute UI idea:

Use a horizontal progress path:

```text
Setup 🧁 → Discord Signups 💌 → Groups 🍡 → Matches 🎮 → Scores 🧮 → Champion 🏆
```

## 2. Discord Signups Panel

Purpose:

Manage registration coming from Discord.

Required content:

- Signup list from Discord
- Player/team name
- Discord username
- Game UID
- Submitted time
- Status
- Admin note

Actions:

- Approve
- Reject
- Mark duplicate
- Mark incomplete
- Bulk approve selected
- Sync from Discord

Cute UI direction:

- Each signup can be a rounded row/card
- Use avatar circle for Discord user
- Use a small `New ✨` badge for new signup

## 3. Players / Teams Panel

Purpose:

Show approved participants.

Required content:

- Player/team cards
- Search
- Filter by group/status
- Contact visibility only for admins
- Check-in status when available

Actions:

- Edit
- Move group
- Mark no-show
- Disqualify with reason

Cute UI direction:

- Use collectible-card feeling
- Team card can show logo/avatar
- Use soft group tags such as `Group A 🍓`, `Group B 🫐`

## 4. Groups / Lobbies Panel

Purpose:

Assign participants into lobbies.

Layout:

- Lobby cards arranged in columns
- Unassigned participants card
- Waitlist card
- Group generation preview

Actions:

- Generate groups
- Regenerate before lock
- Move participant
- Lock groups

Cute UI direction:

Use dessert/fruit group labels if desired:

```text
Group A 🍓
Group B 🫐
Group C 🍋
Group D 🍇
```

This is visual only. Backend group names remain normal identifiers.

## 5. Matches / Rounds Panel

Purpose:

Manage rounds and match/session progress.

Required content:

- Stage selector
- Round selector
- Lobby selector
- Match/session cards
- Status badges

Actions:

- Start round
- Mark live
- Mark completed
- Open score entry
- Reschedule

Cute UI direction:

- Match card should look like a small battle card
- Use `VS` badge in the center
- Live match can have soft animated glow

## 6. Score Entry Panel

Purpose:

Fast score input.

Required content:

- Stage
- Lobby
- Game number
- Participant rows
- Placement selector
- Kill/bonus/penalty fields if ruleset allows
- Evidence reference
- Auto preview score

Rules:

- Prevent duplicate placement
- Warn missing placement
- Client score is preview only
- Official score must come from FastAPI

Cute UI direction:

- Use large easy-to-click placement chips
- Example: `1st 🥇`, `2nd 🥈`, `3rd 🥉`
- Show total preview in a soft sticky footer

## 7. Score Review Panel

Purpose:

Review submitted scores.

Required content:

- Pending review queue
- Evidence reference
- Score summary
- Change history
- Dispute marker

Actions:

- Approve
- Reject/request correction
- Correct with reason
- Finalize

Cute UI direction:

- Use checklist style
- Approved score gets a cute success animation or small sparkle

## 8. Leaderboard Panel

Purpose:

Show ranking state clearly.

Required content:

- Rank
- Player/team
- Group
- Game scores
- Total
- Qualification status
- Score status
- Dispute status

Cute UI direction:

- Top 3 should have special crown cards
- Remaining players in clean table
- Use soft medal visuals

## 9. Bracket Panel

Purpose:

Show knockout path if tournament format uses bracket.

Required content:

- Bracket rounds
- Participant names
- Winner indicator
- Match status

Cute UI direction:

- Rounded bracket nodes
- Soft connector lines
- Champion card at the end

## 10. Announcements Panel

Purpose:

Publish updates to public page or Discord.

Required content:

- Draft announcement
- Target: Discord / Public page / Both
- Preview
- Publish status

Cute UI direction:

- Message composer should feel like chat
- Use preview bubble

## 11. Disputes Panel

Purpose:

Resolve score disputes.

Required content:

- Dispute list
- Player/team
- Score being disputed
- Reason
- Evidence reference
- Status
- Opened time

Actions:

- Mark under review
- Accept
- Reject
- Cancel duplicate
- Correct score after accepted dispute

Important:

Every resolution requires a note.

## 12. Export Panel

Purpose:

Generate official files.

MVP exports:

- Leaderboard Excel
- Registration summary Excel

Cute UI direction:

- Export cards with icons
- Example: `📊 Leaderboard Excel`, `💌 Registration Summary`

## 13. Audit Log Panel

Purpose:

Trace sensitive changes.

Required content:

- Actor
- Action
- Entity
- Before/after when practical
- Reason
- Timestamp

Design:

- Keep this more serious and readable
- Cute theme should not reduce audit clarity

## Public Pages Cute Direction

Public pages should be more decorative than admin pages.

Public page mood:

- Cute esports event page
- Stream-safe
- Mobile-first
- Shareable

Public pages:

- Tournament landing/status
- Public groups
- Public leaderboard
- Public bracket
- Stream-safe view

Public landing should include:

- Tournament name
- Game
- Status
- Current stage
- Join Discord button
- Rules summary
- Leaderboard link
- Bracket link

Do not show:

- Contact data
- Admin notes
- Private evidence links
- Audit log

## Responsive Behavior

Desktop:

- 3-column command center
- Left workflow fixed
- Right quick panel fixed
- Center scrolls

Tablet:

- Left workflow becomes horizontal icon tabs
- Right panel can collapse into drawer

Mobile:

- Top bar remains
- Workflow becomes bottom tab bar
- Center panel full width
- Right quick actions become expandable sheet

## Motion And Microinteractions

Use small, soft interactions:

- Hover glow on active cards
- Sparkle on successful approval
- Gentle pulse for live matches
- Slide-in toast notifications
- Smooth tab transition

Avoid:

- Too much animation
- Distracting background effects
- Motion that slows score entry

## Empty States

Use friendly empty states.

Examples:

```text
No Discord signups yet 💌
Waiting for players to join from Discord.
```

```text
No scores pending ✨
Everything is reviewed.
```

```text
No disputes 🎀
Tournament is calm right now.
```

## Loading States

Use skeleton cards, not blank screens.

Examples:

- Loading signup cards
- Loading leaderboard rows
- Loading score review queue

## Error States

Errors must be clear and recoverable.

Examples:

```text
Could not sync Discord signups.
Try again or check bot connection.
```

```text
Score save failed.
Your draft is still on this screen. Please retry.
```

## Accessibility

Cute design must remain readable.

Requirements:

- Text contrast must be sufficient
- Status must not depend only on color
- Buttons must have text labels
- Keyboard navigation should work
- Tables must remain readable
- Mobile tap targets should be large enough

## Implementation Notes For Codex

When implementing:

1. Do not change backend API contracts yet.
2. Do not remove current Tournament OS specs.
3. Build UI as a single-page command center.
4. Use mock data only if backend is not implemented yet.
5. Keep components reusable.
6. Keep admin and public data models separate.
7. Discord registration is the source for signup flow.
8. FastAPI remains the source of tournament truth.
9. Client-side score preview is not official.
10. Official score must come from backend response.

## Suggested Component Names

```text
TournamentCommandCenter
TournamentTopBar
WorkflowSidebar
QuickActionPanel
CuteStatusBadge
SoftCard
DiscordSignupQueue
ParticipantCard
GroupLobbyBoard
MatchRoundBoard
ScoreEntryPanel
ScoreReviewQueue
LeaderboardPanel
BracketPanel
AnnouncementComposer
DisputeReviewPanel
ExportPanel
AuditLogPanel
```

## Final Direction

Tournament OS should feel like:

```text
A cute pastel esports cockpit for running a real tournament.
```

It should be beautiful and friendly, but still fast, serious, and reliable when the tournament is live.
