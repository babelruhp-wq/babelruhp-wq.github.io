import 'package:babel_final_project/screens/female_contracts_table_screen/new_contracts_widgets/new_contracts_data_table.dart';
import 'package:flutter/material.dart';
import '../../../models/female_contract.dart';

class NewContractsView extends StatelessWidget {
  final List<FemaleContract> items;

  final Future<void> Function() onRefresh;
  final void Function(FemaleContract c) onDetails;

  // ✅ NEW actions
  final Future<void> Function(FemaleContract c, String note) onUpdateNote;
  final Future<void> Function(FemaleContract c, DateTime approvalDate) onApprove;
  final Future<void> Function(FemaleContract c, int cancelationBy, String reason) onCancel;

  const NewContractsView({
    super.key,
    required this.items,
    required this.onRefresh,
    required this.onDetails,
    required this.onUpdateNote,
    required this.onApprove,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: NewContractsDataTable(
          items: items,
          onDetails: onDetails,
          onUpdateNote: onUpdateNote,
          onApprove: onApprove,
          onCancel: onCancel,
        ),
      ),
    );
  }
}
