import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../localization/translator.dart';
import '../../../models/office.dart';
import '../../../models/office_female_stats.dart';

class OfficeExternalOfficesBarCard extends StatelessWidget {
  final List<Office> offices;

  /// ✅ الإحصائيات الفعلية لكل مكتب
  /// key = officeId
  final Map<String, OfficeFemaleStats> femaleStatsByOffice;

  /// ✅ تحميل الإحصائيات (اختياري)
  final bool isLoading;

  const OfficeExternalOfficesBarCard({
    super.key,
    required this.offices,
    required this.femaleStatsByOffice,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (offices.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          tr(context, 'no_offices_for_country'),
          style: GoogleFonts.cairo(fontSize: 14),
        ),
      );
    }

    // احسب أعلى قيمة في الرسم
    int maxValue = 1;
    for (final o in offices) {
      final s = femaleStatsByOffice[o.officeId];
      final total = s?.total ?? 0;
      final under = s?.underProcess ?? 0;
      maxValue = math.max(maxValue, math.max(total, under));
    }

    final maxY = (maxValue + 1).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===== Title + Loading =====
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1BBAE1).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF1BBAE1).withOpacity(0.22),
                      ),
                    ),
                    child: const Icon(
                      Icons.bar_chart_rounded,
                      size: 18,
                      color: Color(0xFF1BBAE1),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tr(context, 'statistics'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tr(context, 'overview'), // لو مش موجودة خليه نص ثابت
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.black.withOpacity(0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
            ,
            if (isLoading)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),

        const SizedBox(height: 10),

        // ===== Legend =====
        Wrap(
          spacing: 14,
          runSpacing: 8,
          children: [
            _legendItem(
              color: Colors.blueAccent,
              text: tr(context, 'total_maids'), // ✅ أضفها في الترجمة لو مش موجودة
            ),
            _legendItem(
              color: Colors.redAccent,
              text: tr(context, 'under_process'), // ✅ أضفها في الترجمة لو مش موجودة
            ),
          ],
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 280,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
              ),
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
                    reservedSize: 34,
                    interval: maxY <= 10 ? 1 : (maxY / 5).ceilToDouble(),
                    getTitlesWidget: (v, meta) => Text(
                      v.toInt().toString(),
                      style: GoogleFonts.cairo(fontSize: 10),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (value, meta) => _bottomTitle(context, value, meta),
                  ),
                ),
              ),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBorderRadius: BorderRadius.all(Radius.circular(10)),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final office = offices[group.x.toInt()];
                    final s = femaleStatsByOffice[office.officeId];
                    final total = s?.total ?? 0;
                    final under = s?.underProcess ?? 0;

                    final isTotal = rodIndex == 0;
                    final title = isTotal
                        ? tr(context, 'total_maids')
                        : tr(context, 'under_process');
                    final value = isTotal ? total : under;

                    return BarTooltipItem(
                      '${office.officeName}\n$title: $value',
                      GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
              barGroups: _barGroups(context),
              groupsSpace: 18,
            ),
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _barGroups(BuildContext context) {
    return List.generate(offices.length, (i) {
      final office = offices[i];
      final s = femaleStatsByOffice[office.officeId];

      final total = (s?.total ?? 0).toDouble();
      final under = (s?.underProcess ?? 0).toDouble();

      return BarChartGroupData(
        x: i,
        barsSpace: 8,
        barRods: [
          // ✅ Total
          BarChartRodData(
            toY: total,
            width: 12,
            borderRadius: BorderRadius.circular(6),
            color: Colors.blueAccent,
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: math.max(total, under) + 1,
              color: Colors.black12.withOpacity(0.06),
            ),
          ),

          // ✅ Under Process
          BarChartRodData(
            toY: under,
            width: 12,
            borderRadius: BorderRadius.circular(6),
            color: Colors.redAccent,
          ),
        ],
      );
    });
  }

  Widget _bottomTitle(BuildContext context, double value, TitleMeta meta) {
    final index = value.toInt();
    if (index < 0 || index >= offices.length) return const SizedBox.shrink();

    final name = offices[index].officeName;

    return SideTitleWidget(
      meta: meta,
      space: 6,
      child: SizedBox(
        width: 70,
        child: Text(
          name,
          style: GoogleFonts.cairo(fontSize: 10),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
      ),
    );
  }

  Widget _legendItem({required Color color, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
