import 'package:babel_final_project/screens/office_screen/office_screen.dart';
import 'package:babel_final_project/screens/orders_screens/arrival_requests_history_screen.dart';
import 'package:babel_final_project/screens/orders_screens/cancelation_orders_screen.dart';
import 'package:babel_final_project/screens/users_screen/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_provider.dart';
import '../../../core/constants/constants.dart';
import '../../../core/lang/app_language.dart';
import '../../../localization/translator.dart';
import '../../../models/country.dart';
import '../../../models/female_contract.dart';
import '../../../models/male_agency.dart';
import '../../../models/office.dart';

import '../../adding_new_contract_screen/adding_new_contract_screen.dart';
import '../../adding_new_male_agency/adding_new_agency_screen.dart';
import '../../all_shelters_screen/all_shelters_screen.dart';
import '../../awaiting_delivery_screen/awaiting_delivery_screen.dart';
import '../../contacts_screen/contacts_screen.dart';
import '../../dashboard_screen/dashboard_screen.dart';
import '../../country_screen/country_screen.dart';
import '../../female_contracts_table_screen/female_contracts_table_screen.dart';
import '../../male_agencies_table_screen/male_agencies_table_screen.dart';
import '../../office_female_details_screen/office_female_details_screen.dart';
import '../../office_male_details_screen/office_male_agencies_details_screen.dart';
import '../../orders_screens/arrival_orders_screen.dart';

