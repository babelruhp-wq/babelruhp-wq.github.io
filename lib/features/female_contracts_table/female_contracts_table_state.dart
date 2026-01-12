import '../../models/female_contract.dart';

enum FemaleContractsTableStatus { initial, loading, loaded, deleting, error }

class FemaleContractsTableState {
  final FemaleContractsTableStatus status;
  final List<FemaleContract> all;
  final List<FemaleContract> filtered;
  final int? statusFilter;
  final String? error;

  const FemaleContractsTableState({
    required this.status,
    this.all = const [],
    this.filtered = const [],
    this.statusFilter,
    this.error,
  });

  factory FemaleContractsTableState.initial() =>
      const FemaleContractsTableState(status: FemaleContractsTableStatus.initial);

  FemaleContractsTableState copyWith({
    FemaleContractsTableStatus? status,
    List<FemaleContract>? all,
    List<FemaleContract>? filtered,
    int? statusFilter,
    String? error,
  }) {
    return FemaleContractsTableState(
      status: status ?? this.status,
      all: all ?? this.all,
      filtered: filtered ?? this.filtered,
      statusFilter: statusFilter ?? this.statusFilter,
      error: error,
    );
  }
}
