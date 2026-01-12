import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/country.dart';
import '../../models/country_office_stats.dart';
import '../../services/countries_service.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final CountriesService service;

  DashboardCubit({required this.service}) : super(const DashboardState());

  Future<void> refresh() async {
    emit(state.copyWith(
      isLoadingCountries: true,
      isLoadingStats: true,
      clearError: true,
    ));

    try {
      // ✅ نفس الـ endpoint اللي بيغذي الرسم البياني
      final stats = await service.getAllCountriesInfo();

      // ✅ نطلع countries من نفس الـ stats (علشان UI يشتغل بدون endpoint تاني)
      // لو عندك Country.fromJson (غالباً عندك) ده هيكون أنضف وأضمن.
      final countries = stats
          .map(
            (s) => Country.fromJson({
          "countryId": s.countryId,
          "nameArabic": s.nameArabic,
          "nameEnglish": s.nameEnglish,
          // لو الموديل عندك فيه officesNumber خليه، لو مش موجود مش هيضر لو fromJson يتجاهله
          "officesNumber": s.officesNumber,
        }),
      )
          .toList();

      emit(state.copyWith(
        countries: countries,
        stats: stats,
        isLoadingCountries: false,
        isLoadingStats: false,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingCountries: false,
        isLoadingStats: false,
        error: e.toString(),
      ));
    }
  }
}
