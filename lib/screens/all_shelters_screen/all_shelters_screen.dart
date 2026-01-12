import 'package:flutter/material.dart';

import 'all_shelters_screen_widgets/all_shelters_grid_widget.dart';
import 'all_shelters_screen_widgets/all_shelters_screen_header.dart';

class AllSheltersScreen extends StatefulWidget {
  final BoxConstraints constraints;
  final VoidCallback onAwaitingDeliveryTap;

  const AllSheltersScreen({super.key, required this.constraints, required this.onAwaitingDeliveryTap});

  @override
  State<AllSheltersScreen> createState() => _AllSheltersScreenState();
}

class _AllSheltersScreenState extends State<AllSheltersScreen> {

  @override
  Widget build(BuildContext context) {

    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Column(
          children: [
            AllSheltersScreenHeader(),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: AllSheltersGridWidget(maxWidth: widget.constraints.maxWidth, onAwaitingDeliveryTap: widget.onAwaitingDeliveryTap,),
            )
          ],
        ),
      ),
    );
  }
}
