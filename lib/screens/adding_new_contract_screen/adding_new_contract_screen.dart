import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/auth/auth_provider.dart';
import '../../features/add_new_contract/add_female_contract_cubit.dart';
import '../../features/add_new_contract/add_female_contract_state.dart';
import '../../localization/translator.dart';
import '../../models/female_contract.dart';
import '../../services/contracts_service.dart';

import '../adding_new_contract_screen/adding_new_contract_screen/action_buttons.dart';
import '../adding_new_contract_screen/adding_new_contract_screen/contract_section.dart';
import '../adding_new_contract_screen/adding_new_contract_screen/form_fields.dart';
import '../adding_new_contract_screen/adding_new_contract_screen/two_columns.dart';
import '../adding_new_contract_screen/adding_new_contract_screen/add_female_contract_form_controller.dart';
import '../adding_new_contract_screen/adding_new_contract_screen/date_field.dart';

/// ✅ Call this بدل Navigator.push
Future<bool?> showAddFemaleContractDialog(
  BuildContext context, {
  required String officeId,
  required String countryName,
  required String officeName,
  required String baseUrl,
  FemaleContract? initialContract, // null => add
}) async {
  final w = MediaQuery.of(context).size.width;
  final isWide = w >= 900;

  // ✅ Mobile: BottomSheet (full-ish)
  if (!isWide) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.95,
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: AddFemaleContractDialogBody(
            officeId: officeId,
            countryName: countryName,
            officeName: officeName,
            baseUrl: baseUrl,
            initialContract: initialContract,

            // ✅ مهم: استخدم sheetCtx مش context الخارجي
            onClose: (ok) => Navigator.of(sheetCtx).pop(ok),
          ),
        );
      },
    );
  }

  // ✅ Web/Desktop: Dialog
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) {
      return Dialog(
        insetPadding: const EdgeInsets.all(18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 980,
          height: 720,
          child: AddFemaleContractDialogBody(
            officeId: officeId,
            countryName: countryName,
            officeName: officeName,
            baseUrl: baseUrl,
            initialContract: initialContract,

            // ✅ مهم: استخدم dialogCtx مش context الخارجي
            onClose: (ok) => Navigator.of(dialogCtx).pop(ok),
          ),
        ),
      );
    },
  );
}

