import 'package:flutter/material.dart';
import '../../../localization/translator.dart';

String religionLabel(BuildContext context, int v) {
  switch (v) {
    case 1:
      return tr(context, 'religion_islam');
    case 2:
      return tr(context, 'religion_christian');
    case 3:
      return tr(context, 'religion_other');
    default:
      return '$v';
  }
}

String visaTypeLabel(BuildContext context, int v) {
  switch (v) {
    case 1:
      return tr(context, 'visa_type_full');
    case 2:
      return tr(context, 'visa_type_normal');
    default:
      return '$v';
  }
}

String statusLabel(BuildContext context, int v) {
  switch (v) {
    case 1:
      return tr(context, 'status_new_contract');
    case 2:
      return tr(context, 'status_under_process');
    case 3:
      return tr(context, 'status_canceled');
    case 4:
      return tr(context, 'status_on_arrival');
    case 5:
      return tr(context, 'status_finished');
    default:
      return '$v';
  }
}
String formatDateOnly(String? s) {
  if (s == null) return '-';
  final v = s.trim();
  if (v.isEmpty) return '-';

  final d = DateTime.tryParse(v);
  if (d == null) {
    // لو أصلاً "2026-01-10" أو صيغة مش معروفة
    return v.length >= 10 ? v.substring(0, 10) : v;
  }

  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

String formatCreatedAt(DateTime? dt, {bool asLocal = true}) {
  if (dt == null) return '-';

  // ✅ لو عايز تعرض نفس اللحظة بتوقيت جهاز المستخدم:
  final d = asLocal ? dt : dt.toUtc();

  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');

  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');

  return '$y-$m-$day $hh:$mm';
}





