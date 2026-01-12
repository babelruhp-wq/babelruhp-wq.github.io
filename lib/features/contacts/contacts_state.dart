import 'package:babel_final_project/models/contacts_model.dart';


class ContactsState {
  final bool isLoading;
  final String? error;

  final List<WhatsappContact> rows;
  final int totalCount;

  final String query;
  final int page; // 1-based
  final int pageSize;

  const ContactsState({
    this.isLoading = false,
    this.error,
    this.rows = const [],
    this.totalCount = 0,
    this.query = '',
    this.page = 1,
    this.pageSize = 10,
  });

  ContactsState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    List<WhatsappContact>? rows,
    int? totalCount,
    String? query,
    int? page,
    int? pageSize,
  }) {
    return ContactsState(
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
