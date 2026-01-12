import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/auth/auth_provider.dart';
import '../../../localization/translator.dart';
import '../../../models/office.dart';

class OfficeCardWidget extends StatelessWidget {
  final Office office;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  // ✅ NEW
  final int maidsTotal;
  final int maidsUnderProcess;
  final bool isStatsLoading;

  const OfficeCardWidget({
    super.key,
    required this.office,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,

    // ✅ NEW
    required this.maidsTotal,
    required this.maidsUnderProcess,
    this.isStatsLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = auth.role; // role أو fallback "Admin"
    final isAdmin = role == 'Admin';
    final isManager = role == 'Manager';
    return Stack(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 14),

                /// Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    office.officeName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xff1bbae1),
                      height: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                /// ✅ Chips row (Total + Under process)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _infoChip(
                    context,
                    icon: Icons.groups_rounded,
                    label: tr(context, 'total_maids'),
                    value: isStatsLoading ? null : maidsTotal,
                    bg: const Color(0xFFE8F1FF),
                    fg: const Color(0xFF175CD3),
                  ),
                ),

                const Spacer(),

                /// Bottom bar (تحت الإجراء + رقمها)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xff394263),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(14),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.workspaces_outline,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tr(context, 'under_process'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            color: Colors.white.withOpacity(0.92),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      /// ✅ Badge (Under process count)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.18),
                          ),
                        ),
                        child: isStatsLoading
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                '$maidsUnderProcess',
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isAdmin || isManager)
          /// Actions (Edit/Delete)
          PositionedDirectional(
            top: 10,
            end: 10,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _actionPill(
                  icon: Icons.edit,
                  color: Colors.blue,
                  tooltip: tr(context, 'edit'),
                  onTap: onEdit,
                ),
                const SizedBox(width: 8),
                _actionPill(
                  icon: Icons.delete_outline,
                  color: Colors.red,
                  tooltip: tr(context, 'delete'),
                  onTap: onDelete,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _infoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int? value, // null => loading
    required Color bg,
    required Color fg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withOpacity(0.20)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
          ),
          const SizedBox(width: 8),
          value == null
              ? SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                )
              : Text(
                  '$value',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: fg,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _actionPill({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
