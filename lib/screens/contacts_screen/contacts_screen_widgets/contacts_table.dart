import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../features/contacts/contacts_cubit.dart';
import '../../../features/contacts/contacts_state.dart';
import '../../../localization/translator.dart';
import '../../female_contracts_table_screen/female_contracts_table_widgets/table_cells.dart';

class ContactsTable extends StatefulWidget {
  const ContactsTable({super.key});

  @override
  State<ContactsTable> createState() => _ContactsTableState();
}

class _ContactsTableState extends State<ContactsTable> {
  static const Color _gridColor = Color(0xFFE5E7EB);
  final TableCells _cells = const TableCells(gridColor: _gridColor);

  final _searchCtrl = TextEditingController();
  final ScrollController _hCtrl = ScrollController();
  final ScrollController _vCtrl = ScrollController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    _hCtrl.dispose();
    _vCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Cairo for whole widget tree
    final base = Theme.of(context);
    final themed = base.copyWith(
      textTheme: GoogleFonts.cairoTextTheme(base.textTheme),
      primaryTextTheme: GoogleFonts.cairoTextTheme(base.primaryTextTheme),
    );

    return Theme(
      data: themed,
      child: BlocBuilder<ContactsCubit, ContactsState>(
        builder: (context, state) {
          final cubit = context.read<ContactsCubit>();

          final total = state.totalCount;
          final page = state.page;
          final size = state.pageSize;

          final start = total == 0 ? 0 : ((page - 1) * size) + 1;
          final end = min(page * size, total);
          final maxPage = (total / size).ceil().clamp(1, 999999);

          return Column(
            children: [
              // ✅ Toolbar
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
                          onChanged: (v) => cubit.setQuery(v),
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF111827),
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: tr(context, 'search'),
                            hintStyle: GoogleFonts.cairo(
                              color: const Color(0xFF6B7280),
                              fontWeight: FontWeight.w700,
                            ),
                            prefixIcon: const Icon(Icons.search, size: 18),
                            suffixIcon: _searchCtrl.text.trim().isEmpty
                                ? null
                                : IconButton(
                              tooltip: tr(context, 'close'),
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () {
                                _searchCtrl.clear();
                                cubit.setQuery('');
                                setState(() {});
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

                    DropdownButton<int>(
                      value: state.pageSize,
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(value: 10, child: Text('10')),
                        DropdownMenuItem(value: 20, child: Text('20')),
                        DropdownMenuItem(value: 50, child: Text('50')),
                      ],
                      onChanged: state.isLoading
                          ? null
                          : (v) {
                        if (v == null) return;
                        cubit.setPageSize(v);
                      },
                    ),
                    const SizedBox(width: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
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
                    const SizedBox(width: 10),

                    SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: state.isLoading ? null : cubit.load,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: Text(
                          tr(context, 'refresh'),
                          style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ✅ Table Card
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
                      // Title bar
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
                                  color: const Color(0xFFE8F1FF),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF175CD3)
                                        .withOpacity(.15),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.contact_phone_outlined,
                                  size: 22,
                                  color: Color(0xFF1960DA),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tr(context, 'contacts'),
                                      style: GoogleFonts.cairo(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${tr(context, 'showing')} $start ${tr(context, 'to')} $end ${tr(context, 'of')} $total',
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

                      // Body
                      Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: state.rows.isEmpty
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
                                child: Container(
                                  // ✅ outer border like Excel
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: _gridColor,
                                      width: 1,
                                    ),
                                  ),
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      dividerColor: _gridColor,
                                      dataTableTheme: DataTableThemeData(
                                        dividerThickness: 0,
                                        headingRowColor:
                                        WidgetStateProperty.all(
                                          const Color(0xFFF8FAFC),
                                        ),
                                        headingTextStyle:
                                        GoogleFonts.cairo(
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
                                      // ✅ grid style
                                      columnSpacing: 0,
                                      horizontalMargin: 0,
                                      dividerThickness: 0,
                                      headingRowHeight: 48,
                                      dataRowMinHeight: 54,
                                      dataRowMaxHeight: 64,
                                      columns: [
                                        DataColumn(
                                          label: _cells.headerCell(
                                            '#',
                                            w: 70,
                                          ),
                                        ),
                                        DataColumn(
                                          label: _cells.headerCell(
                                            tr(context, 'sponsor_name'),
                                            w: 260,
                                          ),
                                        ),
                                        DataColumn(
                                          label: _cells.headerCell(
                                            tr(context, 'phone'),
                                            w: 220,
                                            last: true,
                                          ),
                                        ),
                                      ],
                                      rows: List.generate(state.rows.length, (i) {
                                        final m = state.rows[i];
                                        final rowNo = start + i;

                                        final zebraBg = (i % 2 == 0)
                                            ? const Color(0xFFFFFFFF)
                                            : const Color(0xFFFBFCFE);

                                        return DataRow(
                                          color: WidgetStateProperty.resolveWith<Color?>(
                                                (states) {
                                              if (states.contains(
                                                WidgetState.hovered,
                                              )) {
                                                return const Color(
                                                  0xFFF3F7FF,
                                                );
                                              }
                                              return zebraBg;
                                            },
                                          ),
                                          cells: [
                                            DataCell(
                                              _cells.gridCellText(
                                                '$rowNo',
                                                w: 70,
                                              ),
                                            ),
                                            DataCell(
                                              _cells.gridCellText(
                                                m.sponsorName,
                                                w: 260,
                                              ),
                                            ),
                                            DataCell(
                                              _cells.gridCellText(
                                                m.phone,
                                                w: 220,
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
                      ),

                      if (state.isLoading)
                        Container(
                          color: Colors.white.withOpacity(0.55),
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ✅ Pagination footer
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
                        '${tr(context, 'showing')} $start ${tr(context, 'to')} $end ${tr(context, 'of')} $total',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
                      ),
                    ),
                    IconButton(
                      onPressed: state.page <= 1 ? null : cubit.prevPage,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text(
                      '${state.page} / $maxPage',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
                    ),
                    IconButton(
                      onPressed: state.page >= maxPage ? null : cubit.nextPage,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),

              if (state.error != null) ...[
                const SizedBox(height: 8),
                Text(state.error!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          );
        },
      ),
    );
  }
}
