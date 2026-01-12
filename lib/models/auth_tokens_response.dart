class AuthTokensResponse {
  final String token;
  final String refreshToken;
  final String message;

  AuthTokensResponse({
    required this.token,
    required this.refreshToken,
    required this.message,
  });

  factory AuthTokensResponse.fromJson(Map<String, dynamic> json) {
    return AuthTokensResponse(
      token: (json['token'] ?? '').toString(),
      refreshToken: (json['refreshToken'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
    );
  }
}
