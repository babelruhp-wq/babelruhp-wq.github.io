import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

import '../models/arrival_orders_row.dart';

class OrdersPageResult {
  final List<ArrivalOrdersRow> rows;
  final int totalCount;

  OrdersPageResult({required this.rows, required this.totalCount});
}

class ArrivalOrdersService {
  final String baseUrl;
  final http.Client _client;

  ArrivalOrdersService({
    required String baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl,
        _client = client ?? http.Client();

  String _join(String path) => '$baseUrl$path';

  // =========================
  // Headers (Token per request)
  // =========================
  Map<String, String> _headersWith(String token) => {
    'Content-Type': 'application/json',
    if (token.trim().isNotEmpty) 'Authorization': 'Bearer ${token.trim()}',
  };

  // ======================================================================
  // GET: /Admin/GetAllArrivalRequests
  // ======================================================================
  Future<OrdersPageResult> fetchOrders({
    required String token,
    required String query,
    required int page,
    required int pageSize,
  }) async {
    final uri = Uri.parse(_join('/Admin/GetAllArrivalRequests'));

    final res = await _client.get(uri, headers: _headersWith(token));
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

    final all = <ArrivalOrdersRow>[];
    for (int i = 0; i < list.length; i++) {
      final m = (list[i] is Map)
          ? Map<String, dynamic>.from(list[i] as Map)
          : <String, dynamic>{};
      all.add(_mapArrivalRequestToRow(m, i + 1));
    }

    // ✅ Search
    final q = query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? all
        : all.where((r) {
      return r.employeeName.toLowerCase().contains(q) ||
          r.visaNo.toLowerCase().contains(q) ||
          r.contractNo.toLowerCase().contains(q) ||
          r.sponsor.toLowerCase().contains(q) ||
          r.employee.toLowerCase().contains(q);
    }).toList();

    // ✅ Pagination
    final start = max(0, (page - 1) * pageSize);
    final end = min(filtered.length, start + pageSize);
    final pageRows = (start >= filtered.length)
        ? <ArrivalOrdersRow>[]
        : filtered.sublist(start, end);

    return OrdersPageResult(rows: pageRows, totalCount: filtered.length);
  }

  // ======================================================================
  // Approve / Reject (Token per request)
  // ======================================================================
  Future<void> approve(String requestId, {required String token}) async {
    final uri = Uri.parse(_join('/Admin/ApproveArrival'))
        .replace(queryParameters: {'RequestId': requestId});

    final res = await _patchOrPost(uri, token: token);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(_prettyHttpError(res));
    }
  }

  Future<void> reject(String requestId, {required String token}) async {
    final uri = Uri.parse(_join('/Admin/RejectArrival'))
        .replace(queryParameters: {'RequestId': requestId});

    final res = await _patchOrPost(uri, token: token);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(_prettyHttpError(res));
    }
  }

  /// ✅ بعض السيرفرات POST بدل PATCH
  Future<http.Response> _patchOrPost(Uri uri, {required String token}) async {
    var res = await _client.patch(uri, headers: _headersWith(token));
    if (res.statusCode >= 200 && res.statusCode < 300) return res;

    // fallback POST
    res = await _client.post(uri, headers: _headersWith(token));
    return res;
  }

  // ======================================================================
  // Mapping
  // ======================================================================
  ArrivalOrdersRow _mapArrivalRequestToRow(Map<String, dynamic> m, int rowNo) {
    final requestId = _pickStr(m, ['requestId', 'id'], fallback: '');
    final workerName = _pickStr(m, ['workerName', 'name'], fallback: '—');
    final employeeName = _pickStr(m, ['employeeName', 'employee'], fallback: '—');
    final visaNumber = _pickStr(m, ['visaNumber', 'visaNo'], fallback: '—');
    final contractNumber = _pickStr(m, ['contractNumber', 'contractNo'], fallback: '—');

    final sponsorRaw = _pickStr(m, ['sponsorName', 'sponsor'], fallback: '—');
    final sponsor =
    sponsorRaw.startsWith('/') ? sponsorRaw.substring(1).trim() : sponsorRaw;

    final createdAt = _pickDate(m, ['arrivalDate', 'createdAt']) ?? DateTime.now();
    final passportNumber =
    _pickStr(m, ['passportNumber', 'passportNo'], fallback: '—');

    final sponsorId =
    _pickStr(m, ['sponsorId', 'nationalId', 'sponsorIDNumber'], fallback: '—');

    final int arrivalNote = _pickInt(m, ['arrivalNote'], fallback: 0) ?? 0;

    return ArrivalOrdersRow(
      id: requestId,
      rowNo: rowNo,

      // ⚠️ عندك naming غريب في الموديل: employeeName هنا هو اسم العاملة
      employeeName: workerName,

      visaNo: visaNumber,
      contractNo: contractNumber,
      sponsor: sponsor,
      employee: employeeName,
      createdAt: createdAt,
      passportNo: passportNumber,
      nationalId: sponsorId,

      // description انت مستخدمها كـ arrivalNote
      description: arrivalNote,

      supervisionFees: false,
      contractFees: false,
      updatedAt: null,
      status: ArrivalOrderStatus.newOrder,
    );
  }

  DateTime? _pickDate(Map<String, dynamic> m, List<String> keys) {
    final lower = <String, dynamic>{};
    for (final e in m.entries) {
      lower[e.key.toString().toLowerCase()] = e.value;
    }
    for (final k in keys) {
      final v = lower[k.toLowerCase()];
      if (v == null) continue;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {}
    }
    return null;
  }

  String _pickStr(Map<String, dynamic> m, List<String> keys,
      {String fallback = ''}) {
    final lower = <String, dynamic>{};
    for (final e in m.entries) {
      lower[e.key.toString().toLowerCase()] = e.value;
    }

    for (final k in keys) {
      final v = lower[k.toLowerCase()];
      if (v == null) continue;
      final s = v.toString().trim();
      if (s.isNotEmpty) return s;
    }
    return fallback;
  }

  int? _pickInt(Map<String, dynamic> m, List<String> keys, {int? fallback}) {
    final lower = <String, dynamic>{};
    for (final e in m.entries) {
      lower[e.key.toString().toLowerCase()] = e.value;
    }

    for (final k in keys) {
      final v = lower[k.toLowerCase()];
      if (v == null) continue;
      if (v is int) return v;
      if (v is num) return v.toInt();

      final s = v.toString().trim();
      if (s.isEmpty) continue;
      final parsed = int.tryParse(s);
      if (parsed != null) return parsed;
    }
    return fallback;
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

  void dispose() => _client.close();
}
