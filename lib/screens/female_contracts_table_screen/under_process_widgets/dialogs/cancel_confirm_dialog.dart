import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../localization/translator.dart';
import '../../../../models/female_contract.dart';
import '../utils/cairo_theme.dart';

Future<void> openCancelConfirmDialog(
    BuildContext context, {
      required FemaleContract c,
      required Future<void> Function(int cancelBy, String reason) onSave,
    }) async {
  bool saving = false;
  int? cancelBy; // ✅ null = لسه مفيش اختيار
  final reasonCtrl = TextEditingController();

  await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) {
      return Theme(
        data: cairoTheme(dialogCtx),
        child: StatefulBuilder(
          builder: (ctx, setS) {
            final reason = reasonCtrl.text.trim();
            final canSave = !saving && reason.isNotEmpty && cancelBy != null;

            return Dialog(
              insetPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
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
                              color: const Color(0xFFFFE8E8),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color:
                                const Color(0xFFB42318).withOpacity(.20),
                              ),
                            ),
                            child: const Icon(
                              Icons.block_rounded,
                              color: Color(0xFFB42318),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'إلغاء العقد',
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
                              'هل أنت متأكد من إلغاء العقد؟\n(${c.workerName})',
                              style: GoogleFonts.cairo(
                                fontSize: 13.5,
                                height: 1.4,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF2B3250),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'الإلغاء بواسطة',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                        DropdownButtonFormField<int>(
                          value: cancelBy, // ✅ null في البداية
                          isExpanded: true,
                          decoration: InputDecoration(
                            hintText: tr(dialogCtx, 'choose_from'), // "اختر من"
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE7ECF4)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          items: [
                            DropdownMenuItem<int>(
                              value: 1,
                              child: Text(tr(dialogCtx, 'cancel_by_office')),
                            ),
                            DropdownMenuItem<int>(
                              value: 2,
                              child: Text(tr(dialogCtx, 'cancel_by_client')),
                            ),
                          ],
                          onChanged: saving
                              ? null
                              : (v) {
                            setS(() => cancelBy = v);
                          },
                        ),
                        SizedBox(height: 20,),
                        TextField(
                              controller: reasonCtrl,
                              onChanged: (_) => setS(() {}),
                              minLines: 2,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: 'اكتب سبب الإلغاء...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            if (reason.isEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'سبب الإلغاء مطلوب.',
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
                              onPressed: canSave
                                  ? () async {
                                setS(() => saving = true);
                                try {
                                  await onSave(
                                    cancelBy!,
                                    reasonCtrl.text.trim(),
                                  );
                                  if (dialogCtx.mounted) {
                                    Navigator.of(dialogCtx).pop(true);
                                  }
                                } catch (_) {
                                  if (dialogCtx.mounted) {
                                    setS(() => saving = false);
                                  }
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
                                  : const Icon(Icons.block_rounded, size: 18),
                              label: Text(
                                'تأكيد الإلغاء',
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFB42318),
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

  reasonCtrl.dispose();
}
