import '../../../../models/male_agency.dart';

class ContractAlerts {
  bool _hasValueLate(dynamic v) {
    if (v == null) return false;
    final s = v.toString().trim();
    return s.isNotEmpty && s.toLowerCase() != 'null';
  }

  DateTime? _asDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return DateTime(v.year, v.month, v.day);

    final s = v.toString().trim();
    if (s.isEmpty) return null;

    final onlyDate = s.contains('T')
        ? s.split('T').first
        : (s.contains(' ') ? s.split(' ').first : s);

    final parts = onlyDate.split('-');
    if (parts.length != 3) return null;

    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;

    return DateTime(y, m, d);
  }

  bool isOver35DaysWithoutStamp(MaleAgency c) {
    final contractDate = _asDate(c.contractDate);
    if (contractDate == null) return false;

    final hasStamp = _hasValueLate(c.stamped);
    if (hasStamp) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diffDays = today.difference(contractDate).inDays;
    return diffDays >= 35;
  }

  bool isOver75DaysWithoutArrival(MaleAgency c) {
    final contractDate = _asDate(c.contractDate);
    if (contractDate == null) return false;

    final hasArrived = _hasValueLate(c.arrivalDate);
    if (hasArrived) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diffDays = today.difference(contractDate).inDays;
    return diffDays >= 75;
  }

  /// 0 = طبيعي، 1 = تحذير، 2 = خطر قوي
  int rowAlertLevel(MaleAgency c) {
    if (isOver75DaysWithoutArrival(c)) return 2;
    if (isOver35DaysWithoutStamp(c)) return 1;
    return 0;
  }
}
