import 'package:babel_final_project/screens/female_contracts_table_screen/female_contracts_table_widgets/female_contracts_labels.dart';
import 'package:babel_final_project/screens/female_contracts_table_screen/female_contracts_table_widgets/table_actions.dart';
import 'package:babel_final_project/screens/female_contracts_table_screen/female_contracts_table_widgets/table_cells.dart';
import 'package:babel_final_project/screens/female_contracts_table_screen/female_contracts_table_widgets/table_chips.dart';
import 'package:babel_final_project/screens/female_contracts_table_screen/female_contracts_table_widgets/table_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../localization/translator.dart';
import '../../../../models/female_contract.dart';

// ✅ نفس Theme اللي في UnderProcess
import '../under_process_widgets/utils/cairo_theme.dart';

class RejectedContractsDataTable extends StatefulWidget {
  final List<FemaleContract> items;
  final void Function(FemaleContract c) onDetails;

  const RejectedContractsDataTable({
    super.key,
    required this.items,
    required this.onDetails,
  });

  @override
  State<RejectedContractsDataTable> createState() =>
      _RejectedContractsDataTableState();
}

class _RejectedContractsDataTableState extends State<RejectedContractsDataTable> {
  static const Color _gridColor = Color(0xFFE5E7EB);

  final TextEditingController _searchCtrl = TextEditingController();

  // ✅ Scrollbars (زي UnderProcess)
  final ScrollController _hCtrl = ScrollController();
  final ScrollController _vCtrl = ScrollController();

  String _query = '';
  final int _rowsPerPage = 10;
  int _page = 0;

  int? _sortColumnIndex;
  bool _sortAscending = true;

  late final TableCells _cells = const TableCells(gridColor: _gridColor);
  late final TableChips _chips = const TableChips();
  late final TableUtils _utils = const TableUtils();

