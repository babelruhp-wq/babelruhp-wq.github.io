import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../localization/translator.dart';
import '../../../models/add_office_request.dart';
import '../../../services/offices_service.dart';

Future<bool?> showAddOfficeDialog(
    BuildContext context, {
      required String countryId,
    }) {
  final service = context.read<OfficesService>();

  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _AddOfficeDialog(
      countryId: countryId,
      service: service,
    ),
  );
}

class _AddOfficeDialog extends StatefulWidget {
  final String countryId;
  final OfficesService service;

  const _AddOfficeDialog({
    required this.countryId,
    required this.service,
  });

  @override
  State<_AddOfficeDialog> createState() => _AddOfficeDialogState();
}

class _AddOfficeDialogState extends State<_AddOfficeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await widget.service.addOffice(
        AddOfficeRequest(
          countryId: widget.countryId,
          officeName: _nameCtrl.text.trim(),
        ),
      );

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString(), style: GoogleFonts.cairo()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr(context, 'add_new_office'), style: titleStyle),
                        const SizedBox(height: 4),
                        Text(
                          tr(context, 'office_name'),
                          style: subtitleStyle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: _loading ? null : () => Navigator.pop(context, false),
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

              /// Form
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _nameCtrl,
                  style: GoogleFonts.cairo(fontSize: 14),
                  decoration: fieldDecoration(
                    label: tr(context, 'office_name'),
                    icon: Icons.apartment_outlined,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return tr(context, 'required');
                    return null;
                  },
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                ),
              ),

              const SizedBox(height: 16),

              /// Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _loading ? null : () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _loading
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                          : Text(
                        tr(context, 'save'),
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
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
