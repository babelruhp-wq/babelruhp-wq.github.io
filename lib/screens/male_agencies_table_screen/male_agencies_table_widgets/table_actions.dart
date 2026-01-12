import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TableActions extends StatelessWidget {
  final VoidCallback onDetails;
  final Future<void> Function()? onEdit;

  final String tDetails;
  final String? tEdit;

  const TableActions({
    super.key,
    required this.onDetails,
    this.onEdit,
    required this.tDetails,
    this.tEdit,
  });

  @override
  Widget build(BuildContext context) {
    final hasEdit = onEdit != null;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _pill(
          context,
          icon: Icons.visibility_rounded,
          label: tDetails,
          fg: const Color(0xFF175CD3),
          bg: const Color(0xFFE8F1FF),
          onTap: onDetails,
        ),

        // ✅ اعرض Edit فقط لو onEdit موجود
        if (hasEdit)
          _pill(
            context,
            icon: Icons.edit_rounded,
            label: tEdit ?? 'Edit',
            fg: const Color(0xFF7A5AF8),
            bg: const Color(0xFFF3F0FF),
            onTap: () async => await onEdit!.call(),
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
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: fg.withOpacity(0.22)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
