import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/constants.dart';
import '../../core/lang/app_language.dart';
import '../../features/arrival_requests_history/arrival_requests_history_cubit.dart';
import '../../features/arrival_requests_history/arrival_requests_history_state.dart';
import '../../services/arrival_requests_history_service.dart';
import '../../localization/translator.dart';

// ✅ نفس Widgets بتاعت جدول العقود
import 'package:babel_final_project/screens/female_contracts_table_screen/female_contracts_table_widgets/table_cells.dart';

class ArrivalRequestsHistoryScreen extends StatelessWidget {
  final double maxWidth;
  final VoidCallback? onBack;

  /// ✅ لازم تبعت التوكن هنا
  final String token;

  const ArrivalRequestsHistoryScreen({
    super.key,
    required this.token,
    this.maxWidth = 1400,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ArrivalRequestsHistoryCubit(
        service: ArrivalRequestsHistoryService(baseUrl: mainUrl),
      )..load(token: token),
      child: Consumer<AppLanguage>(
        builder: (context, lang, _) {
          // لو عندك طريقة جاهزة تحدد RTL/LTR استخدمها هنا
          // حالياً نخليها RTL زي بقية شاشاتك
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              backgroundColor: const Color(0xFFF3F5F9),
              body: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _Header(),
                          const SizedBox(height: 12),
                          Expanded(child: _TableLayout(token: token)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xff3a4262),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tr(context, 'orders_history'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff2c334a),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tr(context, 'orders_history_subtitle'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TableLayout extends StatefulWidget {
  final String token;
  const _TableLayout({required this.token});

  @override
  State<_TableLayout> createState() => _TableLayoutState();
}

class _TableLayoutState extends State<_TableLayout> {
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
    final base = Theme.of(context);
    final themed = base.copyWith(
      textTheme: GoogleFonts.cairoTextTheme(base.textTheme),
      primaryTextTheme: GoogleFonts.cairoTextTheme(base.primaryTextTheme),
    );

    return Theme(
      data: themed,
      child: BlocBuilder<ArrivalRequestsHistoryCubit, ArrivalRequestsHistoryState>(
        builder: (context, state) {
          final cubit = context.read<ArrivalRequestsHistoryCubit>();

          final total = state.totalCount;
          final page = state.page;
          final size = state.pageSize;

          final start = total == 0 ? 0 : ((page - 1) * size) + 1;
          final end = (page * size) > total ? total : (page * size);
          final maxPage = (total / size).ceil().clamp(1, 999999);

          return Column(
            children: [
              // ===== Toolbar =====
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
                          onChanged: (v) {
                            setState(() {}); // ✅ عشان suffixIcon يتحدث
                            cubit.setQuery(q: v, token: widget.token);
                          },
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
                                setState(() {});
                                cubit.setQuery(q: '', token: widget.token);
                              },
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.2),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                            '${tr(context, 'total')}: $total',
                            style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: state.isLoading ? null : () => cubit.load(token: widget.token),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: Text(
                          tr(context, 'refresh'),
                          style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ===== Table Card =====
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
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFBFCFE),
                            border: Border(bottom: BorderSide(color: Color(0xFFE7ECF4))),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F1FF),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFF175CD3).withOpacity(.15)),
                                ),
                                child: const Icon(Icons.history_rounded, color: Color(0xFF175CD3)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tr(context, 'orders_history'),
                                      style: GoogleFonts.cairo(fontWeight: FontWeight.w900, fontSize: 14),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${tr(context, 'showing')} $start ${tr(context, 'to')} $end ${tr(context, 'from')} $total',
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

                      Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: state.rows.isEmpty
                              ? Center(
                            child: Text(
                              tr(context, 'no_data_available_in_table'),
                              style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
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
                                notificationPredicate: (n) => n.metrics.axis == Axis.horizontal,
                                child: SingleChildScrollView(
                                  controller: _hCtrl,
                                  scrollDirection: Axis.horizontal,
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      dividerColor: _gridColor,
                                      dataTableTheme: DataTableThemeData(
                                        dividerThickness: 1,
                                        headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
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
                                      columnSpacing: 16,
                                      horizontalMargin: 14,
                                      headingRowHeight: 48,
                                      dataRowMinHeight: 54,
                                      dataRowMaxHeight: 64,
                                      columns: [
                                        DataColumn(label: _cells.headerCell('#', w: 60)),
                                        DataColumn(label: _cells.headerCell(tr(context, 'name'), w: 180)),
                                        DataColumn(label: _cells.headerCell(tr(context, 'arrival_date'), w: 140)),
                                        DataColumn(label: _cells.headerCell(tr(context, 'passport_number'), w: 150)),
                                        DataColumn(label: _cells.headerCell(tr(context, 'visa_number'), w: 140)),
                                        DataColumn(label: _cells.headerCell(tr(context, 'contract_number'), w: 150)),
                                        DataColumn(label: _cells.headerCell(tr(context, 'sponsor'), w: 170)),
                                        DataColumn(label: _cells.headerCell(tr(context, 'id_number'), w: 140)),
                                        DataColumn(label: _cells.headerCell(tr(context, 'employee'), w: 140)),
                                        DataColumn(label: _cells.headerCell(tr(context, 'approved_by'), w: 140, last: true)),
                                      ],
                                      rows: List.generate(state.rows.length, (i) {
                                        final r = state.rows[i];
                                        final zebraBg = (i % 2 == 0) ? const Color(0xFFFFFFFF) : const Color(0xFFFBFCFE);

                                        return DataRow(
                                          color: MaterialStateProperty.resolveWith<Color?>((states) {
                                            if (states.contains(MaterialState.hovered)) return const Color(0xFFF3F7FF);
                                            return zebraBg;
                                          }),
                                          cells: [
                                            DataCell(_cells.gridCellText('${r.rowNo}', w: 60)),
                                            DataCell(_cells.gridCellText(_v(r.workerName), w: 180)),
                                            DataCell(_cells.gridCellText(_fmtDate(r.arrivalDate), w: 140)),
                                            DataCell(_cells.gridCellText(_v(r.passportNo), w: 150)),
                                            DataCell(_cells.gridCellText(_v(r.visaNo), w: 140)),
                                            DataCell(_cells.gridCellText(_v(r.contractNo), w: 150)),
                                            DataCell(_cells.gridCellText(_v(r.sponsor), w: 170)),
                                            DataCell(_cells.gridCellText(_v(r.sponsorId), w: 140)),
                                            DataCell(_cells.gridCellText(_v(r.employeeName), w: 140)),
                                            DataCell(_cells.gridCellText(_v(r.approvedBy), w: 140, last: true)),
                                          ],
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),),
                          if (state.isLoading)
                      Container(
                        color: Colors.white.withOpacity(0.60),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ===== Pagination =====
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
                    Text(
                      '${tr(context, 'showing')} $start ${tr(context, 'to')} $end ${tr(context, 'from')} $total',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: page <= 1 ? null : () => cubit.prevPage(token: widget.token),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text(
                      '$page / $maxPage',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
                    ),
                    IconButton(
                      onPressed: page >= maxPage ? null : () => cubit.nextPage(token: widget.token),
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

  static String _v(String? s) => (s == null || s.trim().isEmpty) ? '—' : s.trim();

  static String _fmtDate(DateTime? d) {
    if (d == null) return '—';
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }
}
