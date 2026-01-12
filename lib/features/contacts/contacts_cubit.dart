import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/contacts_service.dart';
import 'contacts_state.dart';

class ContactsCubit extends Cubit<ContactsState> {
  final WhatsappService service;

  ContactsCubit({required this.service}) : super(const ContactsState());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final res = await service.fetch(
        query: state.query,
        page: state.page,
        pageSize: state.pageSize,
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

  void setQuery(String v) {
    emit(state.copyWith(query: v, page: 1));
    load();
  }

  void setPageSize(int v) {
    emit(state.copyWith(pageSize: v, page: 1));
    load();
  }

  void nextPage() {
    final maxPage = (state.totalCount / state.pageSize).ceil().clamp(1, 999999);
    if (state.page >= maxPage) return;
    emit(state.copyWith(page: state.page + 1));
    load();
  }

  void prevPage() {
    if (state.page <= 1) return;
    emit(state.copyWith(page: state.page - 1));
    load();
  }
}
