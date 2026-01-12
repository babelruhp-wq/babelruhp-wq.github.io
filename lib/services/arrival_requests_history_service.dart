import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

import '../models/arrival_requests_history_row.dart';

class ArrivalRequestsHistoryPageResult {
  final List<ArrivalRequestsHistoryRow> rows;
  final int totalCount;

  ArrivalRequestsHistoryPageResult({
    required this.rows,
    required this.totalCount,
  });
}

class ArrivalRequestsHistoryService {
  final String baseUrl;

  ArrivalRequestsHistoryService({
    required String baseUrl,
  }) : baseUrl = baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl;

  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    if (token.trim().isNotEmpty)
      'Authorization': 'Bearer ${token.trim()}',
  };

  static const String _path = '/Admin/GetAllArrivalRequestsHistory';

  Future<ArrivalRequestsHistoryPageResult> fetchOrders({
    required String query,
    required int page, // 1-based
    required int pageSize,
    required String token,
  }) async {
    final uri = Uri.parse('$baseUrl$_path');
    final res = await http.get(uri, headers: _headers(token));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(_prettyHttpError(res));
    }

    final decoded = jsonDecode(res.body);

    final List list = (decoded is List)
        ? decoded
        : (decoded is Map
        ? (decoded['data'] ??
        decoded['items'] ??
        decoded['result'] ??
        decoded['value'] ??
        const [])
        : const []);

    final all = <ArrivalRequestsHistoryRow>[];
    for (int i = 0; i < list.length; i++) {
      final m = (list[i] is Map)
          ? Map<String, dynamic>.from(list[i] as Map)
          : <String, dynamic>{};
      all.add(_mapToRow(m, i + 1));
    }

    final q = query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? all
        : all.where((r) {
      return r.workerName.toLowerCase().contains(q) ||
          r.passportNo.toLowerCase().contains(q) ||
          r.visaNo.toLowerCase().contains(q) ||
          r.contractNo.toLowerCase().contains(q) ||
          r.sponsor.toLowerCase().contains(q) ||
          r.sponsorId.toLowerCase().contains(q) ||
          r.employeeName.toLowerCase().contains(q) ||
          r.approvedBy.toLowerCase().contains(q) ||
          r.arrivalNote.toString().contains(q) ||
          r.id.toLowerCase().contains(q);
    }).toList();

    final start = max(0, (page - 1) * pageSize);
    final end = min(filtered.length, start + pageSize);
    final pageRows = (start >= filtered.length)
        ? <ArrivalRequestsHistoryRow>[]
        : filtered.sublist(start, end);

    // ✅ ضبط rowNo حسب الصفحة
    final numbered = <ArrivalRequestsHistoryRow>[];
    for (int i = 0; i < pageRows.length; i++) {
      numbered.add(pageRows[i].copyWith(rowNo: start + i + 1));
    }

    return ArrivalRequestsHistoryPageResult(rows: numbered, totalCount: filtered.length);
  }

  // ----------------- Mapping (Case-insensitive) -----------------

  ArrivalRequestsHistoryRow _mapToRow(Map<String, dynamic> m, int rowNo) {
    final lower = <String, dynamic>{};
    for (final e in m.entries) {
      lower[e.key.toString().toLowerCase()] = e.value;
    }

    String pickStr(List<String> keys, {String fallback = ''}) {
      for (final k in keys) {
        final v = lower[k.toLowerCase()];
        if (v == null) continue;
        final s = v.toString().trim();
        if (s.isNotEmpty && s.toLowerCase() != 'null') return s;
      }
      return fallback;
    }

    int pickInt(List<String> keys, {int fallback = 0}) {
      for (final k in keys) {
        final v = lower[k.toLowerCase()];
        if (v == null) continue;
        if (v is int) return v;
        final n = int.tryParse(v.toString().trim());
        if (n != null) return n;
      }
      return fallback;
    }

    DateTime? pickDate(List<String> keys) {
      for (final k in keys) {
        final v = lower[k.toLowerCase()];
        if (v == null) continue;
        try {
          return DateTime.parse(v.toString());
        } catch (_) {}
      }
      return null;
    }

    return ArrivalRequestsHistoryRow(
      id: pickStr(['requestid', 'id']),
      rowNo: rowNo,
      workerName: pickStr(['workername', 'name']),
      arrivalDate: pickDate(['arrivaldate', 'date']),
      employeeName: pickStr(['employeename', 'employee']),
      visaNo: pickStr(['visanumber', 'visano', 'visa']),
      contractNo: pickStr(['contractnumber', 'contractno']),
      sponsor: pickStr(['sponsorname', 'sponsor']),
      passportNo: pickStr(['passportnumber', 'passportno', 'passport']),
      sponsorId: pickStr(['sponsorid', 'nationalid', 'idnumber']),
      approvedBy: pickStr(['approvedBy'], fallback: '—'),
      arrivalNote: pickInt(['arrivalnote'], fallback: 0),
    );
  }

  String _prettyHttpError(http.Response res) {
    try {
      final d = jsonDecode(res.body);
      if (d is Map) {
        final title = (d['title'] ?? '').toString();
        final detail = (d['detail'] ?? '').toString();
        final errors = d['errors'];
        if (errors is Map && errors.isNotEmpty) {
          return 'HTTP ${res.statusCode} - $title\n$errors';
        }
        if (title.isNotEmpty || detail.isNotEmpty) {
          return 'HTTP ${res.statusCode} - $title\n$detail';
        }
      }
    } catch (_) {}
    return 'HTTP ${res.statusCode} - ${res.body}';
  }
}
