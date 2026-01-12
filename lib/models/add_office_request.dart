class AddOfficeRequest {
  final String countryId;
  final String officeName;

  const AddOfficeRequest({
    required this.countryId,
    required this.officeName,
  });

  Map<String, dynamic> toJson() => {
    // ✅ الباك اند عايزها Capital
    "CountryId": countryId,
    "officeName": officeName,
  };
}
