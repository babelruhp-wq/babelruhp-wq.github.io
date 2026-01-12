import 'package:babel_final_project/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/auth/auth_provider.dart';
import '../../core/network/dio_factory.dart';
import '../../localization/translator.dart';
import '../../models/country.dart';
import '../../models/office.dart';

import '../../features/offices/offices_cubit.dart';
import '../../features/offices/offices_state.dart';

import '../../services/offices_service.dart';
import '../../services/contracts_service.dart';

import 'country_screen_widgets/country_screen_app_bar.dart';
import 'country_screen_widgets/office_external_offices_bar_card.dart';
import 'country_screen_widgets/offices_grid_widget.dart';

class CountryScreen extends StatelessWidget {
  final Country country;
  final double maxWidth;
  final VoidCallback onBackToDashboard;
  final void Function(Office office) onOfficeSelected;

  const CountryScreen({
    super.key,
    required this.country,
    required this.maxWidth,
    required this.onBackToDashboard,
    required this.onOfficeSelected,
  });

  bool get isWeb => maxWidth >= 800;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => OfficesService(dio: createDio(), tokenProvider:()=> context.read<AuthProvider>().ensureValidToken())),
        RepositoryProvider(
          create: (_) => ContractsService(baseUrl: mainUrl),
        ),
      ],
      child: BlocProvider(
        create: (ctx) {
          final token = ctx.read<AuthProvider>().token ?? '';
          return OfficesCubit(
            service: ctx.read<OfficesService>(),
            contractsService: ctx.read<ContractsService>(),
            countryId: country.countryId,
          )..refresh(status: 0, token: token);
        },
        child: BlocConsumer<OfficesCubit, OfficesState>(
          listenWhen: (prev, curr) => prev.error != curr.error && curr.error != null,
          listener: (context, state) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error ?? tr(context, 'failed_to_load_offices')),
                backgroundColor: Colors.red,
              ),
            );
          },
          builder: (context, state) {
            final cubit = context.read<OfficesCubit>();
            final token = context.read<AuthProvider>().token ?? '';

            return Scaffold(
              appBar: CountryScreenAppBar(
                country: country,
                onBack: onBackToDashboard,
                onOfficeAdded: () async {
                  // ✅ بعد إضافة مكتب: رجّع ALL
                  if (token.isNotEmpty) {
                    await cubit.refresh(status: 0, token: token);
                  }
                },
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Center(
                  child: ConstrainedBox(
                    // ✅ بدل 1400 ثابتة
                    constraints: BoxConstraints(maxWidth: maxWidth >= 1400 ? 1400 : maxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // =====================
                        // Offices Grid Section
                        // =====================
                        _section(
                          child: Stack(
                            children: [
                              if (state.offices.isEmpty && !state.isLoading)
                                Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Text(
                                    tr(context, 'no_offices_for_country'),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                )
                              else
                                OfficesGridWidget(
                                  maxWidth: maxWidth,
                                  offices: state.offices,

                                  // ✅ stats map
                                  femaleStatsByOffice: state.femaleStatsByOffice,
                                  isStatsLoading: state.isStatsLoading,

                                  onOfficeSelected: onOfficeSelected,
                                  onChanged: () async {
                                    // ✅ أي تغيير/تحديث: رجّع ALL
                                    if (token.isNotEmpty) {
                                      await cubit.refresh(status: 0, token: token);
                                    }
                                  },
                                ),

                              // Loading overlay
                              if (state.isLoading)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(child: CircularProgressIndicator()),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // =====================
                        // Bottom Section
                        // =====================
                        _section(
                          child: OfficeExternalOfficesBarCard(
                            offices: state.offices,
                            femaleStatsByOffice: state.femaleStatsByOffice,
                            isLoading: state.isStatsLoading,
                          ),
                        ),
                      ],
                    ),
                  ), 
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _section({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
