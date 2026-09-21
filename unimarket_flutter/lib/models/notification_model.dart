class NotificationItemModel {
  final int id;
  final String title;
  final String message;
  final String link;
  final bool isRead;
  final DateTime createdAt;

  NotificationItemModel({
    required this.id,
    required this.title,
    required this.message,
    this.link = '',
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationItemModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      link: json['link'] ?? '',
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }

  NotificationItemModel copyWith({
    int? id,
    String? title,
    String? message,
    String? link,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      link: link ?? this.link,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'link': link,
    'is_read': isRead,
    'created_at': createdAt.toIso8601String(),
  };
}
