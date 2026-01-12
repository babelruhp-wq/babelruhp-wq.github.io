import 'dart:convert';
import 'package:http/http.dart' as http;

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

class AuthService {
  final String baseUrl;
  const AuthService({required this.baseUrl});

  Future<AuthTokensResponse> login({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/login');

    final res = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Login failed: ${res.statusCode} ${res.body}');
    }

    final data = jsonDecode(res.body);
    return AuthTokensResponse.fromJson(data as Map<String, dynamic>);
  }

  /// ✅ POST: auth/refresh
  /// بعض السيرفرات بتحتاج refreshToken فقط، وبعضها بتحتاج token + refreshToken
  Future<AuthTokensResponse> refresh({
    required String refreshToken,
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/refresh');

    final body = <String, dynamic>{
      "refreshToken": refreshToken,
      if (token != null && token.trim().isNotEmpty) "token": token,
    };

    final res = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Refresh failed: ${res.statusCode} ${res.body}');
    }

    final data = jsonDecode(res.body);
    return AuthTokensResponse.fromJson(data as Map<String, dynamic>);
  }

  Future<void> logout({required String token}) async {
    final uri = Uri.parse('$baseUrl/auth/logout');

    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    // بعض السيرفرات بترجع 200 أو 204
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Logout failed: ${res.statusCode} ${res.body}');
    }
  }
}
