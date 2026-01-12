import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/auth/auth_provider.dart';
import '../../services/agencies_service.dart';
import 'add_male_agency_state.dart';

class AddMaleAgencyCubit extends Cubit<AddMaleAgencyState> {
  final MaleAgenciesService service;
  final AuthProvider auth;

  AddMaleAgencyCubit({
    required this.service,
    required this.auth,
  }) : super(AddMaleAgencyState.initial());



  /// ✅ في الإضافة فقط: لو payload مفيهوش createdBy هنضيفه تلقائيًا
  Map<String, dynamic> _attachCreatedByForSubmit(Map<String, dynamic> payload) {
    final p = Map<String, dynamic>.from(payload);

    final current = (p['createdBy'] ?? p['CreatedBy'] ?? '').toString().trim();
    if (current.isNotEmpty) return p;

    p['createdBy'] = auth.displayName;
    return p;
  }

  Future<void> submit(Map<String, dynamic> payload) async {
    emit(state.copyWith(
      status: AddMaleAgencyStatus.loading,
      errorMessage: null,
    ));

    try {
      final token = auth.token;
      if (token == null || token.isEmpty) {
        throw Exception('Not authenticated. Please login.');
      }

      final fixedPayload = _attachCreatedByForSubmit(payload);
      await service.addMaleAgency(fixedPayload, token: token);

      emit(state.copyWith(status: AddMaleAgencyStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: AddMaleAgencyStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// ✅ Update (Edit) — ما نغيرش createdBy نهائيًا
  Future<void> update({
    required String agencyId,
    required Map<String, dynamic> payload,
  }) async {
    emit(state.copyWith(
      status: AddMaleAgencyStatus.loading,
      errorMessage: null,
    ));

    try {
      final token = auth.token;
      if (token == null || token.isEmpty) {
        throw Exception('Not authenticated. Please login.');
      }

      await service.updateMaleContract(
        contractId: agencyId,
        payload: payload, // ✅ بدون أي تعديل
        token: token,
      );

      emit(state.copyWith(status: AddMaleAgencyStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: AddMaleAgencyStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
