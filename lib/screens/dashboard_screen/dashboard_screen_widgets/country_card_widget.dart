import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/auth/auth_provider.dart';
import '../../../localization/translator.dart';
import '../../../models/country.dart';
import '../../../models/country_office_stats.dart';

class CountryCardWidget extends StatelessWidget {
  final Country country;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final CountryOfficeStats stats;

  const CountryCardWidget({
    super.key,
    required this.country,
    required this.onEdit,
    required this.onDelete,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = Directionality.of(context) == TextDirection.rtl;
    final title = isArabic ? country.nameArabic : country.nameEnglish;
    final auth = context.watch<AuthProvider>();
    final role = auth.role; // role أو fallback "Admin"
    final isAdmin = role == 'Admin';
    final isManager = role == 'Manager';
    return Stack(
      children: [
        Container(
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
                  title,
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

              const Spacer(),

              /// Bottom bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xff394263),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(14),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.apartment, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tr(context, "external_offices"),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${stats.officesNumber}',
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
