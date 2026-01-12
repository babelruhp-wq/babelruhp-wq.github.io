import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/auth/auth_provider.dart';
import '../../features/office_male_details/office_male_details_counts_cubit.dart';
import '../../features/office_male_details/office_male_details_counts_state.dart';
import '../../localization/translator.dart';
import '../../core/constants/constants.dart';

import '../../services/agencies_service.dart';
import 'office_male_agencies_details_widgets/OfficeMaleAgenciesDetailsAppBar.dart';
import 'office_male_agencies_details_widgets/office_male_agencies_details_grid_widget.dart';



// ✅ تفاصيل كروت الإحصائيات للوكالات الرجالية (تقدر تنقلها لملف constants.dart لو حبيت)
const List<Map<String, dynamic>> allMaleAgenciesDetails = [
  {'nameKey': 'all_workers', 'color': 0xff3a4262},
  {'nameKey': 'new', 'color': 0xff34ae65},
  {'nameKey': 'under_process', 'color': 0xffe27f30},
  {'nameKey': 'rejected', 'color': 0xffe34f40},
  {'nameKey': 'arrival', 'color': 0xff34ae65},
  {'nameKey': 'finished', 'color': 0xffe34f40},
];
class OfficeMaleAgenciesDetailsScreen extends StatefulWidget {
  final String title;
  final double maxWidth;

  final String officeId;
  final String officeName;

  final Future<bool?> Function() onAddAgency;
  final VoidCallback onBack;
  final void Function(String nameKey) onCardTap;

  const OfficeMaleAgenciesDetailsScreen({
    super.key,
    required this.maxWidth,
    required this.officeId,
    required this.officeName,
    required this.title,
    required this.onBack,
    required this.onCardTap,
    required this.onAddAgency,
  });

  @override
  State<OfficeMaleAgenciesDetailsScreen> createState() => _OfficeMaleAgenciesDetailsScreenState();
}

class _OfficeMaleAgenciesDetailsScreenState extends State<OfficeMaleAgenciesDetailsScreen> {
  late final OfficeMaleDetailsCountsCubit _cubit;

  final Color primary = const Color(0xff7fb841);
  final Color bg = const Color(0xffF6F7FB);

  @override
  void initState() {
    super.initState();

    _cubit = OfficeMaleDetailsCountsCubit(
      service: MaleAgenciesService(baseUrl: mainUrl),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().token ?? '';
      if (token.isNotEmpty) {
        _cubit.loadCounts(officeId: widget.officeId, token: token);
        _cubit.startAutoRefresh(
          officeId: widget.officeId,
          token: token,
          interval: const Duration(seconds: 15),
        );
      }
    });
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final token = auth.token ?? '';
    final role = auth.role; // role أو fallback "Admin"
    final isAdmin = role == 'Admin';
    final isManager = role == 'Manager';
    final isReceptionEmployee=role=='ReceptionEmployee';

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: bg,

        appBar: OfficeMaleAgenciesDetailsAppbar(
          onBack: widget.onBack,
          title: widget.officeName,
          subtitle: widget.title,
          action:
          isAdmin || isManager || isReceptionEmployee ?
          _PrimaryButton(
            label: tr(context, 'add_new_male_agency'),
            icon: Icons.add,
            color: primary,
            onTap: () async {
              final ok = await widget.onAddAgency();
              if (ok == true) {
                if (token.isNotEmpty) {
                  await _cubit.loadCounts(officeId: widget.officeId, token: token);
                }
              }
            },
          ) : null,
        ),

        body: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final isWide = w >= 900;
            final horizontal = isWide ? 24.0 : 16.0;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: 12),
              child: BlocBuilder<OfficeMaleDetailsCountsCubit, OfficeMaleDetailsCountsState>(
                builder: (context, state) {
                  Map<String, int> counts = const {};
                  if (state is OfficeMaleDetailsCountsLoaded) {
                    counts = state.counts;
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      final token = context.read<AuthProvider>().token ?? '';
                      if (token.isNotEmpty) {
                        await context.read<OfficeMaleDetailsCountsCubit>().loadCounts(
                          officeId: widget.officeId,
                          token: token,
                        );
                      }
                    },
                    child: Stack(
                      children: [
                        ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            OfficeMaleAgenciesDetailsGridWidget(
                              maxWidth: widget.maxWidth,
                              allDetails: allMaleAgenciesDetails,
                              onCardTap: widget.onCardTap,
                              counts: counts,
                              loading: state is OfficeMaleDetailsCountsLoading,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),

                        if (state is OfficeMaleDetailsCountsLoading && counts.isEmpty)
                          Positioned.fill(
                            child: IgnorePointer(
                              ignoring: true,
                              child: Container(
                                color: bg.withOpacity(.35),
                                alignment: Alignment.center,
                                child: const CircularProgressIndicator(),
                              ),
                            ),
                          ),
                      ],
                    ),                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
