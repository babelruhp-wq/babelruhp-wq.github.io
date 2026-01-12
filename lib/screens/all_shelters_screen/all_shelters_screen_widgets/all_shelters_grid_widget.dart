import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import 'all_shelters_card_widget.dart';


class AllSheltersGridWidget extends StatelessWidget {
  final double maxWidth;
  final VoidCallback onAwaitingDeliveryTap;


  const AllSheltersGridWidget({
    super.key,
    required this.maxWidth, required this.onAwaitingDeliveryTap,
  });

  @override
  Widget build(BuildContext context) {
    int gridCount = maxWidth >= 1200
        ? 3
        : maxWidth >= 800
        ? 2
        : 1;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: allShelters.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: 140,
      ),
      itemBuilder: (context, index) {
        return AllSheltersCardWidget(item: allShelters[index], onAwaitingDeliveryTap: onAwaitingDeliveryTap, index: index,);
      },
    );
  }
}
