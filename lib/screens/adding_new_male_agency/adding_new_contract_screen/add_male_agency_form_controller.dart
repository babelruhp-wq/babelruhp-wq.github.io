import 'package:babel_final_project/models/male_agency.dart';
import 'package:flutter/material.dart';

import '../../../localization/translator.dart';

class AddMaleAgencyFormController {
  // =========================
  // Controllers
  // =========================
  final workerNameCtrl = TextEditingController();
  final passportCtrl = TextEditingController();
  final ageCtrl = TextEditingController();
  final salaryCtrl = TextEditingController();

  final visaNumberCtrl = TextEditingController();
  final contractNumberCtrl = TextEditingController();

  final sponsorNameCtrl = TextEditingController();
  final sponsorPhoneCtrl = TextEditingController(); // UI: 8 digits
  final sponsorAltPhoneCtrl = TextEditingController(); // optional
  final sponsorIdCtrl = TextEditingController(); // 10 digits

  final notesCtrl = TextEditingController();

  // =========================
  // Date controllers
  // =========================
  final contractDateCtrl = TextEditingController();
  final approvalDateCtrl = TextEditingController();
  final stampedDateCtrl = TextEditingController();
  final flightDateCtrl = TextEditingController();
  final arrivalDateCtrl = TextEditingController();

  // =========================
  // Dropdown values (strings for UI)
  // =========================
  String? religionValue; // '1','2','3'
  String? visaTypeValue; // '1','2'
  String? experienceValue; // 'true'/'false'

  /// ✅ زي الفيميل: نوع العقد (1 = معين باسم, 2 = حسب المواصفات)
  String? contractTypeValue; // '1' or '2'

  // =========================
  // Dates
  // =========================
  DateTime? contractDate; // required
  bool approved = false;
  DateTime? approvalDate;
  DateTime? stampedDate;
  DateTime? flightDate;
  DateTime? arrivalDate;

  // =========================
  // Dispose
  // =========================
  void dispose() {
    workerNameCtrl.dispose();
    passportCtrl.dispose();
    ageCtrl.dispose();
    salaryCtrl.dispose();
    visaNumberCtrl.dispose();
    contractNumberCtrl.dispose();
    sponsorNameCtrl.dispose();
    sponsorPhoneCtrl.dispose();
    sponsorAltPhoneCtrl.dispose();
    sponsorIdCtrl.dispose();
    notesCtrl.dispose();

    contractDateCtrl.dispose();
    approvalDateCtrl.dispose();
    stampedDateCtrl.dispose();
    flightDateCtrl.dispose();
    arrivalDateCtrl.dispose();
  }

  // =========================
  // Validators
  // =========================
  String? requiredValidator(String? v, String msg) {
    if (v == null || v.trim().isEmpty) return msg;
    return null;
  }

  String? passportValidator(BuildContext context, String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return tr(context, 'enter_passport_number');
    final ok = RegExp(r'^[A-Za-z0-9]{5,20}$').hasMatch(s);
    if (!ok) return tr(context, 'invalid_passport');
    return null;
  }

  String? ageValidator(BuildContext context, String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return tr(context, 'enter_age');
    final n = int.tryParse(s);
    if (n == null) return tr(context, 'invalid_age');
    if (n < 1 || n > 150) return tr(context, 'age_range_1_150');
    return null;
  }

  String? salaryValidator(BuildContext context, String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return tr(context, 'enter_salary');
    final n = int.tryParse(s);
    if (n == null) return tr(context, 'invalid_salary');
    if (n <= 0) return tr(context, 'salary_must_be_positive');
    return null;
  }

  String? contractNoValidator(BuildContext context, String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return tr(context, 'enter_contract_number');
    final ok = RegExp(r'^[A-Za-z0-9\-_]{3,30}$').hasMatch(s);
    if (!ok) return tr(context, 'invalid_contract_number');
    return null;
  }

  String? visaNoValidator(BuildContext context, String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return tr(context, 'enter_visa_number');
    final ok = RegExp(r'^[A-Za-z0-9\-_]{3,30}$').hasMatch(s);
    if (!ok) return tr(context, 'invalid_visa_number');
    return null;
  }

