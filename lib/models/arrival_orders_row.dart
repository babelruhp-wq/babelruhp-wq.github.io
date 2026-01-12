class ArrivalOrdersRow {
  final String id;
  final int rowNo;

  final String employeeName;
  final String passportNo;
  final String visaNo;
  final String contractNo;
  final String sponsor;
  final String nationalId;

  final int description;
  final bool supervisionFees;
  final bool contractFees;

  final String employee;
  final DateTime createdAt;
  final DateTime? updatedAt;

  final ArrivalOrderStatus status;

  const ArrivalOrdersRow({
    required this.id,
    required this.rowNo,
    required this.employeeName,
    required this.passportNo,
    required this.visaNo,
    required this.contractNo,
    required this.sponsor,
    required this.nationalId,
    required this.description,
    required this.supervisionFees,
    required this.contractFees,
    required this.employee,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
  });

  ArrivalOrdersRow copyWith({ArrivalOrderStatus? status}) {
    return ArrivalOrdersRow(
      id: id,
      rowNo: rowNo,
      employeeName: employeeName,
      passportNo: passportNo,
      visaNo: visaNo,
      contractNo: contractNo,
      sponsor: sponsor,
      nationalId: nationalId,
      description: description,
      supervisionFees: supervisionFees,
      contractFees: contractFees,
      employee: employee,
      createdAt: createdAt,
      updatedAt: updatedAt,
      status: status ?? this.status,
    );
  }
}

enum ArrivalOrderStatus { newOrder, approved, rejected }
