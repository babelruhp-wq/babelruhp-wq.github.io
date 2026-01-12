import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/arrival_requests_history_service.dart';
import 'arrival_requests_history_state.dart';

class ArrivalRequestsHistoryCubit extends Cubit<ArrivalRequestsHistoryState> {
  final ArrivalRequestsHistoryService service;

  ArrivalRequestsHistoryCubit({required this.service})
      : super(const ArrivalRequestsHistoryState());

  Timer? _debounce;

  Future<void> load({required String token}) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final res = await service.fetchOrders(
        query: state.query,
        page: state.page,
        pageSize: state.pageSize,
        token: token,
      );

      emit(state.copyWith(
        isLoading: false,
        rows: res.rows,
        totalCount: res.totalCount,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void setQuery({required String q, required String token}) {
    emit(state.copyWith(query: q, page: 1));

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => load(token: token));
  }

  void nextPage({required String token}) {
    final maxPage = (state.totalCount / state.pageSize).ceil().clamp(1, 999999);
    if (state.page >= maxPage) return;
    emit(state.copyWith(page: state.page + 1));
    load(token: token);
  }

  void prevPage({required String token}) {
    if (state.page <= 1) return;
    emit(state.copyWith(page: state.page - 1));
    load(token: token);
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