  String? dropdownRequired(String? v, String msg) {
    if (v == null || v.trim().isEmpty) return msg;
    return null;
  }

  String? phone8Validator(
      BuildContext context,
      String? v, {
        required bool requiredField,
      }) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return requiredField ? tr(context, 'enter_phone') : null;
    if (!RegExp(r'^\d+$').hasMatch(s)) return tr(context, 'invalid_phone');
    if (s.length != 8) return tr(context, 'phone_must_be_8_digits');
    return null;
  }

  String? id10Validator(BuildContext context, String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return tr(context, 'enter_id_number');
    if (!RegExp(r'^\d+$').hasMatch(s)) return tr(context, 'invalid_id_number');
    if (s.length != 10) return tr(context, 'id_must_be_10_digits');
    return null;
  }

  String? notesValidator(BuildContext context, String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return null;
    if (s.length > 500) return tr(context, 'notes_too_long');
    return null;
  }

  /// ✅ إجباري فقط لو approved
  String? approvalDateValidator(BuildContext context) {
    if (!approved) return null;
    if (approvalDate == null) return tr(context, 'choose_approval_date');
    return null;
  }

  // =========================
  // Section error checks
  // =========================
  bool contractHasErrors(BuildContext context) {
    if (visaNoValidator(context, visaNumberCtrl.text) != null) return true;
    if (contractNoValidator(context, contractNumberCtrl.text) != null) return true;

    if (dropdownRequired(visaTypeValue, tr(context, 'choose_visa_type')) != null) return true;

    // ✅ نوع العقد (1/2) إجباري
    if (dropdownRequired(contractTypeValue, tr(context, 'choose_contract_type')) != null) return true;

    if (contractDate == null) return true;
    return false;
  }

  bool workerHasErrors(BuildContext context) {
    if (workerNameCtrl.text.trim().isEmpty) return true;
    if (passportValidator(context, passportCtrl.text) != null) return true;
    if (ageValidator(context, ageCtrl.text) != null) return true;
    if (salaryValidator(context, salaryCtrl.text) != null) return true;

    if (dropdownRequired(religionValue, tr(context, 'choose_religion')) != null) return true;
    if (dropdownRequired(experienceValue, tr(context, 'choose_experience_value')) != null) return true;

    return false;
  }

  bool sponsorHasErrors(BuildContext context) {
    if (sponsorNameCtrl.text.trim().isEmpty) return true;
    if (phone8Validator(context, sponsorPhoneCtrl.text, requiredField: true) != null) return true;
    if (phone8Validator(context, sponsorAltPhoneCtrl.text, requiredField: false) != null) return true;
    if (id10Validator(context, sponsorIdCtrl.text) != null) return true;
    return false;
  }

  // =========================
  // Date helpers
  // =========================
  String _toIsoDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  String _fullKsaPhone(String digits8) => '+9665$digits8';

  String _extract8DigitsFromKsa(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    if (digits.length <= 8) return digits;
    return digits.substring(digits.length - 8);
  }

  // =========================
  // Setters (Dates)
  // =========================
  void setContractDate(DateTime? d) {
    contractDate = d;
    contractDateCtrl.text = d == null ? '' : _toIsoDate(d);
  }

  void setApprovalDate(DateTime? d) {
    approvalDate = d;
    approvalDateCtrl.text = d == null ? '' : _toIsoDate(d);
  }

  void setStampedDate(DateTime? d) {
    stampedDate = d;
    stampedDateCtrl.text = d == null ? '' : _toIsoDate(d);
  }

  void setFlightDate(DateTime? d) {
    flightDate = d;
    flightDateCtrl.text = d == null ? '' : _toIsoDate(d);
  }

  void setArrivalDate(DateTime? d) {
    arrivalDate = d;
    arrivalDateCtrl.text = d == null ? '' : _toIsoDate(d);
  }

  void clearApprovalDate() => setApprovalDate(null);
  void clearStampedDate() => setStampedDate(null);
  void clearFlightDate() => setFlightDate(null);
  void clearArrivalDate() => setArrivalDate(null);

  // =========================
  // Approved behavior
  // =========================
  void setApproved(bool v) {
    if (approved == v) return;

    approved = v;

    if (!approved) {
      approvalDate = null;
      approvalDateCtrl.text = '';
    }
  }

  // =========================
  // Prefill (Edit)
  // =========================
  void prefillFromAgency(MaleAgency c) {
    workerNameCtrl.text = c.workerName;
    passportCtrl.text = c.passportNumber;
    ageCtrl.text = c.workerAge.toString();
    salaryCtrl.text = c.salary.toString();

    religionValue = c.religion.toString();
    experienceValue = c.experienced ? 'true' : 'false';

    visaTypeValue = c.visaType.toString();
    visaNumberCtrl.text = c.visaNumber;
    contractNumberCtrl.text = c.contractNumber;

    // ✅ نوع العقد 1/2 (لو موجود في موديلك)
    // لو contractType nullable:
    contractTypeValue = (c.contractType ?? 0).toString();

    setContractDate(DateTime.tryParse(c.contractDate));

    sponsorNameCtrl.text = c.sponsorName;
    sponsorIdCtrl.text = c.sponsorIDNumber;

    sponsorPhoneCtrl.text = _extract8DigitsFromKsa(c.sponsorPhoneNumber);
    sponsorAltPhoneCtrl.text = _extract8DigitsFromKsa(
      c.sponsorSecondaryPhoneNumber ?? '',
    );

    notesCtrl.text = (c.notes ?? '');

    approved = c.approved;

    if (c.approved && (c.approvalDate ?? '').trim().isNotEmpty) {
      setApprovalDate(DateTime.tryParse(c.approvalDate!));
    } else {
      approvalDate = null;
      approvalDateCtrl.text = '';
    }

    if ((c.stamped ?? '').trim().isNotEmpty) {
      setStampedDate(DateTime.tryParse(c.stamped!));
    } else {
      stampedDate = null;
      stampedDateCtrl.text = '';
    }

    if ((c.flightTicketDate ?? '').trim().isNotEmpty) {
      setFlightDate(DateTime.tryParse(c.flightTicketDate!));
    } else {
      flightDate = null;
      flightDateCtrl.text = '';
    }

    if ((c.arrivalDate ?? '').trim().isNotEmpty) {
      setArrivalDate(DateTime.tryParse(c.arrivalDate!));
    } else {
      setArrivalDate(null);
    }
  }

  // =========================
  // Payload builder
  // =========================
  Map<String, dynamic> buildPayload({
    required BuildContext context,
    required String officeId,
  }) {
    return <String, dynamic>{
      "officeId": officeId,

      "workerName": workerNameCtrl.text.trim(),
      "workerAge": int.parse(ageCtrl.text.trim()),
      "religion": int.parse(religionValue!),
      "experienced": experienceValue == 'true',
      "salary": int.parse(salaryCtrl.text.trim()),

      "visaType": int.parse(visaTypeValue!),
      "visaNumber": visaNumberCtrl.text.trim(),

      // ✅ نوع العقد 1/2
      "contractType": int.parse(contractTypeValue!),

      "contractDate": _toIsoDate(contractDate!),
      "contractNumber": contractNumberCtrl.text.trim(),
      "passportNumber": passportCtrl.text.trim(),

      "sponsorName": sponsorNameCtrl.text.trim(),
      "sponsorIDNumber": sponsorIdCtrl.text.trim(),
      "sponsorPhoneNumber": _fullKsaPhone(sponsorPhoneCtrl.text.trim()),

      // ✅ لا نبعت contractStatus (الباك إند بيحسبه)
      "approved": approved,

      "sponsorSecondaryPhoneNumber": sponsorAltPhoneCtrl.text.trim().isNotEmpty
          ? _fullKsaPhone(sponsorAltPhoneCtrl.text.trim())
          : null,

      "notes": notesCtrl.text.trim().isNotEmpty ? notesCtrl.text.trim() : null,

      "approvalDate": (approved && approvalDate != null) ? _toIsoDate(approvalDate!) : null,

      "stamped": stampedDate != null ? _toIsoDate(stampedDate!) : null,
      "flightTicketDate": flightDate != null ? _toIsoDate(flightDate!) : null,
      "arrivalDate": arrivalDate != null ? _toIsoDate(arrivalDate!) : null,
    };
  }
}
