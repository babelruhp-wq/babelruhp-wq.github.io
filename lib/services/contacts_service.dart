import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

import '../models/contacts_model.dart';

class WhatsappPageResult {
  final List<WhatsappContact> rows;
  final int totalCount;

  WhatsappPageResult({required this.rows, required this.totalCount});
}

class WhatsappService {
  final String baseUrl;
  final String? bearerToken;

  WhatsappService({
    required String baseUrl,
    this.bearerToken,
  }) : baseUrl = baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl;

  // ✅ API افتراضي
  static const String _path = '/Contacts/GetAllContacts';

  String _cleanToken(String? t) {
    var s = (t ?? '').trim();
    if (s.toLowerCase().startsWith('bearer ')) s = s.substring(7).trim();
    return s;
  }

  Map<String, String> get _headers {
    final t = _cleanToken(bearerToken);
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (t.isNotEmpty) 'Authorization': 'Bearer $t',
    };
  }

  Future<WhatsappPageResult> fetch({
    required String query,
    required int page, // 1-based
    required int pageSize,
  }) async {
    final uri = Uri.parse('$baseUrl$_path');
    final res = await http.get(uri, headers: _headers);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('HTTP ${res.statusCode} - ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    final List list = (decoded is List)
        ? decoded
        : (decoded is Map
        ? (decoded['data'] ?? decoded['items'] ?? decoded['result'] ?? decoded['value'] ?? const [])
        : const []);

    final all = list
        .whereType<Map>()
        .map((e) => WhatsappContact.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    // ✅ بحث client-side
    final q = query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? all
        : all.where((m) {
      return m.sponsorName.toLowerCase().contains(q) ||
          m.phone.toLowerCase().contains(q);
    }).toList();

    // ✅ Pagination client-side
    final total = filtered.length;
    final start = max(0, (page - 1) * pageSize);
    final end = min(total, start + pageSize);
    final pageRows = (start >= total) ? <WhatsappContact>[] : filtered.sublist(start, end);

    return WhatsappPageResult(rows: pageRows, totalCount: total);
  }
}
