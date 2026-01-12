import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../localization/translator.dart';
import '../../../../models/male_agency.dart';
import '../utils/cairo_theme.dart';

Future<void> openNoteDialog(
    BuildContext context, {
      required MaleAgency c,
      required Future<void> Function(String note) onSave,
    }) async {
  final ctrl = TextEditingController(text: (c.notes ?? '').trim());
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
                              color: const Color(0xFFE8F1FF),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color:
                                const Color(0xFF175CD3).withOpacity(.20),
                              ),
                            ),
                            child: const Icon(
                              Icons.edit_note_rounded,
                              color: Color(0xFF175CD3),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              tr(dialogCtx, 'notes'),
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
                            const SizedBox(height: 8),
                            TextField(
                              controller: ctrl,
                              maxLines: 4,
                              minLines: 3,
                              decoration: InputDecoration(
                                hintText: tr(dialogCtx, 'notes'),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
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
                                tr(dialogCtx, 'cancel'),
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
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
                                  await onSave(ctrl.text.trim());
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
                                tr(dialogCtx, 'save'),
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF175CD3),
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

  ctrl.dispose();
}
