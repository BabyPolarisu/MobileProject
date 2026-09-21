import 'user_model.dart';

class ReviewModel {
  final int id;
  final UserModel reviewer;
  final int sellerId;
  final int rating; // 1 - 5
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.reviewer,
    required this.sellerId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? 0,
      reviewer: UserModel.fromJson(json['reviewer'] ?? {}),
      sellerId: json['seller_id'] ?? 0,
      rating: json['rating'] ?? 5,
      comment: json['comment'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'reviewer': reviewer.toJson(),
    'seller_id': sellerId,
    'rating': rating,
    'comment': comment,
    'created_at': createdAt.toIso8601String(),
  };
}
