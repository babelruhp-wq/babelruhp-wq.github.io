import 'package:babel_final_project/models/male_agency.dart';

import '../../models/female_contract.dart';

enum MaleAgenciesTableStatus { initial, loading, loaded, deleting, error }

class MaleAgenciesTableState {
  final MaleAgenciesTableStatus status;
  final List<MaleAgency> all;
  final List<MaleAgency> filtered;
  final int? statusFilter;
  final String? error;

  const MaleAgenciesTableState({
    required this.status,
    this.all = const [],
    this.filtered = const [],
    this.statusFilter,
    this.error,
  });

  factory MaleAgenciesTableState.initial() =>
      const MaleAgenciesTableState(status: MaleAgenciesTableStatus.initial);

  MaleAgenciesTableState copyWith({
    MaleAgenciesTableStatus? status,
    List<MaleAgency>? all,
    List<MaleAgency>? filtered,
    int? statusFilter,
    String? error,
  }) {
    return MaleAgenciesTableState(
      status: status ?? this.status,
      all: all ?? this.all,
      filtered: filtered ?? this.filtered,
      statusFilter: statusFilter ?? this.statusFilter,
      error: error,
    );
  }
}
