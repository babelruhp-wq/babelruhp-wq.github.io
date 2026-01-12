import 'dart:async';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/contracts_service.dart';

part 'office_female_details_counts_state.dart';

class OfficeFemaleDetailsCountsCubit extends Cubit<OfficeFemaleDetailsCountsState> {
  final ContractsService service;

  Timer? _timer;
  bool _refreshing = false;

  OfficeFemaleDetailsCountsCubit({required this.service})
      : super(OfficeFemaleDetailsCountsInitial());

  Future<void> loadCounts({required String officeId, required String token}) async {
    // منع تكرار ضربات API لو auto refresh شغال
    if (_refreshing) return;
    _refreshing = true;

    // لو مفيش بيانات قديمة: اعرض loading
    if (state is! OfficeFemaleDetailsCountsLoaded) {
      emit(OfficeFemaleDetailsCountsLoading());
    }

    try {
      // ✅ counts دايمًا بتتحسب من status=0 جوه السيرفس
      final counts = await service.fetchFemaleCounts(officeId: officeId, token: token);
      emit(OfficeFemaleDetailsCountsLoaded(counts));
    } catch (e) {
      emit(OfficeFemaleDetailsCountsError(e.toString()));
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
