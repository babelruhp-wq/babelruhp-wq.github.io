part of 'add_country_cubit.dart';

enum CountryAction { add, edit, delete }

abstract class AddCountryState {}

class AddCountryInitial extends AddCountryState {}

class AddCountryLoading extends AddCountryState {
  final CountryAction action;
  AddCountryLoading(this.action);
}

class AddCountrySuccess extends AddCountryState {
  final CountryAction action;
  final String message;
  AddCountrySuccess(this.action, this.message);
}

class AddCountryFailure extends AddCountryState {
  final CountryAction action;
  final String message;
  AddCountryFailure(this.action, this.message);
}