Widget buildContent(
  BuildContext context,
  BoxConstraints constraints, {
  required HomeSection currentSection,
  required Country? selectedCountry,
  required Office? selectedOffice,
  required String? femaleStatusKey,
  required String? maleStatusKey,

  required void Function(Office office) openOfficeDetails,
  required void Function(Country country) openOffices,

  required VoidCallback backToDashboard,
  required VoidCallback backToOffices,
  required VoidCallback backToOfficeDetails,

  required VoidCallback openAddingNewContract,
  required VoidCallback openAddingNewAgency,

  required VoidCallback openMaleAgencies,
  required VoidCallback openFemaleDetails,

  required void Function(String nameKey) openFemaleContractsTable,
  required void Function(String nameKey) openMaleAgenciesTable,

  required VoidCallback backToFemaleDetails,
  required VoidCallback backToMaleDetails,
  required VoidCallback openAwaitingDelivery,
  required VoidCallback backToHousing,
}) {
  final maxWidth = constraints.maxWidth;
  final isArabic = context.watch<AppLanguage>().isArabic;

  // =========================
  // Helpers
  // =========================

  String countryName(Country c) => isArabic ? c.nameArabic : c.nameEnglish;
  final auth = context.watch<AuthProvider>();
  final role = auth.role; // role أو fallback "Admin"
  final token = (auth.token ?? '').toString();
  final isAdmin = role == 'Admin';
  final isManager = role == 'Manager';
  Widget missingSelection({
    required String message,
    required VoidCallback onBack,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onBack, child: const Text('رجوع')),
        ],
      ),
    );
  }

  int statusFilterIntFromKey(String key) {
    switch (key) {
      case 'all_workers':
        return 0; // ✅ بدل null
      case 'new':
        return 1;
      case 'under_process':
        return 2;
      case 'rejected':
        return 3;
      case 'arrival':
        return 4;
      case 'finished':
        return 5;
      default:
        return 0; // ✅ default = all
    }
  }

  // =========================
  // Navigation Flow (Ordered)
  // =========================
  switch (currentSection) {
  // 1) Dashboard
    case HomeSection.dashboardHome:
      return DashboardScreen(
        constraints: constraints,
        onCountrySelected: openOffices,
      );

  // 2) Country -> Offices list
    case HomeSection.offices:
      if (selectedCountry == null) {
        return missingSelection(
          message: 'من فضلك اختر دولة أولاً.',
          onBack: backToDashboard,
        );
      }

      return CountryScreen(
        country: selectedCountry,
        maxWidth: maxWidth,
        onBackToDashboard: backToDashboard,
        onOfficeSelected: openOfficeDetails,
      );

  // 3) Office details (اختيار نسائي/رجالي)
    case HomeSection.officeDetails:
      if (selectedOffice == null) {
        return missingSelection(
          message: 'من فضلك اختر مكتب أولاً.',
          onBack: backToOffices,
        );
      }

      return OfficeDetailsScreen(
        maxWidth: maxWidth,
        office: selectedOffice,
        onBack: backToOffices,
        onFemaleTap: openFemaleDetails,
        onMaleTap: openMaleAgencies,
      );

  // =========================
  // 4) Female Flow
  // =========================
    case HomeSection.officeFemaleDetails:
      if (selectedOffice == null) {
        return missingSelection(
          message: 'اختر مكتب أولاً.',
          onBack: backToOffices,
        );
      }

      return OfficeFemaleDetailsScreen(
        maxWidth: maxWidth,
        officeId: selectedOffice.officeId,
        officeName: selectedOffice.officeName,
        title: tr(context, 'female_contracts'),
        onBack: backToOfficeDetails,
        onCardTap: (nameKey) => openFemaleContractsTable(nameKey),
        onAddContract: () async {
          final ok = await showAddFemaleContractDialog(
            context,
            officeId: selectedOffice.officeId,
            countryName: countryName(selectedCountry!),
            officeName: selectedOffice.officeName,
            baseUrl: mainUrl,
            initialContract: null,
          );

          // ✅ مهم: رجّع ok عشان الشاشة تعمل refresh
          return ok;
        },
      );

    case HomeSection.femaleContractsTable:
      if (selectedOffice == null) {
        return missingSelection(
          message: 'من فضلك اختر مكتب أولاً.',
          onBack: backToOfficeDetails,
        );
      }

      final fKey = (femaleStatusKey ?? '').trim();
      final fTitleKey = fKey.isEmpty ? 'all_workers' : fKey;
      final fStatus = statusFilterIntFromKey(
        fTitleKey,
      );

      return FemaleContractsTableScreen(
        baseUrl: mainUrl,
        officeId: selectedOffice.officeId,
        title: tr(context, fTitleKey),
        statusFilter: fStatus,
        // ✅ int 0..5
        onBack: backToFemaleDetails,
        onEdit: (BuildContext ctx, FemaleContract contract) async {
          final ok = await showAddFemaleContractDialog(
            ctx,
            officeId: selectedOffice.officeId,
            countryName: countryName(selectedCountry!),
            officeName: selectedOffice.officeName,
            baseUrl: mainUrl,
            initialContract: contract,
          );
          return ok == true;
        },
      );

    case HomeSection.addingNewContract:
      if (selectedOffice == null || selectedCountry == null) {
        return missingSelection(
          message: 'لا يمكن إضافة عقد بدون اختيار دولة ومكتب.',
          onBack: backToFemaleDetails,
        );
      }

      return Center();


  // =========================
  // 5) Male Flow
  // =========================
    case HomeSection.officeMaleDetails:
      if (selectedOffice == null) {
        return missingSelection(
          message: 'من فضلك اختر مكتب أولاً.',
          onBack: backToOfficeDetails,
        );
      }

      return OfficeMaleAgenciesDetailsScreen(
        maxWidth: maxWidth,
        officeId: selectedOffice.officeId,
        officeName: selectedOffice.officeName,
        title: tr(context, 'male_agencies'),
        onBack: backToOfficeDetails,
        onCardTap: (nameKey) => openMaleAgenciesTable(nameKey),
        // ✅ مهم
        onAddAgency: () async {
          final ok = await showAddMaleAgencyDialog(
            context,
            baseUrl: mainUrl,
            officeId: selectedOffice.officeId,
            countryName: countryName(selectedCountry!),
            officeName: selectedOffice.officeName,
            initialAgency: null,
          );
          return ok == true;
        },
      );

    case HomeSection.maleAgenciesTable:
      if (selectedOffice == null) {
        return missingSelection(
          message: 'من فضلك اختر مكتب أولاً.',
          onBack: backToOfficeDetails,
        );
      }

      final mKey = (maleStatusKey ?? '').trim();
      final mTitleKey = mKey.isEmpty ? 'all_workers' : mKey;

      return MaleAgenciesTableScreen(
        baseUrl: mainUrl,
        officeId: selectedOffice.officeId,
        title: tr(context, mTitleKey),
        statusFilter: statusFilterIntFromKey(mKey),
        onBack: backToMaleDetails,

        onEdit: (BuildContext ctx, MaleAgency agency) async {
          final ok = await showAddMaleAgencyDialog(
            ctx,
            baseUrl: mainUrl,
            officeId: selectedOffice.officeId,
            countryName: countryName(selectedCountry!),
            officeName: selectedOffice.officeName,
            initialAgency: agency, // ✅ edit
          );
          return ok == true;
        },
      );


    case HomeSection.addingNewAgency:
      if (selectedOffice == null || selectedCountry == null) {
        return missingSelection(
          message: 'لا يمكن الإضافة بدون اختيار دولة ومكتب.',
          onBack: backToMaleDetails,
        );
      }

      return Center();

  // =========================
  // 6) Other placeholders
  // =========================

  // Housing
    case HomeSection.housingAll:
      return AllSheltersScreen(
        constraints: constraints,
        onAwaitingDeliveryTap: openAwaitingDelivery,
      );
    case HomeSection.housingWaitingDelivery:
      return AwaitingDeliveryScreen(onBack: backToHousing);
    case HomeSection.housingPending:
      return const Center(child: Text('الإيواء - في الانتظار '));
    case HomeSection.housingTransfer:
      return const Center(child: Text('الإيواء - للتنازل'));
    case HomeSection.housingEscape:
      return const Center(child: Text('الإيواء - الهروب'));
    case HomeSection.housingCompany:
      return const Center(child: Text('الإيواء - شركة سكن'));
    case HomeSection.housingFinished:
      return const Center(child: Text('الإيواء - منتهية'));
    case HomeSection.housingDeportation:
      return const Center(child: Text('الإيواء - للترحيل'));
    case HomeSection.housingOther:
      return const Center(child: Text('الإيواء - أخري'));

  // Accounts
    case HomeSection.accountsExternal:
      return const Center(child: Text("External Accounts Screen"));

  // Standalone
    case HomeSection.arrivalOrders:
      if (isManager || isAdmin) {
        return ArrivalOrdersScreen();
      } else {
        return Center(child: Text("هذه الصفحة خاصة بالمسؤولين فقط"));
      }
    case HomeSection.cancelOrders:
      if (isManager || isAdmin) {
        return CancelationOrdersScreen();
      } else {
        return Center(child: Text("هذه الصفحة خاصة بالمسؤولين فقط"));
      }

    case HomeSection.users:
      return UsersScreen(baseUrl: mainUrl);
    case HomeSection.contacts:
      return ContactsScreen();
    case HomeSection.arrivalOrdersHistory:
      if (isManager || isAdmin) {
        return ArrivalRequestsHistoryScreen(
          token: token,
          maxWidth: maxWidth, // اختياري بس مناسب مع بناء الشاشة عندك
          onBack: backToDashboard, // أو أي رجوع يناسب تدفقك
        );
      } else {
        return const Center(child: Text("هذه الصفحة خاصة بالمسؤولين فقط"));
      }
  }
}
