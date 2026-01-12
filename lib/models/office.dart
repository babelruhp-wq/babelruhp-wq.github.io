class Office {
  final String officeId;
  final String officeName;

  const Office({
    required this.officeId,
    required this.officeName,
  });

  factory Office.fromJson(Map<String, dynamic> json) {
    return Office(
      officeId: (json['officeId'] ?? json['id'] ?? '').toString(),
      officeName: (json['officeName'] ?? json['name'] ?? '').toString(),
    );
  }
}
