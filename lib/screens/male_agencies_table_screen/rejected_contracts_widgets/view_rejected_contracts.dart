import 'package:babel_final_project/screens/male_agencies_table_screen/rejected_contracts_widgets/rejected_contracts_data_table.dart';
import 'package:flutter/material.dart';
import '../../../models/male_agency.dart';

class RejectedContractsView extends StatelessWidget {
  final List<MaleAgency> items;

  final Future<void> Function() onRefresh;
  final void Function(MaleAgency c) onDetails;

  const RejectedContractsView({
    super.key,
    required this.items,
    required this.onRefresh,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: RejectedContractsDataTable(
          items: items,
          onDetails: onDetails,
        ),
      ),
    );
  }
}
