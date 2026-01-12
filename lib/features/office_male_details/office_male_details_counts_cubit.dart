import 'dart:async';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/agencies_service.dart';
import 'office_male_details_counts_state.dart';

class OfficeMaleDetailsCountsCubit extends Cubit<OfficeMaleDetailsCountsState> {
  final MaleAgenciesService service;

  Timer? _timer;
  bool _refreshing = false;

  OfficeMaleDetailsCountsCubit({required this.service})
      : super(OfficeMaleDetailsCountsInitial());

  Future<void> loadCounts({required String officeId, required String token}) async {
    // منع تكرار ضربات API لو auto refresh شغال
    if (_refreshing) return;
    _refreshing = true;

    // لو مفيش بيانات قديمة: اعرض loading
    if (state is! OfficeMaleDetailsCountsLoaded) {
      emit(OfficeMaleDetailsCountsLoading());
    }

    try {
      // ✅ counts دايمًا بتتحسب من status=0 جوه السيرفس
      final counts = await service.fetchMaleCounts(
        officeId: officeId,
        token: token,
      );
      emit(OfficeMaleDetailsCountsLoaded(counts));
    } catch (e) {
      emit(OfficeMaleDetailsCountsError(e.toString()));
    } finally {
      _refreshing = false;
    }
  }

  void startAutoRefresh({
    required String officeId,
    required String token,
    Duration interval = const Duration(seconds: 15),
  }) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) {
      // ✅ يمنع التصادم مع MouseTracker أثناء الفريم
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (isClosed) return;
        loadCounts(officeId: officeId, token: token);
      });
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
