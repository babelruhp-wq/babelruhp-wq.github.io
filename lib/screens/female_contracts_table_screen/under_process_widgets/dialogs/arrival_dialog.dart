import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../localization/translator.dart';
import '../../../../models/female_contract.dart';
import '../dialogs/confirm_before_send_dialog.dart';
import '../utils/cairo_theme.dart';

Future<void> openArrivalDialog(
    BuildContext context, {
      required FemaleContract c,
      required Future<void> Function(DateTime arrivalDate) onSave,
    }) async {
  DateTime? pickedDate;
  bool saving = false;

  const warningText =
      'يجب التأكد تمامًا من تاريخ الوصول قبل الإرسال للمسؤول لأنه سيتم البدء في حساب فترة الضمان بناءً على هذا التاريخ.';
  const confirmText =
      'هل أنت متأكد من تاريخ الوصول قبل الإرسال للمسؤول؟ لأنه سيتم البدء في حساب فترة الضمان بناءً على هذا التاريخ.';

  await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) {
      return Theme(
        data: cairoTheme(dialogCtx),
        child: StatefulBuilder(
          builder: (ctx, setS) {
            final canSave = !saving && pickedDate != null;

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
                              border: Border.all(
                                color: const Color(0xFF1E7A3B).withOpacity(.20),
                              ),
                            ),
                            child: const Icon(
                              Icons.flight_land_rounded,
                              color: Color(0xFF1E7A3B),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'إضافة تاريخ الوصول',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: tr(dialogCtx, 'close'),
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
                                style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
                              ),
                            ),

                            const SizedBox(height: 12),

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
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: saving ? null : () => Navigator.of(dialogCtx).pop(false),
                              child: Text(
                                'رجوع',
                                style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: canSave
                                  ? () async {
                                final ok = await showConfirmBeforeSendDialog(
                                  dialogCtx,
                                  message: confirmText,
                                );
                                if (!ok) return;

                                setS(() => saving = true);
                                try {
                                  await onSave(pickedDate!);
                                  if (dialogCtx.mounted) {
                                    Navigator.of(dialogCtx).pop(true);
                                  }
                                } catch (_) {
                                  if (dialogCtx.mounted) setS(() => saving = false);
                                }
                              }
                                  : null,
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
                                'حفظ تاريخ الوصول',
                                style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E7A3B),
                                foregroundColor: Colors.white,
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
