class ProfileModel {
  final String id;
  final String email;
  final String? fullName;
  final String? phone;
  final String role; // 'admin' or 'user'
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileModel({
    required this.id,
    required this.email,
    this.fullName,
    this.phone,
    this.role = 'user',
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'],
      phone: json['phone'],
      role: json['role'] ?? 'user',
      avatarUrl: json['avatar_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'role': role,
      'avatar_url': avatarUrl,
    };
  }

  bool get isAdmin => role == 'admin';
}
