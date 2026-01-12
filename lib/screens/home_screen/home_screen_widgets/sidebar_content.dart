import 'package:flutter/material.dart';
import '../../../core/constants/constants.dart';

import 'sidebar_header.dart';
import 'sidebar_list_view_widget.dart';

class SidebarContent extends StatelessWidget {
  final Function(HomeSection) onSectionSelected;
  final bool isCollapsed;

  /// ✅ جديد: عشان نعمل Highlight للعنصر المختار
  final HomeSection currentSection;

  const SidebarContent({
    super.key,
    required this.onSectionSelected,
    required this.isCollapsed,
    required this.currentSection,
  });

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return Column(
      children: [
        /// Header
        SidebarHeader(isCollapsed: isCollapsed),

        const Divider(
          height: 1,
          thickness: 0.3,
          color: Colors.white24,
        ),

        /// Menu
        Expanded(
          child: Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            child: SidebarListViewWidget(
              onSelect: onSectionSelected,
              isCollapsed: isCollapsed,
              controller: scrollController,

              /// ✅ تمريرها
              currentSection: currentSection,
            ),
          ),
        ),
      ],
    );
  }
}
