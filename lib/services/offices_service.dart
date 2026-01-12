import 'package:dio/dio.dart';

import '../models/add_office_request.dart';
import '../models/edit_office_request.dart';
import '../models/office.dart';

class OfficesService {
  final Dio dio;
  final Future<String?> Function() tokenProvider;

  OfficesService({
    required this.dio,
    required this.tokenProvider,
  }) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final t = (await tokenProvider())?.trim() ?? '';
          if (t.isNotEmpty) {
            final clean =
            t.toLowerCase().startsWith('bearer ') ? t.substring(7).trim() : t;
            options.headers['Authorization'] = 'Bearer $clean';
          }
          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept'] = 'application/json';
          handler.next(options);
        },
      ),
    );
  }

  /// ✅ POST /Offices/AddOffice
  Future<void> addOffice(AddOfficeRequest req) async {
    try {
      await dio.post('/Offices/AddOffice', data: req.toJson());
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Dio error';
      throw Exception(msg);
    }
  }

  /// ✅ GET /Offices/GetAllOfficesByCountry/?countryid=...
  Future<List<Office>> getAllOfficesByCountry(String countryId) async {
    try {
      final res = await dio.get(
        '/Offices/GetAllOfficesByCountry/',
        queryParameters: {'countryid': countryId},
      );

      final data = res.data;
      if (data is! List) return [];

      return data
          .map((e) => Office.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Dio error';
      throw Exception(msg);
    }
  }

  /// ✅ POST/PUT /Offices/EditOfficeName
  /// Body: { officeId, officeName }
  Future<void> editOfficeName(EditOfficeRequest req) async {
    try {
      await dio.post('/Offices/EditOfficeName', data: req.toJson());
    } on DioException catch (e) {
      if (e.response?.statusCode == 405) {
        try {
          await dio.put('/Offices/EditOfficeName', data: req.toJson());
          return;
        } on DioException catch (e2) {
          final msg = e2.response?.data?.toString() ?? e2.message ??
              'Dio error';
          throw Exception(msg);
        }
      }

      final msg = e.response?.data?.toString() ?? e.message ?? 'Dio error';
      throw Exception(msg);
    }
  }

  /// ✅ DELETE /Offices/RemoveOffice/?OfficeId=...
  Future<void> removeOffice({
    required String officeId,
    required String password,
  }) async {
    try {
      final res = await dio.delete(
        '/Offices/RemoveOffice',
        data: {
          "officeId": officeId,
          "password": password,
        },
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      // ✅ لو السيرفر بيرجع isSuccess=false زي الدول
      _throwIfOfficeRemoveFailed(res.data);
    } on DioException catch (e) {
      // لو رجع 4xx/5xx
      final msg = e.response?.data?.toString() ?? e.message ?? 'Dio error';
      throw Exception(_mapOfficeRemoveError(msg));
    }
  }

  void _throwIfOfficeRemoveFailed(dynamic data) {
    if (data == null) return;

    if (data is Map) {
      final m = Map<String, dynamic>.from(data);
      final ok = m['isSuccess'] ?? m['success'] ?? m['result'];

      if (ok is bool && ok == false) {
        final errors = m['errors'];
        String? first;

        if (errors is List && errors.isNotEmpty) {
          first = errors.first?.toString();
        }
        if (errors is String) first = errors;

        throw Exception(_mapOfficeRemoveError(
            first ?? m['message']?.toString() ?? 'فشل حذف المكتب'));
      }
    }

    if (data is String) {
      final s = data.toLowerCase();
      if (s.contains('password')) {
        throw Exception('الباسورد غير صحيح');
      }
    }
  }

  String _mapOfficeRemoveError(String msg) {
    final s = msg.toLowerCase();

    if (s.contains('password') &&
        (s.contains('incorrect') || s.contains('wrong') ||
            s.contains('in correct'))) {
      return 'الباسورد غير صحيح';
    }
    if (s.contains('deactivated') || s.contains('inactive')) {
      return 'الحساب غير نشط';
    }
    return msg.replaceAll('Exception:', '').trim();
  }

}
