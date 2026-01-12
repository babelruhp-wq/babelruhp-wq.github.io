import '../../../../models/male_agency.dart';

class TableUtils {
  const TableUtils();

  List<MaleAgency> applySearch(List<MaleAgency> list, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return list;

    bool contains(String? v) => (v ?? '').toLowerCase().contains(q);

    return list.where((c) {
      return contains(c.workerName) ||
          contains(c.passportNumber) ||
          contains(c.visaNumber) ||
          contains(c.contractNumber) ||
          contains(c.sponsorName) ||
          contains(c.sponsorPhoneNumber) ||
          contains(c.sponsorSecondaryPhoneNumber) ||
          contains(c.sponsorIDNumber) ||
          contains(c.notes) ||
          contains(c.contractDate);
    }).toList();
  }

  int cmp<T extends Comparable>(T? a, T? b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    return a.compareTo(b);
  }

  List<MaleAgency> applySort({
    required List<MaleAgency> list,
    required int? sortColumnIndex,
    required bool sortAscending,
  }) {
    if (sortColumnIndex == null) return list;
    final sorted = [...list];

    int compare(MaleAgency a, MaleAgency b) {
      int r = 0;

      switch (sortColumnIndex) {
        case 0:
          r = 0;
          break;
        case 1:
          r = a.workerName.toLowerCase().compareTo(b.workerName.toLowerCase());
          break;
        case 2:
          r = a.passportNumber.toLowerCase().compareTo(b.passportNumber.toLowerCase());
          break;
        case 3:
          r = a.workerAge.compareTo(b.workerAge);
          break;
        case 4:
          r = a.sponsorName.toLowerCase().compareTo(b.sponsorName.toLowerCase());
          break;
        case 5:
          r = a.sponsorPhoneNumber.toLowerCase().compareTo(b.sponsorPhoneNumber.toLowerCase());
          break;
        case 6:
          r = (a.sponsorSecondaryPhoneNumber ?? '').toLowerCase().compareTo(
            (b.sponsorSecondaryPhoneNumber ?? '').toLowerCase(),
          );
          break;
        case 7:
          r = a.sponsorIDNumber.compareTo(b.sponsorIDNumber);
          break;
        case 8:
          r = a.visaNumber.toLowerCase().compareTo(b.visaNumber.toLowerCase());
          break;
        case 9:
          r = a.visaType.compareTo(b.visaType);
          break;
        case 10:
          r = a.contractNumber.toLowerCase().compareTo(b.contractNumber.toLowerCase());
          break;
        case 11:
          r = a.contractDate.compareTo(b.contractDate);
          break;
        case 12:
          r = a.contractStatus.compareTo(b.contractStatus);
          break;
        case 13:
          r = a.salary.compareTo(b.salary);
          break;
        case 14:
          r = a.religion.compareTo(b.religion);
          break;
        case 15:
          r = (a.experienced ? 1 : 0).compareTo(b.experienced ? 1 : 0);
          break;
        case 16:
          r = (a.approved ? 1 : 0).compareTo(b.approved ? 1 : 0);
          break;
        case 17:
          r = (a.approvalDate ?? '').compareTo(b.approvalDate ?? '');
          break;
        case 18:
          r = (a.stamped ?? '').compareTo(b.stamped ?? '');
          break;
        case 19:
          r = (a.flightTicketDate ?? '').compareTo(b.flightTicketDate ?? '');
          break;
        case 20:
          r = (a.arrivalDate ?? '').compareTo(b.arrivalDate ?? '');
          break;
        case 21:
          r = (a.notes ?? '').toLowerCase().compareTo((b.notes ?? '').toLowerCase());
          break;
        case 22:
          r = cmp<DateTime>(a.createdAt, b.createdAt);
          break;
        default:
          r = 0;
      }

      return sortAscending ? r : -r;
    }

    sorted.sort(compare);
    return sorted;
  }
}
