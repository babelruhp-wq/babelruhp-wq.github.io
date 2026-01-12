import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/constants.dart';
import '../../../localization/translator.dart';

class SidebarListViewWidget extends StatelessWidget {
  final Function(HomeSection) onSelect;
  final bool isCollapsed;
  final ScrollController? controller;

  /// ✅ جديد: عشان نعمل highlight
  final HomeSection currentSection;

  const SidebarListViewWidget({
    super.key,
    required this.onSelect,
    required this.isCollapsed,
    required this.currentSection,
    this.controller,
  });

  HomeSection? _sectionOf(dynamic v) => v is HomeSection ? v : null;

  bool _isMainSelected(Map<String, dynamic> item) {
    final HomeSection? main = _sectionOf(item['section']);
    final List<Map<String, dynamic>> subMenu =
    (item['subMenu'] ?? []).cast<Map<String, dynamic>>();

    if (main != null && currentSection == main) return true;

    for (final s in subMenu) {
      final HomeSection? sub = _sectionOf(s['section']);
      if (sub != null && currentSection == sub) return true;
    }
    return false;
  }

  bool _isSubSelected(Map<String, dynamic> subItem) {
    final HomeSection? sub = _sectionOf(subItem['section']);
    return sub != null && currentSection == sub;
  }

  bool _shouldExpand(Map<String, dynamic> item) {
    final List<Map<String, dynamic>> subMenu =
    (item['subMenu'] ?? []).cast<Map<String, dynamic>>();
    for (final s in subMenu) {
      final HomeSection? sub = _sectionOf(s['section']);
      if (sub != null && currentSection == sub) return true;
    }
    return false;
  }

  void _safeSelect(HomeSection? section) {
    if (section == null) return; // ✅ لو null ما نغيّرش أي آلية
    onSelect(section);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: EdgeInsets.symmetric(
        horizontal: isCollapsed ? 8 : 12,
        vertical: 18,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        final List<Map<String, dynamic>> subMenu =
        (item['subMenu'] ?? []).cast<Map<String, dynamic>>();

        final bool hasSubMenu = subMenu.isNotEmpty;

        if (isCollapsed || !hasSubMenu) {
          return _buildMainItem(context, item, hasSubMenu);
        } else {
          return _buildExpansionTile(context, item, subMenu);
        }
      },
    );
  }

  // ================= Expansion Tile =================

  Widget _buildExpansionTile(
      BuildContext context,
      Map<String, dynamic> item,
      List<Map<String, dynamic>> subMenu,
      ) {
    final title = tr(context, item['titleKey']);
    final selected = _isMainSelected(item);

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: selected
              ? Colors.white.withOpacity(0.30)
              : Colors.white.withOpacity(0.1),
          border: Border.all(
            color: selected
                ? Colors.white.withOpacity(0.18)
                : Colors.white.withOpacity(0.08),
          ),
        ),
        child: ExpansionTile(
          /// ✅ يفتح تلقائي لو الـ currentSection جوه submenu
          initiallyExpanded: _shouldExpand(item),

          tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          collapsedIconColor: Colors.white54,
          iconColor: Colors.white70,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          collapsedShape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: _buildItemRow(
            icon: item['icon'],
            title: title,
            selected: selected,
          ),
          trailing: const Icon(Icons.keyboard_arrow_down, size: 18),
          children: subMenu.map((e) => _buildSubItem(context, e)).toList(),
        ),
      ),
    );
  }

  // ================= Main Item =================

  Widget _buildMainItem(
      BuildContext context,
      Map<String, dynamic> item,
      bool hasSubMenu,
      ) {
    final title = tr(context, item['titleKey']);
    final selected = _isMainSelected(item);

    final child = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        hoverColor: Colors.white.withOpacity(0.3),
        splashColor: Colors.white.withOpacity(0.3),
        onTap: () {
          // ✅ نفس الآلية بالظبط + حماية من null
          if (isCollapsed && hasSubMenu) {
            final List subMenu = item['subMenu'] ?? [];
            if (subMenu.isNotEmpty) {
              final HomeSection? first =
              _sectionOf((subMenu.first as Map)['section']);
              _safeSelect(first);
            }
            return;
          }

          final HomeSection? section = _sectionOf(item['section']);
          _safeSelect(section);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 0 : 10,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: selected
                ? Colors.white.withOpacity(0.5)
                : Colors.white.withOpacity(0.06),
            border: Border.all(
              color: selected
                  ? Colors.white.withOpacity(0.18)
                  : Colors.white.withOpacity(0.08),
            ),
          ),
          child: _buildItemContent(
            icon: item['icon'],
            title: title,
            hasSubMenu: hasSubMenu,
            selected: selected,
          ),
        ),
      ),
    );

    if (!isCollapsed) return child;

    return Tooltip(
      message: title,
      child: child,
    );
  }

  // ================= Item Content =================

  Widget _buildItemContent({
    required IconData icon,
    required String title,
    required bool hasSubMenu,
    required bool selected,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 50) {
          return SizedBox(
            width: double.infinity,
            child: Center(
              child: Icon(
                icon,
                size: 22,
                color: selected ? Colors.white : Colors.white70,
              ),
            ),
          );
        }

        return _buildItemRow(icon: icon, title: title, selected: selected);
      },
    );
  }

  Widget _buildItemRow({
    required IconData icon,
    required String title,
    required bool selected,
  }) {
    return Row(
      mainAxisAlignment:
      isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: selected
                ? Colors.white.withOpacity(0.14)
                : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: selected ? Colors.white : Colors.white70,
          ),
        ),
        if (!isCollapsed) ...[
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ================= Sub Item =================

  Widget _buildSubItem(BuildContext context, Map<String, dynamic> subItem) {
    if (isCollapsed) return const SizedBox.shrink();

    final selected = _isSubSelected(subItem);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        hoverColor: Colors.white.withOpacity(0.08),
        splashColor: Colors.white.withOpacity(0.08),
        onTap: () {
          final HomeSection? section = _sectionOf(subItem['section']);
          _safeSelect(section); // ✅ نفس الآلية + حماية من null
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: selected ? Colors.white.withOpacity(0.10) : Colors.transparent,
          ),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.white54,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  tr(context, subItem['titleKey']),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected ? Colors.white : Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
