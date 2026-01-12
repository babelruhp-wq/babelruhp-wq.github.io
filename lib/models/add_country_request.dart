class AddCountryRequest {
  final String nameArabic;
  final String nameEnglish;

  const AddCountryRequest({
    required this.nameArabic,
    required this.nameEnglish,
  });

  Map<String, dynamic> toJson() => {
    "nameArabic": nameArabic,
    "nameEnglish": nameEnglish,
  };
}
