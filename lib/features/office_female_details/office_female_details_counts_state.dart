part of 'office_female_details_counts_cubit.dart';

sealed class OfficeFemaleDetailsCountsState {}

class OfficeFemaleDetailsCountsInitial extends OfficeFemaleDetailsCountsState {}

class OfficeFemaleDetailsCountsLoading extends OfficeFemaleDetailsCountsState {}

class OfficeFemaleDetailsCountsLoaded extends OfficeFemaleDetailsCountsState {
  final Map<String, int> counts;
  OfficeFemaleDetailsCountsLoaded(this.counts);
}

class OfficeFemaleDetailsCountsError extends OfficeFemaleDetailsCountsState {
  final String message;
  OfficeFemaleDetailsCountsError(this.message);
}
