class ArrivalRequestsHistoryRow {
  final String id; // requestId
  final int rowNo;

  final String workerName;
  final DateTime? arrivalDate;

  final String employeeName;
  final String visaNo;
  final String contractNo;
  final String sponsor;
  final String passportNo;
  final String sponsorId;

  final String approvedBy;
  final int arrivalNote; // 1 or 2

  const ArrivalRequestsHistoryRow({
    required this.id,
    required this.rowNo,
    required this.workerName,
    required this.arrivalDate,
    required this.employeeName,
    required this.visaNo,
    required this.contractNo,
    required this.sponsor,
    required this.passportNo,
    required this.sponsorId,
    required this.approvedBy,
    required this.arrivalNote,
  });

  ArrivalRequestsHistoryRow copyWith({int? rowNo}) {
    return ArrivalRequestsHistoryRow(
      id: id,
      rowNo: rowNo ?? this.rowNo,
      workerName: workerName,
      arrivalDate: arrivalDate,
      employeeName: employeeName,
      visaNo: visaNo,
      contractNo: contractNo,
      sponsor: sponsor,
      passportNo: passportNo,
      sponsorId: sponsorId,
      approvedBy: approvedBy,
      arrivalNote: arrivalNote,
    );
  }
}
