# UniMarket Flutter (Multi-Platform) 🎓🛍️

แอปพลิเคชันตลาดนัดออนไลน์สำหรับมหาวิทยาลัย พัฒนาด้วย **Flutter** รองรับการทำงานแบบสมบูรณ์บนทุกระบบปฏิบัติการ (**Web, Windows Desktop, Android, iOS, macOS, Linux**) โดยออกแบบระบบและการทำงานเทียบเคียงกับระบบ Django เดิมใน `DssiProject` ครบถ้วน 100%

---

## 📱 จุดเด่นของระบบ (Key Features)

1. **รองรับทุกระบบ (True Cross-Platform & Responsive)**:
   - **Desktop / Web**: มีแถบเมนูด้านบน (Top Navigation Bar) และแสดงรายการสินค้าแบบ Grid กว้างสวยงาม
   - **Mobile (iOS / Android)**: มีแถบเมนูด้านล่าง (Bottom Navigation Bar) และระบบสัมผัสที่ใช้งานง่าย
2. **ระบบสินค้า (Marketplace)**:
   - หน้าแรกพร้อมแบนเนอร์แนะนำ และหมวดหมู่ 8 หมวดหมู่นักศึกษา (📚 หนังสือ, 💻 อิเล็กทรอนิกส์, 👕 เสื้อผ้า, 👟 รองเท้า ฯลฯ)
   - ค้นหาสินค้าแบบ Real-time และกรองตามสภาพ (✨ มือหนึ่ง / 📦 มือสอง)
   - หน้ารายละเอียดสินค้า แสดงรูปภาพ ราคา สภาพ ข้อมูลผู้ขาย พร้อมป้ายกำกับ
   - ระบบลงขายสินค้าใหม่ และแก้ไขข้อมูลสินค้า
   - ระบบสินค้าของฉัน (My Listings) แยกแท็บ กำลังขาย / รอตรวจสอบ / ขายแล้ว
3. **ระบบแชทและการสื่อสาร (Chat & Messaging)**:
   - กล่องข้อความ (Inbox) และห้องสนทนาแยกตามสินค้า
   - แสดงข้อมูลสินค้าที่สนใจไว้ด้านบนของห้องแชท
   - ปุ่มส่งข้อความด่วน (Quick Prompts)
4. **ความน่าเชื่อถือและความปลอดภัย**:
   - ระบบยืนยันตัวตนนักศึกษา (Identity Verification) ด้วยบัตรนักศึกษา
   - ป้ายกำกับผู้ขายที่ผ่านการยืนยันตัวตน (Verified Badge ✅)
   - ระบบรีวิวและคะแนนดาวผู้ขาย (Rating & Reviews)
   - ระบบรายงานปัญหา (Report System) แยกหมวดหมู่ปัญหา เช่น หลอกลวง สินค้าปลอม บั๊ก
5. **ศูนย์การแจ้งเตือน (Notifications)**:
   - แจ้งเตือนเมื่อสินค้าผ่านการอนุมัติ ได้รับข้อความใหม่ หรือสถานะเปลี่ยน
6. **แผงควบคุมผู้ดูแลระบบ (Admin Moderation Dashboard)**:
   - คิวตรวจสอบและอนุมัติสินค้า (Approve / Reject / Suspend)
   - คิวตรวจสอบบัตรนักศึกษา
   - จัดการเรื่องร้องเรียนและรายงานปัญหา
   - แถบ **สลับบทบาท (Role Switcher)** ด้านบนเพื่อสลับทดสอบระหว่างนักศึกษาและแอดมินได้ทันที

---

## 🚀 วิธีการรันแอปพลิเคชัน (How to Run)

เปิด Terminal แล้วเข้าไปที่โฟลเดอร์ `unimarket_flutter`:

```bash
cd unimarket_flutter
```

### 1. รันบน Web Browser (Chrome / Edge)
```bash
flutter run -d chrome
```

### 2. รันบน Windows Desktop
```bash
flutter run -d windows
```

### 3. รันบนอุปกรณ์พกพา (Android / iOS)
```bash
# ตรวจสอบเครื่องหรือ Emulator ที่เชื่อมต่อ
flutter devices

# รันบนเครื่องเป้าหมาย
flutter run -d <device_id>
```

### 4. Build สำหรับ Production
```bash
# Build Web
flutter build web

# Build Windows (.exe)
flutter build windows

# Build Android (.apk)
flutter build apk
```

---

## 🛠️ โครงสร้างโฟลเดอร์โปรเจกต์

```
unimarket_flutter/
├── lib/
│   ├── main.dart                      # จุดเริ่มต้นของแอปพลิเคชัน
│   ├── core/
│   │   ├── constants.dart             # ข้อมูลหมวดหมู่, เหตุผลการรีพอร์ต, ข้อความด่วน
│   │   ├── responsive.dart            # Helper Responsive (Mobile / Tablet / Desktop)
│   │   └── theme.dart                 # ธีมสี (Navy Blue & Orange) และฟอนต์
│   ├── models/
│   │   ├── user_model.dart            # User & UserProfile
│   │   ├── product_model.dart         # Product & Category
│   │   ├── chat_model.dart            # ChatRoom & ChatMessage
│   │   ├── review_model.dart          # Review & Rating
│   │   ├── report_model.dart          # Report
│   │   ├── verification_model.dart    # Student Card Verification
│   │   └── notification_model.dart    # Notification
│   ├── services/
│   │   ├── api_service.dart           # REST API Client เชื่อมต่อ Backend
│   │   └── app_state.dart             # State Management ครอบคลุมการทำงานทั้งระบบ
│   └── views/
│       ├── main_navigation.dart       # โครงสร้าง Navigation หลัก
│       ├── home/                      # หน้าแรกและระบบค้นหา
│       ├── product/                   # รายละเอียดสินค้า, ลงขาย, สินค้าของฉัน
│       ├── chat/                      # กล่องข้อความและห้องสนทนา
│       ├── wishlist/                  # รายการโปรด
│       ├── profile/                   # โปรไฟล์, หน้าร้านผู้ขาย, แก้ไขโปรไฟล์
│       ├── verification/              # ส่งบัตรนักศึกษายืนยันตัวตน
│       ├── report/                    # รายงานปัญหาและประวัติรายงาน
│       ├── notifications/             # ศูนย์แจ้งเตือน
│       ├── admin/                     # แดชบอร์ดแอดมิน
│       └── widgets/                   # การ์ดสินค้า, แบนเนอร์สลับบทบาท, กล่องรีพอร์ต
```

---

> [!NOTE]
> โฟลเดอร์ `DssiProject` และฐานข้อมูล/ไฟล์มีเดียเดิมทั้งหมดไม่มีการดัดแปลงหรือเปลี่ยนแปลงใดๆ สามารถทำงานควบคู่กันได้ทันที
