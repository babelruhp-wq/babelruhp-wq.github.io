import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../localization/translator.dart';
import '../../../models/male_agency.dart';
import '../male_agencies_table_widgets/male_agencies_labels.dart';
import '../male_agencies_table_widgets/table_actions.dart';
import '../male_agencies_table_widgets/table_cells.dart';
import '../male_agencies_table_widgets/table_chips.dart';
import '../male_agencies_table_widgets/table_utils.dart';


class ArrivalContractsDataTable extends StatefulWidget {
  final List<MaleAgency> items;
  final void Function(MaleAgency c) onDetails;
  final Future<void> Function(MaleAgency c) onEdit;

  const ArrivalContractsDataTable({
    super.key,
    required this.items,
    required this.onDetails,
    required this.onEdit,
  });

  @override
  State<ArrivalContractsDataTable> createState() =>
      _ArrivalContractsDataTableState();
}

class _ArrivalContractsDataTableState extends State<ArrivalContractsDataTable> {
  final TextEditingController _searchCtrl = TextEditingController();

  String _query = '';
  int _rowsPerPage = 10;
  int _page = 0;

  int? _sortColumnIndex;
  bool _sortAscending = true;

  static const Color _gridColor = Colors.black12;

  late final TableCells _cells = const TableCells(gridColor: _gridColor);
  late final TableChips _chips = const TableChips();
  late final TableUtils _utils = const TableUtils();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSort(int index, bool asc) {
    setState(() {
      _sortColumnIndex = index;
      _sortAscending = asc;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Cairo everywhere inside this widget (toolbar + table + footer)
    final base = Theme.of(context);
    final themed = base.copyWith(
      textTheme: GoogleFonts.cairoTextTheme(base.textTheme),
      primaryTextTheme: GoogleFonts.cairoTextTheme(base.primaryTextTheme),
    );

    final searched = _utils.applySearch(widget.items, _query);
    final finalList = _utils.applySort(
      list: searched,
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
    );

    final total = finalList.length;
    final totalPages = total == 0 ? 1 : ((total - 1) ~/ _rowsPerPage) + 1;

    if (_page >= totalPages) _page = totalPages - 1;
    if (_page < 0) _page = 0;

    final start = total == 0 ? 0 : _page * _rowsPerPage;
    final end = total == 0 ? 0 : (start + _rowsPerPage).clamp(0, total);

    final pageItems =
    total == 0 ? <MaleAgency>[] : finalList.sublist(start, end);

    return Theme(
      data: themed,
      child: Column(
        children: [
          // ===== Toolbar =====
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Text(tr(context, 'show')),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _rowsPerPage,
                  items: const [
                    DropdownMenuItem(value: 10, child: Text('10')),
                    DropdownMenuItem(value: 25, child: Text('25')),
                    DropdownMenuItem(value: 50, child: Text('50')),
                    DropdownMenuItem(value: 100, child: Text('100')),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      _rowsPerPage = v;
                      _page = 0;
                    });
                  },
                ),
                const SizedBox(width: 8),
                Text(tr(context, 'entries')),
                const Spacer(),
                SizedBox(
                  width: 320,
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() {
                      _query = v;
                      _page = 0;
                    }),
                    decoration: InputDecoration(
                      isDense: true,
                      prefixIcon: const Icon(Icons.search, size: 18),
                      hintText: tr(context, 'search'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ===== Table =====
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: total == 0
                  ? Center(child: Text(tr(context, 'no_data_available_in_table')))
                  : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: _gridColor,
                      dataTableTheme: const DataTableThemeData(
                        dividerThickness: 2, // ✅ Grid lines
                      ),
                    ),
                    child: DataTable(
                      sortAscending: _sortAscending,
                      sortColumnIndex: _sortColumnIndex,
                      columnSpacing: 0,
                      horizontalMargin: 0,
                      headingRowHeight: 46,
                      dataRowMinHeight: 52,
                      dataRowMaxHeight: 62,
                      columns: [
                        DataColumn(
                          label: _cells.headerCell('#', w: 60),
                          onSort: (_, a) => _onSort(0, a),
                        ),
                        DataColumn(
                          label: _cells.headerCell(tr(context, 'name')),
                          onSort: (_, a) => _onSort(1, a),
                        ),
                        DataColumn(
                          label: _cells.headerCell(tr(context, 'passport_number')),
                          onSort: (_, a) => _onSort(2, a),
                        ),
                        DataColumn(
                          label: _cells.headerCell(tr(context, 'age'), w: 80),
                          onSort: (_, a) => _onSort(3, a),
                        ),
                        DataColumn(
                          label: _cells.headerCell(tr(context, 'sponsor_name')),
                          onSort: (_, a) => _onSort(4, a),
                        ),
                        DataColumn(
                          label: _cells.headerCell(tr(context, 'phone')),
                          onSort: (_, a) => _onSort(5, a),
                        ),
                        DataColumn(
                          label: _cells.headerCell(tr(context, 'alternative_phone_table')),
                          onSort: (_, a) => _onSort(6, a),
                        ),
                        DataColumn(
                          label: _cells.headerCell(tr(context, 'id_number')),
                          onSort: (_, a) => _onSort(7, a),
                        ),
                        DataColumn(
                          label: _cells.headerCell(tr(context, 'visa_number')),
                          onSort: (_, a) => _onSort(8, a),
                        ),
                        DataColumn(
                          label: _cells.headerCell(tr(context, 'visa_type')),
                          onSort: (_, a) => _onSort(9, a),
                        ),
                        DataColumn(
                          label: _cells.headerCell(tr(context, 'contract_number')),
                          onSort: (_, a) => _onSort(10, a),
                        ),
                        DataColumn(
                          label: _cells.headerCell(tr(context, 'contract_date')),
                          onSort: (_, a) => _onSort(11, a),
                        ),
                        DataColumn(
                          label: _cells.headerCell(tr(context, 'contract_status')),
                          onSort: (_, a) => _onSort(12, a),
                        ),
                        DataColumn(
                          label: _cells.headerCell(tr(context, 'salary')),
                          onSort: (_, a) => _onSort(13, a),
                        ),
                        DataColumn(
                          label: _cells.headerCell(tr(context, 'religion')),
                          onSort: (_, a) => _onSort(14, a),
                        ),
                        DataColumn(
                          label: _cells.headerCell(tr(context, 'experience')),
                          onSort: (_, a) => _onSort(15, a),
                        ),
                        DataColumn(
                          label: _cells.headerCell(tr(context, 'approved_')),
                          onSort: (_, a) => _onSort(16, a),
                        ),
                        DataColumn(
                          label: _cells.headerCell(tr(context, 'approval_date')),
                          onSort: (_, a) => _onSort(17, a),
                        ),
                        DataColumn(
                          label: _cells.headerCell(tr(context, 'stamped_date')),
                          onSort: (_, a) => _onSort(18, a),
                        ),
                        DataColumn(
                          label: _cells.headerCell(tr(context, 'flight_ticket_date')),
                          onSort: (_, a) => _onSort(19, a),
                        ),
                        DataColumn(
                          label: _cells.headerCell(tr(context, 'arrival_date')),
                          onSort: (_, a) => _onSort(20, a),
                        ),
                        DataColumn(
                          label: _cells.headerCell(tr(context, 'notes_table')),
                          onSort: (_, a) => _onSort(21, a),
                        ),
                        DataColumn(
                          label: _cells.headerCell(tr(context, 'created_at')),
                          onSort: (_, a) => _onSort(22, a),
                        ),
                        DataColumn(
                          label: _cells.headerCell(
                            tr(context, 'actions'),
                            w: 240,
                            last: true,
                          ),
                        ),
                      ],
                      rows: List.generate(pageItems.length, (i) {
                        final c = pageItems[i];
                        final index = start + i + 1;

                        return DataRow(
                          cells: [
                            DataCell(_cells.gridCellText('$index', w: 60)),
                            DataCell(_cells.gridCellText(c.workerName)),
                            DataCell(_cells.gridCellText(c.passportNumber)),
                            DataCell(_cells.gridCellText('${c.workerAge}', w: 80)),
                            DataCell(_cells.gridCellText(c.sponsorName)),
                            DataCell(_cells.gridCellText(c.sponsorPhoneNumber)),
                            DataCell(_cells.gridCellText(c.sponsorSecondaryPhoneNumber ?? '-')),
                            DataCell(_cells.gridCellText(c.sponsorIDNumber)),
                            DataCell(_cells.gridCellText(c.visaNumber)),
                            DataCell(_cells.gridCellText(visaTypeLabel(context, c.visaType))),
                            DataCell(_cells.gridCellText(c.contractNumber)),
                            DataCell(_cells.gridCellText(c.contractDate)),

                            // ✅ Contract status chip
                            DataCell(
                              _cells.gridCellWidget(
                                _chips.statusChip(context, c.contractStatus),
                              ),
                            ),

                            DataCell(_cells.gridCellText('${c.salary}')),
                            DataCell(_cells.gridCellText(religionLabel(context, c.religion))),

                            // ✅ Experience chip
                            DataCell(
                              _cells.gridCellWidget(
                                _chips.yesNoChip(
                                  value: c.experienced,
                                  yesText: tr(context, 'experience_yes'),
                                  noText: tr(context, 'experience_no'),
                                ),
                              ),
                            ),

                            // ✅ Approved chip
                            DataCell(
                              _cells.gridCellWidget(
                                _chips.yesNoChip(
                                  value: c.approved,
                                  yesText: tr(context, 'yes'),
                                  noText: tr(context, 'no'),
                                ),
                              ),
                            ),

                            DataCell(_cells.gridCellText(c.approvalDate ?? '-')),
                            DataCell(_cells.gridCellText(c.stamped ?? '-')),
                            DataCell(_cells.gridCellText(c.flightTicketDate ?? '-')),
                            DataCell(_cells.gridCellText(c.arrivalDate ?? '-')),
                            DataCell(
                              _cells.gridCellText(
                                (c.notes == null || c.notes!.trim().isEmpty)
                                    ? '-'
                                    : c.notes!,
                              ),
                            ),
                            DataCell(_cells.gridCellText(formatCreatedAt(c.createdAt))),

                            // ✅ Actions
                            DataCell(
                              _cells.gridCellWidget(
                                TableActions(
                                  onDetails: () => widget.onDetails(c),
                                  onEdit: () async => await widget.onEdit(c),
                                  tDetails: tr(context, 'details'),
                                  tEdit: tr(context, 'edit'),
                                ),
                                w: 240,
                                last: true,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ===== Pagination footer =====
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Text(
                    '${tr(context, 'showing')} ${total == 0 ? 0 : (start + 1)} ${tr(context, 'to')} $end ${tr(context, 'of')} $total ${tr(context, 'entries')}',
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _page <= 0
                        ? null
                        : () => setState(() {
                      _page--;
                    }),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text('${_page + 1} / $totalPages'),
                  IconButton(
                    onPressed: (_page + 1) >= totalPages
                        ? null
                        : () => setState(() {
                      _page++;
                    }),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
