class AppUser {
  final String id;
  final String firstName;
  final String lastName;
  final String userName;
  final bool isActive;

  final String role;

  const AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.userName,
    required this.role,
    required this.isActive,
  });

  static String _s(dynamic v) => (v ?? '').toString();

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: _s(json['id'] ?? json['userId'] ?? json['Id']),
      firstName: _s(json['firstName']),
      lastName: _s(json['lastName']),
      userName: _s(json['userName'] ?? json['username'] ?? json['user_name']),
      role: _s(json['role']),
      isActive: json['isActive'],
    );
  }

  String get fullName {
    final n = ('$firstName $lastName').trim();
    return n.isEmpty ? '-' : n;
  }
}
