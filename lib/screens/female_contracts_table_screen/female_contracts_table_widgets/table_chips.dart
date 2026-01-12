import 'package:flutter/material.dart';
import 'female_contracts_labels.dart';

class TableChips {
  const TableChips();

  Widget pill({
    required String text,
    required Color bg,
    required Color fg,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 30),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacity(0.25)),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: fg,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget yesNoChip({
    required bool value,
    required String yesText,
    required String noText,
  }) {
    return value
        ? pill(
      text: yesText,
      bg: const Color(0xFFE7F7EE),
      fg: const Color(0xFF1E7A3B),
    )
        : pill(
      text: noText,
      bg: const Color(0xFFFFE8E8),
      fg: const Color(0xFFB42318),
    );
  }

  (Color bg, Color fg) statusColors(int status) {
    Color bg = const Color(0xFFF2F4F7);
    Color fg = const Color(0xFF344054);

    if (status == 0) {
      bg = const Color(0xFFE8F1FF);
      fg = const Color(0xFF175CD3);
    } else if (status == 1) {
      bg = const Color(0xFFFFF4E5);
      fg = const Color(0xFFB54708);
    } else if (status == 2) {
      bg = const Color(0xFFE7F7EE);
      fg = const Color(0xFF1E7A3B);
    } else if (status == 3) {
      bg = const Color(0xFFFFE8E8);
      fg = const Color(0xFFB42318);
    }

    return (bg, fg);
  }

  Widget statusChip(BuildContext context, int status) {
    final label = statusLabel(context, status);
    final colors = statusColors(status);
    return pill(text: label, bg: colors.$1, fg: colors.$2);
  }
}
