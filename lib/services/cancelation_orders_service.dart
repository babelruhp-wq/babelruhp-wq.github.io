import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

import '../models/cancelation_orders_row.dart';

class CancelationOrdersPageResult {
  final List<CancelationOrdersRow> rows;
  final int totalCount;

  CancelationOrdersPageResult({
    required this.rows,
    required this.totalCount,
  });
}

class CancelationOrdersService {
  final String baseUrl;
  final http.Client _client;

  CancelationOrdersService({
    required String baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl,
        _client = client ?? http.Client();

  Map<String, String> _headersWith(String token) => {
    'Content-Type': 'application/json',
    if (token.trim().isNotEmpty) 'Authorization': 'Bearer ${token.trim()}',
  };

  static const String _getAllPath = '/Admin/GetAllCancelationRequests';
  static const String _approvePath = '/Admin/ApproveCancelation';
  static const String _rejectPath = '/Admin/RejectCancelation';

  // ======================================================================
  // GET: Admin/GetAllCancelationRequests
  // ======================================================================
  Future<CancelationOrdersPageResult> fetchOrders({
    required String token,
    required String query,
    required int page,
    required int pageSize,
  }) async {
    final uri = Uri.parse('$baseUrl$_getAllPath');
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

    final all = <CancelationOrdersRow>[];
    for (int i = 0; i < list.length; i++) {
      final m = (list[i] is Map)
          ? Map<String, dynamic>.from(list[i] as Map)
          : <String, dynamic>{};
      all.add(_mapToRow(m, i + 1));
    }

    // ✅ Search
    final q = query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? all
        : all.where((r) {
      return r.employeeName.toLowerCase().contains(q) ||
          r.passportNo.toLowerCase().contains(q) ||
          r.visaNo.toLowerCase().contains(q) ||
          r.contractNo.toLowerCase().contains(q) ||
          r.sponsor.toLowerCase().contains(q) ||
          r.nationalId.toLowerCase().contains(q) ||
          r.description.toLowerCase().contains(q) ||
          r.employee.toLowerCase().contains(q);
    }).toList();

    // ✅ Pagination
    final start = max(0, (page - 1) * pageSize);
    final end = min(filtered.length, start + pageSize);
    final pageRows = (start >= filtered.length)
        ? <CancelationOrdersRow>[]
        : filtered.sublist(start, end);

    return CancelationOrdersPageResult(rows: pageRows, totalCount: filtered.length);
  }

  // ======================================================================
  // Approve / Reject
  // ======================================================================
  Future<void> approve(String requestId, {required String token}) async {
    final uri = Uri.parse('$baseUrl$_approvePath')
        .replace(queryParameters: {'RequestId': requestId});

    final res = await _patchOrPost(uri, token: token);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(_prettyHttpError(res));
    }
  }

  Future<void> reject(String requestId, {required String token}) async {
    final uri = Uri.parse('$baseUrl$_rejectPath')
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

    res = await _client.post(uri, headers: _headersWith(token));
    return res;
  }

  // ----------------- Mapping -----------------
  CancelationOrdersRow _mapToRow(Map<String, dynamic> m, int rowNo) {
    final lower = <String, dynamic>{};
    for (final e in m.entries) {
      lower[e.key.toString().toLowerCase()] = e.value;
    }

    String pickStr(List<String> keys, {String fallback = '—'}) {
      for (final k in keys) {
        final v = lower[k.toLowerCase()];
        if (v == null) continue;
        final s = v.toString().trim();
        if (s.isNotEmpty && s.toLowerCase() != 'null') return s;
      }
      return fallback;
    }

    int? pickInt(List<String> keys) {
      for (final k in keys) {
        final v = lower[k.toLowerCase()];
        if (v == null) continue;

        if (v is int) return v;
        if (v is num) return v.toInt();

        final s = v.toString().trim();
        final n = int.tryParse(s);
        if (n != null) return n;
      }
      return null;
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

    CancelationOrderStatus pickStatus() {
      final approvedVal = lower['approved'];
      if (approvedVal is bool) {
        return approvedVal
            ? CancelationOrderStatus.approved
            : CancelationOrderStatus.newOrder;
      }

      final raw =
      pickStr(['status', 'requeststatus', 'state', 'approved'], fallback: '');
      final s = raw.toLowerCase();

      if (s.contains('approve') ||
          s.contains('confirmed') ||
          s == '1' ||
          s == 'approved' ||
          s == 'true') {
        return CancelationOrderStatus.approved;
      }
      if (s.contains('reject') || s == '2' || s == 'rejected') {
        return CancelationOrderStatus.rejected;
      }
      return CancelationOrderStatus.newOrder;
    }

    final requestId = pickStr(['requestid', 'id']);
    final workerName = pickStr(['workername', 'name']);
    final employeeName = pickStr(['employeename', 'employee']);
    final visaNumber = pickStr(['visanumber', 'visano', 'visa']);
    final contractNumber = pickStr(['contractnumber', 'contractno']);
    final sponsorName = pickStr(['sponsorname', 'sponsor']);
    final cancelReason =
    pickStr(['cancelationreason', 'cancellationreason', 'reason']);
    final passportNumber = pickStr(['passportnumber', 'passportno', 'passport']);
    final sponsorId =
    pickStr(['sponsorid', 'sponsor_id', 'sponsoridnumber', 'sponsoridno']);
    final cancelBy = pickInt(['cancelationby', 'canceledby', 'cancelby']) ?? 0;

    return CancelationOrdersRow(
      id: requestId,
      rowNo: rowNo,
      employeeName: workerName,
      passportNo: passportNumber,
      visaNo: visaNumber,
      contractNo: contractNumber,
      sponsor: sponsorName,
      nationalId: sponsorId,
      description: cancelReason,
      cancelationBy: cancelBy,
      employee: employeeName,
      createdAt:
      pickDate(['createdat', 'createdon', 'dateadded', 'createddate']) ??
          DateTime.now(),
      updatedAt: pickDate(['updatedat', 'modifiedat', 'editedat', 'lastupdate']),
      status: pickStatus(),
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

  void dispose() => _client.close();
}
