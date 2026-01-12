import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../localization/translator.dart';
import '../../../features/auth/login/login_cubit.dart';
import '../../../features/auth/login/login_state.dart';
import '../../home_screen/home_screen.dart';
import 'login_to_dashboard_button_widget.dart';

class LoginScreenWidgets extends StatefulWidget {
  const LoginScreenWidgets({super.key});

  @override
  State<LoginScreenWidgets> createState() => _LoginScreenWidgetsState();
}

class _LoginScreenWidgetsState extends State<LoginScreenWidgets> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscure = true;

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _dec({
    required BuildContext context,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.cairo(color: Colors.black45, fontWeight: FontWeight.w700),
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
        borderSide: const BorderSide(color: Color(0xff5B67CA), width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xffE34F40), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xffE34F40), width: 1.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return BlocListener<LoginCubit, LoginState>(
      listenWhen: (p, c) => p.error != c.error || p.successMessage != c.successMessage,
        listener: (context, st) async {
          if (st.error != null && st.error!.trim().isNotEmpty) {
            ScaffoldMessenger.of(context).clearSnackBars();
            if (Navigator.of(context, rootNavigator: true).canPop()) {
            }

            final isRtl = Directionality.of(context) == TextDirection.rtl;

            // ✅ رسالة ثابتة للوجين
            final raw = (st.error ?? '').toLowerCase();

            final isDeactivated = raw.contains('deactivated') ||
                raw.contains('deactivate') ||
                raw.contains('inactive') ||
                raw.contains('disabled') ||
                raw.contains('not active') ||
                raw.contains('غير نشط') ||
                raw.contains('موقوف') ||
                raw.contains('معطل');

            final msg = isDeactivated
                ? (isRtl ? 'هذا الحساب غير نشط، تواصل مع الإدارة لتفعيله' : 'This account is deactivated. Please contact admin.')
                : (isRtl ? 'اسم المستخدم أو كلمة المرور خاطئة' : 'Invalid username or password');

            final titleText = isDeactivated
                ? (isRtl ? 'الحساب غير نشط' : 'Account deactivated')
                : (isRtl ? 'خطأ في تسجيل الدخول' : 'Login failed');

            await showDialog<void>(
              context: context,
              barrierDismissible: true,
              builder: (dCtx) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  titlePadding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                  contentPadding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                  actionsPadding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                  title: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xffE34F40).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xffE34F40).withOpacity(0.25)),
                        ),
                        child: const Icon(Icons.error_outline_rounded, color: Color(0xffE34F40)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                           titleText ,
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w900,
                            fontSize: 15.5,
                            color: const Color(0xff2c334a),
                          ),
                        ),
                      ),
                    ],
                  ),
                  content: Text(
                    msg,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xff2c334a),
                      height: 1.4,
                    ),
                  ),
                  actions: [
                    SizedBox(
                      height: 42,
                      child: TextButton(
                        onPressed: () => Navigator.pop(dCtx),
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          isRtl ? 'حسناً' : 'OK',
                          style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );

            return; // ✅ ما تكملش
          }


        if (st.successMessage != null && st.successMessage!.trim().isNotEmpty) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(
                st.successMessage!,
                style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
              ),
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      },
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xff394263).withOpacity(0.08),
                  const Color(0xff5B67CA).withOpacity(0.06),
                ],
              ),
            ),
            child: Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xff394263),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.lock_rounded, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tr(context, 'login') == 'login'
                                      ? (isRtl ? 'تسجيل الدخول' : 'Login')
                                      : tr(context, 'login'),
                                  style: GoogleFonts.cairo(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xff2c334a),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isRtl
                                      ? 'أدخل بياناتك للمتابعة إلى لوحة التحكم'
                                      : 'Enter your credentials to continue to dashboard',
                                  style: GoogleFonts.cairo(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      Text(tr(context, 'username'),
                          style: GoogleFonts.cairo(fontWeight: FontWeight.w900, color: const Color(0xff2c334a))),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _userNameController,
                        textInputAction: TextInputAction.next,
                        validator: (v) => (v == null || v.trim().isEmpty) ? tr(context, 'enter_username') : null,
                        decoration: _dec(
                          context: context,
                          hint: tr(context, 'enter_username'),
                          icon: Icons.person_rounded,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(tr(context, 'password'),
                          style: GoogleFonts.cairo(fontWeight: FontWeight.w900, color: const Color(0xff2c334a))),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) {
                          // نفس زر اللوجين
                          FocusScope.of(context).unfocus();
                          if (!(_formKey.currentState?.validate() ?? false)) return;
                          context.read<LoginCubit>().login(
                            username: _userNameController.text.trim(),
                            password: _passwordController.text,
                          );
                        },
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return tr(context, 'enter_password');
                          if (v.trim().length < 4) return isRtl ? 'كلمة المرور قصيرة' : 'Password is too short';
                          return null;
                        },
                        decoration: _dec(
                          context: context,
                          hint: tr(context, 'enter_password'),
                          icon: Icons.lock_rounded,
                          suffix: IconButton(
                            tooltip: _obscure ? (isRtl ? 'إظهار' : 'Show') : (isRtl ? 'إخفاء' : 'Hide'),
                            onPressed: () => setState(() => _obscure = !_obscure),
                            icon: Icon(
                              _obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      LoginToDashboardButtonWidget(
                        formKey: _formKey,
                        usernameController: _userNameController,
                        passwordController: _passwordController,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        '© Babel for Recruitment',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
