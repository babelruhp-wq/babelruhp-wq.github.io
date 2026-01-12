import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/countries_service.dart';
import '../../../models/add_country_request.dart';

part 'add_country_state.dart';

class AddCountryCubit extends Cubit<AddCountryState> {
  final CountriesService service;

  AddCountryCubit({required this.service}) : super(AddCountryInitial());

  Future<void> add({
    required String nameArabic,
    required String nameEnglish,
  }) async {
    emit(AddCountryLoading(CountryAction.add));
    try {
      await service.addCountry(
        AddCountryRequest(
          nameArabic: nameArabic.trim(),
          nameEnglish: nameEnglish.trim(),
        ),
      );
      emit(AddCountrySuccess(CountryAction.add, 'تمت إضافة الدولة بنجاح ✅'));
    } catch (e) {
      emit(AddCountryFailure(CountryAction.add, e.toString()));
    }
  }

  Future<void> edit({
    required String id,
    required String nameArabic,
    required String nameEnglish,
  }) async {
    emit(AddCountryLoading(CountryAction.edit));
    try {
      await service.editCountryNames(
        id: id,
        req: AddCountryRequest(
          nameArabic: nameArabic.trim(),
          nameEnglish: nameEnglish.trim(),
        ),
      );
      emit(AddCountrySuccess(CountryAction.edit, 'تم تعديل الدولة بنجاح ✅'));
    } catch (e) {
      emit(AddCountryFailure(CountryAction.edit, e.toString()));
    }
  }

  Future<void> remove({required String id,required String password}) async {
    emit(AddCountryLoading(CountryAction.delete));
    try {
      await service.removeCountry(id,password);
      emit(AddCountrySuccess(CountryAction.delete, 'تم حذف الدولة بنجاح ✅'));
    } catch (e) {
      emit(AddCountryFailure(CountryAction.delete, e.toString()));
    }
  }
}
