class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String bio;
  final String avatar;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.bio = '',
    this.avatar = '🏸',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'] ?? '',
      bio: json['bio'] ?? '',
      avatar: json['avatar'] ?? '🏸',
    );
  }
}
