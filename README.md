# UniMarket — ตลาดนัดออนไลน์มหาวิทยาลัย (Full-Stack Flutter + Django OIDC)

> **วิชา:** Mobile Application Development  
> **อาจารย์ผู้สอน:** ดร.วิชิต สมบัติ (Wichit Sombat)  
> **ผู้พัฒนา:** Kitthanakorn Chueaprathum (66114540047)  

UniMarket คือแพลตฟอร์มตลาดนัดออนไลน์สำหรับนักศึกษาและบุคลากรมหาวิทยาลัยอุบลราชธานี เพื่อแก้ปัญหาการซื้อขายและส่งต่อสิ่งของในมหาวิทยาลัย เช่น หนังสือเรียน อุปกรณ์การเรียน เครื่องแต่งกาย และของใช้ในหอพัก ให้เป็นไปอย่างสะดวก ปลอดภัย และยืนยันตัวตนได้จริง โดยเชื่อมต่อระบบยืนยันตัวตนมาตรฐาน **OpenID Connect (OIDC)** ผ่าน Django OIDC Server ร่วมกับแอปพลิเคชันมือถือและเว็บที่พัฒนาด้วย **Flutter (MVVM Architecture)**

---

## ✨ Features

### 🎯 1. ฟีเจอร์หลัก (Core Functions — 20 คะแนน)
* 🔐 **Authentication (OIDC):** เข้าสู่ระบบและออกจากระบบผ่าน OpenID Connect Provider (`django-oidc-provider`) Authorization Code Flow มี Route Guard ปกป้องทุกหน้าจอ และจัดเก็บ Token ใน `flutter_secure_storage` เพื่อให้ Session อยู่รอดเมื่อปิด-เปิดแอป
* ➕ **Create (สร้างข้อมูล):** ลงขายสินค้าใหม่พร้อมฟอร์มตรวจสอบความถูกต้อง (Validation) ทั้งชื่อ ราคา สภาพสินค้า และหมวดหมู่
* 📖 **Read (ดึงข้อมูล):** แสดงรายการสินค้าในตลาด (List View) พร้อมรายละเอียดของสินค้า ผู้ขาย และสถานะ (Detail View)
* ✏️ **Update (แก้ไขข้อมูล):** เจ้าของสินค้าสามารถแก้ไขราคา รายละเอียด หรือปรับสถานะสินค้าเป็น "ขายแล้ว" (Sold) ได้ผ่านหน้าสินค้าของฉัน (My Listings) ซิงค์ตรงกับ Backend REST API
* 🗑️ **Delete (ลบข้อมูล):** เจ้าของสินค้าสามารถลบรายการสินค้าของตนเองออกจากระบบได้จริง
* 🛡️ **Error Handling:** จัดการข้อผิดพลาดอย่างเป็นมิตร แสดง SnackBar / แจ้งเตือนเมื่อเซิร์ฟเวอร์ออฟไลน์ หรือการเชื่อมต่อล้มเหลว โดยแอปพลิเคชันไม่แครช

### ⭐ 2. ฟีเจอร์เสริม (Extra Features — 10 คะแนน)
* 🌙 **Dark Mode (โหมดมืด):** สลับธีมสว่าง/มืดได้ทันทีผ่านปุ่มบน Top Bar หรือหน้า Profile พร้อมจดจำค่าไว้ด้วย `shared_preferences`
* 🔍 **Real-time Search & Multi-Filter:** ค้นหาชื่อและคำอธิบายสินค้าแบบเรียลไทม์ พร้อมกรองตาม 8 หมวดหมู่ และสภาพสินค้า (มือหนึ่ง / มือสอง)
* 💬 **Chat System:** ห้องสนทนาสอบถามสินค้าระหว่างผู้ซื้อและผู้ขาย
* 🪪 **Student Identity Verification:** ส่งคำขอยืนยันตัวตนด้วยบัตรนักศึกษา พร้อมตราสัญลักษณ์ Verified Student
* ⚙️ **Admin Moderation & Role Switch:** แดชบอร์ดตรวจสอบ อนุมัติ ระงับสินค้า และจัดการเรื่องร้องเรียน

