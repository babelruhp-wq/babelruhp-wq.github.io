import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/male_agency.dart';
import '../../services/agencies_service.dart';
import 'male_agencies_table_state.dart';

class MaleAgenciesTableCubit extends Cubit<MaleAgenciesTableState> {
  final MaleAgenciesService service;

  Timer? _timer;
  bool _refreshing = false;

  MaleAgenciesTableCubit({required this.service})
      : super(MaleAgenciesTableState.initial());

  // ============ 
  // LOAD
  // statusFilter: 0 = all, 1..5 = specific status
  // ============ 
  Future<void> load({
    required String officeId,
    required int statusFilter,
    required String token,
  }) async {
    emit(state.copyWith(status: MaleAgenciesTableStatus.loading, error: null));

    try {
      // ✅ API نفسه بيعمل فلترة حسب statusFilter
      final list = await service.fetchMaleContracts(
        officeId: officeId,
        status: statusFilter,
        token: token,
      );

      // ✅ الأحدث الأول (createdAt من API)
      list.sort((a, b) {
        final ad = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bd = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bd.compareTo(ad);
      });

      // ✅ بما إن الـ endpoint بيرجع حسب statusFilter:
      // - لو statusFilter=0: list = all
      // - لو 1..5: list = already filtered
      final filtered = (statusFilter == 0)
          ? list
          : list.where((c) => c.contractStatus == statusFilter).toList();

      emit(state.copyWith(
        status: MaleAgenciesTableStatus.loaded,
        all: list,
        filtered: filtered,
        statusFilter: statusFilter,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MaleAgenciesTableStatus.error,
        error: e.toString(),
      ));
    }
  }

  // ========================== 
  // REFRESH SILENT (بدون Loading)
  // ========================== 
  Future<void> refreshSilent({
    required String officeId,
    required int statusFilter,
    required String token,
  }) async {
    if (_refreshing) return;
    if (state.status == MaleAgenciesTableStatus.deleting) return;

    _refreshing = true;
    try {
      final list = await service.fetchMaleContracts(
        officeId: officeId,
        status: statusFilter,
        token: token,
      );

      list.sort((a, b) {
        final ad = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bd = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bd.compareTo(ad);
      });

      final filtered = (statusFilter == 0)
          ? list
          : list.where((c) => c.contractStatus == statusFilter).toList();

      emit(state.copyWith(
        status: MaleAgenciesTableStatus.loaded,
        all: list,
        filtered: filtered,
        statusFilter: statusFilter,
        error: null,
      ));
    } catch (_) {
      // تجاهل الأخطاء في الصامت
    } finally {
      _refreshing = false;
    }
  }

  // ========================== 
  // AUTO REFRESH
  // ========================== 
  void startAutoRefresh({
    required String officeId,
    required int statusFilter,
    required String token,
    Duration every = const Duration(seconds: 10),
  }) {
    _timer?.cancel();
    _timer = Timer.periodic(every, (_) {
      refreshSilent(officeId: officeId, statusFilter: statusFilter, token: token);
    });
  }

  void stopAutoRefresh() {
    _timer?.cancel();
    _timer = null;
  }

  // ========================== 
  // ✅ Update Note
  // ========================== 
  Future<void> updateNote({
    required MaleAgency agency,
    required String note,
    required String officeId,
    required int statusFilter,
    required String token,
  }) async {
    final id = agency.id.trim();
    if (id.isEmpty) return;

    emit(state.copyWith(status: MaleAgenciesTableStatus.deleting, error: null));

    try {
      await service.updateMaleContractNote(contractId: id, note: note, token: token);
      await load(officeId: officeId, statusFilter: statusFilter, token: token);
    } catch (e) {
      emit(state.copyWith(
        status: MaleAgenciesTableStatus.error,
        error: e.toString(),
      ));
    }
  }

  // ========================== 
  // ✅ Approve + Approval Date
  // ========================== 
  Future<void> approveAgency({
    required String agencyId,
    required DateTime approvalDate,
    required String officeId,
    required int statusFilter,
    required String token,
  }) async {
    final id = agencyId.trim();
    if (id.isEmpty) return;

    emit(state.copyWith(status: MaleAgenciesTableStatus.deleting, error: null));

    try {
      await service.approveMaleContract(
        contractId: id,
        approvalDate: approvalDate,
        token: token,
      );

      await load(officeId: officeId, statusFilter: statusFilter, token: token);
    } catch (e) {
      emit(state.copyWith(
        status: MaleAgenciesTableStatus.error,
        error: e.toString(),
      ));
    }
  }

  // ========================== 
  // Stamp / FlightTicket / Arrival
  // ========================== 
  Future<void> setStampedDate({
    required MaleAgency agency,
    required DateTime date,
    required String officeId,
    required int statusFilter,
    required String token,
  }) async {
    final id = agency.id.trim();
    if (id.isEmpty) return;

    emit(state.copyWith(status: MaleAgenciesTableStatus.deleting, error: null));

    try {
      await service.stampMaleContract(contractId: id, stampedDate: date, token: token);
      await load(officeId: officeId, statusFilter: statusFilter, token: token);
    } catch (e) {
      emit(state.copyWith(
        status: MaleAgenciesTableStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> setFlightTicketDate({
    required MaleAgency agency,
    required DateTime date,
    required String officeId,
    required int statusFilter,
    required String token,
  }) async {
    final id = agency.id.trim();
    if (id.isEmpty) return;

    emit(state.copyWith(status: MaleAgenciesTableStatus.deleting, error: null));

    try {
      await service.setFlightTicketDate(
        contractId: id,
        flightTicketDate: date,
        token: token,
      );
      await load(officeId: officeId, statusFilter: statusFilter, token: token);
    } catch (e) {
      emit(state.copyWith(
        status: MaleAgenciesTableStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> setArrivalDate({
    required MaleAgency agency,
    required DateTime date,
    required String employeeName, // ✅ لازم يتبعت للسيرفس
    required String officeId,
    required int statusFilter,
    required String token,
  }) async {
    final id = agency.id.trim();
    if (id.isEmpty) return;

    emit(state.copyWith(status: MaleAgenciesTableStatus.deleting, error: null));

    try {
      await service.setArrivalDate(
        contractId: id,
        arrivalDate: date,
        employeeName: employeeName,
        token: token,
      );
      await load(officeId: officeId, statusFilter: statusFilter, token: token);
    } catch (e) {
      emit(state.copyWith(
        status: MaleAgenciesTableStatus.error,
        error: e.toString(),
      ));
    }
  }

  // ========================== 
  // ✅ Cancel Agency
  // ========================== 
  Future<void> cancelAgency({
    required String agencyId,
    required int cancelationBy,
    required String cancelationReason,
    required String employeeName, // ✅ لازم يتبعت للسيرفس
    required String officeId,
    required int statusFilter,
    required String token,
  }) async {
    final id = agencyId.trim();
    if (id.isEmpty) return;

    emit(state.copyWith(status: MaleAgenciesTableStatus.deleting, error: null));

    try {
      await service.cancelMaleContract(
        contractId: id,
        cancelationBy: cancelationBy,
        cancelationReason: cancelationReason,
        employeeName: employeeName,
        token: token,
      );

      await load(officeId: officeId, statusFilter: statusFilter, token: token);
    } catch (e) {
      emit(state.copyWith(
        status: MaleAgenciesTableStatus.error,
        error: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    stopAutoRefresh();
    return super.close();
  }
}
