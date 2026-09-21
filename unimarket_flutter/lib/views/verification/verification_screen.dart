import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../core/theme.dart';
import '../../core/responsive.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final String sampleCardUrl = 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=600&fit=crop';
  late TextEditingController cardUrlCtrl;

  @override
  void initState() {
    super.initState();
    cardUrlCtrl = TextEditingController(text: sampleCardUrl);
  }

  @override
  void dispose() {
    cardUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final myRequests = state.verificationRequests.where((v) => v.userId == state.currentUser.id).toList();
        final latestReq = myRequests.isNotEmpty ? myRequests.first : null;

        return Scaffold(
          appBar: AppBar(
            title: const Text('ยืนยันตัวตนนักศึกษา'),
          ),
          body: MaxWidthContainer(
            maxWidth: 650,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Card
                  Card(
                    color: const Color(0xFFEFF6FF),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_user, color: AppTheme.primary, size: 36),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'ทำไมต้องยืนยันตัวตน?',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'เพื่อสร้างความปลอดภัยในชุมชนมหาวิทยาลัย ผู้ที่ยืนยันตัวตนจะได้รับเครื่องหมาย ✅ และเพิ่มความน่าเชื่อถือในการซื้อขาย',
                                  style: TextStyle(fontSize: 12, color: Colors.blueGrey[800]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Current Status
                  if (latestReq != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('สถานะการยืนยันตัวตนปัจจุบัน', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: latestReq.status == 'approved'
                                        ? AppTheme.success.withAlpha(40)
                                        : (latestReq.status == 'rejected' ? AppTheme.danger.withAlpha(40) : AppTheme.warning.withAlpha(40)),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    latestReq.statusLabel,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: latestReq.status == 'approved'
                                          ? AppTheme.success
                                          : (latestReq.status == 'rejected' ? AppTheme.danger : AppTheme.warning),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  DateFormat('dd/MM/yyyy HH:mm').format(latestReq.createdAt),
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            if (latestReq.adminComment.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'หมายเหตุจากแอดมิน: ${latestReq.adminComment}',
                                style: const TextStyle(fontSize: 13, color: AppTheme.danger),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Form to Submit
                  const Text('รูปถ่ายบัตรนักศึกษา', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      cardUrlCtrl.text,
                      fit: BoxFit.cover,
                      errorBuilder: (context, err, stack) => const Center(
                        child: Icon(Icons.credit_card, size: 50, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: cardUrlCtrl,
                    decoration: const InputDecoration(
                      labelText: 'ลิงก์รูปถ่ายบัตรนักศึกษา',
                      prefixIcon: Icon(Icons.link),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.upload_file),
                      label: const Text('ส่งหลักฐานยืนยันตัวตน', style: TextStyle(fontSize: 16)),
                      onPressed: () {
                        if (cardUrlCtrl.text.trim().isEmpty) return;
                        state.submitVerification(studentCardUrl: cardUrlCtrl.text.trim());
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('ส่งคำขอยืนยันตัวตนเรียบร้อยแล้ว รอการตรวจสอบจากแอดมิน'),
                            backgroundColor: AppTheme.success,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
