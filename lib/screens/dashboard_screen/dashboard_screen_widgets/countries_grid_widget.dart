import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../features/countries/add_country/add_country_cubit.dart';
import '../../../localization/translator.dart';
import '../../../models/country.dart';
import '../../../models/country_office_stats.dart';
import 'add_edit_country_dialog.dart';
import 'country_card_widget.dart';

class CountriesGridWidget extends StatelessWidget {
  final double maxWidth;
  final List<Country> countries;
  final List<CountryOfficeStats> stats;
  final void Function(Country country) onCountrySelected;
  final VoidCallback onChanged;

  const CountriesGridWidget({
    super.key,
    required this.maxWidth,
    required this.countries,
    required this.onCountrySelected,
    required this.onChanged,
    required this.stats,
  });

  int get gridCount {
    if (maxWidth >= 1200) return 3;
    if (maxWidth >= 800) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddCountryCubit, AddCountryState>(
      listener: (context, state) {
        if (state is AddCountrySuccess && state.action == CountryAction.delete) {
          onChanged();
        }
        if (state is AddCountryFailure && state.action == CountryAction.delete) {
        }
      },
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: countries.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          mainAxisExtent: 140,
        ),
        itemBuilder: (context, index) {
          final country = countries[index];

          final countryStats = stats.firstWhere(
                (s) => s.countryId == country.countryId,
            orElse: () => CountryOfficeStats(
              countryId: country.countryId,
              nameArabic: country.nameArabic,
              nameEnglish: country.nameEnglish,
              officesNumber: 0,
            ),
          );

          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onCountrySelected(country),
              child: CountryCardWidget(
                stats: countryStats,
                country: country,
                onEdit: () async {
                  final result = await showAddCountryDialog(
                    context,
                    country: country,
                  );
                  if (result == true) onChanged();
                },
                onDelete: () async {
                  final cubit = context.read<AddCountryCubit>();

                  final password = await showDeleteDialog(context);
                  if (password == null || password.trim().isEmpty) return;

                  await cubit.remove(
                    id: country.countryId,
                    password: password.trim(),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}



Future<String?> showDeleteDialog(BuildContext context) {
  return showDialog<String?>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _DeleteCountryDialog(), // الديالوج اللي بيعمل pop(password)
  );
}


class _DeleteCountryDialog extends StatefulWidget {
  const _DeleteCountryDialog();

  @override
  State<_DeleteCountryDialog> createState() => _DeleteCountryDialogState();
}

class _DeleteCountryDialogState extends State<_DeleteCountryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passController = TextEditingController();

  bool _obscure = true;

  @override
  void dispose() {
    _passController.dispose();
    super.dispose();
  }

  void _confirm() {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final password = _passController.text.trim();
    Navigator.pop(context, password); // ✅ رجّع الباسورد للـ caller
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.cairo(
      fontSize: 18,
      fontWeight: FontWeight.w800,
      color: const Color(0xff2c334a),
    );

    final bodyStyle = GoogleFonts.cairo(
      fontSize: 13.5,
      height: 1.35,
      color: Colors.grey.shade700,
      fontWeight: FontWeight.w500,
    );

    final labelStyle = GoogleFonts.cairo(
      fontSize: 13,
      fontWeight: FontWeight.w800,
      color: const Color(0xff2c334a),
    );

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr(context, 'confirm_delete'), style: titleStyle),
                        const SizedBox(height: 4),
                        Text(
                          tr(context, 'delete_country_confirm'),
                          style: bodyStyle,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => Navigator.pop(context, null), // ✅ null => cancel
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.close, color: Color(0xff3a4262)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 14),

              // Password field
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tr(context, 'password'), style: labelStyle),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passController,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _confirm(),
                      decoration: InputDecoration(
                        hintText: tr(context, 'enter_password_to_confirm'),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xff3a4262)),
                        ),
                      ),
                      validator: (v) {
                        final s = (v ?? '').trim();
                        if (s.isEmpty) return tr(context, 'required_field');
                        // لو عايز شروط زيادة للباسورد:
                        // if (s.length < 6) return tr(context, 'password_too_short');
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, null),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        tr(context, 'cancel'),
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xff2c334a),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _confirm,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: Text(
                        tr(context, 'delete'),
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


