import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/auth/auth_provider.dart';
import '../../models/app_users.dart';
import '../../services/users_service.dart';
import 'users_state.dart';

class UsersCubit extends Cubit<UsersState> {
  final UsersService service;
  final AuthProvider auth;

  UsersCubit({
    required this.service,
    required this.auth,
  }) : super(const UsersState());

  String _tokenOrThrow() {
    final t = (auth.session?.token ?? '').trim();
    if (t.isEmpty) throw Exception('Missing token');
    return t;
  }
  Future<String> _validTokenOrThrow() async {
    final t = await auth.ensureValidToken(); // ✅ هنا الصح
    if (t == null || t.trim().isEmpty) {
      throw Exception('Session expired. Please login again.');
    }
    return t.trim();
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final token = await _validTokenOrThrow();
      final users = await service.fetchAllUsers(token: token);
      emit(state.copyWith(isLoading: false, users: users, clearError: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> toggleActive(AppUser u) async {
    emit(state.copyWith(isBusy: true, clearError: true));
    try {
      final token = await _validTokenOrThrow();

      if (u.isActive) {
        await service.deactivateAccount(token: token, userId: u.id);
      } else {
        await service.activateAccount(token: token, userId: u.id);
      }

      await load();
      emit(state.copyWith(isBusy: false, clearError: true));
    } catch (e) {
      emit(state.copyWith(isBusy: false, error: e.toString()));
    }
  }

  Future<void> resetPassword({
  required String userId,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    emit(state.copyWith(isBusy: true, clearError: true));
    try {
      final token = await _validTokenOrThrow();
      if (token.isEmpty) throw Exception('Missing token');

      await service.adminResetPassword(
        token: token,
        userId: userId,
        newPassword: newPassword, passwordConfirm: newPasswordConfirm,
      );

      emit(state.copyWith(isBusy: false, clearError: true));
    } catch (e) {
      emit(state.copyWith(isBusy: false, error: e.toString()));
    }
  }

  Future<void> addUser({
    required String role,
    required String firstName,
    required String lastName,
    required String userName,
    required String password,
    required String passwordConfirm,
  }) async {
    emit(state.copyWith(isBusy: true, clearError: true));
    try {
      final token = await _validTokenOrThrow();

      await service.registerUser(
        token: token,
        firstName: firstName,
        lastName: lastName,
        userName: userName,
        password: password,
        passwordConfirm: passwordConfirm,
        role: role,
      );

      await load(); // ✅ refresh after add
      emit(state.copyWith(isBusy: false));
    } catch (e) {
      emit(state.copyWith(isBusy: false, error: e.toString()));
    }
  }
}
