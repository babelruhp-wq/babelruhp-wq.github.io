import 'package:flutter/material.dart';
import '../../../models/female_contract.dart';
import 'under_process_contracts_data_table.dart';

class UnderProcessContractsView extends StatelessWidget {
  final List<FemaleContract> items;

  final Future<void> Function() onRefresh;
  final void Function(FemaleContract c) onDetails;

  // ✅ ملاحظة
  final Future<void> Function(FemaleContract c, String note) onUpdateNote;

  // ✅ إلغاء
  final Future<void> Function(FemaleContract c, int cancelationBy, String reason) onCancel;

  // ✅ تواريخ
  final Future<void> Function(FemaleContract c, DateTime stampedDate) onSetStampedDate;
  final Future<void> Function(FemaleContract c, DateTime flightTicketDate) onSetFlightTicketDate;
  final Future<void> Function(FemaleContract c, DateTime arrivalDate) onSetArrivalDate;

  const UnderProcessContractsView({
    super.key,
    required this.items,
    required this.onRefresh,
    required this.onDetails,
    required this.onUpdateNote,
    required this.onCancel,
    required this.onSetStampedDate,
    required this.onSetFlightTicketDate,
    required this.onSetArrivalDate,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: UnderProcessContractsDataTable(
          items: items,
          onDetails: onDetails,
          onUpdateNote: onUpdateNote,
          onCancel: onCancel,
          onSetStampedDate: onSetStampedDate,
          onSetFlightTicketDate: onSetFlightTicketDate,
          onSetArrivalDate: onSetArrivalDate,
        ),
      ),
    );
  }
}
