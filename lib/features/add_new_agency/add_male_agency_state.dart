enum AddMaleAgencyStatus { initial, loading, success, error }

class AddMaleAgencyState {
  final AddMaleAgencyStatus status;
  final String? errorMessage;

  const AddMaleAgencyState({
    required this.status,
    this.errorMessage,
  });

  factory AddMaleAgencyState.initial() =>
      const AddMaleAgencyState(status: AddMaleAgencyStatus.initial);

  AddMaleAgencyState copyWith({
    AddMaleAgencyStatus? status,
    String? errorMessage,
  }) {
    return AddMaleAgencyState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}
