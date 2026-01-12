import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../localization/translator.dart';

class NewContractsActions extends StatelessWidget {
  final bool disabled; // ✅ زي UnderProcess
  final VoidCallback onDetails;
  final Future<void> Function() onNote;
  final Future<void> Function() onApprove;
  final Future<void> Function() onCancel;

  const NewContractsActions({
    super.key,
    required this.disabled,
    required this.onDetails,
    required this.onNote,
    required this.onApprove,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _pill(
          context,
          icon: Icons.visibility_rounded,
          label: tr(context, 'details'),
          fg: const Color(0xFF175CD3),
          bg: const Color(0xFFE8F1FF),
          onTap: onDetails,
        ),
        _pill(
          context,
          icon: Icons.edit_note_rounded,
          label: tr(context, 'notes_table'),
          fg: const Color(0xFF7A5AF8),
          bg: const Color(0xFFF3F0FF),
          onTap: () async => onNote(),
        ),
        _pill(
          context,
          icon: Icons.verified_rounded,
          label: 'موافقة',
          fg: const Color(0xFF1E7A3B),
          bg: const Color(0xFFE7F7EE),
          onTap: disabled ? null : () async => onApprove(),
        ),
        _pill(
          context,
          icon: Icons.block_rounded,
          label: 'إلغاء',
          fg: const Color(0xFFB42318),
          bg: const Color(0xFFFFE8E8),
          onTap: disabled ? null : () async => onCancel(),
        ),
      ],
    );
  }

  Widget _pill(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color fg,
        required Color bg,
        VoidCallback? onTap,
      }) {
    final isDisabled = onTap == null;

    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(999),
      child: Opacity(
        opacity: isDisabled ? 0.45 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isDisabled ? bg.withOpacity(0.55) : bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: (isDisabled ? fg.withOpacity(0.12) : fg.withOpacity(0.22)),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: isDisabled ? fg.withOpacity(0.5) : fg),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: isDisabled ? fg.withOpacity(0.5) : fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
