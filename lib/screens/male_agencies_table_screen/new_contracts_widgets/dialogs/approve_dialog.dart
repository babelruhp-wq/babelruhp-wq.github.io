import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../localization/translator.dart';
import '../../../../models/male_agency.dart';

Future<void> openApproveDialog(
    BuildContext context, {
      required MaleAgency c,
      required Future<void> Function(DateTime approvalDate) onApprove,
    }) async {
  bool saving = false;

  String fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) {
      final base = Theme.of(dialogCtx);
      final themed = base.copyWith(
        textTheme: GoogleFonts.cairoTextTheme(base.textTheme),
        primaryTextTheme: GoogleFonts.cairoTextTheme(base.primaryTextTheme),
      );

      return Theme(
        data: themed,
        child: StatefulBuilder(
          builder: (ctx, setS) {
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE7F7EE),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFF1E7A3B).withOpacity(.20)),
                            ),
                            child: const Icon(Icons.verified_rounded, color: Color(0xFF1E7A3B)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'تأكيد الموافقة',
                              style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w900),
                            ),
                          ),
                          IconButton(
                            tooltip: tr(dialogCtx, 'cancel'),
                            onPressed: saving ? null : () => Navigator.of(dialogCtx).pop(false),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F9FC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE7ECF4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.workerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'عند اعتماد الموافقة سيتم نقل الحالة إلى "تحت الإجراء".',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2B3250),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE7F7EE),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFF1E7A3B).withOpacity(.20)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.event_rounded, size: 18, color: Color(0xFF1E7A3B)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'سيتم تسجيل تاريخ الموافقة: ${fmt(today)}',
                                    style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF1E7A3B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF4E5),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFFFD7A6)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.info_outline_rounded, color: Color(0xFFB25E00)),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'هل أنت متأكد من اعتماد الموافقة الآن؟ سيتم اعتمادها بتاريخ اليوم.',
                                      style: GoogleFonts.cairo(
                                        fontSize: 13,
                                        height: 1.45,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF2B3250),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: saving ? null : () => Navigator.of(dialogCtx).pop(false),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: Text(tr(dialogCtx, 'cancel'), style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: saving
                                  ? null
                                  : () async {
                                setS(() => saving = true);
                                try {
                                  final n = DateTime.now();
                                  final todayPressed = DateTime(n.year, n.month, n.day);
                                  await onApprove(todayPressed);
                                  if (dialogCtx.mounted) Navigator.of(dialogCtx).pop(true);
                                } catch (_) {
                                  if (dialogCtx.mounted) setS(() => saving = false);
                                }
                              },
                              icon: saving
                                  ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                                  : const Icon(Icons.check_rounded, size: 18),
                              label: Text('اعتماد الموافقة', style: GoogleFonts.cairo(fontWeight: FontWeight.w900)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E7A3B),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
