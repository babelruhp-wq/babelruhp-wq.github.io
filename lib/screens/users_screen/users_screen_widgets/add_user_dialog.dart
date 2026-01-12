import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterData {
  final String firstName;
  final String lastName;
  final String userName;
  final String password;
  final String passwordConfirm;

  RegisterData({
    required this.firstName,
    required this.lastName,
    required this.userName,
    required this.password,
    required this.passwordConfirm,
  });
}

class AddUserDialog extends StatefulWidget {
  final String title;
  final bool isArabic;

  const AddUserDialog({
    super.key,
    required this.title,
    required this.isArabic,
  });

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();

  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final userName = TextEditingController();
  final pass = TextEditingController();
  final pass2 = TextEditingController();

  bool _ob1 = true;
  bool _ob2 = true;

  // live rules
  bool _hasMinLen = false;
  bool _hasUpper = false;
  bool _hasLower = false;
  bool _hasDigit = false;
  bool _hasSpecial = false;

  void _evalPass(String v) {
    final s = v.trim();
    setState(() {
      _hasMinLen = s.length >= 8;
      _hasUpper = RegExp(r'[A-Z]').hasMatch(s);
      _hasLower = RegExp(r'[a-z]').hasMatch(s);
      _hasDigit = RegExp(r'\d').hasMatch(s);
      // special: أي شيء غير حرف أو رقم
      _hasSpecial = RegExp(r'[^a-zA-Z0-9]').hasMatch(s);
    });
  }

  @override
  void initState() {
    super.initState();
    _evalPass('');
    pass.addListener(() => _evalPass(pass.text));
  }

  @override
  void dispose() {
    firstName.dispose();
    lastName.dispose();
    userName.dispose();
    pass.dispose();
    pass2.dispose();
    super.dispose();
  }

  String? _req(String? v) => (v == null || v.trim().isEmpty)
      ? (widget.isArabic ? 'مطلوب' : 'Required')
      : null;

  String? _passwordValidator(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return widget.isArabic ? 'مطلوب' : 'Required';

    final minLen = s.length >= 8;
    final hasUpper = RegExp(r'[A-Z]').hasMatch(s);
    final hasLower = RegExp(r'[a-z]').hasMatch(s);
    final hasDigit = RegExp(r'\d').hasMatch(s);
    final hasSpecial = RegExp(r'[^a-zA-Z0-9]').hasMatch(s);

    if (!minLen) return widget.isArabic ? 'لا تقل عن 8 أحرف' : 'At least 8 characters';
    if (!hasUpper) return widget.isArabic ? 'لازم حرف كبير (A-Z)' : 'Needs uppercase (A-Z)';
    if (!hasLower) return widget.isArabic ? 'لازم حرف صغير (a-z)' : 'Needs lowercase (a-z)';
    if (!hasDigit) return widget.isArabic ? 'لازم رقم (0-9)' : 'Needs a number (0-9)';
    if (!hasSpecial) return widget.isArabic ? 'لازم رمز خاص !@#' : 'Needs a special char !@#';

    return null;
  }

  InputDecoration _dec(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.w800),
      prefixIcon: Icon(icon, color: const Color(0xff394263)),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xffF3F6FB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xff394263), width: 1.2),
      ),
    );
  }

  Widget _ruleChip({
    required bool ok,
    required String ar,
    required String en,
  }) {
    final fg = ok ? const Color(0xFF16A34A) : const Color(0xFF667085);
    final bg = ok ? const Color(0xFFEAFBF0) : const Color(0xFFF2F4F7);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            ok ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 16,
            color: fg,
          ),
          const SizedBox(width: 6),
          Text(
            widget.isArabic ? ar : en,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    Navigator.pop(
      context,
      RegisterData(
        firstName: firstName.text.trim(),
        lastName: lastName.text.trim(),
        userName: userName.text.trim(),
        password: pass.text.trim(),
        passwordConfirm: pass2.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F1FF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF175CD3).withOpacity(0.18)),
                          ),
                          child: const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF175CD3), size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.title,
                            style: GoogleFonts.cairo(fontSize: 16.5, fontWeight: FontWeight.w900),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context, null),
                          icon: const Icon(Icons.close),
                          tooltip: widget.isArabic ? 'إغلاق' : 'Close',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Fields
                    TextFormField(
                      controller: firstName,
                      validator: _req,
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
                      decoration: _dec(
                        widget.isArabic ? 'الاسم الأول' : 'First name',
                        Icons.badge_outlined,
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: lastName,
                      validator: _req,
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
                      decoration: _dec(
                        widget.isArabic ? 'اسم العائلة' : 'Last name',
                        Icons.badge,
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: userName,
                      validator: _req,
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
                      decoration: _dec(
                        widget.isArabic ? 'اسم المستخدم' : 'Username',
                        Icons.alternate_email_rounded,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Password
                    TextFormField(
                      controller: pass,
                      obscureText: _ob1,
                      validator: _passwordValidator,
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
                      decoration: _dec(
                        widget.isArabic ? 'كلمة المرور' : 'Password',
                        Icons.lock_rounded,
                        suffix: IconButton(
                          onPressed: () => setState(() => _ob1 = !_ob1),
                          icon: Icon(_ob1 ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                          tooltip: _ob1
                              ? (widget.isArabic ? 'إظهار' : 'Show')
                              : (widget.isArabic ? 'إخفاء' : 'Hide'),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Live rules panel
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFBFE),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.black.withOpacity(0.06)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isArabic
                                ? 'شروط كلمة المرور'
                                : 'Password rules',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.w900,
                              color: const Color(0xff2c334a),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _ruleChip(ok: _hasMinLen, ar: '٨ أحرف+', en: '8+ chars'),
                              _ruleChip(ok: _hasUpper, ar: 'حرف كبير', en: 'Uppercase'),
                              _ruleChip(ok: _hasLower, ar: 'حرف صغير', en: 'Lowercase'),
                              _ruleChip(ok: _hasDigit, ar: 'رقم', en: 'Number'),
                              _ruleChip(ok: _hasSpecial, ar: 'رمز خاص', en: 'Special'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Confirm
                    TextFormField(
                      controller: pass2,
                      obscureText: _ob2,
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
                      validator: (v) {
                        final r = _req(v);
                        if (r != null) return r;
                        if (v!.trim() != pass.text.trim()) {
                          return widget.isArabic ? 'غير متطابقة' : 'Not match';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _submit(),
                      decoration: _dec(
                        widget.isArabic ? 'تأكيد كلمة المرور' : 'Confirm password',
                        Icons.lock_outline_rounded,
                        suffix: IconButton(
                          onPressed: () => setState(() => _ob2 = !_ob2),
                          icon: Icon(_ob2 ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                          tooltip: _ob2
                              ? (widget.isArabic ? 'إظهار' : 'Show')
                              : (widget.isArabic ? 'إخفاء' : 'Hide'),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context, null),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              side: BorderSide(color: Colors.black.withOpacity(0.12)),
                            ),
                            child: Text(
                              widget.isArabic ? 'إلغاء' : 'Cancel',
                              style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff394263),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: Text(
                              widget.isArabic ? 'حفظ' : 'Save',
                              style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
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
      ),
    );
  }
}
