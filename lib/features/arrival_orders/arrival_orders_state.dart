import '../../models/arrival_orders_row.dart';

class ArrivalOrdersState {
  final bool isLoading;
  final String? error;
  final int newIncomingDelta; // كام طلب جديد ظهر في آخر silent refresh
  final int snackNonce;
  final List<ArrivalOrdersRow> rows;

  final String query;
  final int page; // 1-based
  final int pageSize;
  final int totalCount;

  // ✅ جديد: عشان نعمل disable للزرار في صف معين
  final String? actionRowId;

  const ArrivalOrdersState({
    this.isLoading = false,
    this.error,
    this.rows = const [],
    this.query = '',
    this.page = 1,
    this.pageSize = 10,
    this.totalCount = 0,
    this.actionRowId,  this.newIncomingDelta=0,  this.snackNonce=0,
  });

  ArrivalOrdersState copyWith({
    int? newIncomingDelta,
    int? snackNonce,

    bool? isLoading,
    String? error,
    bool clearError = false,
    List<ArrivalOrdersRow>? rows,
    String? query,
    int? page,
    int? pageSize,
    int? totalCount,
    String? actionRowId,
    bool clearActionRowId = false,
  }) {
    return ArrivalOrdersState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      rows: rows ?? this.rows,
      query: query ?? this.query,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      totalCount: totalCount ?? this.totalCount,
      actionRowId: clearActionRowId ? null : (actionRowId ?? this.actionRowId),
      newIncomingDelta: newIncomingDelta ?? this.newIncomingDelta,
      snackNonce: snackNonce ?? this.snackNonce,

    );
  }
}
