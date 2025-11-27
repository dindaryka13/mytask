class UserModel {
  final String id;
  final String username;
  final String email;
  final String socialMedia;
  final String? profileImage;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.socialMedia,
    this.profileImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'socialMedia': socialMedia,
      'profileImage': profileImage,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      socialMedia: json['socialMedia'],
      profileImage: json['profileImage'],
    );
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? socialMedia,
    String? profileImage,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      socialMedia: socialMedia ?? this.socialMedia,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
