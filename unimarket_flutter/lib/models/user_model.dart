class UserModel {
  final int id;
  final String username;
  final String email;
  final String displayName;
  final String avatarUrl;
  final String phoneNumber;
  final String address;
  final String bio;
  final bool isVerified;
  final bool isAdmin;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.displayName,
    this.avatarUrl = '',
    this.phoneNumber = '',
    this.address = '',
    this.bio = '',
    this.isVerified = false,
    this.isAdmin = false,
  });

  String get effectiveName =>
      displayName.isNotEmpty ? displayName : username;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      displayName: json['display_name'] ?? json['username'] ?? '',
      avatarUrl: json['avatar'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      address: json['address'] ?? '',
      bio: json['bio'] ?? '',
      isVerified: json['is_verified'] ?? false,
      isAdmin: json['is_staff'] ?? json['is_admin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'display_name': displayName,
      'avatar': avatarUrl,
      'phone_number': phoneNumber,
      'address': address,
      'bio': bio,
      'is_verified': isVerified,
      'is_admin': isAdmin,
    };
  }

  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? displayName,
    String? avatarUrl,
    String? phoneNumber,
    String? address,
    String? bio,
    bool? isVerified,
    bool? isAdmin,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      bio: bio ?? this.bio,
      isVerified: isVerified ?? this.isVerified,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
