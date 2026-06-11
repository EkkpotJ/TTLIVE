# State Machine

This document defines the main states for registration, tournament operation, scores, and disputes.

## Registration State

```text
Guest
  -> Draft
  -> Submitted
  -> Approved
  -> Rejected
  -> Waitlisted
  -> Withdrawn
```

Allowed transitions:

| From | To | Actor | Notes |
| :--- | :--- | :--- | :--- |
| Guest | Draft | Player | Starts registration |
| Draft | Submitted | Player | Sends registration for review |
| Submitted | Approved | Tournament Admin | Participant can enter tournament |
| Submitted | Rejected | Tournament Admin | Must include reason |
| Submitted | Waitlisted | Tournament Admin | Used when slots are full |
| Approved | Withdrawn | Player or Admin | Depends on tournament rules |
| Waitlisted | Approved | Tournament Admin | Used when a slot opens |
| Rejected | Submitted | Player | Allowed only if resubmission is enabled |

Forbidden transitions:

- Rejected -> Approved without a new review note
- Withdrawn -> Approved after tournament starts, unless admin override is enabled
- Guest -> Approved

## Tournament State

```text
Draft
  -> Registration Open
  -> Registration Closed
  -> Grouping
  -> Ready
  -> Live
  -> Scoring
  -> Review
  -> Finalized
  -> Archived
```

Allowed transitions:

| From | To | Notes |
| :--- | :--- | :--- |
| Draft | Registration Open | Basic rules are configured |
| Registration Open | Registration Closed | Manual close or capacity reached |
| Registration Closed | Grouping | Approved participants are locked for grouping |
| Grouping | Ready | Groups or bracket are generated |
| Ready | Live | Competition starts |
| Live | Scoring | Scores are being entered |
| Scoring | Review | Results need approval |
| Review | Finalized | Official results are published |
| Finalized | Archived | Event is complete |

## Score State

```text
Draft
  -> Submitted
  -> Pending Verification
  -> Approved
  -> Disputed
  -> Corrected
  -> Final
```

Rules:

- Draft scores are visible only to admins.
- Submitted scores can be reviewed by Score Admin or Referee.
- Pending Verification scores should show as pending on player-facing pages.
- Approved scores count toward leaderboard.
- Disputed scores should remain visible with a dispute marker.
- Corrected scores must reference an audit log entry.
- Final scores should be locked except for Super Admin correction.

## Dispute State

```text
Open
  -> Under Review
  -> Accepted
  -> Rejected
  -> Cancelled
```

Rules:

- Players can open disputes for their own scores.
- Referees or Tournament Admins can move disputes under review.
- Accepted disputes should trigger score correction.
- Rejected disputes should include a reason.
- Cancelled disputes are player-withdrawn or admin-closed duplicates.
