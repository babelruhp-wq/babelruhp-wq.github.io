import 'package:flutter/material.dart';
import 'office_male_agencies_details_card_widget.dart';

class OfficeMaleAgenciesDetailsGridWidget extends StatelessWidget {
  final double maxWidth;
  final List<dynamic> allDetails;
  final void Function(String nameKey) onCardTap;

  final Map<String, int> counts;
  final bool loading;

  const OfficeMaleAgenciesDetailsGridWidget({
    super.key,
    required this.maxWidth,
    required this.allDetails,
    required this.onCardTap,
    this.counts = const {},
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final gridCount = maxWidth >= 1200
        ? 3
        : maxWidth >= 800
        ? 2
        : 1;

    return GridView.builder(
      // ✅ مهم جدًا لأنه داخل ListView
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),

      itemCount: allDetails.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: 140,
      ),
      itemBuilder: (context, index) {
        final raw = allDetails[index];
        final item = Map<String, dynamic>.from(raw as Map);

        final nameKey = (item['nameKey'] ?? '').toString();
        final number = counts[nameKey] ?? 0;

        return InkWell(
          onTap: nameKey.isEmpty ? null : () => onCardTap(nameKey),
          child: OfficeMaleAgenciesDetailsCardWidget(
            item: item,
            number: loading ? null : number,
          ),
        );
      },
    );
  }
}
