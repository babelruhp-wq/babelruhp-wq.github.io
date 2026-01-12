import 'package:flutter/foundation.dart';

import 'auth_session.dart';
import 'jwt_utils.dart';
import 'token_storage.dart';
import 'auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService authService;
  final TokenStorage storage;

  AuthSession? _session;

  AuthProvider({
    required this.authService,
    required this.storage,
  });

  AuthSession? get session => _session;

  bool get isLoggedIn => _session != null && !_session!.isExpired;

  String? get token => _session?.token;

  String get displayName {
    final s = _session;
    if (s == null) return 'Admin';
    return (s.name?.trim().isNotEmpty ?? false)
        ? s.name!.trim()
        : (s.username?.trim().isNotEmpty ?? false)
        ? s.username!.trim()
        : 'Admin';
  }

  String get role => _session?.role ?? 'Admin';

  // =========================
  // Session helpers
  // =========================

  void setFromToken({required String token, String? refreshToken}) {
    final claims = JwtUtils.decodePayload(token);

    _session = AuthSession(
      token: token,
      refreshToken: refreshToken,
      name: (claims['name'] ?? '').toString(),
      username: (claims['unique_name'] ?? '').toString(),
      role: (claims['role'] ?? '').toString(),
      expiresAt: JwtUtils.expToDateTime(claims),
    );

    notifyListeners();
  }

  Future<void> setSession({
    required String token,
    required String refreshToken,
  }) async {
    await storage.save(token: token, refreshToken: refreshToken);
    setFromToken(token: token, refreshToken: refreshToken);
  }

  /// ✅ استرجاع الجلسة عند فتح التطبيق
  Future<void> restoreSession() async {
    final token = await storage.getToken();
    final refreshToken = await storage.getRefreshToken();

    if (token == null || token.trim().isEmpty) return;

    setFromToken(token: token, refreshToken: refreshToken);

    // لو منتهي أو قرب ينتهي، جرّب refresh
    await ensureValidToken();
  }

  /// ✅ يرجّع Token صالح (ويعمل refresh لو قرب يخلص/منتهي)
  Future<String?> ensureValidToken({int refreshBeforeSeconds = 60}) async {
    final s = _session;
    if (s == null) return null;

    // لو مفيش expiresAt مش هنعمل refresh
    final exp = s.expiresAt;
    if (exp == null) return s.token;

    final now = DateTime.now();
    final diff = exp.difference(now).inSeconds;

    final shouldRefresh = diff <= refreshBeforeSeconds;

    if (!shouldRefresh) return s.token;

    // لازم refreshToken
    final rt = s.refreshToken;
    if (rt == null || rt.trim().isEmpty) {
      // مفيش refreshToken → logout
      await logout();
      return null;
    }

    try {
      final res = await authService.refresh(
        refreshToken: rt,
        token: s.token, // optional لو السيرفر محتاجه
      );

      if (res.token.trim().isEmpty) throw Exception('Refresh returned empty token');

      await setSession(token: res.token, refreshToken: res.refreshToken);
      return res.token;
    } catch (_) {
      // لو refresh فشل: logout (حسب سياستك)
      await logout();
      return null;
    }
  }

  /// ✅ logout يمسح التخزين كمان
  Future<void> logout({bool callServer = true}) async {
    final s = _session;

    if (callServer && s != null) {
      try {
        await authService.logout(token: s.token);
      } catch (_) {
        // حتى لو فشل السيرفر، هنكمل logout محليًا
      }
    }

    _session = null;
    await storage.clear();
    notifyListeners();
  }

}
