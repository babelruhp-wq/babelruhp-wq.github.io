import 'package:flutter/material.dart';
import '../../../models/female_contract.dart';
import '../female_contracts_table_widgets/female_contracts_data_table.dart';

class FinishedContractsView extends StatelessWidget {
  final List<FemaleContract> items;

  final Future<void> Function() onRefresh;
  final void Function(FemaleContract c) onDetails;
  final Future<void> Function(FemaleContract c) onEdit;

  const FinishedContractsView({
    super.key,
    required this.items,
    required this.onRefresh,
    required this.onDetails,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: FemaleContractsDataTable(
          items: items,
          onDetails: onDetails,
          onEdit: (c) async => onEdit(c),
        ),
      ),
    );
  }
}
