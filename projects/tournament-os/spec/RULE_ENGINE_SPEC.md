# Rule Engine Specification

สถานะ: Draft

เอกสารนี้กำหนดว่า Tournament Operating System ต้องรองรับการออกแบบกติกาแบบไม่ตายตัว โดยให้ผู้จัดสามารถตั้งค่ารูปแบบการแข่งขันและสูตรคะแนนตามเกม จำนวนผู้เล่น เวลา และข้อจำกัดของรายการ

## เป้าหมายของ Rule Engine

Rule Engine ต้องตอบคำถามหลัก 5 ข้อ:

1. มีผู้เล่นกี่คน
2. มีเวลาแข่งเท่าไหร่
3. เกมหนึ่งรองรับผู้เล่นกี่คนต่อ lobby หรือ match
4. ต้องการคัดเหลือกี่คนหรือกี่ทีม
5. คะแนนและการเข้ารอบคำนวณจากกติกาใด

ผลลัพธ์ของ Rule Engine คือ tournament structure ที่นำไปสร้าง stages, lobbies, rounds, score formulas, advancement rules, and leaderboard rules

## Variables

ตัวแปรที่ไม่ตายตัวและต้องใช้ในการคำนวณ:

### Player Variables

- Total participants: `N`
- Participant type: Solo, Duo, Squad, Team
- Players per lobby or match: `lobby_size`
- Maximum participants
- Minimum participants
- Approved participant count
- Waitlist count

### Time Variables

- Available tournament days
- Hours per day
- Expected game duration
- Break time between games
- Check-in duration
- Review and dispute duration
- Stream or broadcast window

### Prize and Goal Variables

- Number of winners
- Number of finalists
- Prize tiers
- Desired final lobby size
- Target elimination speed

### Game Rule Variables

- Placement points
- Kill points or bonus points
- Penalty points
- Bye behavior
- Tie-break order
- Whether scores reset each stage
- Whether scores carry forward
- Whether score approval is required before leaderboard update

## Structural Models

ระบบควรรองรับ structural model อย่างน้อย 5 แบบ

### 1. Fixed Points

ใช้เมื่อ:

- ผู้เล่นน้อย
- ทุกคนแข่งด้วยกันได้ใน 1 lobby หรือไม่กี่ lobby
- ต้องการกติกาเข้าใจง่าย

ตัวอย่าง:

```text
8 players
1 lobby
3-5 games
highest total score wins
```

เหมาะกับ:

- 8 players
- 16 players with a short qualifier
- Final round

### 2. Group Points Qualifier

ใช้เมื่อ:

- ผู้เล่น 16-64 คน
- ต้องแบ่ง lobby
- ต้องคัด Top N จากแต่ละ lobby

ตัวอย่าง:

```text
32 players
4 lobbies
2 games per lobby
Top 4 advance from each lobby
Final 16 or Semi Final 16
```

เหมาะกับ MVP ปัจจุบัน

### 3. Lobby Shuffle

ใช้เมื่อ:

- ผู้เล่น 32-64 คน
- ต้องการความยุติธรรมมากกว่าการล็อกกลุ่มเดิม
- ต้องการให้ผู้เล่นเจอ opponent หลากหลาย

หลักการ:

- หลังทุก 1 หรือ 2 เกม ให้จัด lobby ใหม่ตามคะแนนรวม
- ใช้ snake seeding เพื่อกระจายผู้เล่นคะแนนสูง
- คัดผู้เล่นจากคะแนนรวมหลังครบจำนวนเกมที่กำหนด

ตัวอย่าง snake seeding สำหรับ 32 คน 4 lobbies:

```text
Lobby A: rank 1, 8, 9, 16, 17, 24, 25, 32
Lobby B: rank 2, 7, 10, 15, 18, 23, 26, 31
Lobby C: rank 3, 6, 11, 14, 19, 22, 27, 30
Lobby D: rank 4, 5, 12, 13, 20, 21, 28, 29
```

### 4. Bracket Knockout

ใช้เมื่อ:

- ผู้เล่นจำนวนมาก
- ต้องคัดออกเร็ว
- เกมหรือ format เหมาะกับ match-based elimination

สำหรับเกมแบบ lobby-based สามารถใช้ bracket knockout แบบ:

- แบ่งหลาย lobby
- Top N ผ่านเข้ารอบ
- ผู้ไม่ผ่านถูกคัดออก

ไม่ควรเริ่ม MVP ด้วย single elimination เต็มรูปแบบ ถ้าเกมหลักวัดผลด้วยคะแนน lobby

### 5. Checkmate Final

ใช้เมื่อ:

- เหลือ 8 คนสุดท้าย
- ต้องการรอบชิงที่ลุ้นและจบด้วยเงื่อนไขพิเศษ
- จำนวนเกมไม่ตายตัว

ตัวอย่างเงื่อนไข:

