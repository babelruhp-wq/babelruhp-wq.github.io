class AwaitingDeliveryRow {
  final int index; // #
  final String workerName;
  final String passportNo;
  final String sponsor;
  final String nationalId;
  final String officeName;
  final String arrival;
  final String notes;
  final String actions; // أو سيبها فاضية

  const AwaitingDeliveryRow({
    required this.index,
    required this.workerName,
    required this.passportNo,
    required this.sponsor,
    required this.nationalId,
    required this.officeName,
    required this.arrival,
    required this.notes,
    this.actions = '',
  });
}
