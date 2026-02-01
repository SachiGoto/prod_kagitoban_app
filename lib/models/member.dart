class Member {
  final String id;
  final String name;
  final String? email;
  final String? avatar;

  const Member({
    required this.id,
    required this.name,
    this.email,
    this.avatar,
  });

  /// Create Member from API / Amplify / JSON
  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      avatar: json['avatar'] as String?,
    );
  }

  /// Convert Member to JSON (for API / DB)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
    };
  }

  /// Helpful for debugging
  @override
  String toString() {
    return 'Member(id: $id, name: $name, email: $email, avatar: $avatar)';
  }
}