  void _onSort(int index, bool asc) {
    setState(() {
      _sortColumnIndex = index;
      _sortAscending = asc;
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _hCtrl.dispose();
    _vCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
    total == 0 ? <FemaleContract>[] : finalList.sublist(start, end);

    return Theme(
      data: cairoTheme(context),
      child: Column(
        children: [
          // =========================
          // ✅ Pro Toolbar (زي UnderProcess)
          // =========================
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE7ECF4)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() {
                        _query = v;
                        _page = 0;
                      }),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: tr(context, 'search'),
                        prefixIcon: const Icon(Icons.search, size: 18),
                        suffixIcon: _searchCtrl.text.trim().isEmpty
                            ? null
                            : IconButton(
                          tooltip: tr(context, 'close'),
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() {
                              _query = '';
                              _page = 0;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                          const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                          const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Total pill
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.fact_check_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${tr(context, 'entries')}: $total',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // =========================
          // ✅ Table Card (Pro) + Title bar (زي UnderProcess)
          // =========================
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE7ECF4)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // ===== Title bar inside card
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFBFCFE),
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFE7ECF4)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE8E8),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                const Color(0xFFB42318).withOpacity(.15),
                              ),
                            ),
                            child: const Icon(
                              Icons.block_rounded,
                              color: Color(0xFFB42318),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tr(context, 'rejected'),
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${tr(context, 'showing')} ${total == 0 ? 0 : (start + 1)} '
                                      '${tr(context, 'to')} $end ${tr(context, 'of')} $total',
                                  style: GoogleFonts.cairo(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ===== Table body area
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: total == 0
                        ? Center(
                      child: Text(
                        tr(context, 'no_data_available_in_table'),
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    )
                        : Scrollbar(
                      controller: _vCtrl,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: _vCtrl,
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Scrollbar(
                          controller: _hCtrl,
                          thumbVisibility: true,
                          notificationPredicate: (n) =>
                          n.metrics.axis == Axis.horizontal,
                          child: SingleChildScrollView(
                            controller: _hCtrl,
                            scrollDirection: Axis.horizontal,
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                dividerColor: _gridColor,
                                dataTableTheme: DataTableThemeData(
                                  dividerThickness: 1,
                                  headingRowColor:
                                  MaterialStateProperty.all(
                                    const Color(0xFFF8FAFC),
                                  ),
                                  headingTextStyle: GoogleFonts.cairo(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF111827),
                                  ),
                                  dataTextStyle: GoogleFonts.cairo(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF111827),
                                  ),
                                ),
                              ),
                              child: DataTable(
                                showCheckboxColumn: false,
                                sortAscending: _sortAscending,
                                sortColumnIndex: _sortColumnIndex,
                                columnSpacing: 16,
                                horizontalMargin: 14,
                                headingRowHeight: 48,
                                dataRowMinHeight: 54,
                                dataRowMaxHeight: 74,
                                columns: [
                                  DataColumn(
                                    label: _cells.headerCell('#', w: 60),
                                    onSort: (_, a) => _onSort(0, a),
                                  ),
                                  DataColumn(
                                    label: _cells.headerCell(
                                      tr(context, 'name'),
                                      w: 170,
                                    ),
                                    onSort: (_, a) => _onSort(1, a),
                                  ),
                                  DataColumn(
                                    label: _cells.headerCell(
                                      tr(context, 'passport_number'),
                                      w: 150,
                                    ),
                                    onSort: (_, a) => _onSort(2, a),
                                  ),
                                  DataColumn(
                                    label: _cells.headerCell(
                                      tr(context, 'age'),
                                      w: 80,
                                    ),
                                    onSort: (_, a) => _onSort(3, a),
                                  ),
                                  DataColumn(
                                    label: _cells.headerCell(
                                      tr(context, 'sponsor_name'),
                                      w: 170,
                                    ),
                                    onSort: (_, a) => _onSort(4, a),
                                  ),
                                  DataColumn(
                                    label: _cells.headerCell(
                                      tr(context, 'phone'),
                                      w: 140,
                                    ),
                                    onSort: (_, a) => _onSort(5, a),
                                  ),
                                  DataColumn(
                                    label: _cells.headerCell(
                                      tr(context, 'alternative_phone_table'),
                                      w: 160,
                                    ),
                                    onSort: (_, a) => _onSort(6, a),
                                  ),
                                  DataColumn(
                                    label: _cells.headerCell(
                                      tr(context, 'id_number'),
                                      w: 140,
                                    ),
                                    onSort: (_, a) => _onSort(7, a),
                                  ),
                                  DataColumn(
                                    label: _cells.headerCell(
                                      tr(context, 'visa_number'),
                                      w: 140,
                                    ),
                                    onSort: (_, a) => _onSort(8, a),
                                  ),
                                  DataColumn(
                                    label: _cells.headerCell(
                                      tr(context, 'visa_type'),
                                      w: 140,
                                    ),
                                    onSort: (_, a) => _onSort(9, a),
                                  ),
                                  DataColumn(
                                    label: _cells.headerCell(
                                      tr(context, 'contract_number'),
                                      w: 150,
                                    ),
                                    onSort: (_, a) => _onSort(10, a),
                                  ),
                                  DataColumn(
                                    label: _cells.headerCell(
                                      tr(context, 'contract_date'),
                                      w: 140,
                                    ),
                                    onSort: (_, a) => _onSort(11, a),
                                  ),
                                  DataColumn(
                                    label: _cells.headerCell(
                                      tr(context, 'contract_status'),
                                      w: 150,
                                    ),
                                    onSort: (_, a) => _onSort(12, a),
                                  ),
                                  DataColumn(
                                    label: _cells.headerCell(
                                      tr(context, 'salary'),
                                      w: 120,
                                    ),
                                    onSort: (_, a) => _onSort(13, a),
                                  ),
                                  DataColumn(
                                    label: _cells.headerCell(
                                      tr(context, 'religion'),
                                      w: 130,
                                    ),
                                    onSort: (_, a) => _onSort(14, a),
                                  ),
                                  DataColumn(
                                    label: _cells.headerCell(
                                      tr(context, 'experience'),
                                      w: 130,
                                    ),
                                    onSort: (_, a) => _onSort(15, a),
                                  ),
                                  DataColumn(
                                    label: _cells.headerCell(
                                      tr(context, 'approved_'),
                                      w: 150,
                                    ),
                                    onSort: (_, a) => _onSort(16, a),
                                  ),

                                  DataColumn(
                                    label: _cells.headerCell(
                                      tr(context, 'created_at'),
                                      w: 140,
                                    ),
                                    onSort: (_, a) => _onSort(17, a),
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

                                  final zebraBg = (i % 2 == 0)
                                      ? const Color(0xFFFFFFFF)
                                      : const Color(0xFFFBFCFE);

                                  return DataRow(
                                    color: MaterialStateProperty.resolveWith<Color?>(
                                            (states) {
                                          if (states.contains(MaterialState.hovered)) {
                                            return const Color(0xFFF3F7FF);
                                          }
                                          return zebraBg;
                                        }),
                                    cells: [
                                      DataCell(_cells.gridCellText('$index', w: 60)),
                                      DataCell(_cells.gridCellText(c.workerName, w: 170)),
                                      DataCell(_cells.gridCellText(c.passportNumber, w: 150)),
                                      DataCell(_cells.gridCellText('${c.workerAge}', w: 80)),
                                      DataCell(_cells.gridCellText(c.sponsorName, w: 170)),
                                      DataCell(_cells.gridCellText(c.sponsorPhoneNumber, w: 140)),
                                      DataCell(_cells.gridCellText(c.sponsorSecondaryPhoneNumber ?? '-', w: 160)),
                                      DataCell(_cells.gridCellText(c.sponsorIDNumber, w: 140)),
                                      DataCell(_cells.gridCellText(c.visaNumber, w: 140)),
                                      DataCell(_cells.gridCellText(visaTypeLabel(context, c.visaType), w: 140)),
                                      DataCell(_cells.gridCellText(c.contractNumber, w: 150)),
                                      DataCell(_cells.gridCellText(c.contractDate, w: 140)),

                                      DataCell(
                                        _cells.gridCellWidget(
                                          _chips.statusChip(context, c.contractStatus),
                                          w: 150,
                                        ),
                                      ),

                                      DataCell(_cells.gridCellText('${c.salary}', w: 120)),
                                      DataCell(_cells.gridCellText(religionLabel(context, c.religion), w: 130)),

                                      DataCell(
                                        _cells.gridCellWidget(
                                          _chips.yesNoChip(
                                            value: c.experienced,
                                            yesText: tr(context, 'experience_yes'),
                                            noText: tr(context, 'experience_no'),
                                          ),
                                          w: 130,
                                        ),
                                      ),

                                      DataCell(
                                        _cells.gridCellWidget(
                                          _chips.yesNoChip(
                                            value: c.approved,
                                            yesText: tr(context, 'yes'),
                                            noText: tr(context, 'no'),
                                          ),
                                          w: 150,
                                        ),
                                      ),


                                      DataCell(_cells.gridCellText(formatCreatedAt(c.createdAt), w: 140)),

                                      // ✅ Actions
                                      DataCell(
                                        _cells.gridCellWidget(
                                          TableActions(
                                            onDetails: () => widget.onDetails(c),
                                            tDetails: tr(context, 'details'),
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
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // =========================
          // ✅ Pagination footer (Pro)
          // =========================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE7ECF4)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${tr(context, 'showing')} ${total == 0 ? 0 : (start + 1)} '
                        '${tr(context, 'to')} $end ${tr(context, 'of')} $total '
                        '${tr(context, 'entries')}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _page <= 0 ? null : () => setState(() => _page--),
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  '${_page + 1} / $totalPages',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
                ),
                IconButton(
                  onPressed: (_page + 1) >= totalPages
                      ? null
                      : () => setState(() => _page++),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _dateOrDash(String? s) {
    if (s == null) return '-';
    final t = s.trim();
    return t.isEmpty ? '-' : t;
  }
}
