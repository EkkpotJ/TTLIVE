# Roles And Permissions

เอกสารนี้เป็นร่างระบบสิทธิ์สำหรับ TTLIVE เมื่ออนาคตมีคนเพิ่มเข้ามาช่วยงาน

หลักการสำคัญ:

- ให้สิทธิ์เท่าที่จำเป็นต่อหน้าที่
- ไม่เก็บ password, token, stream key หรือ secret ใน Git
- ใช้ password manager หรือระบบจัดการสิทธิ์ของ platform
- งานที่กระทบแบรนด์หรือบัญชีหลักต้องมี Owner อนุมัติ

## Permission Levels

| Level | ความหมาย | ใช้กับ |
| :---: | :--- | :--- |
| L0 | ดูข้อมูลสาธารณะ/คู่มือได้ | คนช่วยทั่วไป |
| L1 | แก้เอกสาร/เสนอแผนได้ | Content, Moderator |
| L2 | แก้ asset/template/output ได้ | Designer, Editor |
| L3 | จัดการ automation/data ได้ | Automation / Tech |
| L4 | จัดการบัญชี platform และอนุมัติงาน | Owner / Admin |

## Role Matrix

| Role | สิทธิ์หลัก | แก้ได้ | ต้องขออนุมัติก่อน |
| :--- | :--- | :--- | :--- |
| Owner | ตัดสินใจทั้งหมด ดูแลบัญชีหลัก | ทุกส่วน | ไม่ต้อง |
| Admin | ช่วยดูระบบและประสานงาน | Dashboard, schedules, reports | เปลี่ยนสิทธิ์บัญชี, sponsor |
| Streamer | ไลฟ์จริงและสื่อสารกับคนดู | live reports, clip candidates | เปลี่ยน brand/system |
| Content Planner | วางแผนตาราง หัวข้อ caption | content, schedules, templates text | โพสต์ใหญ่/campaign |
| Designer | ทำภาพ ปก ตาราง overlay | assets, templates, outputs | เปลี่ยน brand guideline |
| Editor | ตัดคลิปและเตรียม upload | clips, clip reports | โพสต์จริงถ้ายังไม่ใช่ admin |
| Moderator | ดูแล chat และกิจกรรมคนดู | community notes, viewer notes | ban ถาวร/กฎใหม่ |
| Automation / Tech | ดูแล script/data/config | automation, data, templates | secret, production credentials |
| Sponsor / Sales | ติดต่อ sponsor และดีลงาน | monetization docs | ราคา/สัญญา/ข้อมูลบัญชี |

## GitHub Permission Draft

| Role | GitHub Permission | เหตุผล |
| :--- | :--- | :--- |
| Owner | Admin | จัดการ repo และสิทธิ์ |
| Admin | Maintain | ดูแล branch, issue, project |
| Automation / Tech | Write | แก้ script/data |
| Designer / Editor | Write หรือ Triage | เพิ่ม asset/output หรือจัด issue |
| Moderator | Triage | ดู issue/comment ไม่จำเป็นต้องแก้ code |
| Viewer/Contributor | Read | อ่านคู่มือหรือเสนอผ่าน issue |

## Approval Rules

ต้องให้ Owner อนุมัติก่อน:

- เปลี่ยนชื่อช่องหรือ brand direction
- เพิ่ม/ลบสิทธิ์บัญชี platform
- เปลี่ยน stream key หรือข้อมูล sensitive
- โพสต์ sponsor หรือดีลเงิน
- ลบ asset/output ที่ใช้จริงแล้ว
- merge งานใหญ่เข้า `main`

## Security Rules

- ห้าม commit password, token, stream key
- ห้ามส่งข้อมูลลับใน issue/comment สาธารณะ
- ถ้าต้องแชร์ไฟล์ใหญ่ ให้ใช้ cloud storage แล้วกำหนดสิทธิ์
- ถ้าคนออกจากทีม ต้อง revoke access ทันที
