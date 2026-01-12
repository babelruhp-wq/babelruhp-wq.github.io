
import '../../models/app_users.dart';

class UsersState {
  final bool isLoading;
  final bool isBusy;
  final String? error;
  final List<AppUser> users;

  const UsersState({
    this.isLoading = false,
    this.isBusy = false,
    this.error,
    this.users = const [],
  });

  UsersState copyWith({
    bool? isLoading,
    bool? isBusy,
    String? error,
    List<AppUser>? users,
    bool clearError = false,
  }) {
    return UsersState(
      isLoading: isLoading ?? this.isLoading,
      isBusy: isBusy ?? this.isBusy,
      error: clearError ? null : (error ?? this.error),
      users: users ?? this.users,
    );
  }
}
