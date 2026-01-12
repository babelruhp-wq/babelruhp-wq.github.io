import '../../models/cancelation_orders_row.dart';

class CancelationOrdersState {
  final bool isLoading;
  final String? error;
  final int newIncomingDelta;
  final int snackNonce;

  final List<CancelationOrdersRow> rows;

  final String query;
  final int page; // 1-based
  final int pageSize;
  final int totalCount;

  const CancelationOrdersState({
    this.isLoading = false,
    this.error,
    this.rows = const [],
    this.query = '',
    this.page = 1,
    this.pageSize = 10,
    this.totalCount = 0,
    this.newIncomingDelta=0,  this.snackNonce=0
  });

  CancelationOrdersState copyWith({
    int? newIncomingDelta,
    int? snackNonce,
    bool? isLoading,
    String? error,
    bool clearError = false,
    List<CancelationOrdersRow>? rows, // ✅ هنا الصح
    String? query,
    int? page,
    int? pageSize,
    int? totalCount,
  }) {
    return CancelationOrdersState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      rows: rows ?? this.rows,
      query: query ?? this.query,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      totalCount: totalCount ?? this.totalCount,
      newIncomingDelta: newIncomingDelta ?? this.newIncomingDelta,
      snackNonce: snackNonce ?? this.snackNonce,
    );
  }
}
