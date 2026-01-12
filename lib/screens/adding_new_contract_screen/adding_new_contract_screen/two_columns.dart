import 'package:flutter/material.dart';

class TwoColumns extends StatelessWidget {
  final List<Widget> children;

  const TwoColumns({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final maxW = c.maxWidth;

        // 2 columns only if wide enough
        final twoCols = maxW >= 900;
        final spacing = 24.0;

        final itemW = twoCols ? (maxW - spacing) / 2 : maxW;

        return Wrap(
          spacing: spacing,
          runSpacing: 16,
          children: children.map((child) => SizedBox(width: itemW, child: child)).toList(),
        );
      },
    );
  }
}
