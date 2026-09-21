import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';

class ReportDialog extends StatefulWidget {
  final int? productId;
  final String? productName;
  final int? reportedUserId;
  final String? reportedUserName;

  const ReportDialog({
    super.key,
    this.productId,
    this.productName,
    this.reportedUserId,
    this.reportedUserName,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String selectedReason = 'fraud';
  final TextEditingController detailsCtrl = TextEditingController();
  final TextEditingController contactCtrl = TextEditingController();

  @override
  void dispose() {
    detailsCtrl.dispose();
    contactCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppTheme.danger),
          const SizedBox(width: 8),
          Text(
            widget.productName != null
                ? 'รายงาน: ${widget.productName}'
                : 'แจ้งปัญหา / รายงาน',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('หัวข้อปัญหา', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: selectedReason,
                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                items: AppConstants.reportReasons.map((r) {
                  return DropdownMenuItem<String>(
                    value: r['code'],
                    child: Text(r['name']!),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => selectedReason = val);
                },
              ),
              const SizedBox(height: 14),
              const Text('รายละเอียดเพิ่มเติม', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: detailsCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'โปรดระบุรายละเอียดปัญหาที่พบ...',
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 14),
              const Text('ข้อมูลติดต่อกลับ (ไม่บังคับ)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: contactCtrl,
                decoration: const InputDecoration(
                  hintText: 'เบอร์โทรหรือ Line ID',
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ยกเลิก'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
          onPressed: () {
            if (detailsCtrl.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('กรุณากรอกรายละเอียดปัญหา')),
              );
              return;
            }

            Provider.of<AppState>(context, listen: false).submitReport(
              productId: widget.productId,
              productName: widget.productName,
              reportedUserId: widget.reportedUserId,
              reportedUserName: widget.reportedUserName,
              reason: selectedReason,
              details: detailsCtrl.text.trim(),
              contactInfo: contactCtrl.text.trim(),
            );

            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('ส่งรายงานปัญหาเรียบร้อยแล้ว ทีมงานจะตรวจสอบโดยเร็วที่สุด'),
                backgroundColor: AppTheme.success,
              ),
            );
          },
          child: const Text('ส่งรายงาน'),
        ),
      ],
    );
  }
}
