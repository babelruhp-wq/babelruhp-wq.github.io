import '../../../../models/male_agency.dart';

bool hasValueLate(dynamic v) {
  if (v == null) return false;
  final s = v.toString().trim();
  return s.isNotEmpty && s.toLowerCase() != 'null';
}

/// يقبل DateTime أو String (2026-01-10 / 2026-01-10T00:00:00 / 2026-01-10 00:00:00)
DateTime? asDate(dynamic v) {
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

/// ✅ 7 أيام بدون موافقة (مش بدون ختم)
bool isOver7DaysWithoutApprove(MaleAgency c) {
  final contractDate = asDate(c.contractDate);
  if (contractDate == null) return false;

  final bool hasApproved = (c.approved == true) || hasValueLate(c.approvalDate);
  if (hasApproved) return false;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final diffDays = today.difference(contractDate).inDays;

  return diffDays >= 7;
}

/// ✅ نفس نصوص شاشة الإجراءات
String adminRequestsStatusText(MaleAgency c) {
  final s = c.adminRequestsStatus;
  if (s == 1) return "يوجد طلب الغاء في انتظار موافقة المسؤول";
  if (s == 2) return "تمت الموافقة علي طلب الإلغاء";
  if (s == 3) return "تم رفض  طلب الإلغاء !!!! يرجي مراجعة بيانات الطلب";
  if (s == 4) return "يوجد طلب وصول في انتظار موافقة المسؤول";
  if (s == 5) return "تمت الموافقة علي طلب الوصول";
  if (s == 6) return " تم رفض  طلب الوصول !!!! يرجي مراجعة بيانات الطلب";
  return "لا يوجد طلبات حاليا";
}

/// ✅ تعطيل أزرار موافقة/إلغاء لو فيه طلب عند الأدمن
bool actionsDisabled(MaleAgency c) {
  return (c.adminRequestsStatus == 1 || c.adminRequestsStatus == 4);
}

String itemKey(MaleAgency c) {
  final id = (c.id ?? '').toString().trim();
  if (id.isNotEmpty && id.toLowerCase() != 'null') return id;
  return (c.contractNumber).toString().trim();
}
