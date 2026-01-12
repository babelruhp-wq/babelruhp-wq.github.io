import 'dart:async';
import 'package:flutter/foundation.dart';

class HomeNotificationsProvider extends ChangeNotifier {
  int arrivalCount = 0;
  int cancelCount = 0;

  bool isLoading = false;
  String? error;

  Timer? _timer;

  // ✅ last deltas (للسناك بار)
  int lastDeltaArrival = 0;
  int lastDeltaCancel = 0;

  // ✅ يتغير كل مرة يظهر فيها "جديد" عشان الـUI تسمع وتطلع SnackBar
  int snackNonce = 0;

  int get total => arrivalCount + cancelCount;
  bool get hasArrival => arrivalCount > 0;
  bool get hasCancel => cancelCount > 0;

  final Future<int> Function() fetchPendingArrivalCount;
  final Future<int> Function() fetchPendingCancelCount;

  HomeNotificationsProvider({
    required this.fetchPendingArrivalCount,
    required this.fetchPendingCancelCount,
  });

  Future<void> refresh({bool silent = false}) async {
    if (!silent) {
      isLoading = true;
      error = null;
      notifyListeners();
    }

    try {
      final newArrival = await fetchPendingArrivalCount();
      final newCancel = await fetchPendingCancelCount();

      // ✅ احسب الزيادة مقارنة بالقديم
      final oldArrival = arrivalCount;
      final oldCancel = cancelCount;

      arrivalCount = newArrival;
      cancelCount = newCancel;

      lastDeltaArrival = (newArrival - oldArrival) > 0 ? (newArrival - oldArrival) : 0;
      lastDeltaCancel = (newCancel - oldCancel) > 0 ? (newCancel - oldCancel) : 0;

      // ✅ لو فيه جديد -> حرّك nonce (ده اللي هيشغل SnackBar)
      if (lastDeltaArrival > 0 || lastDeltaCancel > 0) {
        snackNonce++;
      }

      isLoading = false;
      error = null;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
    }
  }

  void startAutoRefresh({Duration every = const Duration(seconds: 25)}) {
    _timer?.cancel();
    _timer = Timer.periodic(every, (_) => refresh(silent: true));
  }

  void stopAutoRefresh() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }
}
