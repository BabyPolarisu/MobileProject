import 'user_model.dart';

class CategoryModel {
  final int id;
  final String name;
  final String icon;
  final String code;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    this.code = '',
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      icon: json['icon'] ?? '📦',
      code: json['code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon,
    'code': code,
  };
}

class ProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final String condition; // 'new' or 'used'
  final String imageUrl;
  final CategoryModel? category;
  final UserModel seller;
  final String status; // 'pending', 'active', 'sold', 'rejected', 'suspended'
  final int favoritesCount;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.condition,
    required this.imageUrl,
    this.category,
    required this.seller,
    this.status = 'active',
    this.favoritesCount = 0,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  String get conditionLabel {
    if (condition == 'new') return '✨ มือหนึ่ง (New)';
    return '📦 มือสอง (Used)';
  }

  String get statusLabel {
    switch (status) {
      case 'active':
        return 'กำลังขาย';
      case 'sold':
        return 'ขายแล้ว';
      case 'pending':
        return 'รออนุมัติ';
      case 'rejected':
        return 'ถูกปฏิเสธ';
      case 'suspended':
        return 'ถูกระงับ';
      default:
        return status;
    }
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : double.tryParse(json['price'].toString()) ?? 0.0,
      condition: json['condition'] ?? 'used',
      imageUrl: json['image'] ?? json['imageUrl'] ?? '',
      category: json['category'] != null ? CategoryModel.fromJson(json['category']) : null,
      seller: json['seller'] != null ? UserModel.fromJson(json['seller']) : UserModel(id: 0, username: 'Seller', email: '', displayName: 'ผู้ขาย'),
      status: json['status'] ?? 'active',
      favoritesCount: json['favorites_count'] ?? 0,
      isFavorite: json['is_favorite'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'condition': condition,
    'image': imageUrl,
    'category': category?.toJson(),
    'seller': seller.toJson(),
    'status': status,
    'favorites_count': favoritesCount,
    'is_favorite': isFavorite,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  ProductModel copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    String? condition,
    String? imageUrl,
    CategoryModel? category,
    UserModel? seller,
    String? status,
    int? favoritesCount,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      condition: condition ?? this.condition,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      seller: seller ?? this.seller,
      status: status ?? this.status,
      favoritesCount: favoritesCount ?? this.favoritesCount,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
