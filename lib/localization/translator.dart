import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/lang/app_language.dart';
import 'app_strings.dart';

String tr(BuildContext context, String key) {
  final isArabic = context.read<AppLanguage>().isArabic;

  return isArabic
      ? AppStrings.ar[key] ?? key
      : AppStrings.en[key] ?? key;
}

