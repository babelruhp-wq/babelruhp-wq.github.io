import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FemaleContractsTableAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onBack;

  /// optional actions (مثل زر refresh / add)
  final List<Widget> actions;

  const FemaleContractsTableAppbar({
    super.key,
    required this.title,
    required this.onBack,
    this.actions = const [],
  });

  @override
  Size get preferredSize => const Size.fromHeight(120);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: preferredSize.height,
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black12),
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
              // Back
              InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 20,
                    color: Color(0xff3a4262),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Accent bar
              Container(
                width: 4,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xff3a4262),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              const SizedBox(width: 14),

              // Title
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xff2c334a),
                  ),
                ),
              ),

              if (actions.isNotEmpty) ...[
                const SizedBox(width: 8),
                Row(children: actions),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
