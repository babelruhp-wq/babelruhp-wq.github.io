import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/app_users.dart';


class UsersService {
  final String baseUrl;
  const UsersService({required this.baseUrl});

  Map<String, String> _headers(String token) {
    var t = token.trim();
    if (t.toLowerCase().startsWith('bearer ')) {
      t = t.substring(7).trim(); // يمنع Bearer Bearer
    }

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $t',
    };
  }


  /// ✅ GET: auth/GetAppUsers
  Future<List<AppUser>> fetchAllUsers({required String token}) async {
    final uri = Uri.parse('$baseUrl/auth/GetAppUsers');
    final res = await http.get(uri, headers: _headers(token));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('GetAppUsers failed: ${res.statusCode} ${res.body}');
    }

    final data = jsonDecode(res.body);
    final list = (data is List) ? data : (data['data'] as List? ?? const []);

    return list
        .map((e) => AppUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// ✅ POST: auth/register
  Future<void> registerUser({
    required String token,
    required String firstName,
    required String lastName,
    required String userName,
    required String password,
    required String passwordConfirm,
    required String role,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/register');

    final res = await http.post(
      uri,
      headers: _headers(token),
      body: jsonEncode({
        "firstName": firstName,
        "lastName": lastName,
        "userName": userName,
        "password": password,
        "passwordConfirm": passwordConfirm,
        "role": role,
      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Register failed: ${res.statusCode} ${res.body}');
    }
  }
  /// ✅ POST: auth/ActivateAccount
  Future<void> activateAccount({
    required String token,
    required String userId,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/ActivateAccount');

    final res = await http.post(
      uri,
      headers: _headers(token),
      body: jsonEncode({"userId": userId}),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('ActivateAccount failed: ${res.statusCode} ${res.body}');
    }
  }

  /// ✅ POST: auth/DeactivateAccount
  Future<void> deactivateAccount({
    required String token,
    required String userId,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/DeactivateAccount');

    final res = await http.post(
      uri,
      headers: _headers(token),
      body: jsonEncode({"userId": userId}),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('DeactivateAccount failed: ${res.statusCode} ${res.body}');
    }
  }

  /// ✅ POST: auth/AdminResetPassword
  Future<void> adminResetPassword({
    required String token,
    required String userId,
    required String newPassword,
    required String passwordConfirm,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/AdminResetPassword');

    final res = await http.post(
      uri,
      headers: _headers(token),
      body: jsonEncode({
        "userId": userId,
        "newPassword": newPassword,
        "newPasswordConfirm": passwordConfirm,
      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(
          'AdminResetPassword failed: ${res.statusCode} ${res.body}');
    }
  }

}
