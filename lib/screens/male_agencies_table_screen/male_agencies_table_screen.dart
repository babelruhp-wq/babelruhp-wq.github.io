import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/auth/auth_provider.dart';
import '../../localization/translator.dart';
import '../../models/male_agency.dart';
import '../../services/agencies_service.dart';
import '../../features/male_agencies_table/male_agencies_table_cubit.dart';
import '../../features/male_agencies_table/male_agencies_table_state.dart';

import 'male_agencies_table_widgets/male_agencies_table_appbar.dart';

import 'all_contracts_widgets/view_all_contracts.dart';
import 'new_contracts_widgets/view_new_contracts.dart';
import 'under_process_widgets/view_under_process_contracts.dart';
import 'rejected_contracts_widgets/view_rejected_contracts.dart';
import 'arrival_contracts_widgets/view_arrival_contracts.dart';
import 'finished_contracts_widgets/view_finished_contracts.dart';

class MaleAgenciesTableScreen extends StatefulWidget {
  final String officeId;
  final String baseUrl;

  final String title;
  final int statusFilter; // null => all
  final VoidCallback onBack;

  final Future<bool> Function(BuildContext context, MaleAgency agency)
      onEdit;

  const MaleAgenciesTableScreen({
    super.key,
    required this.officeId,
    required this.baseUrl,
    required this.title,
    required this.statusFilter,
    required this.onBack,
    required this.onEdit,
  });

  @override
  State<MaleAgenciesTableScreen> createState() =>
      _MaleAgenciesTableScreenState();
}

