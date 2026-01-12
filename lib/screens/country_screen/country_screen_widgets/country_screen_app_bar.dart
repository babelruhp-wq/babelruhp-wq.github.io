import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/auth/auth_provider.dart';
import '../../../localization/translator.dart';
import '../../../models/country.dart';
import 'show_add_office_dialog.dart';

class CountryScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Country country;
  final VoidCallback onBack;
  final VoidCallback onOfficeAdded;

  const CountryScreenAppBar({
    super.key,
    required this.country,
    required this.onBack,
    required this.onOfficeAdded,
  });

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    final isArabic = Directionality.of(context) == TextDirection.rtl;
    final auth = context.watch<AuthProvider>();
    final role = auth.role; // role أو fallback "Admin"
    final isAdmin = role == 'Admin';
    final isManager = role == 'Manager';
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 24, 20),
      margin: EdgeInsets.only(left: 30,right: 30,top: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          /// 🔙 Back
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: Color(0xff3a4262),
              ),
            ),
          ),

          const SizedBox(width: 16),

          /// Accent bar
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xff3a4262),
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          const SizedBox(width: 16),

          /// Country name
          Expanded(
            child: Text(
              isArabic ? country.nameArabic : country.nameEnglish,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xff2c334a),
              ),
            ),
          ),
          if(isAdmin || isManager)
          /// ➕ Add office
          ElevatedButton.icon(
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              tr(context, 'add_new_office'),
              style: GoogleFonts.cairo(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              final result = await showAddOfficeDialog(
                context,
                countryId: country.countryId, // ✅ الجديد
              );

              if (result == true) {
                onOfficeAdded(); // ✅ refresh
              }
            },
          ),
        ],
      ),
    );
  }
}
