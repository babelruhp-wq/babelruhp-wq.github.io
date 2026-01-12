import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../models/female_contract.dart';
import '../../../../localization/translator.dart';

class UnderProcessActions extends StatelessWidget {
  final FemaleContract c;
  final VoidCallback onDetails;
  final VoidCallback onNote;
  final VoidCallback onCancel;
  final VoidCallback onStamped;
  final VoidCallback onTicket;
  final VoidCallback onArrival;

  const UnderProcessActions({
    super.key,
    required this.c,
    required this.onDetails,
    required this.onNote,
    required this.onCancel,
    required this.onStamped,
    required this.onTicket,
    required this.onArrival,
  });

  bool _hasDate(dynamic v) {
    if (v == null) return false;
    final s = v.toString().trim();
    return s.isNotEmpty && s != 'null';
  }

  @override
  Widget build(BuildContext context) {
    final hasStamped = _hasDate(c.stamped);
    final hasTicket = _hasDate(c.flightTicketDate);

    final bool disabled =
    (c.adminRequestsStatus == 1 || c.adminRequestsStatus == 4);

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
          onTap: onNote,
        ),
        _pill(
          context,
          icon: Icons.verified_outlined,
          label: tr(context, 'stamp'),
          fg: const Color(0xFF7A5AF8),
          bg: const Color(0xFFF3F0FF),
          onTap: onStamped,
        ),
        if (hasStamped)
          _pill(
            context,
            icon: Icons.airplane_ticket_rounded,
            label: tr(context, 'flight_ticket'),
            fg: const Color(0xFF175CD3),
            bg: const Color(0xFFE8F1FF),
            onTap: onTicket,
          ),
        if (hasTicket)
          _pill(
            context,
            icon: Icons.flight_land_rounded,
            label: tr(context, 'arrival'),
            fg: const Color(0xFF1E7A3B),
            bg: const Color(0xFFE7F7EE),
            onTap: disabled ? null : onArrival,
          ),
        _pill(
          context,
          icon: Icons.block_rounded,
          label: tr(context, 'btn_cancel'),
          fg: const Color(0xFFB42318),
          bg: const Color(0xFFFFE8E8),
          onTap: disabled ? null : onCancel,
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
    final bool disabled = onTap == null;

    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(999),
      child: Opacity(
        opacity: disabled ? 0.45 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: disabled ? bg.withOpacity(0.55) : bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: (disabled ? fg.withOpacity(0.12) : fg.withOpacity(0.22)),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: disabled ? fg.withOpacity(0.5) : fg),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: disabled ? fg.withOpacity(0.5) : fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
