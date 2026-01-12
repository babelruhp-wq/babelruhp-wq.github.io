import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../localization/translator.dart';
import '../../../../models/female_contract.dart';
import '../dialogs/confirm_before_send_dialog.dart';
import '../utils/cairo_theme.dart';

Future<void> openDateDialog(
    BuildContext context, {
      required FemaleContract c,
      required String title,
      required IconData icon,
      required Color fg,
      required Color bg,
      required String buttonText,
      required Future<void> Function(DateTime d) onSave,
      String? warningText,
      String? confirmBeforeSendText,
    }) async {
  DateTime? pickedDate;
  bool saving = false;

  await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) {
      return Theme(
        data: cairoTheme(dialogCtx),
        child: StatefulBuilder(
          builder: (ctx, setS) {
            return Dialog(
              insetPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
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
                              color: bg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: fg.withOpacity(.20)),
                            ),
                            child: Icon(icon, color: fg),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              title,
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: tr(dialogCtx, 'close'),
                            onPressed: saving
                                ? null
                                : () => Navigator.of(dialogCtx).pop(false),
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
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: saving
                                  ? null
                                  : () async {
                                final now = DateTime.now();
                                final d = await showDatePicker(
                                  context: dialogCtx,
                                  initialDate: pickedDate ?? now,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (d == null) return;
                                setS(() => pickedDate = d);
                              },
                              icon: const Icon(Icons.event_rounded, size: 18),
                              label: Text(
                                pickedDate == null
                                    ? 'اختر التاريخ'
                                    : '${pickedDate!.year}-${pickedDate!.month.toString().padLeft(2, '0')}-${pickedDate!.day.toString().padLeft(2, '0')}',
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding:
                                const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                            if (warningText != null &&
                                warningText.trim().isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF4E5),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFFFD7A6),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.warning_amber_rounded,
                                      color: Color(0xFFB25E00),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        warningText,
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
                            if (pickedDate == null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'مطلوب تحديد التاريخ قبل الحفظ.',
                                style: GoogleFonts.cairo(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFFB42318),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: saving
                                  ? null
                                  : () => Navigator.of(dialogCtx).pop(false),
                              style: OutlinedButton.styleFrom(
                                padding:
                                const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                'رجوع',
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: (saving || pickedDate == null)
                                  ? null
                                  : () async {
                                if (confirmBeforeSendText != null &&
                                    confirmBeforeSendText
                                        .trim()
                                        .isNotEmpty) {
                                  final ok =
                                  await showConfirmBeforeSendDialog(
                                    dialogCtx,
                                    message: confirmBeforeSendText,
                                  );
                                  if (!ok) return;
                                }

                                setS(() => saving = true);
                                try {
                                  await onSave(pickedDate!);
                                  if (dialogCtx.mounted) {
                                    Navigator.of(dialogCtx).pop(true);
                                  }
                                } catch (_) {
                                  if (dialogCtx.mounted) {
                                    setS(() => saving = false);
                                  }
                                }
                              },
                              icon: saving
                                  ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                                  : const Icon(Icons.save_rounded, size: 18),
                              label: Text(
                                buttonText,
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: fg,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding:
                                const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
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
