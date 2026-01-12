import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../localization/translator.dart';
import '../../../models/country_office_stats.dart';

class CountryOfficeStat {
  final String countryName;
  final int officesCount;

  CountryOfficeStat({
    required this.countryName,
    required this.officesCount,
  });
}

class ExternalOfficesBarCard extends StatelessWidget {
  final List<CountryOfficeStats> stats;

  const ExternalOfficesBarCard({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (stats.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxY =
        stats.map((e) => e.officesCount).reduce((a, b) => a > b ? a : b) + 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// العنوان
          Text(
            tr(context, 'external_offices'),
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          /// Bar Chart
          SizedBox(
            height: 260,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY.toDouble(),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 1,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) =>
                          _bottomTitle(value, meta,isArabic),
                    ),
                  ),
                ),
                barGroups: _barGroups(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 الأعمدة
  List<BarChartGroupData> _barGroups() {
    return List.generate(stats.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: stats[i].officesCount.toDouble(),
            width: 22,
            borderRadius: BorderRadius.circular(4),
            color: Colors.blueAccent,
          ),
        ],
      );
    });
  }

  /// 🔹 أسماء الدول تحت
  Widget _bottomTitle(double value, TitleMeta meta,isArabic) {
    final index = value.toInt();
    if (index < 0 || index >= stats.length) {
      return const SizedBox.shrink();
    }

    return SideTitleWidget(
      meta: meta,
      space: 6,
      child: Text(
        isArabic
            ? stats[index].nameAr
            : stats[index].nameEn
        ,
        style: GoogleFonts.cairo(fontSize: 10),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
