import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../localization/translator.dart';
import '../../../features/auth/login/login_cubit.dart';
import '../../../features/auth/login/login_state.dart';

class LoginToDashboardButtonWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  const LoginToDashboardButtonWidget({
    super.key,
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, st) {
        return SizedBox(
          height: 46,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: st.isLoading
                ? null
                : () {
              if (!(formKey.currentState?.validate() ?? false)) return;

              context.read<LoginCubit>().login(
                username: usernameController.text.trim(),
                password: passwordController.text,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff394263),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: st.isLoading
                  ? const SizedBox(
                key: ValueKey('loading'),
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Row(
                key: const ValueKey('content'),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.login_rounded, size: 18),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      tr(context, 'login_to_dashboard'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w900,
                        fontSize: 14.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
