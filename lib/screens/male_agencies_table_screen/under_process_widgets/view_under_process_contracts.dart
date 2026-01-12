import 'package:flutter/material.dart';
import '../../../models/male_agency.dart';
import 'under_process_contracts_data_table.dart';

class UnderProcessContractsView extends StatelessWidget {
  final List<MaleAgency> items;

  final Future<void> Function() onRefresh;
  final void Function(MaleAgency c) onDetails;

  // ✅ ملاحظة
  final Future<void> Function(MaleAgency c, String note) onUpdateNote;

  // ✅ إلغاء
  final Future<void> Function(MaleAgency c, int cancelationBy, String reason) onCancel;

  // ✅ تواريخ
  final Future<void> Function(MaleAgency c, DateTime stampedDate) onSetStampedDate;
  final Future<void> Function(MaleAgency c, DateTime flightTicketDate) onSetFlightTicketDate;
  final Future<void> Function(MaleAgency c, DateTime arrivalDate) onSetArrivalDate;

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
