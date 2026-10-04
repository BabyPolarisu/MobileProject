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
    int parsedId = 0;
    if (json['id'] != null) {
      parsedId = json['id'] is int ? json['id'] : (int.tryParse(json['id'].toString()) ?? 0);
    } else if (json['sub'] != null) {
      parsedId = int.tryParse(json['sub'].toString()) ?? 0;
    }

    final username = json['username'] ?? json['preferred_username'] ?? json['nickname'] ?? '';
    final displayName = json['display_name'] ?? json['name'] ?? username;
    final avatar = json['avatar'] ?? json['picture'] ?? json['avatar_url'] ?? '';

    return UserModel(
      id: parsedId,
      username: username,
      email: json['email'] ?? '',
      displayName: displayName.toString().isNotEmpty ? displayName.toString() : username.toString(),
      avatarUrl: avatar.toString(),
      phoneNumber: json['phone_number']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      bio: json['bio']?.toString() ?? '',
      isVerified: json['is_verified'] == true || json['verified'] == true,
      isAdmin: json['is_staff'] == true || json['is_admin'] == true || json['is_superuser'] == true,
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
