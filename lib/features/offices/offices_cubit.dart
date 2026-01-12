import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/office_female_stats.dart';
import '../../services/offices_service.dart';
import '../../services/contracts_service.dart';
import '../../models/female_contract.dart';

import 'offices_state.dart';

class OfficesCubit extends Cubit<OfficesState> {
  final OfficesService service;
  final ContractsService contractsService; // ✅ جديد
  final String countryId;

  OfficesCubit({
    required this.service,
    required this.contractsService,
    required this.countryId,
  }) : super(const OfficesState());

  Future<void> refresh({required int status, required String token}) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final offices = await service.getAllOfficesByCountry(countryId);
      emit(state.copyWith(offices: offices, isLoading: false, clearError: true));

      await _loadFemaleStats(offices: offices, status: status, token: token);
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _loadFemaleStats({
    required List offices,
    required int status,
    required String token,
  }) async {
    if (offices.isEmpty) {
      emit(state.copyWith(
        isStatsLoading: false,
        femaleStatsByOffice: const {},
      ));
      return;
    }

    emit(state.copyWith(isStatsLoading: true));

    try {
      final entries = await Future.wait(
        offices.map((o) async {
          final List<FemaleContract> contracts = await contractsService.fetchFemaleContracts(
            officeId: o.officeId,
            status: status,
            token: token,
          );

          final total = contracts.length;

          final underProcess = contracts.where((x) => x.contractStatus == 2).length;

          return MapEntry(
            o.officeId as String,
            OfficeFemaleStats(total: total, underProcess: underProcess),
          );
        }),
      );

      emit(state.copyWith(
        isStatsLoading: false,
        femaleStatsByOffice: Map<String, OfficeFemaleStats>.fromEntries(entries),
      ));
    } catch (_) {
      emit(state.copyWith(isStatsLoading: false));
    }
  }
}
