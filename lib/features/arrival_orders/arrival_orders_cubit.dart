import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/arrival_orders_row.dart';
import '../../services/arrival_orders_service.dart';
import 'arrival_orders_state.dart';

class ArrivalOrdersCubit extends Cubit<ArrivalOrdersState> {
  final ArrivalOrdersService service;

  /// ✅ دايمًا هيرجع التوكن الحالي (حل مشكلة التوكن القديم)
  final String Function() tokenProvider;

  ArrivalOrdersCubit({
    required this.service,
    required this.tokenProvider,
  }) : super(const ArrivalOrdersState());

  Timer? _debounce;

  // ✅ Auto refresh poller
  Timer? _autoRefresh;
  static const Duration _autoRefreshInterval = Duration(seconds: 10);

  // ✅ Fingerprint لتقليل emits
  String _lastFingerprint = '';

  // ✅ عشان مانطلعش "طلب جديد" أول مرة
  bool _loadedOnce = false;

  String _token() => tokenProvider().trim();

  Future<void> load({
    bool showLoader = true,
    bool clearActionRowId = true,
  }) async {
    final token = _token();

    if (showLoader) {
      emit(state.copyWith(isLoading: true, clearError: true));
    } else {
      emit(state.copyWith(clearError: true));
    }

    try {
      final oldTotal = state.totalCount;

      final res = await service.fetchOrders(
        token: token,
        query: state.query,
        page: state.page,
        pageSize: state.pageSize,
      );

      final fp = _fingerprint(res.rows, res.totalCount);
      if (!showLoader && fp == _lastFingerprint) {
        _loadedOnce = true;
        _ensureAutoRefresh();
        return;
      }
      _lastFingerprint = fp;

      int newDelta = 0;
      int newNonce = state.snackNonce;

      if (!showLoader && _loadedOnce) {
        final deltaTotal = res.totalCount - oldTotal;
        newDelta = deltaTotal > 0 ? deltaTotal : 0;
        if (newDelta > 0) newNonce = state.snackNonce + 1;
      }

      emit(
        state.copyWith(
          isLoading: false,
          rows: res.rows,
          totalCount: res.totalCount,
          clearError: true,
          clearActionRowId: clearActionRowId,
          newIncomingDelta: newDelta,
          snackNonce: newNonce,
        ),
      );

      _loadedOnce = true;
      _ensureAutoRefresh();
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: e.toString(),
          clearActionRowId: clearActionRowId,
        ),
      );
    }
  }

  void setQuery(String q) {
    emit(state.copyWith(query: q, page: 1));

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      load(showLoader: true);
    });
  }

  void setPageSize(int size) {
    emit(state.copyWith(pageSize: size, page: 1));
    load(showLoader: true);
  }

  void nextPage() {
    final maxPage =
    (state.totalCount / state.pageSize).ceil().clamp(1, 999999);
    if (state.page >= maxPage) return;
    emit(state.copyWith(page: state.page + 1));
    load(showLoader: true);
  }

  void prevPage() {
    if (state.page <= 1) return;
    emit(state.copyWith(page: state.page - 1));
    load(showLoader: true);
  }

  Future<void> approveOrder(ArrivalOrdersRow row) async {
    if (row.id.trim().isEmpty) return;

    final token = _token();

    emit(state.copyWith(actionRowId: row.id, clearError: true));

    try {
      await service.approve(row.id, token: token);

      final updatedRows = List<ArrivalOrdersRow>.from(state.rows)
        ..removeWhere((r) => r.id == row.id);

      emit(
        state.copyWith(
          rows: updatedRows,
          totalCount: (state.totalCount - 1).clamp(0, 999999999),
          clearActionRowId: true,
        ),
      );

      await load(showLoader: false, clearActionRowId: false);
    } catch (e) {
      emit(state.copyWith(error: e.toString(), clearActionRowId: true));
    }
  }

  Future<void> rejectOrder(ArrivalOrdersRow row) async {
    if (row.id.trim().isEmpty) return;

    final token = _token();

    emit(state.copyWith(actionRowId: row.id, clearError: true));

    try {
      await service.reject(row.id, token: token);

      final updatedRows = List<ArrivalOrdersRow>.from(state.rows)
        ..removeWhere((r) => r.id == row.id);

      emit(
        state.copyWith(
          rows: updatedRows,
          totalCount: (state.totalCount - 1).clamp(0, 999999999),
          clearActionRowId: true,
        ),
      );

      await load(showLoader: false, clearActionRowId: false);
    } catch (e) {
      emit(state.copyWith(error: e.toString(), clearActionRowId: true));
    }
  }

  // =========================
  // ✅ Auto Refresh
  // =========================
  void _ensureAutoRefresh() {
    if (_autoRefresh != null) return;

    _autoRefresh = Timer.periodic(_autoRefreshInterval, (_) async {
      if (isClosed) return;

      if (state.isLoading) return;
      if (state.actionRowId != null && state.actionRowId!.trim().isNotEmpty) {
        return;
      }
      if (_debounce?.isActive == true) return;

      await load(showLoader: false, clearActionRowId: false);
    });
  }

  void stopAutoRefresh() {
    _autoRefresh?.cancel();
    _autoRefresh = null;
  }

  String _fingerprint(List<ArrivalOrdersRow> rows, int totalCount) {
    final b = StringBuffer()..write('t:$totalCount|');
    for (final r in rows) {
      b.write(r.id);
      b.write(':');
      b.write(r.status.index);
      b.write(':');
      b.write(r.createdAt.millisecondsSinceEpoch);
      b.write(':');
      b.write(r.description);
      b.write('|');
    }
    return b.toString();
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    _autoRefresh?.cancel();
    return super.close();
  }
}
