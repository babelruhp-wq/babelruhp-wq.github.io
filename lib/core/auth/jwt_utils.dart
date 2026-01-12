import 'dart:convert';

class JwtUtils {
  static Map<String, dynamic> decodePayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const FormatException('Invalid JWT token');
    }

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final bytes = base64Url.decode(normalized);
    final jsonStr = utf8.decode(bytes);
    final map = json.decode(jsonStr);

    if (map is Map<String, dynamic>) return map;
    return Map<String, dynamic>.from(map as Map);
  }

  static DateTime? expToDateTime(Map<String, dynamic> claims) {
    final exp = claims['exp'];
    if (exp is int) {
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true).toLocal();
    }
    return null;
  }
}
