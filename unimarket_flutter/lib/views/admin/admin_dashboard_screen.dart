import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../core/theme.dart';
import '../../core/responsive.dart';
import '../product/product_detail_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🛡️ แดชบอร์ดผู้ดูแลระบบ (Admin)'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppTheme.primary,
            indicatorColor: AppTheme.primary,
            tabs: [
              Tab(text: 'รออนุมัติสินค้า'),
              Tab(text: 'ตรวจสอบบัตรนักศึกษา'),
              Tab(text: 'จัดการเรื่องร้องเรียน'),
            ],
          ),
        ),
        body: Consumer<AppState>(
          builder: (context, state, _) {
            final pendingProducts = state.products.where((p) => p.status == 'pending').toList();
            final pendingVerifications = state.verificationRequests.where((v) => v.status == 'pending').toList();
            final pendingReports = state.reports;

            return TabBarView(
              children: [
                _buildProductApprovalTab(context, state, pendingProducts),
                _buildVerificationTab(context, state, pendingVerifications),
                _buildReportsTab(context, state, pendingReports),
              ],
            );
          },
        ),
      ),
    );
  }

  // 1. Tab: Product Approvals
  Widget _buildProductApprovalTab(BuildContext context, AppState state, List<dynamic> items) {
    final currencyFormatter = NumberFormat('#,##0', 'th_TH');

    return MaxWidthContainer(
      maxWidth: 900,
      child: Column(
        children: [
          // Stat summary banner
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildStatCard('สินค้าทั้งหมด', state.products.length.toString(), Colors.blue),
                const SizedBox(width: 8),
                _buildStatCard('รอการอนุมัติ', items.length.toString(), Colors.orange),
                const SizedBox(width: 8),
                _buildStatCard('กำลังขาย', state.products.where((p) => p.status == 'active').length.toString(), Colors.green),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 60, color: AppTheme.success),
                        SizedBox(height: 12),
                        Text('ไม่มีสินค้าที่รอการตรวจสอบ', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: items.length,
                    separatorBuilder: (context, sepIndex) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final product = items[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      product.imageUrl,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, err, stack) => const Icon(Icons.broken_image),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '฿${currencyFormatter.format(product.price)} • ${product.conditionLabel}',
                                          style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'ผู้ลงขาย: ${product.seller.effectiveName}',
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.open_in_new),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ProductDetailScreen(productId: product.id),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(foregroundColor: AppTheme.danger),
                                    onPressed: () {
                                      state.rejectProduct(product.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('ปฏิเสธสินค้าแล้ว')),
                                      );
                                    },
                                    child: const Text('ปฏิเสธ'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
                                    icon: const Icon(Icons.check, size: 18),
                                    label: const Text('อนุมัติวางจำหน่าย'),
                                    onPressed: () {
                                      state.approveProduct(product.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('อนุมัติสินค้าเรียบร้อยแล้ว'), backgroundColor: AppTheme.success),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // 2. Tab: Student ID Verifications
  Widget _buildVerificationTab(BuildContext context, AppState state, List<dynamic> items) {
    return MaxWidthContainer(
      maxWidth: 900,
      child: items.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified, size: 60, color: AppTheme.primaryLight),
                  SizedBox(height: 12),
                  Text('ไม่มีคำขอยืนยันตัวตนที่รอตรวจสอบ', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (context, sepIndex) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final req = items[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ผู้ส่งคำขอ: ${req.username}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              DateFormat('dd/MM/yyyy HH:mm').format(req.createdAt),
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            req.studentCardImageUrl,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, err, stack) => const Center(child: Icon(Icons.credit_card, size: 40)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(foregroundColor: AppTheme.danger),
                              onPressed: () {
                                state.rejectVerification(req.id, 'ข้อมูลไม่ตรงกับฐานข้อมูล');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('ปฏิเสธคำขอยืนยันตัวตนแล้ว')),
                                );
                              },
                              child: const Text('ปฏิเสธ'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
                              onPressed: () {
                                state.approveVerification(req.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('อนุมัติการยืนยันตัวตนสำเร็จ'), backgroundColor: AppTheme.success),
                                );
                              },
                              child: const Text('อนุมัติบัตรนักศึกษา'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // 3. Tab: Reports Management
  Widget _buildReportsTab(BuildContext context, AppState state, List<dynamic> items) {
    return MaxWidthContainer(
      maxWidth: 900,
      child: items.isEmpty
          ? const Center(
              child: Text('ไม่มีรายการร้องเรียน', style: TextStyle(color: Colors.grey)),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (context, sepIndex) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final r = items[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              r.reasonLabel,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withAlpha(30),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                r.statusLabel,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('ผู้แจ้ง: ${r.reporter.effectiveName} • ${DateFormat('dd/MM/yyyy HH:mm').format(r.createdAt)}'),
                        if (r.productName != null) ...[
                          const SizedBox(height: 4),
                          Text('สินค้าที่ถูกแจ้ง: ${r.productName}', style: const TextStyle(color: AppTheme.primary)),
                        ],
                        const SizedBox(height: 8),
                        Text('รายละเอียด: ${r.details}', style: TextStyle(color: Colors.grey[800])),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (r.status != 'investigating')
                              TextButton(
                                onPressed: () => state.updateReportStatus(r.id, 'investigating'),
                                child: const Text('กำลังตรวจสอบ'),
                              ),
                            if (r.status != 'resolved')
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
                                onPressed: () {
                                  state.updateReportStatus(r.id, 'resolved');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('ปรับสถานะเป็นแก้ไขแล้ว')),
                                  );
                                },
                                child: const Text('แก้ไขแล้ว'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        color: color.withAlpha(25),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 2),
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            ],
          ),
        ),
      ),
    );
  }
}
