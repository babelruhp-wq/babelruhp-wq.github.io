import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../localization/translator.dart';

class AllSheltersScreenHeader extends StatelessWidget {
  const AllSheltersScreenHeader({super.key});

  @override
  Widget build(BuildContext context) {
    const Color accent = Color(0xff3a4262);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      margin: EdgeInsets.symmetric(horizontal: 32,vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Accent / Icon
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accent.withOpacity(0.95),
                  accent.withOpacity(0.70),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 10,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.apartment_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),

          const SizedBox(width: 14),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tr(context, 'housing-all'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tr(context, 'overview'), // لو مش موجودة عندك غيّرها/احذف السطر كله
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),


        ],
      ),
    );
  }
}
