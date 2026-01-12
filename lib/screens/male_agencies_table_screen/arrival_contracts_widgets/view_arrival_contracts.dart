import 'package:flutter/material.dart';
import '../../../models/male_agency.dart';
import 'arrival_contracts_data_table.dart';

class ArrivalContractsView extends StatelessWidget {
  final List<MaleAgency> items;

  final Future<void> Function() onRefresh;
  final void Function(MaleAgency c) onDetails;
  final Future<void> Function(MaleAgency c) onEdit;

  const ArrivalContractsView({
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
        child: ArrivalContractsDataTable(
          items: items,
          onDetails: onDetails,
          onEdit: (c) async => onEdit(c),
        ),
      ),
    );
  }
}
