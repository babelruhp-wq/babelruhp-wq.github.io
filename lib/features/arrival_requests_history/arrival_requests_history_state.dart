import '../../models/arrival_requests_history_row.dart';

class ArrivalRequestsHistoryState {
  final bool isLoading;
  final String? error;

  final List<ArrivalRequestsHistoryRow> rows;
  final int totalCount;

  final String query;
  final int page; // 1-based
  final int pageSize;

  const ArrivalRequestsHistoryState({
    this.isLoading = false,
    this.error,
    this.rows = const [],
    this.totalCount = 0,
    this.query = '',
    this.page = 1,
    this.pageSize = 10,
  });

  ArrivalRequestsHistoryState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    List<ArrivalRequestsHistoryRow>? rows,
    int? totalCount,
    String? query,
    int? page,
    int? pageSize,
  }) {
    return ArrivalRequestsHistoryState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      rows: rows ?? this.rows,
      totalCount: totalCount ?? this.totalCount,
      query: query ?? this.query,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}
