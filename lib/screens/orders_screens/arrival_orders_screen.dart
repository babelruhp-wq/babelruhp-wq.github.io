import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_provider.dart';
import '../../core/constants/constants.dart';
import '../../core/lang/app_language.dart';
import '../../features/arrival_orders/arrival_orders_cubit.dart';
import '../../features/arrival_orders/arrival_orders_state.dart';
import '../../localization/translator.dart';
import '../../models/arrival_orders_row.dart';
import '../../services/arrival_orders_service.dart';

import 'package:babel_final_project/screens/female_contracts_table_screen/female_contracts_table_widgets/table_cells.dart';

import '../female_contracts_table_screen/under_process_widgets/utils/cairo_theme.dart';

class ArrivalOrdersScreen extends StatelessWidget {
  final double maxWidth;
  final VoidCallback? onBack;

  const ArrivalOrdersScreen({
    super.key,
    this.maxWidth = 1400,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return FutureBuilder<String?>(
      future: auth.ensureValidToken(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final token = (snap.data ?? '').trim();
        if (token.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Token is missing')),
          );
        }

        return BlocProvider(
          create: (_) => ArrivalOrdersCubit(
            service: ArrivalOrdersService(baseUrl: mainUrl),
            tokenProvider: () => auth.token ?? '',
          )..load(),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              backgroundColor: const Color(0xFFF3F5F9),
              body: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: const [
                          _Header(),
                          SizedBox(height: 12),
                          Expanded(child: _ArrivalOrdersTableLayout()),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppLanguage>(
      builder: (context, lang, child) {
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
                      tr(context, 'orders'),
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
                      tr(context, 'arrival_orders_subtitle'),
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
      },
    );
  }
}

class _ArrivalOrdersTableLayout extends StatefulWidget {
  const _ArrivalOrdersTableLayout();

  @override
  State<_ArrivalOrdersTableLayout> createState() =>
      _ArrivalOrdersTableLayoutState();
}

class _ArrivalOrdersTableLayoutState extends State<_ArrivalOrdersTableLayout> {
  static const Color _gridColor = Color(0xFFE5E7EB);
  final TableCells _cells = const TableCells(gridColor: _gridColor);

  final TextEditingController _searchCtrl = TextEditingController();

  // ✅ Scrollbars (زي UnderProcess)
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
    return Theme(
      data: cairoTheme(context),
      child: BlocBuilder<ArrivalOrdersCubit, ArrivalOrdersState>(
        builder: (context, state) {
          final cubit = context.read<ArrivalOrdersCubit>();

          final total = state.totalCount;
          final page = state.page; // 1-based
          final size = state.pageSize;

          final start = total == 0 ? 0 : ((page - 1) * size) + 1;
          final end = (page * size) > total ? total : (page * size);
          final maxPage = (total / size).ceil().clamp(1, 999999);

          return Column(
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
                          onChanged: (v) {
                            cubit.setQuery(v); // ✅ نفس آلية البحث
                            setState(() {}); // ✅ عشان suffix يظهر/يختفي
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

                    // Total pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
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
                            style:
                            GoogleFonts.cairo(fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // =========================
              // ✅ Table Card (Pro) + Title bar inside
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
                      // ===== Title bar
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
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
                                  Icons.flight_takeoff_rounded,
                                  color: Color(0xFF175CD3),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tr(context, 'orders'),
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

                      // ===== Table body
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
                            physics:
                            const AlwaysScrollableScrollPhysics(),
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
                                    columnSpacing: 16,
                                    horizontalMargin: 14,
                                    headingRowHeight: 48,
                                    dataRowMinHeight: 54,
                                    dataRowMaxHeight: 74,
                                    columns: [
                                      DataColumn(
                                        label: _cells.headerCell('#',
                                            w: 60),
                                      ),
                                      DataColumn(
                                        label: _cells.headerCell(
                                            'اسم العاملة',
                                            w: 170),
                                      ),
                                      DataColumn(
                                        label: _cells.headerCell(
                                            'رقم جواز السفر',
                                            w: 150),
                                      ),
                                      DataColumn(
                                        label: _cells.headerCell(
                                            'رقم التأشيرة',
                                            w: 140),
                                      ),
                                      DataColumn(
                                        label: _cells.headerCell(
                                            'رقم التذكرة',
                                            w: 150),
                                      ),
                                      DataColumn(
                                        label: _cells.headerCell('الكفيل',
                                            w: 170),
                                      ),
                                      DataColumn(
                                        label: _cells.headerCell(
                                            'رقم الهوية',
                                            w: 140),
                                      ),
                                      DataColumn(
                                        label: _cells.headerCell('الموظف',
                                            w: 160),
                                      ),
                                      DataColumn(
                                        label: _cells.headerCell(
                                            'تاريخ الوصول',
                                            w: 140),
                                      ),
                                      DataColumn(
                                        label: _cells.headerCell('الحالة',
                                            w: 130),
                                      ),
                                      DataColumn(
                                        label: _cells.headerCell(
                                          'الإجراءات',
                                          w: 240,
                                          last: true,
                                        ),
                                      ),
                                    ],
                                    rows: List.generate(state.rows.length,
                                            (i) {
                                          final r = state.rows[i];

                                          final note = (r.description == 1)
                                              ? tr(context,
                                              'arrival_note_named')
                                              : (r.description == 2)
                                              ? tr(context,
                                              'arrival_note_by_specs')
                                              : tr(context, 'no_note');

                                          final zebraBg = (i % 2 == 0)
                                              ? const Color(0xFFFFFFFF)
                                              : const Color(0xFFFBFCFE);

                                          return DataRow(
                                            color: WidgetStateProperty
                                                .resolveWith<Color?>(
                                                    (states) {
                                                  if (states.contains(
                                                      WidgetState.hovered)) {
                                                    return const Color(
                                                        0xFFF3F7FF);
                                                  }
                                                  return zebraBg;
                                                }),
                                            cells: [
                                              DataCell(_cells.gridCellText(
                                                  '${r.rowNo}',
                                                  w: 60)),
                                              DataCell(_cells.gridCellText(
                                                  _v(r.employeeName),
                                                  w: 170)),
                                              DataCell(_cells.gridCellText(
                                                  _v(r.passportNo),
                                                  w: 150)),
                                              DataCell(_cells.gridCellText(
                                                  _v(r.visaNo),
                                                  w: 140)),
                                              DataCell(_cells.gridCellText(
                                                  _v(r.contractNo),
                                                  w: 150)),
                                              DataCell(_cells.gridCellText(
                                                  _v(r.sponsor),
                                                  w: 170)),
                                              DataCell(_cells.gridCellText(
                                                  _v(r.nationalId),
                                                  w: 140)),
                                              DataCell(_cells.gridCellText(
                                                  _v(r.employee),
                                                  w: 160)),
                                              DataCell(_cells.gridCellText(
                                                  _fmt(r.createdAt),
                                                  w: 140)),
                                              DataCell(_cells.gridCellWidget(
                                                  _statusChip(r.status),
                                                  w: 130)),
                                              DataCell(
                                                _cells.gridCellWidget(
                                                  _ArrivalActions(row: r),
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

                      // ✅ overlay loading
                      if (state.isLoading)
                        Container(
                          color: Colors.white.withOpacity(0.55),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // =========================
              // ✅ Pagination footer (زي UnderProcess)
              // =========================
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                        '${tr(context, 'showing')} $start ${tr(context, 'to')} $end ${tr(context, 'of')} $total ${tr(context, 'entries')}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                        GoogleFonts.cairo(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: page <= 1 ? null : cubit.prevPage,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text(
                      '$page / $maxPage',
                      style:
                      GoogleFonts.cairo(fontWeight: FontWeight.w900),
                    ),
                    IconButton(
                      onPressed: page >= maxPage ? null : cubit.nextPage,
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

  // =========================
  // Helpers
  // =========================
  static String _v(String? s) => (s == null || s.trim().isEmpty) ? '—' : s.trim();

  static String _fmt(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

  static Widget _statusChip(ArrivalOrderStatus s) {
    String t;
    Color bg;
    Color fg;

    switch (s) {
      case ArrivalOrderStatus.newOrder:
        t = 'طلب جديد';
        bg = const Color(0xFFFFF3E0);
        fg = const Color(0xFFB45309);
        break;
      case ArrivalOrderStatus.approved:
        t = 'تم التأكيد';
        bg = const Color(0xFFE9F7EF);
        fg = const Color(0xFF1E7D43);
        break;
      case ArrivalOrderStatus.rejected:
        t = 'مرفوض';
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFB91C1C);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(t, style: TextStyle(color: fg, fontWeight: FontWeight.w900)),
    );
  }
}

// =========================
// Actions (زي ما هي)
// =========================

class _ArrivalActions extends StatelessWidget {
  final ArrivalOrdersRow row;
  const _ArrivalActions({required this.row});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ArrivalOrdersCubit>();

    // ✅ هل الصف ده عليه تنفيذ حالياً؟
    final busyRowId =
    context.select((ArrivalOrdersCubit c) => c.state.actionRowId);
    final isBusy = busyRowId == row.id;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _pill(
          icon: Icons.check_circle_outline,
          label: 'تأكيد',
          fg: Colors.white,
          bg: const Color(0xFF2EAD5C),
          border: const Color(0xFF2EAD5C),
          loading: isBusy,
          onTap: isBusy
              ? null
              : () async {
            final ok = await _confirmDialog(
              context,
              type: _ConfirmType.approve,
              title: 'تأكيد الطلب',
              message: 'هل أنت متأكد من تأكيد هذا الطلب؟',
            );
            if (ok == true) {
              await cubit.approveOrder(row);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم تأكيد الطلب بنجاح')),
                );
              }
            }
          },
        ),
        _pill(
          icon: Icons.cancel_outlined,
          label: 'رفض',
          fg: const Color(0xFFDC2626),
          bg: const Color(0xFFFFF5F5),
          border: const Color(0xFFDC2626),
          loading: isBusy,
          onTap: isBusy
              ? null
              : () async {
            final ok = await _confirmDialog(
              context,
              type: _ConfirmType.reject,
              title: 'رفض الطلب',
              message: 'هل أنت متأكد من رفض هذا الطلب؟',
            );
            if (ok == true) {
              await cubit.rejectOrder(row);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم رفض الطلب')),
                );
              }
            }
          },
        ),
      ],
    );
  }

  Widget _pill({
    required IconData icon,
    required String label,
    required Color fg,
    required Color bg,
    required Color border,
    required VoidCallback? onTap,
    bool loading = false,
  }) {
    final disabled = onTap == null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Opacity(
        opacity: disabled ? 0.55 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: border.withOpacity(0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (loading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(fg),
                  ),
                )
              else
                Icon(icon, size: 16, color: fg),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDialog(
      BuildContext context, {
        required _ConfirmType type,
        required String title,
        required String message,
      }) {
    final isApprove = type == _ConfirmType.approve;

    final Color main =
    isApprove ? const Color(0xFF2EAD5C) : const Color(0xFFDC2626);
    final IconData ic =
    isApprove ? Icons.check_circle_rounded : Icons.cancel_rounded;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, minWidth: 320),
          child: Material(
            color: Colors.transparent,
            child: Dialog(
              insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: main.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(ic, color: main, size: 30),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        style: GoogleFonts.cairo(
                          fontSize: 13.5,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context, false),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side:
                                const BorderSide(color: Color(0xFFD1D5DB)),
                                padding:
                                const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(
                                'إلغاء',
                                style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: main,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                const EdgeInsets.symmetric(vertical: 12),
                                elevation: 0,
                              ),
                              child: Text(
                                isApprove ? 'تأكيد' : 'رفض',
                                style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _ConfirmType { approve, reject }