---

## 🧰 Tech Stack

* **Frontend:** [Flutter SDK 3.47.x](https://flutter.dev/) (Dart 3.13.x)
  * State Management: `provider` (MVVM Pattern)
  * OIDC & Storage: `openid_client`, `flutter_secure_storage`, `shared_preferences`
  * Typography & Networking: `google_fonts`, `http`, `intl`
* **Backend:** [Django 5.2.x](https://www.djangoproject.com/) + [Django REST Framework 3.18.x](https://www.django-rest-framework.org/)
  * OIDC Provider: `django-oidc-provider 0.9.x` (RS256, Authorization Code Flow with PKCE, userinfo endpoint)
  * Real-time & WebSockets: `channels`, `daphne`
  * Admin & UI: `django-jazzmin`, `django-cors-headers`
* **Package & Dependency Manager:** [uv 0.9.x](https://docs.astral.sh/uv/) (Astral)

---

## 📦 Prerequisites

ก่อนเริ่มต้นใช้งาน กรุณาติดตั้งเครื่องมือต่อไปนี้บนเครื่องคอมพิวเตอร์ของคุณ:
1. **[Flutter SDK](https://docs.flutter.dev/get-started/install)** (แนะนำเวอร์ชัน 3.24.x ขึ้นไป)
2. **[uv (Fast Python Package Manager)](https://docs.astral.sh/uv/)** — ติดตั้งผ่านคำสั่ง:
   * Windows: `powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"`
   * macOS / Linux: `curl -LsSf https://astral.sh/uv/install.sh | sh`
3. **[Google Chrome](https://www.google.com/chrome/)** สำหรับเปิดรันเว็บแอปพลิเคชัน
4. **[Git](https://git-scm.com/downloads)**

---

## ▶️ How to Run (วิธีรันระบบตามลำดับจริง)

เปิด Terminal 2 หน้าต่าง แล้วรันตามคำสั่งต่อไปนี้ทีละบรรทัด:

### Terminal 1 — Backend (OIDC Server & Django REST API)
```bash
cd backend
uv sync
uv run manage.py migrate
uv run manage.py creatersakey
uv run manage.py seed_data
uv run manage.py runserver 127.0.0.1:8000
```
> **Endpoints สำคัญ:**
> * OIDC Discovery: `http://127.0.0.1:8000/openid/.well-known/openid-configuration/`
> * API Health Check: `http://127.0.0.1:8000/api/health/`
> * Django Admin: `http://127.0.0.1:8000/admin/`

---

### Terminal 2 — Frontend (Flutter Web App)
```bash
cd unimarket_flutter
flutter pub get
flutter run -d chrome --web-port 50000
```
*(หมายเหตุ: ต้องระบุพอร์ต `--web-port 50000` เพื่อให้ตรงกับ Redirect URI ของ OIDC Provider: `http://localhost:50000/callback`)*

> 💡 **ทางเลือกเสริมสำหรับ Windows:** สามารถดับเบิ้ลคลิกไฟล์ `run_all.bat` ที่โฟลเดอร์หลักเพื่อเปิดทำงานทั้ง Backend และ Frontend พร้อมกันได้ทันที

---

## 💡 Demo Accounts (บัญชีทดสอบ OIDC)

| Role | Username | Password | สิทธิ์และหน้าที่ |
|---|---|---|---|
| **ผู้ดูแลระบบ (Admin)** | `admin` | `admin1234` | ตรวจสอบ อนุมัติ/ระงับสินค้า ดูแดชบอร์ด |
| **นักศึกษา 1** | `somchai_ubu` | `somchai1234` | ซื้อ/ลงขายสินค้า แก้ไข/ลบสินค้าของตนเอง ยืนยันตัวตนแล้ว |
| **นักศึกษา 2** | `thanaporn_k` | `thanaporn1234` | ซื้อ/ลงขายสินค้า แชทสนทนากับนักศึกษา 1 |

*(ในหน้า Login Screen มีปุ่ม Quick Select สำหรับคลิกเลือก Demo Account เพื่อความรวดเร็วในการตรวจงานและบันทึกคลิปวิดีโอ)*