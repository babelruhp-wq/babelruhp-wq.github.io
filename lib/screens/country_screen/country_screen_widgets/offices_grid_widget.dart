import 'package:flutter/material.dart';

import '../../../models/office.dart';

import '../../../models/office_female_stats.dart';
import 'office_card_widget.dart';
import 'showDeleteOfficeDialog.dart';
import 'show_edit_office_dialog.dart';

class OfficesGridWidget extends StatelessWidget {
  final double maxWidth;
  final List<Office> offices;

  // ✅ NEW: stats per office
  final Map<String, OfficeFemaleStats> femaleStatsByOffice;
  final bool isStatsLoading;

  final void Function(Office office) onOfficeSelected;
  final VoidCallback onChanged;

  const OfficesGridWidget({
    super.key,
    required this.maxWidth,
    required this.offices,
    required this.onOfficeSelected,
    required this.onChanged,

    // ✅ NEW
    required this.femaleStatsByOffice,
    this.isStatsLoading = false,
  });

  int get gridCount {
    if (maxWidth >= 1200) return 3;
    if (maxWidth >= 800) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    if (offices.isEmpty) {
      return Center(
        child: Text(
          'لا توجد مكاتب لهذه الدولة',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: offices.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 200,
      ),
      itemBuilder: (context, index) {
        final office = offices[index];

        // ✅ Get stats
        final stats = femaleStatsByOffice[office.officeId];
        final total = stats?.total ?? 0;
        final under = stats?.underProcess ?? 0;

        return OfficeCardWidget(
          office: office,

          // ✅ NEW (لازم تضيفهم في OfficeCardWidget)
          maidsTotal: total,
          maidsUnderProcess: under,
          isStatsLoading: isStatsLoading,

          /// ✅ اختيار مكتب
          onTap: () => onOfficeSelected(office),

          /// ✏️ تعديل
          onEdit: () async {
            final ok = await showEditOfficeDialog(context, office);
            if (ok == true) onChanged();
          },

          /// 🗑️ حذف
          onDelete: () async {
            final ok = await showDeleteOfficeDialog(context, office.officeId);
            if (ok == true) onChanged();
          },
        );
      },
    );
  }
}
