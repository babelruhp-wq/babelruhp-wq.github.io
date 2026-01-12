import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../localization/translator.dart';

class AddNewContractAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBack;

  const AddNewContractAppBar({
    super.key,
    required this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(120);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x11000000)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 18,
              offset: Offset(0, 8),
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
            const SizedBox(width: 14),
            Container(
              width: 4,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xff3a4262),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                tr(context, "add_new_contract"),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xff2c334a),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