Future<bool> _showConfirmSaveDialog(BuildContext context) async {
  final isWide = MediaQuery.of(context).size.width >= 700;

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) {
      final baseTextStyle = GoogleFonts.cairo(
        fontSize: 13.5,
        height: 1.4,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF2B3250),
      );

      return Theme(
        // ✅ يخلي Button texts كايرو تلقائيًا داخل الديالوج
        data: Theme.of(context).copyWith(
          textTheme: Theme.of(
            context,
          ).textTheme.apply(fontFamily: GoogleFonts.cairo().fontFamily),
        ),
        child: DefaultTextStyle(
          style: baseTextStyle,
          child: Dialog(
            insetPadding: EdgeInsets.all(isWide ? 24 : 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 520,
                minWidth: isWide ? 520 : 320,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF4E5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFFFD7A6)),
                          ),
                          child: const Icon(
                            Icons.verified_user_rounded,
                            color: Color(0xFFB25E00),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'تأكيد حفظ العقد',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF1F2A44),
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'إغلاق',
                          onPressed: () => Navigator.of(dialogCtx).pop(false),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Body message
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F9FC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE7ECF4)),
                      ),
                      child: Text(
                        'لا يمكن تغيير البيانات الأساسية مرة أخرى إلا من خلال المسؤول.\n'
                        'يرجى التأكد من صحة البيانات قبل الحفظ.',
                        style: GoogleFonts.cairo(
                          fontSize: 13.5,
                          height: 1.45,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2B3250),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(dialogCtx).pop(false),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(
                                color: Colors.black.withOpacity(0.12),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              'رجوع للتعديل',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(dialogCtx).pop(true),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: const Color(0xFF175CD3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'تأكيد الحفظ',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w900,
                                fontSize: 13.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );

  return result == true;
}

/// ✅ نفس الفورم بتاعك لكن داخل Dialog/BottomSheet
class AddFemaleContractDialogBody extends StatefulWidget {
  final String officeId;
  final String countryName;
  final String officeName;
  final String baseUrl;
  final FemaleContract? initialContract;

  /// true=changed, false=cancel
  final ValueChanged<bool> onClose;

  const AddFemaleContractDialogBody({
    super.key,
    required this.officeId,
    required this.countryName,
    required this.officeName,
    required this.baseUrl,
    required this.initialContract,
    required this.onClose,
  });

  @override
  State<AddFemaleContractDialogBody> createState() =>
      _AddFemaleContractDialogBodyState();
}

class _AddFemaleContractDialogBodyState
    extends State<AddFemaleContractDialogBody> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  bool _officeExpanded = true;
  bool _workerExpanded = true;
  bool _contractExpanded = true;
  bool _sponsorExpanded = true;
  bool _notesExpanded = true;

  late final AddFemaleContractFormController form;

  bool get isEdit => widget.initialContract != null;

  // ✅ يمنع double close / double pop
  bool _didClose = false;

  void _closeOnce(bool ok) {
    if (_didClose) return;
    _didClose = true;
    if (!mounted) return;
    widget.onClose(ok);
  }

  @override
  void initState() {
    super.initState();
    form = AddFemaleContractFormController();

    final c = widget.initialContract;
    if (c != null) {
      form.prefillFromContract(c);
    }
  }

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required DateTime? current,
    required ValueChanged<DateTime?> onPicked,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    onPicked(picked);
    if (mounted) setState(() {});
  }

  Future<void> _submit(AddFemaleContractCubit cubit) async {
    FocusScope.of(context).unfocus();

    final formOk = _formKey.currentState?.validate() ?? false;

    final workerErr = form.workerHasErrors(context);
    final contractErr = form.contractHasErrors(context);
    final sponsorErr = form.sponsorHasErrors(context);
    final notesErr = form.notesValidator(context, form.notesCtrl.text) != null;
    final approvalErr = form.approvalDateValidator(context) != null;

    if (!formOk ||
        workerErr ||
        contractErr ||
        sponsorErr ||
        notesErr ||
        approvalErr) {
      setState(() {
        _autoValidateMode = AutovalidateMode.always;
        if (workerErr) _workerExpanded = true;
        if (contractErr) _contractExpanded = true;
        if (sponsorErr) _sponsorExpanded = true;
        if (notesErr || approvalErr) _notesExpanded = true;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr(context, 'please_fix_errors'))));
      return;
    }

    final payload = form.buildPayload(
      context: context,
      officeId: widget.officeId,
    );

    if (isEdit) {
      final id = widget.initialContract!.id.trim();
      if (id.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr(context, 'missing_contract_id'))),
        );
        return;
      }
      await cubit.update(contractId: id, payload: payload);
    } else {
      await cubit.submit(payload);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = isEdit
        ? tr(context, 'edit')
        : tr(context, 'add_new_contract');

    return BlocProvider(
      create: (ctx) => AddFemaleContractCubit(
        service: ContractsService(baseUrl: widget.baseUrl),
        auth: ctx.read<AuthProvider>(), // ✅ ctx مش context
      ),
      child: BlocConsumer<AddFemaleContractCubit, AddFemaleContractState>(
        listener: (context, state) {
          if (state.status == AddFemaleContractStatus.success) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(tr(context, "saved_successfully"))),
            );
            _closeOnce(true);
          }

          if (state.status == AddFemaleContractStatus.error) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? "Error")),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<AddFemaleContractCubit>();
          final isLoading = state.status == AddFemaleContractStatus.loading;
          return PopScope(
            canPop: !isLoading,
            onPopInvoked: (didPop) {
              // ✅ لو اتعمل pop فعلاً (زر X / Cancel / Success) ما تعملش حاجة
              if (didPop) return;

              // ✅ لو المستخدم ضغط Back واحنا مش loading
              if (!isLoading) _closeOnce(false);
            },
            child: Material(
              color: const Color(0xffF5F7FA),
              borderRadius: BorderRadius.circular(16),
              child: Column(
                children: [
                  // ✅ Dialog header بدل AppBar
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 10, 10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: tr(context, 'close'),
                          onPressed: isLoading ? null : () => _closeOnce(false),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  Expanded(
                    child: AbsorbPointer(
                      absorbing: isLoading,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final w = constraints.maxWidth;
                          final horizontal = w >= 1100 ? 32.0 : 16.0;

                          return SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(
                              horizontal,
                              14,
                              horizontal,
                              18,
                            ),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 980,
                                ),
                                child: Form(
                                  key: _formKey,
                                  autovalidateMode: _autoValidateMode,
                                  child: Column(
                                    children: [
                                      if (isLoading) ...[
                                        const _TopLoadingBar(),
                                        const SizedBox(height: 10),
                                      ],

                                      // Office
                                      ContractSection(
                                        title: tr(context, 'office_details'),
                                        icon: Icons.business,
                                        expanded: _officeExpanded,
                                        onExpandedChanged: (v) =>
                                            setState(() => _officeExpanded = v),
                                        children: [
                                          TwoColumns(
                                            children: [
                                              AppFormField(
                                                label: tr(context, 'country'),
                                                initial: widget.countryName,
                                                enabled: false,
                                                icon: Icons.flag_circle,
                                              ),
                                              AppFormField(
                                                label: tr(context, 'office'),
                                                initial: widget.officeName,
                                                enabled: false,
                                                icon: Icons.maps_home_work,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 12),

                                      // Worker
                                      ContractSection(
                                        title: tr(context, 'maid_details'),
                                        icon: Icons.person_outline,
                                        expanded: _workerExpanded,
                                        onExpandedChanged: (v) =>
                                            setState(() => _workerExpanded = v),
                                        children: [
                                          TwoColumns(
                                            children: [
                                              AppFormField(
                                                label: tr(context, 'name'),
                                                hint: tr(context, 'enter_name'),
                                                icon: Icons.person,
                                                controller: form.workerNameCtrl,
                                                validator: (v) =>
                                                    form.requiredValidator(
                                                      v,
                                                      tr(context, 'enter_name'),
                                                    ),
                                              ),
                                              AppFormField(
                                                label: tr(
                                                  context,
                                                  'passport_number',
                                                ),
                                                hint: tr(
                                                  context,
                                                  'enter_passport_number',
                                                ),
                                                icon: Icons.subtitles,
                                                controller: form.passportCtrl,
                                                validator: (v) =>
                                                    form.passportValidator(
                                                      context,
                                                      v,
                                                    ),
                                              ),
                                              AppFormField(
                                                label: tr(context, 'age'),
                                                hint: tr(context, 'enter_age'),
                                                icon: Icons.cake,
                                                controller: form.ageCtrl,
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                  LengthLimitingTextInputFormatter(
                                                    3,
                                                  ),
                                                ],
                                                validator: (v) => form
                                                    .ageValidator(context, v),
                                              ),
                                              AppFormField(
                                                label: tr(context, 'salary'),
                                                hint: tr(
                                                  context,
                                                  'enter_salary',
                                                ),
                                                icon: Icons.attach_money,
                                                controller: form.salaryCtrl,
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                  LengthLimitingTextInputFormatter(
                                                    6,
                                                  ),
                                                ],
                                                validator: (v) =>
                                                    form.salaryValidator(
                                                      context,
                                                      v,
                                                    ),
                                              ),
                                              AppDropdown(
                                                label: tr(
                                                  context,
                                                  'experience',
                                                ),
                                                icon: Icons.star_border,
                                                value: form.experienceValue,
                                                items: [
                                                  DropdownMenuItem(
                                                    value: 'true',
                                                    child: Text(
                                                      tr(
                                                        context,
                                                        'experience_yes',
                                                      ),
                                                    ),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: 'false',
                                                    child: Text(
                                                      tr(
                                                        context,
                                                        'experience_no',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                                onChanged: (v) => setState(
                                                  () =>
                                                      form.experienceValue = v,
                                                ),
                                                validator: (v) =>
                                                    form.dropdownRequired(
                                                      v,
                                                      tr(
                                                        context,
                                                        'choose_experience_value',
                                                      ),
                                                    ),
                                              ),
                                              AppDropdown(
                                                label: tr(context, 'religion'),
                                                icon: Icons.mosque_outlined,
                                                value: form.religionValue,
                                                items: [
                                                  DropdownMenuItem(
                                                    value: '1',
                                                    child: Text(
                                                      tr(
                                                        context,
                                                        'religion_islam',
                                                      ),
                                                    ),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: '2',
                                                    child: Text(
                                                      tr(
                                                        context,
                                                        'religion_christian',
                                                      ),
                                                    ),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: '3',
                                                    child: Text(
                                                      tr(
                                                        context,
                                                        'religion_other',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                                onChanged: (v) => setState(
                                                  () => form.religionValue = v,
                                                ),
                                                validator: (v) =>
                                                    form.dropdownRequired(
                                                      v,
                                                      tr(
                                                        context,
                                                        'choose_religion',
                                                      ),
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 12),

                                      // Contract + Visa
                                      ContractSection(
                                        title: tr(
                                          context,
                                          'contract_visa_details',
                                        ),
                                        icon: Icons.description_outlined,
                                        expanded: _contractExpanded,
                                        onExpandedChanged: (v) => setState(
                                          () => _contractExpanded = v,
                                        ),
                                        children: [
                                          TwoColumns(
                                            children: [
                                              AppDropdown(
                                                label: tr(context, 'contract_type'),
                                                icon: Icons.assignment_turned_in_outlined,
                                                value: form.contractTypeValue,
                                                items: [
                                                  DropdownMenuItem(
                                                    value: '1',
                                                    child: Text(tr(context, 'contract_type_named')), // معين باسم
                                                  ),
                                                  DropdownMenuItem(
                                                    value: '2',
                                                    child: Text(tr(context, 'contract_type_specs')), // حسب المواصفات
                                                  ),
                                                ],
                                                onChanged: (v) => setState(() => form.contractTypeValue = v),
                                                validator: (v) => form.dropdownRequired(
                                                  v,
                                                  tr(context, 'choose_contract_type'),
                                                ),
                                              ),

                                              AppDropdown(
                                                label: tr(context, 'visa_type'),
                                                icon: Icons
                                                    .confirmation_number_outlined,
                                                value: form.visaTypeValue,
                                                items: [
                                                  DropdownMenuItem(
                                                    value: '1',
                                                    child: Text(
                                                      tr(
                                                        context,
                                                        'visa_type_full',
                                                      ),
                                                    ),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: '2',
                                                    child: Text(
                                                      tr(
                                                        context,
                                                        'visa_type_normal',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                                onChanged: (v) => setState(
                                                  () => form.visaTypeValue = v,
                                                ),
                                                validator: (v) =>
                                                    form.dropdownRequired(
                                                      v,
                                                      tr(
                                                        context,
                                                        'choose_visa_type',
                                                      ),
                                                    ),
                                              ),
                                              AppFormField(
                                                label: tr(
                                                  context,
                                                  'visa_number',
                                                ),
                                                hint: tr(
                                                  context,
                                                  'visa_number_hint',
                                                ),
                                                icon: Icons.credit_card,
                                                controller: form.visaNumberCtrl,
                                                validator: (v) =>
                                                    form.visaNoValidator(
                                                      context,
                                                      v,
                                                    ),
                                              ),
                                              AppFormField(
                                                label: tr(
                                                  context,
                                                  'contract_number',
                                                ),
                                                hint: tr(
                                                  context,
                                                  'contract_number_hint',
                                                ),
                                                icon: Icons.article_outlined,
                                                controller:
                                                    form.contractNumberCtrl,
                                                validator: (v) =>
                                                    form.contractNoValidator(
                                                      context,
                                                      v,
                                                    ),
                                              ),
                                              DateField(
                                                label: tr(
                                                  context,
                                                  'contract_date',
                                                ),
                                                icon: Icons.date_range,
                                                value: form.contractDate,
                                                controller:
                                                    form.contractDateCtrl,
                                                required: true,
                                                onPick: () => _pickDate(
                                                  current: form.contractDate,
                                                  onPicked: (d) => setState(
                                                    () =>
                                                        form.setContractDate(d),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 12),

                                      // Sponsor
                                      ContractSection(
                                        title: tr(context, 'sponsor_details'),
                                        icon: Icons.shield_outlined,
                                        expanded: _sponsorExpanded,
                                        onExpandedChanged: (v) => setState(
                                          () => _sponsorExpanded = v,
                                        ),
                                        children: [
                                          TwoColumns(
                                            children: [
                                              AppFormField(
                                                label: tr(
                                                  context,
                                                  "sponsor_name",
                                                ),
                                                hint: tr(
                                                  context,
                                                  "enter_sponsor_name",
                                                ),
                                                icon: Icons.person_search,
                                                controller:
                                                    form.sponsorNameCtrl,
                                                validator: (v) =>
                                                    form.requiredValidator(
                                                      v,
                                                      tr(
                                                        context,
                                                        "enter_sponsor_name",
                                                      ),
                                                    ),
                                              ),
                                              PhoneField(
                                                label: tr(context, "phone"),
                                                controller:
                                                    form.sponsorPhoneCtrl,
                                                validator: (v) =>
                                                    form.phone8Validator(
                                                      context,
                                                      v,
                                                      requiredField: true,
                                                    ),
                                              ),
                                              PhoneField(
                                                label: tr(
                                                  context,
                                                  "alternative_phone",
                                                ),
                                                controller:
                                                    form.sponsorAltPhoneCtrl,
                                                validator: (v) =>
                                                    form.phone8Validator(
                                                      context,
                                                      v,
                                                      requiredField: false,
                                                    ),
                                              ),
                                              AppFormField(
                                                label: tr(context, "id_number"),
                                                hint: tr(
                                                  context,
                                                  "enter_id_number",
                                                ),
                                                icon: Icons.fingerprint,
                                                controller: form.sponsorIdCtrl,
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                  LengthLimitingTextInputFormatter(
                                                    10,
                                                  ),
                                                ],
                                                validator: (v) => form
                                                    .id10Validator(context, v),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 12),

                                      // Notes
                                      ContractSection(
                                        title: tr(context, "notes"),
                                        icon: Icons.note_alt_outlined,
                                        expanded: _notesExpanded,
                                        onExpandedChanged: (v) =>
                                            setState(() => _notesExpanded = v),
                                        children: [
                                          NotesField(
                                            controller: form.notesCtrl,
                                            validator: (v) =>
                                                form.notesValidator(context, v),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 12),

                                      ActionButtons(
                                        isLoading: isLoading,
                                        onSave: () async {
                                          if (isLoading) return;

                                          // ✅ Confirm قبل الإرسال
                                          final ok =
                                              await _showConfirmSaveDialog(
                                                context,
                                              );
                                          if (!ok) return;

                                          await _submit(cubit);
                                        },
                                        onCancel: () => _closeOnce(false),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TopLoadingBar extends StatelessWidget {
  const _TopLoadingBar();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: const LinearProgressIndicator(minHeight: 6),
    );
  }
}
