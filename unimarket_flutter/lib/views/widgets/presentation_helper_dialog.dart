import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../core/theme.dart';

class PresentationHelperDialog extends StatefulWidget {
  const PresentationHelperDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const PresentationHelperDialog(),
    );
  }

  @override
  State<PresentationHelperDialog> createState() => _PresentationHelperDialogState();
}

class _PresentationHelperDialogState extends State<PresentationHelperDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 680),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.slideshow_rounded, color: AppTheme.primaryLight, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'UniMarket — คู่มือนำเสนอ & ผู้ช่วยทดสอบระบบ',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          'ออกแบบตามเกณฑ์การประเมิน 100 คะแนนเต็ม (Mobile Dev Week 16)',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Tab Bar
            TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryLight,
              unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
              indicatorColor: AppTheme.primaryLight,
              tabs: const [
                Tab(icon: Icon(Icons.timeline, size: 18), text: 'บทนำเสนอ 5 ขั้น'),
                Tab(icon: Icon(Icons.manage_accounts, size: 18), text: 'สลับบัญชีทดสอบ'),
                Tab(icon: Icon(Icons.bug_report, size: 18), text: 'ทดสอบ Error Handling'),
              ],
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildStoryboardTab(isDark),
                  _buildAccountsTab(context, state, isDark),
                  _buildTestingTab(context, state, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 1. Storyboard Tab ---
  Widget _buildStoryboardTab(bool isDark) {
    final stages = [
      {
        'time': '0:00 - 0:30',
        'title': 'บทนำ & สถาปัตยกรรมระบบ (Intro & Architecture)',
        'score': '10 คะแนน',
        'desc': 'กล่าวทักทาย แนะนำโครงงาน UniMarket UBU (ตลาดนัดออนไลน์นักศึกษา ม.อุบล) พัฒนาด้วย Flutter Web + Django REST Framework + django-oidc-provider + SQLite/PostgreSQL',
      },
      {
        'time': '0:30 - 2:30',
        'title': 'Zero-Error Setup (รันระบบจาก Terminal)',
        'score': '20 คะแนน',
        'desc': 'แสดงการเปิด 2 เทอร์มินัล หรือรัน `run_all.bat` (Terminal 1: Backend migrate, seed_data, runserver พอร์ต 8000 / Terminal 2: Flutter run พอร์ต 50000) แสดง log สีเขียวสะอาดตา ไร้ Error',
      },
      {
        'time': '2:30 - 3:30',
        'title': 'OIDC Authentication & Route Guard',
        'score': '20 คะแนน',
        'desc': 'สาธิต Login ด้วยบัญชีนักศึกษา/แอดมิน โชว์ OIDC Authorization Code Flow + PKCE, Session Persistence (รีเฟรชหน้าแล้วไม่หลุด), ปลอดภัยด้วย flutter_secure_storage',
      },
      {
        'time': '3:30 - 5:30',
        'title': 'ฟังก์ชันหลัก CRUD & แสดง Error Handling',
        'score': '25 คะแนน',
        'desc': 'สาธิต Create, Read, Update, Delete สินค้า ค้นหาแบบเรียลไทม์ กรองหมวดหมู่ และโชว์ Error Handling โดยกดปิด Backend หรือสลับโหมดจำลองออฟไลน์ เพื่อให้อาจารย์เห็นว่าระบบจัดการข้อผิดพลาดอย่างปลอดภัย',
      },
      {
        'time': '5:30 - จบ',
        'title': 'ฟีเจอร์เสริม & คุณภาพโค้ด (Extra Features & Code Quality)',
        'score': '25 คะแนน',
        'desc': 'สลับโหมด Dark Mode (บันทึกลง SharedPreferences), แชทสดคุยกับผู้ขาย, รีวิวและให้ดาว, สลับบทบาทเป็นแอดมินอนุมัติสินค้าและตรวจสอบบัตรนักศึกษา, สรุปโครงสร้าง MVVM',
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: stages.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final stage = stages[i];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(30),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      stage['time']!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.primaryLight),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      stage['title']!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      stage['score']!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.green),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                stage['desc']!,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.black87,
                  height: 1.35,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- 2. Accounts Tab ---
  Widget _buildAccountsTab(BuildContext context, AppState state, bool isDark) {
    final accounts = [
      {
        'username': 'somchai_ubu',
        'name': 'สมชาย เรียนดี (somchai_ubu)',
        'role': 'นักศึกษาทั่วไป / ผู้ซื้อ / ผู้ลงขายเสื้อช็อป & กีตาร์',
        'badge': 'นักศึกษายืนยันแล้ว ✅',
        'password': 'password123 หรือ somchai1234',
        'isCurrent': state.currentUser.username == 'somchai_ubu',
      },
      {
        'username': 'thanaporn_k',
        'name': 'ธนพร สายช้อป (thanaporn_k)',
        'role': 'ผู้ขายยอดนิยม / เจ้าของ iPad & หนังสือ Calculus / เรตติ้ง 5.0 ⭐',
        'badge': 'ผู้ขายดีเด่น 🏆',
        'password': 'password123 หรือ thanaporn1234',
        'isCurrent': state.currentUser.username == 'thanaporn_k',
      },
      {
        'username': 'admin',
        'name': 'ผู้ดูแลระบบ (admin)',
        'role': 'Superuser / จัดการและอนุมัติสินค้า / ตรวจสอบบัตรนักศึกษา / แดชบอร์ดแอดมิน',
        'badge': 'Admin Moderation 🛡️',
        'password': 'admin หรือ admin1234',
        'isCurrent': state.currentUser.isAdmin,
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: accounts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final acc = accounts[i];
        final isCurrent = acc['isCurrent'] as bool;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isCurrent
                ? (isDark ? const Color(0xFF1E3A8A).withAlpha(60) : const Color(0xFFEFF6FF))
                : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCurrent ? AppTheme.primaryLight : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              width: isCurrent ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          acc['name'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        if (isCurrent) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('กำลังใช้งาน', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      acc['role'] as String,
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '🔑 รหัสผ่าน OIDC: ${acc['password']}',
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.amber[300] : Colors.amber[800], fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCurrent ? Colors.grey[400] : AppTheme.primaryLight,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                onPressed: isCurrent
                    ? null
                    : () {
                        state.switchUser(acc['username'] as String);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('สลับไปยังบัญชี ${acc['name']} เรียบร้อยแล้ว'),
                            backgroundColor: AppTheme.success,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        Navigator.pop(context);
                      },
                child: Text(isCurrent ? 'ใช้งานอยู่' : 'สลับทันที'),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- 3. Testing & Error Handling Tab ---
  Widget _buildTestingTab(BuildContext context, AppState state, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Error Handling Explanation Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Color(0xFFD97706), size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'เกณฑ์การให้คะแนน Error Handling (15 คะแนนเต็ม):',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF92400E)),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'ข้อสอบกำหนดว่า: "พร้อมโชว์ Error Handling อย่างน้อย 1 สถานการณ์ (เช่น ปิด backend แล้วลองโหลด)"\n'
                        'คุณสามารถทดสอบได้ 2 วิธี:\n'
                        '1. ปิด Django Terminal จริงๆ แล้วกดโหลดหน้า\n'
                        '2. หรือกดสวิตช์ "จำลองโหมดออฟไลน์" ด้านล่างนี้เพื่อโชว์ให้อาจารย์เห็นได้ทันที โดยไม่ต้องปิดโปรเซส',
                        style: TextStyle(fontSize: 12, color: Color(0xFF78350F), height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Status & Simulation Switches
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('สถานะการเชื่อมต่อ Django Backend (Port 8000):', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: state.isConnectedToBackend ? Colors.green : Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                state.isConnectedToBackend
                                    ? 'Online (พร้อมให้บริการ API & OIDC)'
                                    : (state.isSimulatedOffline
                                        ? 'Offline (จำลองเพื่อทดสอบ Error Handling)'
                                        : 'Offline (ไม่สามารถเชื่อมต่อ Port 8000)'),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: state.isConnectedToBackend ? Colors.green : Colors.red,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('ตรวจสอบ'),
                        onPressed: () async {
                          final online = await state.checkBackendConnection();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                online
                                    ? '✅ เชื่อมต่อกับ Django Backend (Port 8000) สำเร็จแล้ว'
                                    : '⚠️ ไม่สามารถเชื่อมต่อกับ Django Backend (Port 8000) ได้',
                              ),
                              backgroundColor: online ? AppTheme.success : AppTheme.danger,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('จำลองโหมดออฟไลน์ (Simulate Backend Offline)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('เมื่อเปิดสวิตช์ แอปจะจำลองสถานการณ์ที่ Backend ล่ม เพื่อแสดงระบบ Error Handling และการทำงานในโหมดแคชออฟไลน์'),
                    value: state.isSimulatedOffline,
                    onChanged: (_) {
                      state.toggleSimulatedOffline();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            state.isSimulatedOffline
                                ? 'จำลองสถานะ Backend ออฟไลน์แล้ว — สังเกตแถบแจ้งเตือนด้านบน'
                                : 'กลับสู่โหมดออนไลน์ปกติแล้ว',
                          ),
                          backgroundColor: state.isSimulatedOffline ? AppTheme.warning : AppTheme.success,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Quick Endpoints Reference
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🔗 ลิงก์ระบบหลังบ้านสำหรับพรีเซนต์:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildEndpointRow('OIDC Discovery', 'http://127.0.0.1:8000/openid/.well-known/openid-configuration/'),
                  _buildEndpointRow('Django Admin Panel', 'http://127.0.0.1:8000/admin/'),
                  _buildEndpointRow('Backend Health Check', 'http://127.0.0.1:8000/api/health/'),
                  _buildEndpointRow('Products API Endpoint', 'http://127.0.0.1:8000/api/products/'),
                  _buildEndpointRow('Flutter Web Client', 'http://localhost:50000/'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndpointRow(String label, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          Expanded(
            child: SelectableText(
              url,
              style: const TextStyle(fontSize: 12, color: AppTheme.primaryLight, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}
