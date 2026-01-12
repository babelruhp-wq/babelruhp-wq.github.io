import 'package:dio/dio.dart';

import '../models/add_country_request.dart';
import '../models/country_office_stats.dart';

class CountriesService {
  final Dio dio;
  final Future<String?> Function() tokenProvider;

  CountriesService({
    required this.dio,
    required this.tokenProvider,
  }) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final t = (await tokenProvider())?.trim() ?? '';
          if (t.isNotEmpty) {
            final clean = t.toLowerCase().startsWith('bearer ')
                ? t.substring(7).trim()
                : t;
            options.headers['Authorization'] = 'Bearer $clean';
          }
          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept'] = 'application/json';
          handler.next(options);
        },
      ),
    );
  }

  Future<void> addCountry(AddCountryRequest req) async {
    try {
      await dio.post('/Countries/AddCountry', data: req.toJson());
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Dio error';
      throw Exception(msg);
    }
  }

  Future<void> editCountryNames({
    required String id,
    required AddCountryRequest req,
  }) async {
    try {
      await dio.put(
        '/Countries/EditCountryNames/',
        queryParameters: {'id': id},
        data: req.toJson(),
      );
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Dio error';
      throw Exception(msg);
    }
  }

  Future<void> removeCountry(String id, String password) async {
    try {
      final res = await dio.delete(
        '/Countries/RemoveCountry',
        data: {
          "countryId": id,
          "password": password,
        },
        options: Options(contentType: Headers.jsonContentType),
      );

      _throwIfApiFailed(res.data);
    } on DioException catch (e) {
      // لو السيرفر رجّع 4xx/5xx
      final data = e.response?.data;
      try {
        _throwIfApiFailed(data);
      } catch (_) {
        rethrow; // لو قدرنا نفسّرها فوق هتترمي Exception عربية
      }

      final msg = data?.toString() ?? e.message ?? 'Dio error';
      throw Exception(msg);
    }
  }

  /// ✅ نفسّر رد السيرفر وطلع رسالة مفهومة
  void _throwIfApiFailed(dynamic data) {
    if (data == null) return;

    if (data is Map) {
      final m = Map<String, dynamic>.from(data);

      final ok = m['isSuccess'] ?? m['success'] ?? m['result'];
      if (ok is bool && ok == false) {
        // errors ممكن تبقى List زي عندك
        final errors = m['errors'];
        String? firstError;

        if (errors is List && errors.isNotEmpty) {
          firstError = errors.first?.toString();
        } else if (errors is String) {
          firstError = errors;
        }

        // لو رسالة الباسورد غلط
        if ((firstError ?? '')
            .toLowerCase()
            .contains('password')) {
          throw Exception('الباسورد غير صحيح');
        }

        // fallback: message لو موجودة
        final msg = m['message']?.toString();
        throw Exception(firstError ?? msg ?? 'فشل حذف الدولة');
      }

      return; // isSuccess true
    }

    // لو رجع String وفيها Password
    if (data is String) {
      final s = data.toLowerCase();
      if (s.contains('password')) {
        throw Exception('الباسورد غير صحيح');
      }
    }
  }




  Future<List<CountryOfficeStats>> getAllCountriesInfo() async {
    try {
      final res = await dio.get('/Countries/GetAllCountriesInfo');

      final data = res.data;
      if (data is! List) return [];

      return data
          .map((e) => CountryOfficeStats.fromJson(
        Map<String, dynamic>.from(e as Map),
      ))
          .toList();
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Dio error';
      throw Exception(msg);
    }
  }
}
