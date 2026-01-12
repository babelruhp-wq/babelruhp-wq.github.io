class CancelationOrdersRow {
  final String id;
  final int rowNo;

  final String employeeName;   // workerName
  final String passportNo;     // passportNumber
  final String visaNo;         // visaNumber
  final String contractNo;     // contractNumber
  final String sponsor;        // sponsorName
  final String nationalId;     // sponsorId

  final String description;    // cancelationReason
  final int cancelationBy;     // ✅ 1=office, 2=client

  final String employee;       // employeeName (creator)
  final DateTime createdAt;
  final DateTime? updatedAt;

  final CancelationOrderStatus status;

  const CancelationOrdersRow({
    required this.id,
    required this.rowNo,
    required this.employeeName,
    required this.passportNo,
    required this.visaNo,
    required this.contractNo,
    required this.sponsor,
    required this.nationalId,
    required this.description,
    required this.cancelationBy, // ✅
    required this.employee,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
  });

  CancelationOrdersRow copyWith({
    CancelationOrderStatus? status,
    int? cancelationBy,
  }) {
    return CancelationOrdersRow(
      id: id,
      rowNo: rowNo,
      employeeName: employeeName,
      passportNo: passportNo,
      visaNo: visaNo,
      contractNo: contractNo,
      sponsor: sponsor,
      nationalId: nationalId,
      description: description,
      cancelationBy: cancelationBy ?? this.cancelationBy,
      employee: employee,
      createdAt: createdAt,
      updatedAt: updatedAt,
      status: status ?? this.status,
    );
  }
}

enum CancelationOrderStatus { newOrder, approved, rejected }
