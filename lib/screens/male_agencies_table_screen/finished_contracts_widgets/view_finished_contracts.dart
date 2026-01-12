import 'package:flutter/material.dart';
import '../../../models/male_agency.dart';
import 'finished_contracts_data_table.dart';

class FinishedContractsView extends StatelessWidget {
  final List<MaleAgency> items;

  final Future<void> Function() onRefresh;
  final void Function(MaleAgency c) onDetails;
  final Future<void> Function(MaleAgency c) onEdit;

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
        child: FinishedContractsDataTable(
          items: items,
          onDetails: onDetails,
          onEdit: (c) async => onEdit(c),
        ),
      ),
    );
  }
}
