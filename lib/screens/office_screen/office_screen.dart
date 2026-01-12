import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../localization/translator.dart';
import '../../models/office.dart';
import 'office_screen_widgets/office_details_app_bar.dart';

class OfficeDetailsScreen extends StatefulWidget {
  final double maxWidth;
  final Office office;

  final VoidCallback onBack;

  // ✅ تنقل لعقود نسائية
  final VoidCallback onFemaleTap;

  // ✅ تنقل لوكالات رجالية
  final VoidCallback onMaleTap;

  const OfficeDetailsScreen({
    super.key,
    required this.maxWidth,
    required this.office,
    required this.onBack,
    required this.onFemaleTap,
    required this.onMaleTap,
  });

  @override
  State<OfficeDetailsScreen> createState() => _OfficeDetailsScreenState();
}

class _OfficeDetailsScreenState extends State<OfficeDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OfficeDetailsAppBar(
        officeName: widget.office.officeName,
        onBack: widget.onBack,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWeb = constraints.maxWidth >= 800;
            final pad = EdgeInsets.all(isWeb ? 24 : 16);

            return Padding(
              padding: pad,
              child: Align(
                alignment: Alignment.topCenter,
                child: _OfficeHomeTwoCards(
                  maxWidth: widget.maxWidth,
                  onFemaleTap: widget.onFemaleTap,
                  onMaleTap: widget.onMaleTap,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OfficeHomeTwoCards extends StatelessWidget {
  final double maxWidth;
  final VoidCallback onFemaleTap;
  final VoidCallback onMaleTap;

  const _OfficeHomeTwoCards({
    required this.maxWidth,
    required this.onFemaleTap,
    required this.onMaleTap,
  });

  @override
  Widget build(BuildContext context) {
    final isWeb = maxWidth >= 800;

    // ✅ لو مفاتيحك مختلفة في الترجمة بدّلها
    final femaleTitle = tr(context, 'female_contracts');
    final femaleSub = tr(context, 'open_female_contracts');

    final maleTitle = tr(context, 'male_agencies');
    final maleSub = tr(context, 'open_male_agencies');

    final gap = isWeb ? 16.0 : 12.0;

    if (isWeb) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: _PremiumActionCard(
              title: femaleTitle,
              subtitle: femaleSub,
              icon: Icons.assignment_rounded,
              theme: _CardTheme.green,
              onTap: onFemaleTap,
              height: 170,
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            flex: 2,
            child: _PremiumActionCard(
              title: maleTitle,
              subtitle: maleSub,
              icon: Icons.groups_rounded,
              theme: _CardTheme.navy,
              onTap: onMaleTap,
              height: 170,
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _PremiumActionCard(
          title: femaleTitle,
          subtitle: femaleSub,
          icon: Icons.assignment_rounded,
          theme: _CardTheme.green,
          onTap: onFemaleTap,
          height: 150,
        ),
        SizedBox(height: gap),
        _PremiumActionCard(
          title: maleTitle,
          subtitle: maleSub,
          icon: Icons.groups_rounded,
          theme: _CardTheme.navy,
          onTap: onMaleTap,
          height: 150,
        ),
      ],
    );
  }
}

/// =======================
/// Premium Card (UI only)
/// =======================
enum _CardTheme { green, navy }

class _PremiumActionCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final _CardTheme theme;
  final VoidCallback onTap;
  final double height;

  const _PremiumActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.theme,
    required this.onTap,
    required this.height,
  });

  @override
  State<_PremiumActionCard> createState() => _PremiumActionCardState();
}

class _PremiumActionCardState extends State<_PremiumActionCard> {
  bool _hover = false;

  List<Color> get _gradient {
    switch (widget.theme) {
      case _CardTheme.green:
        return const [Color(0xff86C84A), Color(0xff4C9A2A)];
      case _CardTheme.navy:
        return const [Color(0xff3D4669), Color(0xff2B3250)];
    }
  }

  Color get _accentGlow {
    switch (widget.theme) {
      case _CardTheme.green:
        return const Color(0xff7fb841);
      case _CardTheme.navy:
        return const Color(0xff394263);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width >= 800;

    return MouseRegion(
      onEnter: (_) {
        if (!isWeb) return;
        setState(() => _hover = true);
      },
      onExit: (_) {
        if (!isWeb) return;
        setState(() => _hover = false);
      },
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..translate(0.0, _hover ? -2.0 : 0.0),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: widget.onTap, // ✅ نفس الآلية
            child: Container(
              height: widget.height,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _gradient,
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.16),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _accentGlow.withOpacity(_hover ? 0.25 : 0.18),
                    blurRadius: _hover ? 24 : 18,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // 🔆 subtle highlight
                  Positioned(
                    top: -40,
                    right: -30,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.10),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -50,
                    left: -40,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      // Icon glass
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.18),
                          ),
                        ),
                        child: Icon(
                          widget.icon,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.92),
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Arrow pill
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.16),
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Colors.white.withOpacity(0.90),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
