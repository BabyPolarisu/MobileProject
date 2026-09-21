import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../core/responsive.dart';
import '../widgets/report_dialog.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ประวัติการรายงานปัญหา (My Reports)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'แจ้งเรื่องใหม่',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const ReportDialog(),
              );
            },
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          final myReports = state.reports.where((r) => r.reporter.id == state.currentUser.id).toList();

          if (myReports.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('ยังไม่มีประวัติการรายงานปัญหา', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return MaxWidthContainer(
            maxWidth: 800,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: myReports.length,
              separatorBuilder: (context, sepIdx) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final report = myReports[index];
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
                              report.reasonLabel,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: report.status == 'resolved'
                                    ? Colors.green.withAlpha(40)
                                    : (report.status == 'investigating' ? Colors.blue.withAlpha(40) : Colors.orange.withAlpha(40)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                report.statusLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: report.status == 'resolved'
                                      ? Colors.green[800]
                                      : (report.status == 'investigating' ? Colors.blue[800] : Colors.orange[800]),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (report.productName != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            'สินค้าที่เกี่ยวข้อง: ${report.productName}',
                            style: const TextStyle(fontSize: 13, color: Colors.blueGrey),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          report.details,
                          style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('dd/MM/yyyy HH:mm').format(report.createdAt),
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            Text(
                              'รหัสแจ้ง: #${report.id.toString().substring(report.id.toString().length > 6 ? report.id.toString().length - 6 : 0)}',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
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
        },
      ),
    );
  }
}
