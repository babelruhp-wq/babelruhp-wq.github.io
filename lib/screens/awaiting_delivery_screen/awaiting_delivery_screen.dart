import 'package:flutter/material.dart';

import 'awaiting_delivery_screen_widgets/awaiting_delivery_appbar.dart';
import 'awaiting_delivery_screen_widgets/awaiting_delivery_table.dart';

class AwaitingDeliveryScreen extends StatefulWidget {
  final VoidCallback onBack;


  const AwaitingDeliveryScreen({super.key, required this.onBack});

  @override
  State<AwaitingDeliveryScreen> createState() => _AwaitingDeliveryScreenState();
}

class _AwaitingDeliveryScreenState extends State<AwaitingDeliveryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AwaitingDeliveryAppbar(
        onBack: widget.onBack,
      ),
      body: SingleChildScrollView(child: AwaitingDeliveryTable()),
    );
  }
}
