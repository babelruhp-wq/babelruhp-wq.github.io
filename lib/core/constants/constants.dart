//dashboard constants
import 'package:flutter/material.dart';

final mainUrl = 'https://babel.runasp.net';

final List<Map<String, dynamic>> menuItems = [
  {
    'icon': Icons.grid_view_sharp,
    'titleKey': 'external_offices',
    'subMenu': [
      {'titleKey': 'dashboard', 'section': HomeSection.dashboardHome},

    ],
  },

  {
    'icon': Icons.home_work,
    'titleKey': 'housing',
    'section': HomeSection.housingAll,
    'subMenu': [],
  },

  {
    'icon': Icons.assignment,
    'titleKey': 'orders',
    'subMenu': [
      {'titleKey': 'arrival_orders', 'section': HomeSection.arrivalOrders},
      {'titleKey': 'cancel_orders', 'section': HomeSection.cancelOrders}
    ],
  },

  {
    'icon': Icons.account_balance_wallet,
    'titleKey': 'accounts_external',
    'section': HomeSection.accountsExternal,
    'subMenu': [],
  },

  {
    'icon': Icons.supervised_user_circle_sharp,
    'titleKey': 'users',
    'section': HomeSection.users,
    'subMenu': [],
  },



  {
    'icon': Icons.person,
    'titleKey': 'contacts',
    'section': HomeSection.contacts,
    'subMenu': [],
  },

  {
    'icon': Icons.history,
    'titleKey': 'arrival_orders_history',
    'section': HomeSection.arrivalOrdersHistory,
    'subMenu': [],
  },
];

//-----------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------
enum HomeSection {
  // المكاتب الخارجية
  dashboardHome,
  offices,
  officeDetails,
  addingNewContract,
  // الإيواء
  housingAll,
  housingPending,
  housingWaitingDelivery,
  housingTransfer,
  housingEscape,
  housingCompany,
  housingFinished,
  housingDeportation,
  housingOther,
  officeFemaleDetails,
  cancelOrders,
  /// ✅ جدول العقود النسائية (حسب الفلتر)
  femaleContractsTable,
  officeMaleDetails,
  addingNewAgency,
  // الطلبات
  arrivalOrders,

  // الحسابات
  accountsExternal,
  maleAgenciesTable,
  // باقي الأقسام
  users,
  contacts,
  arrivalOrdersHistory,
}

//-----------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------
final List<Map<String, dynamic>> allShelters = [
  {'key': 'waiting_delivery', 'number': 704, 'color': 0xff3f97d8},
  {'key': 'waiting', 'number': 6, 'color': 0xffe27f30},
  {'key': 'for_transfer', 'number': 8, 'color': 0xff3a4262},
  {'key': 'escape', 'number': 1, 'color': 0xffe34f40},
  {'key': 'selsak_company', 'number': 0, 'color': 0xff3a4262},
  {'key': 'expired', 'number': 0, 'color': 0xff3a4262},
  {'key': 'for_deportation', 'number': 0, 'color': 0xff3a4262},
  {'key': 'others', 'number': 0, 'color': 0xff3a4262},
];

//----------------------------------------------------------------------------------------------------------------------------
final List<Map<String, dynamic>> allFemaleDetails = [
  {'nameKey': 'all_workers', 'color': 0xff3a4262},
  {'nameKey': 'new', 'color': 0xff34ae65},
  {'nameKey': 'under_process', 'color': 0xffe27f30},
  {'nameKey': 'rejected',  'color': 0xffe34f40},
  {'nameKey': 'arrival',  'color': 0xff34ae65},
  {'nameKey': 'finished', 'color': 0xffe34f40},
];

final List<Map<String, dynamic>> allMaleDetails = [
  {'nameKey': 'all_workers', 'color': 0xff3a4262},
  {'nameKey': 'new',  'color': 0xff34ae65},
  {'nameKey': 'under_process',  'color': 0xffe27f30},
  {'nameKey': 'rejected',  'color': 0xffe34f40},
  {'nameKey': 'arrival', 'color': 0xff34ae65},
  {'nameKey': 'finished',  'color': 0xffe34f40},
];

