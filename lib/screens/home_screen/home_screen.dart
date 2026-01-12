import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_provider.dart';
import '../../core/constants/constants.dart';
import '../../core/lang/app_language.dart';
import '../../models/country.dart';
import '../../models/office.dart';

import '../../services/arrival_orders_service.dart';
import '../../services/cancelation_orders_service.dart';

import '../../features/arrival_orders/arrival_orders_cubit.dart';
import '../../features/arrival_orders/arrival_orders_state.dart';

import '../../features/cancelation_orders/cancelation_orders_cubit.dart';
import '../../features/cancelation_orders/cancelation_orders_state.dart';

import 'home_screen_widgets/build_content.dart';
import 'home_screen_widgets/sidebar_widget.dart';
import 'home_screen_widgets/custom_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String? maleStatusKey;
  String? femaleStatusKey;

  bool isSidebarOpen = true;
  HomeSection currentSection = HomeSection.dashboardHome;

  Country? selectedCountry;
  Office? selectedOffice;

  // ---- your navigation methods (keep as you have) ----
  void openMaleAgencies() => setState(() => currentSection = HomeSection.officeMaleDetails);
  void openAddingNewAgency() => setState(() => currentSection = HomeSection.addingNewAgency);
  void backToMaleDetails() => setState(() => currentSection = HomeSection.officeMaleDetails);
  void openFemaleDetails() => setState(() => currentSection = HomeSection.officeFemaleDetails);

  void openFemaleContractsTable(String nameKey) {
    setState(() {
      femaleStatusKey = nameKey;
      currentSection = HomeSection.femaleContractsTable;
    });
  }

  void openMaleAgenciesTable(String nameKey) {
    setState(() {
      maleStatusKey = nameKey;
      currentSection = HomeSection.maleAgenciesTable;
    });
  }

  void openAwaitingDelivery() => setState(() => currentSection = HomeSection.housingWaitingDelivery);
  void backToHousing() => setState(() => currentSection = HomeSection.housingAll);
  void backToFemaleDetails() => setState(() => currentSection = HomeSection.officeFemaleDetails);

  void openOffices(Country country) {
    setState(() {
      selectedCountry = country;
      selectedOffice = null;
      currentSection = HomeSection.offices;
    });
  }

  void _onSectionSelected(HomeSection section) => setState(() => currentSection = section);
  void backToDashboard() => setState(() => currentSection = HomeSection.dashboardHome);
  void backToOffices() => setState(() => currentSection = HomeSection.offices);

  void openOfficeDetails(Office office) {
    setState(() {
      selectedOffice = office;
      currentSection = HomeSection.officeDetails;
    });
  }

  void openAddingNewContract() => setState(() => currentSection = HomeSection.addingNewContract);
  void backToOfficeDetails() => setState(() => currentSection = HomeSection.officeDetails);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    final sidebarWidth = isSidebarOpen
        ? (screenWidth > 1200 ? 250.0 : 210.0)
        : 64.0;

    final isArabic = context.watch<AppLanguage>().isArabic;

    final baseUrl = mainUrl; // عدّل الاسم لو مختلف
    final auth = context.read<AuthProvider>();

    return MultiBlocProvider(
      providers: [
        BlocProvider<ArrivalOrdersCubit>(
          create: (_) => ArrivalOrdersCubit(
            service: ArrivalOrdersService(baseUrl: baseUrl),
            tokenProvider: () => auth.token ?? '',
          )..load(showLoader: false),
        ),
        BlocProvider<CancelationOrdersCubit>(
          create: (_) => CancelationOrdersCubit(
            service: CancelationOrdersService(baseUrl: baseUrl),
            tokenProvider: () => auth.token ?? '',
          )..load(showLoader: false),
        ),
      ],

      // ✅ مهم: Builder عشان الـcontext يبقى شايف الكيوبيتات
      child: Builder(
        builder: (context) {
          final arrivalCount = context.select((ArrivalOrdersCubit c) => c.state.totalCount);
          final cancelCount  = context.select((CancelationOrdersCubit c) => c.state.totalCount);

          return MultiBlocListener(
            listeners: [
              BlocListener<ArrivalOrdersCubit, ArrivalOrdersState>(
                listenWhen: (p, c) => p.snackNonce != c.snackNonce,
                listener: (context, s) {
                  if (s.newIncomingDelta <= 0) return;
                  ScaffoldMessenger.of(context)
                    ..clearSnackBars()
                    ..showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text(
                          isArabic
                              ? 'يوجد ${s.newIncomingDelta} طلب وصول جديد'
                              : '${s.newIncomingDelta} new arrival request(s)',
                        ),
                      ),
                    );
                },
              ),
              BlocListener<CancelationOrdersCubit, CancelationOrdersState>(
                listenWhen: (p, c) => p.snackNonce != c.snackNonce,
                listener: (context, s) {
                  if (s.newIncomingDelta <= 0) return;
                  ScaffoldMessenger.of(context)
                    ..clearSnackBars()
                    ..showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text(
                          isArabic
                              ? 'يوجد ${s.newIncomingDelta} طلب إلغاء جديد'
                              : '${s.newIncomingDelta} new cancel request(s)',
                        ),
                      ),
                    );
                },
              ),
            ],
            child: Scaffold(
              key: _scaffoldKey,
              backgroundColor: const Color(0xffeaedf1),

              drawer: isMobile
                  ? Drawer(
                child: SidebarWidget(
                  onSectionSelected: (section) {
                    Navigator.pop(context);
                    _onSectionSelected(section);
                  },
                  isCollapsed: false,
                  currentSection: currentSection,
                ),
              )
                  : null,

              appBar: CustomAppBar(
                onMenuPressed: () {
                  if (isMobile) {
                    _scaffoldKey.currentState?.openDrawer();
                  } else {
                    setState(() => isSidebarOpen = !isSidebarOpen);
                  }
                },
                arrivalCount: arrivalCount,
                cancelCount: cancelCount,
                onNotificationsTap: () {
                  // TODO: افتح صفحة الطلبات أو اعمل sheet
                },
              ),

              body: SafeArea(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMobile)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        width: sidebarWidth,
                        child: Container(
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xff394263),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.10),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: SidebarWidget(
                              onSectionSelected: _onSectionSelected,
                              isCollapsed: !isSidebarOpen,
                              currentSection: currentSection,
                            ),
                          ),
                        ),
                      ),

                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.07),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return buildContent(
                                context,
                                constraints,
                                currentSection: currentSection,
                                selectedCountry: selectedCountry,
                                selectedOffice: selectedOffice,
                                femaleStatusKey: femaleStatusKey,
                                maleStatusKey: maleStatusKey,

                                openOfficeDetails: openOfficeDetails,
                                openOffices: openOffices,

                                backToDashboard: backToDashboard,
                                backToOffices: backToOffices,
                                backToOfficeDetails: backToOfficeDetails,

                                openAddingNewContract: openAddingNewContract,
                                openAddingNewAgency: openAddingNewAgency,

                                openMaleAgencies: openMaleAgencies,
                                openFemaleDetails: openFemaleDetails,

                                openFemaleContractsTable: openFemaleContractsTable,
                                openMaleAgenciesTable: openMaleAgenciesTable,

                                backToFemaleDetails: backToFemaleDetails,
                                backToMaleDetails: backToMaleDetails,
                                openAwaitingDelivery: openAwaitingDelivery,
                                backToHousing: backToHousing,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
