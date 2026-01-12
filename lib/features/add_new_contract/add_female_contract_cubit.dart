import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/auth/auth_provider.dart';
import '../../services/contracts_service.dart';
import 'add_female_contract_state.dart';

class AddFemaleContractCubit extends Cubit<AddFemaleContractState> {
  final ContractsService service;
  final AuthProvider auth;

  AddFemaleContractCubit({
    required this.service,
    required this.auth,
  }) : super(AddFemaleContractState.initial());



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
      status: AddFemaleContractStatus.loading,
      errorMessage: null,
    ));

    try {
      final token = auth.token;
      if (token == null || token.isEmpty) {
        throw Exception('Not authenticated. Please login.');
      }

      final fixedPayload = _attachCreatedByForSubmit(payload);
      await service.addFemaleContract(fixedPayload, token: token);

      emit(state.copyWith(status: AddFemaleContractStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: AddFemaleContractStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// ✅ Update (Edit) — ما نغيرش createdBy نهائيًا
  Future<void> update({
    required String contractId,
    required Map<String, dynamic> payload,
  }) async {
    emit(state.copyWith(
      status: AddFemaleContractStatus.loading,
      errorMessage: null,
    ));

    try {
      final token = auth.token;
      if (token == null || token.isEmpty) {
        throw Exception('Not authenticated. Please login.');
      }

      await service.updateFemaleContract(
        contractId: contractId,
        payload: payload, // ✅ بدون أي تعديل
        token: token,
      );

      emit(state.copyWith(status: AddFemaleContractStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: AddFemaleContractStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
