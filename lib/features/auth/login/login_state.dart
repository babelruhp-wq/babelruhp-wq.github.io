class LoginState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const LoginState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  LoginState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}
