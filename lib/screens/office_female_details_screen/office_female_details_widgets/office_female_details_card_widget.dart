import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../localization/translator.dart';

class OfficeFemaleDetailsCardWidget extends StatefulWidget {
  final Map<String, dynamic> item;
  final int? number; // null = loading
  final VoidCallback? onTap;

  const OfficeFemaleDetailsCardWidget({
    super.key,
    required this.item,
    required this.number,
    this.onTap,
  });

  @override
  State<OfficeFemaleDetailsCardWidget> createState() =>
      _OfficeFemaleDetailsCardWidgetState();
}

class _OfficeFemaleDetailsCardWidgetState
    extends State<OfficeFemaleDetailsCardWidget> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final Color color = Color((widget.item['color'] ?? 0xFF3A4262) as int);
    final String nameKey = (widget.item['nameKey'] ?? '') as String;

    final title = tr(context, nameKey);
    final icon = _iconForKey(nameKey);

    final clickable = widget.onTap != null;

    // ✅ Hover effects
    final double lift = _hovered ? -3.0 : 0.0;
    final borderColor = _hovered ? const Color(0xFFD6DDF0) : const Color(0xFFE7ECF4);
    final shadow = _hovered
        ? const [
      BoxShadow(
        color: Color(0x14000000),
        blurRadius: 22,
        offset: Offset(0, 14),
      ),
    ]
        : const [
      BoxShadow(
        color: Color(0x0A000000),
        blurRadius: 16,
        offset: Offset(0, 10),
      ),
    ];

    return MouseRegion(
      cursor: clickable ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, lift, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: shadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            hoverColor: Colors.transparent, // احنا عاملين hover بنفسنا
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: AlignmentDirectional.centerStart,
                      end: AlignmentDirectional.centerEnd,
                      colors: [
                        color.withOpacity(0.95),
                        color.withOpacity(0.78),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(_hovered ? 0.22 : 0.16),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(_hovered ? 0.28 : 0.22),
                          ),
                        ),
                        child: Icon(icon, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            height: 1.0,
                          ),
                        ),
                      ),
                      // ✅ subtle hover indicator
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 160),
                        opacity: _hovered ? 1 : 0,
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                // Body (Expanded avoids overflow)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          tr(context, 'total'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF6B7280),
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: widget.number == null
                                  ? _loadingPill(color, active: _hovered)
                                  : Text(
                                '${widget.number}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.cairo(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF111827),
                                  height: 1.0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                          ],
                        ),

                        if (widget.onTap != null) ...[
                          const SizedBox(height: 8),
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 160),
                            opacity: _hovered ? 1 : 0.75,
                            child: Text(
                              tr(context, 'details'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: color,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // UI helpers
  static Widget _loadingPill(Color color, {bool active = false}) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: active ? 94 : 86,
        height: 22,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(999),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                color.withOpacity(active ? 0.16 : 0.12),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  static IconData _iconForKey(String key) {
    if (key.contains('new')) return Icons.fiber_new_rounded;
    if (key.contains('under')) return Icons.work_outline_rounded;
    if (key.contains('arrival')) return Icons.flight_land_rounded;
    if (key.contains('rejected')) return Icons.cancel_rounded;
    if (key.contains('finished')) return Icons.verified_rounded;
    return Icons.groups_rounded;
  }
}
