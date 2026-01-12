import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_provider.dart';
import '../../../core/lang/app_language.dart';
import '../../login_screen/login_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMenuPressed;

  /// ✅ counts جاية من الكيوبيتات
  final int arrivalCount;
  final int cancelCount;

  /// ✅ افتح صفحة/شيت الإشعارات
  final VoidCallback? onNotificationsTap;

  const CustomAppBar({
    super.key,
    required this.onMenuPressed,
    this.arrivalCount = 0,
    this.cancelCount = 0,
    this.onNotificationsTap,
  });

  Future<bool> _confirmLogout(BuildContext context) async {
    final isArabic = context.read<AppLanguage>().isArabic;

    final res = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isArabic ? 'تأكيد تسجيل الخروج' : 'Confirm Logout',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
          ),
          content: Text(
            isArabic
                ? 'هل أنت متأكد أنك تريد تسجيل الخروج؟'
                : 'Are you sure you want to logout?',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: Text(
                isArabic ? 'إلغاء' : 'Cancel',
                style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogCtx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                isArabic ? 'تسجيل الخروج' : 'Logout',
                style: GoogleFonts.cairo(fontWeight: FontWeight.w900, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    return res == true;
  }

  Future<void> _doLogout(BuildContext context) async {
    final ok = await _confirmLogout(context);
    if (!ok) return;

    await context.read<AuthProvider>().logout(callServer: true);
    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<AppLanguage>().isArabic;
    final total = (arrivalCount + cancelCount).clamp(0, 999999999);
    final hasAny = total > 0;

    final screenW = MediaQuery.sizeOf(context).width;
    final showPill = hasAny && screenW >= 1100; // ✅ عشان ما يعملش overflow

    String pillText() {
      if (arrivalCount > 0 && cancelCount > 0) {
        return isArabic
            ? 'يوجد طلب وصول ويوجد طلب إلغاء'
            : 'Arrival + Cancel requests';
      }
      if (arrivalCount > 0) return isArabic ? 'يوجد طلب وصول' : 'Arrival request(s)';
      if (cancelCount > 0) return isArabic ? 'يوجد طلب إلغاء' : 'Cancel request(s)';
      return '';
    }

    return AppBar(
      backgroundColor: const Color(0xff394263),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.18),
      leadingWidth: 56,
      leading: IconButton(
        tooltip: isArabic ? 'القائمة' : 'Menu',
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: onMenuPressed,
      ),
      centerTitle: true,
      title: Text(
        isArabic ? "بابل للاستقدام" : "Babel for Recruitment",
        style: GoogleFonts.cairo(
          fontSize: 16.5,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      actions: [
        /// ✅ Notifications (Pill + Bell + Badge)
        if (hasAny)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showPill)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 260),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white.withOpacity(0.18)),
                      ),
                      child: Text(
                        pillText(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 6),
                _NotificationBell(
                  total: total,
                  tooltip: isArabic ? 'الإشعارات' : 'Notifications',
                  onTap: onNotificationsTap,
                ),
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 6),
            child: _NotificationBell(
              total: 0,
              tooltip: isArabic ? 'الإشعارات' : 'Notifications',
              onTap: onNotificationsTap,
            ),
          ),

        /// ✅ Language
        Consumer<AppLanguage>(
          builder: (context, lang, _) {
            return Padding(
              padding: const EdgeInsetsDirectional.only(end: 6),
              child: TextButton.icon(
                onPressed: lang.toggleLanguage,
                icon: const Icon(Icons.language, color: Colors.white, size: 18),
                label: Text(
                  lang.isArabic ? 'AR' : 'EN',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            );
          },
        ),

        /// ✅ Logout icon only
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 10),
          child: IconButton(
            tooltip: isArabic ? 'تسجيل الخروج' : 'Logout',
            onPressed: () => _doLogout(context),
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _NotificationBell extends StatelessWidget {
  final int total;
  final String tooltip;
  final VoidCallback? onTap;

  const _NotificationBell({
    required this.total,
    required this.tooltip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final has = total > 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.notifications_none_rounded,
                color: Colors.white, size: 24),

            /// ✅ Badge
            if (has)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE11D48),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text(
                    total > 99 ? '99+' : total.toString(),
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
