# Projects

ใช้แยกงานตามเกม รายการ แคมเปญ หรือ sponsor

## ระบบเสริมที่แยกชัดเจน

`tournament-os/` คือระบบเสริมสำหรับกรณีมีการจัดการแข่งขันเกม เช่น รับสมัครผู้เล่น จัดกลุ่ม บันทึกคะแนน ตรวจสอบผล และทำ leaderboard

ระบบนี้แยกจากงานไลฟ์ประจำสัปดาห์ เพื่อให้สามารถนำไปพัฒนาเป็นเว็บหรือ backend จริงต่อได้ในอนาคต

ตัวอย่าง:

```text
projects/
  wild-rift/
  golden-spatula/
  sponsor-campaigns/
```

แต่ละ project ควรมี:

```text
plan.md
schedule.md
assets/
templates/
reports/
```
