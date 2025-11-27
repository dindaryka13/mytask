class UserModel {
  final String id;
  final String username;
  final String email;
  final String? profileImage;
  final String? socialMedia;
  final String? bio;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.profileImage,
    this.socialMedia,
    this.bio,
    this.createdAt,
  });

  // From JSON (Supabase)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      profileImage: json['avatar_url'] as String?,
      socialMedia: json['sosmed'] as String?,
      bio: json['bio'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar_url': profileImage,
      'sosmed': socialMedia,
      'bio': bio,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Copy with method
  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? profileImage,
    String? socialMedia,
    String? bio,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      socialMedia: socialMedia ?? this.socialMedia,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}