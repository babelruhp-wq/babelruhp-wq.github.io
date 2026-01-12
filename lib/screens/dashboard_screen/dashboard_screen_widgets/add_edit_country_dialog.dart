import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../localization/translator.dart';
import '../../../models/country.dart';
import '../../../features/countries/add_country/add_country_cubit.dart';

Future<bool?> showAddCountryDialog(BuildContext context, {Country? country}) {
  final cubit = context.read<AddCountryCubit>();

  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return BlocProvider.value(
        value: cubit,
        child: _AddEditCountryDialog(country: country),
      );
    },
  );
}

class _AddEditCountryDialog extends StatefulWidget {
  final Country? country;
  const _AddEditCountryDialog({this.country});

  @override
  State<_AddEditCountryDialog> createState() => _AddEditCountryDialogState();
}

class _AddEditCountryDialogState extends State<_AddEditCountryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _enController;
  late final TextEditingController _arController;

  @override
  void initState() {
    super.initState();
    _enController = TextEditingController(text: widget.country?.nameEnglish ?? '');
    _arController = TextEditingController(text: widget.country?.nameArabic ?? '');
  }

  @override
  void dispose() {
    _enController.dispose();
    _arController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.country != null;

    final titleText = isEdit ? tr(context, 'edit_country') : tr(context, 'add_new_country');
    final subtitleText = isEdit
        ? tr(context, 'edit_country') // لو عندك key مخصص للشرح حطه هنا
        : tr(context, 'add_new_country');

    final titleStyle = GoogleFonts.cairo(
      fontSize: 18,
      fontWeight: FontWeight.w800,
      color: const Color(0xff2c334a),
    );

    final subtitleStyle = GoogleFonts.cairo(
      fontSize: 12.5,
      fontWeight: FontWeight.w400,
      color: Colors.grey.shade600,
      height: 1.3,
    );

    final labelStyle = GoogleFonts.cairo(
      fontSize: 12.5,
      color: Colors.grey.shade700,
      fontWeight: FontWeight.w600,
    );

    InputDecoration fieldDecoration({
      required String label,
      required IconData icon,
    }) {
      return InputDecoration(
        labelText: label,
        labelStyle: labelStyle,
        prefixIcon: Icon(icon, color: const Color(0xff3a4262)),
        filled: true,
        fillColor: const Color(0xffF7F8FB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xff1bbae1), width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.2),
        ),
      );
    }

    return BlocListener<AddCountryCubit, AddCountryState>(
      listener: (context, state) {
        if (state is AddCountrySuccess) {
          if (state.action == CountryAction.add || state.action == CountryAction.edit) {
            Navigator.pop(context, true);
          }
        }

        if (state is AddCountryFailure) {
          if (state.action == CountryAction.add || state.action == CountryAction.edit) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message, style: GoogleFonts.cairo()),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header (احترافي)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 4,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xff3a4262),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(titleText, style: titleStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(subtitleText, style: subtitleStyle, maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => Navigator.pop(context, false),
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

                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _enController,
                        style: GoogleFonts.cairo(fontSize: 14),
                        decoration: fieldDecoration(
                          label: tr(context, 'country_name_en'),
                          icon: Icons.language,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? tr(context, 'required') : null,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _arController,
                        style: GoogleFonts.cairo(fontSize: 14),
                        decoration: fieldDecoration(
                          label: tr(context, 'country_name_ar'),
                          icon: Icons.translate,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? tr(context, 'required') : null,
                        textInputAction: TextInputAction.done,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                BlocBuilder<AddCountryCubit, AddCountryState>(
                  builder: (context, state) {
                    final loading = state is AddCountryLoading &&
                        (state.action == CountryAction.add || state.action == CountryAction.edit);

                    return Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: loading ? null : () => Navigator.pop(context, false),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              tr(context, 'cancel'),
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xff2c334a),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: loading
                                ? null
                                : () {
                              if (!_formKey.currentState!.validate()) return;

                              final en = _enController.text.trim();
                              final ar = _arController.text.trim();

                              if (!isEdit) {
                                context.read<AddCountryCubit>().add(
                                  nameArabic: ar,
                                  nameEnglish: en,
                                );
                              } else {
                                context.read<AddCountryCubit>().edit(
                                  id: widget.country!.countryId,
                                  nameArabic: ar,
                                  nameEnglish: en,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:  Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: loading
                                ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                                : Text(
                              tr(context, 'save'),
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
