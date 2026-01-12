import 'package:equatable/equatable.dart';

import '../../models/country.dart';
import '../../models/country_office_stats.dart';

class DashboardState extends Equatable {
  final List<Country> countries;
  final List<CountryOfficeStats> stats;

  final bool isLoadingCountries;
  final bool isLoadingStats;

  final String? error;

  const DashboardState({
    this.countries = const [],
    this.stats = const [],
    this.isLoadingCountries = false,
    this.isLoadingStats = false,
    this.error,
  });

  DashboardState copyWith({
    List<Country>? countries,
    List<CountryOfficeStats>? stats,
    bool? isLoadingCountries,
    bool? isLoadingStats,
    String? error,
    bool clearError = false,
  }) {
    return DashboardState(
      countries: countries ?? this.countries,
      stats: stats ?? this.stats,
      isLoadingCountries: isLoadingCountries ?? this.isLoadingCountries,
      isLoadingStats: isLoadingStats ?? this.isLoadingStats,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
    countries,
    stats,
    isLoadingCountries,
    isLoadingStats,
    error,
  ];
}
