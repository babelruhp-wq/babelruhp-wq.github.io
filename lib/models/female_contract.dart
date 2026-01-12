class FemaleContract {
  final String id; // لازم للتعديل/الحذف
  final DateTime? createdAt;

  final String workerName;
  final int workerAge;
  final int religion; // 1..3
  final bool experienced;
  final int salary;

  final int visaType; // 1..2
  final String visaNumber;

  final String contractDate; // yyyy-MM-dd
  final String contractNumber;
  final String passportNumber;

  final String sponsorName;
  final String sponsorIDNumber;
  final String sponsorPhoneNumber;
  final String? sponsorSecondaryPhoneNumber;

  final String? notes;

  final int contractStatus; // 1..5
  final bool approved;
  final String? approvalDate;

  final String? stamped;
  final String? flightTicketDate;
  final String? arrivalDate;
  final int? adminRequestsStatus;

  final String createdBy;
  final int contractType;

  const FemaleContract({
    required this.id,
    required this.createdAt,
    required this.workerName,
    required this.workerAge,
    required this.religion,
    required this.experienced,
    required this.salary,
    required this.visaType,
    required this.visaNumber,
    required this.contractDate,
    required this.contractNumber,
    required this.passportNumber,
    required this.sponsorName,
    required this.sponsorIDNumber,
    required this.sponsorPhoneNumber,
    this.sponsorSecondaryPhoneNumber,
    this.notes,
    required this.contractStatus,
    required this.approved,
    this.approvalDate,
    this.stamped,
    this.flightTicketDate,
    this.arrivalDate,
    this.adminRequestsStatus,
    required this.createdBy,
    required this.contractType,
  });

  // =========================
  // Parsers
  // =========================
  static String _s(dynamic v) => (v ?? '').toString();

  static int _i(dynamic v) => int.tryParse(_s(v)) ?? 0;

  static bool _b(dynamic v) {
    if (v is bool) return v;
    final t = _s(v).trim().toLowerCase();
    return t == 'true' || t == '1';
  }

  static DateTime? _dt(dynamic v) {
    final s = _s(v).trim();
    if (s.isEmpty) return null;

    final match = RegExp(
      r'^(.+?)(?:\.(\d+))?(Z|[+-]\d{2}:?\d{2})?$',
    ).firstMatch(s);
    if (match == null) return DateTime.tryParse(s);

    final base = match.group(1)!;
    var frac = match.group(2);
    final tz = match.group(3) ?? '';

    if (frac == null) return DateTime.tryParse('$base$tz');

    if (frac.length > 6) frac = frac.substring(0, 6);
    if (frac.length < 6) frac = frac.padRight(6, '0');

    return DateTime.tryParse('$base.$frac$tz');
  }

  static DateTime? _dateOnly(dynamic v) {
    final s = _s(v).trim();
    if (s.isEmpty) return null;
    return DateTime.tryParse(s); // "yyyy-MM-dd"
  }

  // ✅ مفيد للـ prefill في form
  DateTime? get contractDateAsDate => _dateOnly(contractDate);

  DateTime? get approvalDateAsDate => _dateOnly(approvalDate);

  DateTime? get stampedAsDate => _dateOnly(stamped);

  DateTime? get flightTicketDateAsDate => _dateOnly(flightTicketDate);

  DateTime? get arrivalDateAsDate => _dateOnly(arrivalDate);

  // =========================
  // JSON -> Model
  // =========================
  factory FemaleContract.fromJson(Map<String, dynamic> json) {
    final id = _s(
      json['id'] ??
          json['contractId'] ??
          json['femaleContractId'] ??
          json['Id'],
    );

    return FemaleContract(
      id: id,
      createdAt: _dt(json['createdAt']),
      workerName: _s(json['workerName']),
      workerAge: _i(json['workerAge']),
      religion: _i(json['religion']),
      experienced: _b(json['experienced']),
      salary: _i(json['salary']),
      visaType: _i(json['visaType']),
      visaNumber: _s(json['visaNumber']),
      contractDate: _s(json['contractDate']),
      contractNumber: _s(json['contractNumber']),
      passportNumber: _s(json['passportNumber']),
      sponsorName: _s(json['sponsorName']),
      sponsorIDNumber: _s(json['sponsorIDNumber']),
      sponsorPhoneNumber: _s(json['sponsorPhoneNumber']),
      sponsorSecondaryPhoneNumber: json['sponsorSecondaryPhoneNumber'] == null
          ? null
          : _s(json['sponsorSecondaryPhoneNumber']),
      notes: json['notes'] == null ? null : _s(json['notes']),
      contractStatus: _i(json['contractStatus']),
      approved: _b(json['approved']),
      approvalDate: json['approvalDate'] == null
          ? null
          : _s(json['approvalDate']),
      stamped: json['stamped'] == null ? null : _s(json['stamped']),
      flightTicketDate: json['flightTicketDate'] == null
          ? null
          : _s(json['flightTicketDate']),
      arrivalDate: json['arrivalDate'] == null ? null : _s(json['arrivalDate']),
      adminRequestsStatus: json['adminRequestsStatus'] == null
          ? null
          : _i(json['adminRequestsStatus']),
      createdBy: _s(json['createdBy']),
      contractType: json["contractType"],
    );
  }

  // =========================
  // copyWith
  // =========================
  FemaleContract copyWith({
    String? id,
    DateTime? createdAt,
    String? workerName,
    int? workerAge,
    int? religion,
    bool? experienced,
    int? salary,
    int? visaType,
    String? visaNumber,
    String? contractDate,
    String? contractNumber,
    String? passportNumber,
    String? sponsorName,
    String? sponsorIDNumber,
    String? sponsorPhoneNumber,
    String? sponsorSecondaryPhoneNumber,
    String? notes,
    int? contractStatus,
    bool? approved,
    String? approvalDate,
    String? stamped,
    String? flightTicketDate,
    String? arrivalDate,
    int? adminRequestsStatus,
    String? createdBy,
    int? contractType,
  }) {
    return FemaleContract(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      workerName: workerName ?? this.workerName,
      workerAge: workerAge ?? this.workerAge,
      religion: religion ?? this.religion,
      experienced: experienced ?? this.experienced,
      salary: salary ?? this.salary,
      visaType: visaType ?? this.visaType,
      visaNumber: visaNumber ?? this.visaNumber,
      contractDate: contractDate ?? this.contractDate,
      contractNumber: contractNumber ?? this.contractNumber,
      passportNumber: passportNumber ?? this.passportNumber,
      sponsorName: sponsorName ?? this.sponsorName,
      sponsorIDNumber: sponsorIDNumber ?? this.sponsorIDNumber,
      sponsorPhoneNumber: sponsorPhoneNumber ?? this.sponsorPhoneNumber,
      sponsorSecondaryPhoneNumber:
          sponsorSecondaryPhoneNumber ?? this.sponsorSecondaryPhoneNumber,
      notes: notes ?? this.notes,
      contractStatus: contractStatus ?? this.contractStatus,
      approved: approved ?? this.approved,
      approvalDate: approvalDate ?? this.approvalDate,
      stamped: stamped ?? this.stamped,
      flightTicketDate: flightTicketDate ?? this.flightTicketDate,
      arrivalDate: arrivalDate ?? this.arrivalDate,
      adminRequestsStatus: adminRequestsStatus ?? this.adminRequestsStatus,
      createdBy: createdBy ?? this.createdBy, contractType: this.contractType,
    );
  }

  // =========================
  // ✅ Payload للـ Add/Update
  // - officeId مطلوب في Add
  // - includeCreatedBy: خليها true في الإضافة فقط، false في التعديل
  // - createdByOverride: الاسم/اليوزر اللي جاي من Auth (بدون تدخل المستخدم)
  // =========================
  Map<String, dynamic> toPayloadForSave({
    String? officeId,
    bool includeCreatedBy = false,
    String? createdByOverride,
  }) {
    final payload = <String, dynamic>{
      if (officeId != null && officeId.trim().isNotEmpty)
        "officeId": officeId.trim(),

      "workerName": workerName,
      "workerAge": workerAge,
      "religion": religion,
      "experienced": experienced,
      "salary": salary,

      "visaType": visaType,
      "visaNumber": visaNumber,

      "contractDate": contractDate,
      "contractNumber": contractNumber,
      "passportNumber": passportNumber,

      "sponsorName": sponsorName,
      "sponsorIDNumber": sponsorIDNumber,
      "sponsorPhoneNumber": sponsorPhoneNumber,

      "contractStatus": contractStatus,
      "approved": approved,
      "contractType": contractType,
    };

    if (sponsorSecondaryPhoneNumber != null &&
        sponsorSecondaryPhoneNumber!.trim().isNotEmpty) {
      payload["sponsorSecondaryPhoneNumber"] = sponsorSecondaryPhoneNumber!
          .trim();
    }

    if (notes != null && notes!.trim().isNotEmpty) {
      payload["notes"] = notes!.trim();
    }

    if (approved && approvalDate != null && approvalDate!.trim().isNotEmpty) {
      payload["approvalDate"] = approvalDate!.trim();
    } else {
      payload["approvalDate"] = null;
    }

    payload["stamped"] = (stamped != null && stamped!.trim().isNotEmpty)
        ? stamped!.trim()
        : null;

    payload["flightTicketDate"] =
        (flightTicketDate != null && flightTicketDate!.trim().isNotEmpty)
        ? flightTicketDate!.trim()
        : null;

    payload["arrivalDate"] =
        (arrivalDate != null && arrivalDate!.trim().isNotEmpty)
        ? arrivalDate!.trim()
        : null;

    payload["adminRequestsStatus"] = adminRequestsStatus;

    // ✅ أهم نقطة: createdBy يتبعت فقط في الإضافة (submit)
    if (includeCreatedBy) {
      final cb = (createdByOverride ?? createdBy).trim();
      if (cb.isNotEmpty) payload["createdBy"] = cb;
    }

    return payload;
  }
}
