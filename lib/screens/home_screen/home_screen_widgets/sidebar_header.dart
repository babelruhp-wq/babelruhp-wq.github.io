import 'package:babel_final_project/localization/translator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_provider.dart'; // ✅ عدّل المسار حسب مكانك

class SidebarHeader extends StatelessWidget {
  final bool isCollapsed;

  const SidebarHeader({
    super.key,
    required this.isCollapsed,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool forceCollapsed = constraints.maxWidth < 80;

        // ✅ اسم/Role من الـAuthProvider
        final auth = context.watch<AuthProvider>();
        final name = auth.displayName; // name أو unique_name أو fallback "Admin"
        final role = auth.role;        // role أو fallback "Admin"

        /// 🔒 فعليًا مقفول (بالعرض)
        if (isCollapsed || forceCollapsed) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: _Avatar(size: 36),
            ),
          );
        }

        /// 🔓 مفتوح فعليًا
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Avatar(size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tr(context, role),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ================= Avatar =================
class _Avatar extends StatelessWidget {
  final double size;

  const _Avatar({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: size / 2,
            backgroundColor: Colors.white24,
            child: CircleAvatar(
              radius: size / 2 - 2,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person_outline,
                size: size / 2,
                color: Colors.grey.shade600,
              ),
            ),
          ),

          /// Status
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
