class AppUser {
  final int id;
  final String name;
  final String email;
  final String token;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
  });

  factory AppUser.fromLoginJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final user = data['user'] ?? {};
    return AppUser(
      id: user['id'] ?? 0,
      name: user['name'] ?? '',
      email: user['email'] ?? '',
      token: data['token'] ?? '',
    );
  }
}
