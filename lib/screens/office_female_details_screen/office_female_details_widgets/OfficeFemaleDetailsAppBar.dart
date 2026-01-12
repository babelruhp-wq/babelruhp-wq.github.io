import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OfficeFemaleDetailsAppbar extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback onBack;

  // ✅ النصوص داخل الكونتينر
  final String title;
  final String subtitle;

  // ✅ زر/أزرار ناحية اليمين (مثلاً زر إضافة عقد)
  final Widget? action;

  // ✅ اللون الشريط الجانبي
  final Color accentColor;

  // ✅ لو عايز تخلي ارتفاعه أكبر/أصغر
  final double height;

  const OfficeFemaleDetailsAppbar({
    super.key,
    required this.onBack,
    required this.title,
    required this.subtitle,
    this.action,
    this.accentColor = const Color(0xff3a4262),
    this.height = 120,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12), // ✅ بوردر خفيف
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
            const SizedBox(width: 14),

            // ✅ الشريط الملون
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 14),

            // ✅ عنوان + سطر صغير
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xff2c334a),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff6B7280),
                    ),
                  ),
                ],
              ),
            ),

            if (action != null) ...[
              const SizedBox(width: 12),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
