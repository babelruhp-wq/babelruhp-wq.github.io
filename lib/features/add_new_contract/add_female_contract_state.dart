enum AddFemaleContractStatus { initial, loading, success, error }

class AddFemaleContractState {
  final AddFemaleContractStatus status;
  final String? errorMessage;

  const AddFemaleContractState({
    required this.status,
    this.errorMessage,
  });

  factory AddFemaleContractState.initial() =>
      const AddFemaleContractState(status: AddFemaleContractStatus.initial);

  AddFemaleContractState copyWith({
    AddFemaleContractStatus? status,
    String? errorMessage,
  }) {
    return AddFemaleContractState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}
