class VerificationRequestModel {
  final int id;
  final int userId;
  final String username;
  final String studentCardImageUrl;
  final String status; // 'pending', 'approved', 'rejected'
  final String adminComment;
  final DateTime createdAt;
  final DateTime updatedAt;

  VerificationRequestModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.studentCardImageUrl,
    this.status = 'pending',
    this.adminComment = '',
    required this.createdAt,
    required this.updatedAt,
  });

  String get statusLabel {
    switch (status) {
      case 'approved':
        return 'อนุมัติแล้ว ✅';
      case 'rejected':
        return 'ปฏิเสธ ❌';
      default:
        return 'รอตรวจสอบ ⏳';
    }
  }

  factory VerificationRequestModel.fromJson(Map<String, dynamic> json) {
    return VerificationRequestModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      username: json['username'] ?? '',
      studentCardImageUrl: json['student_card_image'] ?? '',
      status: json['status'] ?? 'pending',
      adminComment: json['admin_comment'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'username': username,
    'student_card_image': studentCardImageUrl,
    'status': status,
    'admin_comment': adminComment,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
