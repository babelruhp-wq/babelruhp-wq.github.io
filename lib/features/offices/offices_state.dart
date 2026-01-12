import 'package:equatable/equatable.dart';
import '../../models/office.dart';
import '../../models/office_female_stats.dart';

class OfficesState extends Equatable {
  final List<Office> offices;
  final bool isLoading;
  final String? error;

  // ✅ جديد: تحميل/بيانات الإحصائيات
  final bool isStatsLoading;
  final Map<String, OfficeFemaleStats> femaleStatsByOffice; // key = officeId

  const OfficesState({
    this.offices = const [],
    this.isLoading = false,
    this.error,
    this.isStatsLoading = false,
    this.femaleStatsByOffice = const {},
  });

  OfficesState copyWith({
    List<Office>? offices,
    bool? isLoading,
    String? error,
    bool clearError = false,

    // ✅ جديد
    bool? isStatsLoading,
    Map<String, OfficeFemaleStats>? femaleStatsByOffice,
  }) {
    return OfficesState(
      offices: offices ?? this.offices,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),

      isStatsLoading: isStatsLoading ?? this.isStatsLoading,
      femaleStatsByOffice: femaleStatsByOffice ?? this.femaleStatsByOffice,
    );
  }

  @override
  List<Object?> get props => [
    offices,
    isLoading,
    error,
    isStatsLoading,
    femaleStatsByOffice,
  ];
}
