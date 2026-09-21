import 'user_model.dart';

class ReportModel {
  final int id;
  final UserModel reporter;
  final int? productId;
  final String? productName;
  final int? reportedUserId;
  final String? reportedUserName;
  final String contactInfo;
  final String reason;
  final String details;
  final String status; // 'pending', 'investigating', 'resolved', 'ignored'
  final DateTime createdAt;

  ReportModel({
    required this.id,
    required this.reporter,
    this.productId,
    this.productName,
    this.reportedUserId,
    this.reportedUserName,
    this.contactInfo = '',
    required this.reason,
    required this.details,
    this.status = 'pending',
    required this.createdAt,
  });

  String get reasonLabel {
    switch (reason) {
      case 'bug':
        return '🐛 ปัญหาเว็บไซต์ / บั๊ก';
      case 'fraud':
        return '💸 หลอกลวง / ฉ้อโกง';
      case 'fake':
        return '❌ สินค้าปลอม / ลอกเลียนแบบ';
      case 'harassment':
        return '🤬 คำหยาบคาย / คุกคาม';
      case 'spam':
        return '📢 สแปม / โฆษณา';
      default:
        return '📝 อื่นๆ';
    }
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return '⏳ รอตรวจสอบ';
      case 'investigating':
        return '🔍 กำลังตรวจสอบ';
      case 'resolved':
        return '✅ แก้ไขแล้ว';
      case 'ignored':
        return '❌ ปฏิเสธ/ยกเลิก';
      default:
        return status;
    }
  }

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] ?? 0,
      reporter: UserModel.fromJson(json['reporter'] ?? {}),
      productId: json['product_id'],
      productName: json['product_name'],
      reportedUserId: json['reported_user_id'],
      reportedUserName: json['reported_user_name'],
      contactInfo: json['contact_info'] ?? '',
      reason: json['reason'] ?? 'other',
      details: json['details'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'reporter': reporter.toJson(),
    'product_id': productId,
    'product_name': productName,
    'reported_user_id': reportedUserId,
    'reported_user_name': reportedUserName,
    'contact_info': contactInfo,
    'reason': reason,
    'details': details,
    'status': status,
    'created_at': createdAt.toIso8601String(),
  };
}
