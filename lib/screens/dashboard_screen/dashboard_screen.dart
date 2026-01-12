import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/auth/auth_provider.dart';
import '../../features/countries/add_country/add_country_cubit.dart';
import '../../features/dashboard/dashboard_cubit.dart';
import '../../features/dashboard/dashboard_state.dart';
import '../../localization/translator.dart';
import '../../models/country.dart';

import 'dashboard_screen_widgets/bottom_containers_widget.dart';
import 'dashboard_screen_widgets/countries_grid_widget.dart';
import 'dashboard_screen_widgets/dashboard_screen_header.dart';
import 'dashboard_screen_widgets/add_edit_country_dialog.dart';

import '../../services/countries_service.dart';
import '../../core/network/dio_factory.dart';

class DashboardScreen extends StatelessWidget {
  final BoxConstraints constraints;
  final void Function(Country country) onCountrySelected;

  const DashboardScreen({
    super.key,
    required this.constraints,
    required this.onCountrySelected,
  });

  bool get isWeb => constraints.maxWidth >= 800;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = auth.role; // role أو fallback "Admin"
    final isAdmin = role == 'Admin';
    final isManager = role == 'Manager';
    return RepositoryProvider(
      create: (_) => CountriesService(dio: createDio(), tokenProvider:()=> auth.ensureValidToken()),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (ctx) => DashboardCubit(
              service: ctx.read<CountriesService>(),
            )..refresh(),
          ),
          BlocProvider(
            create: (ctx) => AddCountryCubit(
              service: ctx.read<CountriesService>(),
            ),
          ),
        ],
        child: BlocListener<AddCountryCubit, AddCountryState>(
          listener: (context, state) async {
            if (state is AddCountrySuccess) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              await context.read<DashboardCubit>().refresh();
            } else if (state is AddCountryFailure) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocConsumer<DashboardCubit, DashboardState>(
            listenWhen: (prev, curr) =>
            prev.error != curr.error && curr.error != null,
            listener: (context, state) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  backgroundColor: Colors.red,
                ),
              );
            },
            builder: (context, state) {
              final cubit = context.read<DashboardCubit>();

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1400),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: DashboardScreenHeader(
                                  loadCountries: () async {
                                    await cubit.refresh();
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              if(isAdmin || isManager)
                                SizedBox(
                                  height: 44,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green
                                    ),
                                    onPressed: () => showAddCountryDialog(context),
                                    icon: const Icon(Icons.add,color: Colors.white,),
                                    label: Text(tr(context, 'add_new_country'),style: GoogleFonts.cairo(textStyle: TextStyle(color: Colors.white)),),
                                  ),
                                ),


                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        _section(
                          child: Stack(
                            children: [
                              CountriesGridWidget(
                                maxWidth: constraints.maxWidth,
                                countries: state.countries,
                                stats: state.stats,
                                onCountrySelected: onCountrySelected,
                                onChanged: () async => cubit.refresh(),
                              ),
                              if (state.isLoadingCountries)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        _section(
                          child: state.isLoadingStats
                              ? const Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(child: CircularProgressIndicator()),
                          )
                              : BottomContainersWidget(
                            isWeb: isWeb,
                            countryOfficeStats: state.stats,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
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
