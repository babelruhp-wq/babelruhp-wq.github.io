import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import 'sidebar_content.dart';

class SidebarWidget extends StatelessWidget {
  final Function(HomeSection) onSectionSelected;
  final bool isCollapsed;

  /// ✅ جديد: عشان الـ Sidebar يقدر يـ highlight العنصر الحالي
  final HomeSection currentSection;

  const SidebarWidget({
    super.key,
    required this.onSectionSelected,
    required this.isCollapsed,
    required this.currentSection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff394263), Color(0xff2c334a)],
        ),
      ),
      child: SafeArea(
        child: ClipRect(
          child: SidebarContent(
            onSectionSelected: onSectionSelected,
            isCollapsed: isCollapsed,
            currentSection: currentSection, // ✅ تمريرها
          ),
        ),
      ),
    );
  }
}
