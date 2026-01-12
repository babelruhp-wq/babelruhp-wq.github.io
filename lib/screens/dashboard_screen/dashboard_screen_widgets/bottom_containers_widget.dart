import 'package:flutter/material.dart';

import '../../../models/country_office_stats.dart';
import 'external_offices_bar_card.dart';

class BottomContainersWidget extends StatelessWidget {
  final bool isWeb;
  final List<CountryOfficeStats> countryOfficeStats;

  const BottomContainersWidget({
    super.key,
    required this.isWeb,
    required this.countryOfficeStats,
  });

  @override
  Widget build(BuildContext context) {

    return ExternalOfficesBarCard(stats: countryOfficeStats);
  }
}
