import 'user_model.dart';

class ChatMessageModel {
  final int id;
  final int roomId;
  final int senderId;
  final String senderName;
  final String content;
  final String imageUrl;
  final bool isRead;
  final DateTime timestamp;
  final bool isMine;

  ChatMessageModel({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    required this.content,
    this.imageUrl = '',
    this.isRead = false,
    required this.timestamp,
    this.isMine = false,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json, {int currentUserId = 0}) {
    final senderIdVal = json['sender_id'] ?? (json['sender'] is Map ? json['sender']['id'] : 0);
    return ChatMessageModel(
      id: json['id'] ?? 0,
      roomId: json['room_id'] ?? 0,
      senderId: senderIdVal,
      senderName: json['sender_name'] ?? (json['sender'] is Map ? (json['sender']['display_name'] ?? json['sender']['username']) : 'ผู้ใช้'),
      content: json['content'] ?? '',
      imageUrl: json['image'] ?? '',
      isRead: json['is_read'] ?? false,
      timestamp: json['timestamp'] != null ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now() : DateTime.now(),
      isMine: senderIdVal == currentUserId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'room_id': roomId,
    'sender_id': senderId,
    'sender_name': senderName,
    'content': content,
    'image': imageUrl,
    'is_read': isRead,
    'timestamp': timestamp.toIso8601String(),
  };
}

class ChatRoomModel {
  final int id;
  final UserModel otherUser;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final int? relatedProductId;
  final String? relatedProductName;
  final String? relatedProductImage;
  final double? relatedProductPrice;

  ChatRoomModel({
    required this.id,
    required this.otherUser,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.relatedProductId,
    this.relatedProductName,
    this.relatedProductImage,
    this.relatedProductPrice,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: json['id'] ?? 0,
      otherUser: UserModel.fromJson(json['other_user'] ?? {}),
      lastMessage: json['last_message'] ?? '',
      lastMessageTime: json['last_message_time'] != null ? DateTime.tryParse(json['last_message_time'].toString()) ?? DateTime.now() : DateTime.now(),
      unreadCount: json['unread_count'] ?? 0,
      relatedProductId: json['product_id'],
      relatedProductName: json['product_name'],
      relatedProductImage: json['product_image'],
      relatedProductPrice: json['product_price'] != null ? (json['product_price'] as num).toDouble() : null,
    );
  }

  ChatRoomModel copyWith({
    int? id,
    UserModel? otherUser,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    int? relatedProductId,
    String? relatedProductName,
    String? relatedProductImage,
    double? relatedProductPrice,
  }) {
    return ChatRoomModel(
      id: id ?? this.id,
      otherUser: otherUser ?? this.otherUser,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      relatedProductId: relatedProductId ?? this.relatedProductId,
      relatedProductName: relatedProductName ?? this.relatedProductName,
      relatedProductImage: relatedProductImage ?? this.relatedProductImage,
      relatedProductPrice: relatedProductPrice ?? this.relatedProductPrice,
    );
  }
}
