import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/lang/app_language.dart';
import '../../../localization/translator.dart';

class ContactsScreenAppbar extends StatelessWidget {
  const ContactsScreenAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          /// 🎯 Accent bar
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xff3a4262),
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          const SizedBox(width: 16),

          /// 🧠 Text Content
          Expanded(
            child: Consumer<AppLanguage>(
              builder: (context, lang, child) {
                return Text(
                  tr(context, 'contacts'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff2c334a),
                  ),
                );
              },
            ),
          ),


          /// 🚀 مساحة مستقبلية للأزرار (جاهزة)
          // const SizedBox(width: 16),
          // Icon(Icons.filter_alt_outlined, color: Colors.grey),
        ],
      ),
    );
  }
}
