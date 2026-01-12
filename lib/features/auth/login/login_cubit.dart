import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/auth/auth_provider.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/auth/token_storage.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthService authService;
  final TokenStorage storage;
  final AuthProvider auth; // ✅ NEW

  LoginCubit({
    required this.authService,
    required this.storage,
    required this.auth,
  }) : super(const LoginState());

  Future<void> login({
    required String username,
    required String password,
  }) async {
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));

    try {
      final res = await authService.login(username: username, password: password);

      if (res.token.trim().isEmpty) {
        throw Exception('Login failed: empty token');
      }

      // ✅ Save tokens
      await storage.save(token: res.token, refreshToken: res.refreshToken);

      // ✅ Decode token claims & store user info globally
      auth.setFromToken(token: res.token, refreshToken: res.refreshToken);

      emit(state.copyWith(
        isLoading: false,
        successMessage: res.message.isNotEmpty ? res.message : 'Login successful',
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
