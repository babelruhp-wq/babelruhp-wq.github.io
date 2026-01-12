class EditOfficeRequest {
  final String officeId;
  final String officeName;

  const EditOfficeRequest({
    required this.officeId,
    required this.officeName,
  });

  Map<String, dynamic> toJson() => {
    "officeId": officeId,
    "officeName": officeName,
  };
}