class _MaleAgenciesTableScreenState
    extends State<MaleAgenciesTableScreen> {
  late final MaleAgenciesTableCubit cubit;

  @override
  void initState() {
    super.initState();

    cubit = MaleAgenciesTableCubit(
      service: MaleAgenciesService(baseUrl: widget.baseUrl),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().token ?? '';
      if (token.isEmpty) return;

      cubit.load(
        officeId: widget.officeId,
        statusFilter: widget.statusFilter,
        token: token,
      );

      cubit.startAutoRefresh(
        officeId: widget.officeId,
        statusFilter: widget.statusFilter,
        every: const Duration(seconds: 10),
        token: token,
      );
    });
  }

  @override
  void dispose() {
    cubit.stopAutoRefresh();
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MaleAgenciesTableCubit>.value(
      value: cubit,
      child: Scaffold(
        backgroundColor: const Color(0xffF5F7FA),
        appBar: MaleAgenciesTableAppbar(
          title: widget.title,
          onBack: widget.onBack,
        ),
        body: BlocBuilder<MaleAgenciesTableCubit, MaleAgenciesTableState>(
          builder: (context, state) {
            final cubit = context.read<MaleAgenciesTableCubit>();
            final token = context.watch<AuthProvider>().token ?? '';

            if (state.status == MaleAgenciesTableStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == MaleAgenciesTableStatus.error) {
              return Center(child: Text(state.error ?? 'Error'));
            }

            final list = state.filtered;

            return Stack(
              children: [
                _buildViewByStatus(
                  context,
                  cubit: cubit,
                  items: list,
                  token: token,
                  onRefresh: () async {
                    if (token.isEmpty) return;
                    await cubit.load(
                      officeId: widget.officeId,
                      statusFilter: widget.statusFilter,
                      token: token,
                    );
                  },
                  onDetails: (c) => _openDetails(context, c),
                  onEdit: (c) async {
                    final changed = await widget.onEdit(context, c);
                    if (!mounted || token.isEmpty) return;
                    if (changed == true) {
                      await cubit.load(
                        officeId: widget.officeId,
                        statusFilter: widget.statusFilter,
                        token: token,
                      );
                    }
                  },
                ),

                // ✅ overlay busy (مستخدم في update/approve/cancel عندك كـ deleting)
                if (state.status == MaleAgenciesTableStatus.deleting)
                  Container(
                    color: Colors.black.withOpacity(.05),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// ✅ نفس Screen، بس يختار View مختلف حسب الحالة
  Widget _buildViewByStatus(
    BuildContext context, {
    required MaleAgenciesTableCubit cubit,
    required List<MaleAgency> items,
    required String token,
    required Future<void> Function() onRefresh,
    required void Function(MaleAgency c) onDetails,
    required Future<void> Function(MaleAgency c) onEdit,
  }) {
    final f = widget.statusFilter;
    final auth = context.watch<AuthProvider>();
    final name = auth.displayName;

    // 1 => جديد ✅ (ملاحظة/موافقة/إلغاء)
    if (f == 1) {
      return NewContractsView(
        items: items,
        onRefresh: onRefresh,
        onDetails: onDetails,

        /// ✅ إضافة/تعديل ملاحظة
        /// (الكيوبيت بيعمل load بعد النجاح) => مفيش داعي لـ load هنا
        onUpdateNote: (c, note) async {
          if (token.isEmpty) return;
          await cubit.updateNote(
            agency: c,
            note: note,
            officeId: widget.officeId,
            statusFilter: widget.statusFilter,
            token: token,
          );
        },

        /// ✅ اعتماد + تاريخ اعتماد
        onApprove: (c, approvalDate) async {
          if (token.isEmpty) return;
          await cubit.approveAgency(
            agencyId: c.id,
            approvalDate: approvalDate,
            officeId: widget.officeId,
            statusFilter: widget.statusFilter,
            token: token,
          );
        },

        /// ✅ إلغاء + سبب (مطابق للـ API الجديد)
        /// لازم NewContractsView يكون معرف onCancel(MaleAgency, String reason)
        onCancel: (c, by, reason) async {
          if (token.isEmpty) return;
          await cubit.cancelAgency(
            agencyId: c.id,
            cancelationBy: by,
            cancelationReason: reason,
            officeId: widget.officeId,
            statusFilter: widget.statusFilter,
            employeeName: name,
            token: token,
          );
        },
      );
    }

    // 2 => تحت الإجراء
    if (f == 2) {
      return UnderProcessContractsView(
        items: items,
        onRefresh: onRefresh,
        onDetails: onDetails,

        // ✅ ملاحظة
        onUpdateNote: (c, note) async {
          if (token.isEmpty) return;
          await cubit.updateNote(
            agency: c,
            note: note,
            officeId: widget.officeId,
            statusFilter: widget.statusFilter,
            token: token,
          );
        },

        // ✅ إلغاء (by + reason)
        onCancel: (c, by, reason) async {
          if (token.isEmpty) return;
          await cubit.cancelAgency(
            agencyId: c.id,
            cancelationBy: by,
            cancelationReason: reason,
            officeId: widget.officeId,
            statusFilter: widget.statusFilter,
            employeeName: name,
            token: token,
          );
        },

        // ✅ تواريخ (هتعملهم في cubit)
        onSetStampedDate: (c, d) async {
          if (token.isEmpty) return;
          await cubit.setStampedDate(
            agency: c,
            date: d,
            officeId: widget.officeId,
            statusFilter: widget.statusFilter,
            token: token,
          );
        },
        onSetFlightTicketDate: (c, d) async {
          if (token.isEmpty) return;
          await cubit.setFlightTicketDate(
            agency: c,
            date: d,
            officeId: widget.officeId,
            statusFilter: widget.statusFilter,
            token: token,
          );
        },
        onSetArrivalDate: (c, d) async {
          if (token.isEmpty) return;
          await cubit.setArrivalDate(
            agency: c,
            date: d,
            officeId: widget.officeId,
            statusFilter: widget.statusFilter,
            employeeName: name,
            token: token,
          );
        },
      );
    }

    // 3 => مرفوض
    if (f == 3) {
      return RejectedContractsView(
        items: items,
        onRefresh: onRefresh,
        onDetails: onDetails,
      );
    }

    // 4 => وصول
    if (f == 4) {
      return ArrivalContractsView(
        items: items,
        onRefresh: onRefresh,
        onDetails: onDetails,
        onEdit: onEdit,
      );
    }

    // 5 => منتهية
    if (f == 5) {
      return FinishedContractsView(
        items: items,
        onRefresh: onRefresh,
        onDetails: onDetails,
        onEdit: onEdit,
      );
    }

    // fallback
    return AllContractsView(
      items: items,
      onRefresh: onRefresh,
      onDetails: onDetails,
      onEdit: onEdit,
    );
  }

  // ✅ Dialog التفاصيل (حط عندك كود التفاصيل الكامل بدل المؤقت ده)

  void _openDetails(BuildContext context, MaleAgency c) {
    String status = '';
    switch (c.contractStatus) {
      case 1:
        status = tr(context, 'status_new_contract');
        break;
      case 2:
        status = tr(context, 'status_under_process');
        break;
      case 3:
        status = tr(context, 'status_canceled');
        break;
      case 4:
        status = tr(context, 'status_on_arrival');
        break;
      case 5:
        status = tr(context, 'status_finished');
        break;
      default:
        status = '-';
    }

    String fmtDate(dynamic v) {
      if (v == null) return '-';
      if (v is DateTime) {
        final y = v.year.toString().padLeft(4, '0');
        final m = v.month.toString().padLeft(2, '0');
        final d = v.day.toString().padLeft(2, '0');
        return '$y-$m-$d';
      }
      final s = v.toString().trim();
      if (s.isEmpty) return '-';
      if (s.contains('T')) return s.split('T').first;
      if (s.contains(' ')) return s.split(' ').first;
      return s;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: DefaultTextStyle(
            style: GoogleFonts.cairo(
              fontSize: 13.5,
              height: 1.35,
              color: Colors.black87,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(.12),
                          Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(.04),
                        ],
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Avatar Circle
                        Container(
                          width: 42,
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(.12),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(.18),
                            ),
                          ),
                          child: Icon(
                            Icons.person,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),

                        Text(
                          c.workerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Name + status chip
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              Align(
                                alignment: Alignment.centerRight,
                                child: _statusChip(
                                  context,
                                  status,
                                  c.contractStatus,
                                ),
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close_rounded),
                          tooltip: tr(context, 'cancel'),
                        ),
                      ],
                    ),
                  ),

                  // ✅ Body
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                      child: Column(
                        children: [
                          _detailsSection(
                            context,
                            title: tr(context, 'worker_information'),
                            icon: Icons.badge_outlined,
                            children: [
                              _kv(
                                context,
                                tr(context, 'maid_name'),
                                c.workerName,
                              ),
                              _kv(
                                context,
                                tr(context, 'passport_number'),
                                c.passportNumber,
                              ),
                              _kv(context, tr(context, 'age'), c.workerAge),
                              _kv(
                                context,
                                tr(context, 'experience'),
                                c.experienced,
                              ),
                              _kv(context, tr(context, 'religion'), c.religion),
                              _kv(context, tr(context, 'salary'), c.salary),
                            ],
                          ),
                          const SizedBox(height: 12),

                          _detailsSection(
                            context,
                            title: tr(context, 'contract_information'),
                            icon: Icons.description_outlined,
                            children: [
                              _kv(
                                context,
                                tr(context, 'contract_number'),
                                c.contractNumber,
                              ),
                              _kv(
                                context,
                                tr(context, 'contract_date'),
                                fmtDate(c.contractDate),
                              ),
                              _kv(
                                context,
                                tr(context, 'contract_status'),
                                status,
                              ),
                              _kv(
                                context,
                                tr(context, 'col_created_at'),
                                fmtDate(c.createdAt),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          _detailsSection(
                            context,
                            title: tr(context, 'visa_information'),
                            icon: Icons.flight_takeoff_outlined,
                            children: [
                              _kv(
                                context,
                                tr(context, 'visa_number'),
                                c.visaNumber,
                              ),
                              _kv(
                                context,
                                tr(context, 'approval_date'),
                                fmtDate(c.approvalDate),
                              ),
                              _kv(
                                context,
                                tr(context, 'stamped_date'),
                                fmtDate(c.stamped),
                              ),
                              _kv(
                                context,
                                tr(context, 'flight_ticket_date'),
                                fmtDate(c.flightTicketDate),
                              ),
                              _kv(
                                context,
                                tr(context, 'arrival_date'),
                                fmtDate(c.arrivalDate),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          _detailsSection(
                            context,
                            title: tr(context, 'sponsor_information'),
                            icon: Icons.person_pin_circle_outlined,
                            children: [
                              _kv(context, tr(context, 'sponsor_name'), c.sponsorName),
                              _kv(
                                context,
                                tr(context, 'sponsor_id_number'),
                                c.sponsorIDNumber,
                              ),
                              _kv(
                                context,
                                tr(context, 'sponsor_mobile'),
                                c.sponsorPhoneNumber,
                              ),
                            ],
                          ),
                          if (c.notes?.trim().isNotEmpty ?? false)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: _detailsSection(
                                context,
                                title: tr(context, 'notes'),
                                icon: Icons.speaker_notes_outlined,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    child: Text(c.notes!),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusChip(BuildContext context, String label, int status) {
    final colors = [
      Colors.grey,
      Colors.blue,
      Colors.orange,
      Colors.red,
      Colors.green,
      Colors.purple
    ];
    final color = colors[status.clamp(0, 5)];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          color: color,
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _detailsSection(
    BuildContext context,
      {required String title,
      required IconData icon,
      required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _kv(BuildContext context, String key, dynamic value) {
    final v = (value ?? '-').toString().trim();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(v.isEmpty ? '-' : v),
        ],
      ),
    );
  }
}