- ผู้เล่นต้องมีคะแนนรวมถึง threshold ก่อน
- หลังถึง threshold แล้วต้องชนะเกมถัดไปหรือได้อันดับ 1 เพื่อเป็นแชมป์

ตัวอย่าง:

```text
Final lobby
8 players
Checkmate threshold: 20 points
Champion condition: player has at least 20 points and then wins a game
```

Checkmate ควรเป็น phase หลัง MVP เพราะคำนวณและอธิบายซับซ้อนกว่า Fixed Points

## Matrix Guide

| จำนวนผู้เล่น | Recommended Model | Grouping | Scoring | Advancement |
| :--- | :--- | :--- | :--- | :--- |
| 8 | Fixed Points or Checkmate | 1 lobby | Total score | Highest total wins |
| 16 | Group Points Qualifier | 2 lobbies of 8 | 2-3 games per group | Top 4 per lobby |
| 32 | Group Points Qualifier or Lobby Shuffle | 4 lobbies of 8 | 2 games per phase | Top 4 per lobby or Top 16 overall |
| 64 | Lobby Shuffle or Group Points Qualifier | 8 lobbies of 8 | 2 games per phase | Top 32, Top 16, Final 8 |
| 128+ | Bracket Knockout + Group Points | Many lobbies | Short phases | Top N per lobby |

## Decision Algorithm Draft

Rule Engine can recommend a model from inputs:

```text
if N <= lobby_size:
    use Fixed Points
elif N <= lobby_size * 2:
    use Group Points Qualifier
elif N <= lobby_size * 8 and fairness_priority is high:
    use Lobby Shuffle
elif N <= lobby_size * 8:
    use Group Points Qualifier
else:
    use Bracket Knockout with Group Points phases
```

Then adjust by time:

```text
available_game_slots = floor(
  available_minutes / (expected_game_minutes + break_minutes)
)

if available_game_slots is low:
    reduce games_per_stage
    increase elimination rate
    avoid checkmate

if available_game_slots is high:
    increase games_per_stage
    allow lobby shuffle
    allow checkmate final
```

## Configurable Rule Objects

The future system should store tournament rules as structured configuration.

### tournament_format

- model: Fixed Points, Group Points Qualifier, Lobby Shuffle, Bracket Knockout, Checkmate Final
- participant_type
- lobby_size
- max_participants
- min_participants
- games_per_stage
- final_games
- score_reset_policy
- advancement_policy

### score_formula

- placement_points
- bonus_rules
- penalty_rules
- bye_rule
- manual_override_policy

### advancement_rule

- type: Top N Per Lobby, Top N Overall, Threshold, Checkmate, Admin Selection
- top_n
- finalist_count
- carry_score
- tie_break_order

### lobby_assignment_rule

- type: Random, Manual, Seeded, Snake Shuffle, Score-Based Shuffle
- shuffle_after_games
- seed_source
- avoid_rematch

### verification_rule

- require_evidence
- require_approval
- dispute_window_minutes
- lock_after_final

## Effect On Score Calculation

กติกาที่ตั้งค่าต้องมีผลต่อการคำนวณคะแนนโดยตรง:

- `placement_points` กำหนดคะแนนจากอันดับ
- `bonus_rules` เพิ่มคะแนนตามเงื่อนไข
- `penalty_rules` หักคะแนนตามบทลงโทษ
- `bye_rule` กำหนดว่าผ่านเข้ารอบเฉย ๆ หรือได้คะแนน
- `score_reset_policy` กำหนดว่าคะแนนรอบก่อนหน้าถูกยกไปหรือ reset
- `advancement_rule` กำหนดว่าผู้เล่นผ่านเข้ารอบจาก Top N lobby หรือ Top N overall
- `tie_break_order` กำหนดวิธีจัดอันดับเมื่อคะแนนเท่ากัน
- `verification_rule` กำหนดว่าคะแนน pending ถูกนับบน leaderboard หรือไม่

## Current System Position

สถานะปัจจุบันของ Tournament OS:

- Model หลัก: Group Points Qualifier
- Game focus: Golden Spatula
- Participants: Solo
- Lobby size: 8
- Score formula draft: 10/8/7/6/4/3/2/1
- Advancement draft: Top 4 per lobby
- Score reset policy: reset each stage
- Verification: manual approval
- Dispute window: 15 minutes

ระบบยังไม่ได้เป็น Rule Engine เต็มรูปแบบ แต่ spec นี้กำหนดเป้าหมายให้ backend ต่อไปต้องทำกติกาเป็น configuration ที่คำนวณได้

## MVP Recommendation

Phase 1 ควรรองรับก่อน:

- Group Points Qualifier
- Fixed Points
- Placement score formula
- Top N per lobby advancement
- Top N overall advancement
- Reset score per stage
- Carry score as optional setting
- Manual score approval
- Basic tie-break order

Phase 2 ค่อยเพิ่ม:

- Lobby Shuffle
- Snake seeding
- Checkmate Final
- Complex bonus/penalty rules
- Advanced bye rules
- Auto format recommendation from N and time
