import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData cairoTheme(BuildContext context) {
  final base = Theme.of(context);
  return base.copyWith(
    textTheme: GoogleFonts.cairoTextTheme(base.textTheme),
    primaryTextTheme: GoogleFonts.cairoTextTheme(base.primaryTextTheme),
  );
}
