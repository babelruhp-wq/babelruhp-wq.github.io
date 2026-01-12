import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../localization/translator.dart';
import '../../../services/offices_service.dart';

Future<bool?> showDeleteOfficeDialog(
    BuildContext context,
    String officeId,
    ) {
  final service = context.read<OfficesService>();

  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _DeleteOfficeDialog(
      officeId: officeId,
      service: service,
    ),
  );
}

class _DeleteOfficeDialog extends StatefulWidget {
  final String officeId;
  final OfficesService service;

  const _DeleteOfficeDialog({
    required this.officeId,
    required this.service,
  });

  @override
  State<_DeleteOfficeDialog> createState() => _DeleteOfficeDialogState();
}

class _DeleteOfficeDialogState extends State<_DeleteOfficeDialog> {
  bool _loading = false;
  bool _obscure = true;

  final _formKey = GlobalKey<FormState>();
  final _passController = TextEditingController();

  @override
  void dispose() {
    _passController.dispose();
    super.dispose();
  }

  String _prettyError(Object e) {
    final s = e.toString().replaceAll('Exception:', '').trim();
    if (s.toLowerCase().contains('password')) return 'الباسورد غير صحيح';
    return s.isEmpty ? 'حدث خطأ غير متوقع' : s;
  }

  Future<void> _delete() async {
    if (_loading) return;

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final password = _passController.text.trim();

    setState(() => _loading = true);

    try {
      await widget.service.removeOffice(
        officeId: widget.officeId,
        password: password,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_prettyError(e), style: GoogleFonts.cairo()),
          backgroundColor: Colors.red,
        ),
      );

      // ✅ سيب الديالوج مفتوح عشان يقدر يكتب الباسورد صح
      // Navigator.pop(context, false);
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
              /// Header
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
                        Text(tr(context, 'delete_office'), style: titleStyle),
                        const SizedBox(height: 4),
                        Text(
                          tr(context, 'are_you_sure_you_want_to_delete_this_office'),
                          style: bodyStyle,
                          maxLines: 3,
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

              /// Password
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
                      onFieldSubmitted: (_) => _delete(),
                      decoration: InputDecoration(
                        hintText: tr(context, 'enter_password_to_confirm'),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: _loading ? null : () => setState(() => _obscure = !_obscure),
                          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                        return null;
                      },
                    ),
                  ],
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
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _delete,
                      icon: _loading
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                          : const Icon(Icons.delete_outline, color: Colors.white, size: 18),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
