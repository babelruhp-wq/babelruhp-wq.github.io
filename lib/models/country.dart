class Country {
  final String countryId;
  final String nameArabic;
  final String nameEnglish;

  const Country({
    required this.countryId,
    required this.nameArabic,
    required this.nameEnglish,
  });

  // ✅ Backward compatibility مع كودك القديم (country.id / nameAr / nameEn)
  String get id => countryId;
  String get nameAr => nameArabic;
  String get nameEn => nameEnglish;

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      countryId: (json['countryId'] ?? json['id'] ?? '').toString(),
      nameArabic: (json['nameArabic'] ?? json['nameAr'] ?? '').toString(),
      nameEnglish: (json['nameEnglish'] ?? json['nameEn'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "countryId": countryId,
    "nameArabic": nameArabic,
    "nameEnglish": nameEnglish,
  };
}
