import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/female_contract.dart';

class ContractsService {
  final String baseUrl;
  final http.Client _client;

  /// ✅ 0 = All
  static const int allStatusForCounts = 0;

  ContractsService({
    required String baseUrl,
    http.Client? client,
  })  : baseUrl =
  baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl,
        _client = client ?? http.Client();

  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    if (token.trim().isNotEmpty)
      'Authorization': 'Bearer ${token.trim()}',
  };

  // =========================
  // Add Female Contract (POST)
  // =========================
  Future<void> addFemaleContract(Map<String, dynamic> payload, {required String token}) async {
    final uri = Uri.parse(_join('/FemaleContracts/AddFemaleContract'));

    final res = await _client.post(
      uri,
      headers: _headers(token),
      body: jsonEncode(payload),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('AddFemaleContract failed: ${res.statusCode} - ${res.body}');
    }
  }

  // =========================
  // Update Female Contract ✅
  // =========================
  Future<void> updateFemaleContract({
    required String contractId,
    required Map<String, dynamic> payload,
    required String token,
  }) async {
    final id = contractId.trim();
    if (id.isEmpty) return;

    // ✅ شيل /? علشان بعض السيرفرات بتتعب منها
    final uri = Uri.parse(_join('/FemaleContracts/UpdateContractDetails?ContractId=$id'));

    final res = await _client.put(
      uri,
      headers: _headers(token),
      body: jsonEncode(payload),
    );

    if (res.statusCode == 405) {
      final res2 = await _client.post(
        uri,
        headers: _headers(token),
        body: jsonEncode(payload),
      );
      if (res2.statusCode < 200 || res2.statusCode >= 300) {
        throw Exception('UpdateContractDetails failed: ${res2.statusCode} - ${res2.body}');
      }
      return;
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('UpdateContractDetails failed: ${res.statusCode} - ${res.body}');
    }
  }

  // ==========================================================
  // ✅ Update Note
  // ==========================================================
  Future<void> updateFemaleContractNote({
    required String contractId,
    required String note,
    required String token,
  }) async {
    final id = contractId.trim();
    if (id.isEmpty) return;

    final uri = Uri.parse(_join('/FemaleContracts/UpdateNotes?ContractId=$id'));

    final body = jsonEncode({
      "notes": note.trim(),
    });

    final res = await _smartWriteCall(uri, body: body, token: token);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('UpdateNotes failed: ${res.statusCode} - ${res.body}');
    }
  }

  // ==========================================================
  // ✅ Approve contract + approval date
  // ==========================================================
  Future<void> approveFemaleContract({
    required String contractId,
    required DateTime approvalDate,
    required String token,
  }) async {
    final id = contractId.trim();
    if (id.isEmpty) return;

    final uri = Uri.parse(_join('/FemaleContracts/Approve?ContractId=$id'));

    final body = jsonEncode({
      "approvalDate": _formatYmd(approvalDate),
    });

    final res = await _smartWriteCall(uri, body: body, token: token);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Approve failed: ${res.statusCode} - ${res.body}');
    }
  }

  // ==========================================================
  // ✅ Cancel contract
  // ==========================================================
  Future<void> cancelFemaleContract({
    required String contractId,
    required int cancelationBy,
    required String cancelationReason,
    required String employeeName,
    required String token,
  }) async {
    final id = contractId.trim();
    if (id.isEmpty) return;

    final uri = Uri.parse(_join('/FemaleContracts/CancelContract?ContractId=$id'));

    final body = jsonEncode({
      "employeeName": employeeName.trim(),
      "cancelationBy": cancelationBy,
      "cancelationReason": cancelationReason.trim(),
    });

    final res = await _smartWriteCall(uri, body: body, token: token);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('CancelContract failed: ${res.statusCode} - ${res.body}');
    }
  }

  // =========================
  // Stamp / FlightTicket / Arrival
  // =========================
  Future<void> stampFemaleContract({
    required String contractId,
    required DateTime stampedDate,
    required String token,
  }) async {
    final id = contractId.trim();
    if (id.isEmpty) return;

    final uri = Uri.parse(_join('/FemaleContracts/Stamp?ContractId=$id'));
    final res = await _smartWriteCall(uri, body: jsonEncode({"stamped": _formatYmd(stampedDate)}), token: token);



    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Stamp failed: ${res.statusCode} - ${res.body}');
    }
  }

  Future<void> setFlightTicketDate({
    required String contractId,
    required DateTime flightTicketDate,
    required String token,
  }) async {
    final id = contractId.trim();
    if (id.isEmpty) return;

    final uri = Uri.parse(_join('/FemaleContracts/FlightTicket?ContractId=$id'));

    final res = await _smartWriteCall(
      uri,
      body: jsonEncode({"flightTicketDate": _formatYmd(flightTicketDate)}),
      token: token,
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('FlightTicket failed: ${res.statusCode} - ${res.body}');
    }
  }

  Future<void> setArrivalDate({
    required String contractId,
    required DateTime arrivalDate,
    required String employeeName,
    required String token,
  }) async {
    final id = contractId.trim();
    if (id.isEmpty) return;

    final uri = Uri.parse(_join('/FemaleContracts/Arrival?ContractId=$id'));

    final res = await _smartWriteCall(
      uri,
      body: jsonEncode({
        "employeeName": employeeName.trim(),
        "arrivalDate": _formatYmd(arrivalDate),
      }),
      token: token,
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Arrival failed: ${res.statusCode} - ${res.body}');
    }
  }

  // ===========================================
  // Get Female Contracts (GET)
  // ===========================================
  Uri femaleContractsUri({required String officeId, required int status}) {
    if (status==0)     return Uri.parse(_join('/FemaleContracts/GetFemaleContracts/$officeId'));

    return Uri.parse(_join('/FemaleContracts/GetFemaleContracts/$officeId/$status'));
  }

  Future<List<FemaleContract>> fetchFemaleContracts({
    required String officeId,
    required int status,
    required String token,
  }) async {
    final res = await _client.get(
      femaleContractsUri(officeId: officeId, status: status),
      headers: _headers(token),
      
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('GetFemaleContracts failed: ${res.statusCode} - ${res.body}');
    }

    final decoded = jsonDecode(res.body);

    if (decoded is List) {
      return decoded
          .map((e) => FemaleContract.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'] ??
          decoded['items'] ??
          decoded['result'] ??
          decoded['value'];

      if (data is List) {
        return data
            .map((e) => FemaleContract.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }

    throw Exception('Unexpected response format for GetFemaleContracts');
  }

  // ===========================================
  // Counts => compute locally from status=0 ✅
  // ===========================================
  Future<Map<String, int>> fetchFemaleCounts({required String officeId, required String token}) async {
    final list = await fetchFemaleContracts(
      officeId: officeId,
      status: allStatusForCounts, // ✅ 0 = all
      token: token,
    );
    return buildCountsFromContractStatus(list);
  }

  Map<String, int> buildCountsFromContractStatus(List<FemaleContract> list) {
    final all = list.length;

    final s1 = list.where((c) => c.contractStatus == 1).length;
    final s2 = list.where((c) => c.contractStatus == 2).length;
    final s3 = list.where((c) => c.contractStatus == 3).length;
    final s4 = list.where((c) => c.contractStatus == 4).length;
    final s5 = list.where((c) => c.contractStatus == 5).length;

    return <String, int>{
      'all_workers': all,
      'new': s1,
      'under_process': s2,
      'rejected': s3,
      'arrival': s4,
      'finished': s5,
    };
  }

  // =========================
  // Helpers
  // =========================
  String _join(String path) {
    final p = path.startsWith('/') ? path : '/$path';
    return '$baseUrl$p';
  }

  /// ✅ PATCH ثم POST ثم GET لو 405
  Future<http.Response> _smartWriteCall(Uri uri, {Object? body, required String token}) async {
    final patchRes = await _client.patch(uri, headers: _headers(token), body: body);
    if (patchRes.statusCode != 405) return patchRes;

    final postRes = await _client.post(uri, headers: _headers(token), body: body);
    if (postRes.statusCode != 405) return postRes;

    final putRes = await _client.put(uri, headers: _headers(token), body: body);
    if (putRes.statusCode != 405) return putRes;

    throw Exception('Endpoint does not accept PATCH/POST/PUT (still 405).');
  }


  String _formatYmd(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  void dispose() => _client.close();
}
