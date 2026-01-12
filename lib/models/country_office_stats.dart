class CountryOfficeStats {
  final String countryId;
  final String nameArabic;
  final String nameEnglish;
  final int officesNumber;

  const CountryOfficeStats({
    required this.countryId,
    required this.nameArabic,
    required this.nameEnglish,
    required this.officesNumber,
  });

  // ✅ Backward compatibility (لو في كود قديم بيستخدم nameAr/officesCount)
  String get nameAr => nameArabic;
  String get nameEn => nameEnglish;
  int get officesCount => officesNumber;

  factory CountryOfficeStats.fromJson(Map<String, dynamic> json) {
    return CountryOfficeStats(
      countryId: (json['countryId'] ?? '').toString(),
      nameArabic: (json['nameArabic'] ?? '').toString(),
      nameEnglish: (json['nameEnglish'] ?? '').toString(),
      officesNumber: _toInt(json['officesNumber']),
    );
  }

  Map<String, dynamic> toJson() => {
    "countryId": countryId,
    "nameArabic": nameArabic,
    "nameEnglish": nameEnglish,
    "officesNumber": officesNumber,
  };

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}
