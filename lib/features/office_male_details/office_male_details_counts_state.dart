
sealed class OfficeMaleDetailsCountsState {}

class OfficeMaleDetailsCountsInitial extends OfficeMaleDetailsCountsState {}

class OfficeMaleDetailsCountsLoading extends OfficeMaleDetailsCountsState {}

class OfficeMaleDetailsCountsLoaded extends OfficeMaleDetailsCountsState {
  final Map<String, int> counts;
  OfficeMaleDetailsCountsLoaded(this.counts);
}

class OfficeMaleDetailsCountsError extends OfficeMaleDetailsCountsState {
  final String message;
  OfficeMaleDetailsCountsError(this.message);
}
