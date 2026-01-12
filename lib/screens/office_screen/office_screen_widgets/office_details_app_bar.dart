import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OfficeDetailsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String officeName;
  final VoidCallback onBack;

  const OfficeDetailsAppBar({
    super.key,
    required this.officeName,
    required this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 20, left: 30, right: 30),
      padding: const EdgeInsets.fromLTRB(16, 20, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
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
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xff3a4262),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              officeName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xff2c334a),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
