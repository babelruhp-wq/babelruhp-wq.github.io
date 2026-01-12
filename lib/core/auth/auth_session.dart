class AuthSession {
  final String token;
  final String? refreshToken;

  final String? name;        // "Mahmoud Elsaied"
  final String? username;    // unique_name
  final String? role;        // Admin
  final DateTime? expiresAt;

  const AuthSession({
    required this.token,
    this.refreshToken,
    this.name,
    this.username,
    this.role,
    this.expiresAt,
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
}
