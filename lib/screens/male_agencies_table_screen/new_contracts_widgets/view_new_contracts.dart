import 'package:babel_final_project/screens/male_agencies_table_screen/new_contracts_widgets/new_contracts_data_table.dart';
import 'package:flutter/material.dart';
import '../../../models/male_agency.dart';

class NewContractsView extends StatelessWidget {
  final List<MaleAgency> items;

  final Future<void> Function() onRefresh;
  final void Function(MaleAgency c) onDetails;

  // ✅ NEW actions
  final Future<void> Function(MaleAgency c, String note) onUpdateNote;
  final Future<void> Function(MaleAgency c, DateTime approvalDate) onApprove;
  final Future<void> Function(MaleAgency c, int cancelationBy, String reason) onCancel;

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
