import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../localization/translator.dart';

const _kPrimary = Color(0xff3a4262);

class AppFormField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? initial;
  final IconData? icon;
  final bool enabled;

  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int maxLines;

  // ✅ NEW (no behavior change for existing calls)
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffix;

  const AppFormField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.initial,
    this.icon,
    this.enabled = true,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.suffix,
  });

  InputDecoration _decoration() {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: c, width: 1),
    );

    final fill = enabled ? Colors.white : Colors.grey.shade100;

    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, size: 20) : null,
      suffixIcon: suffix,
      isDense: true,
      filled: true,
      fillColor: fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: border(Colors.grey.shade300),
      enabledBorder: border(Colors.grey.shade300),
      focusedBorder: border(_kPrimary),
      errorBorder: border(Colors.red.shade300),
      focusedErrorBorder: border(Colors.red.shade400),
      counterText: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null) {
      return TextFormField(
        initialValue: initial,
        enabled: enabled,
        readOnly: readOnly,
        onTap: onTap,
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        maxLines: maxLines,
        decoration: _decoration(),
      );
    }

    return TextFormField(
      controller: controller,
      enabled: enabled,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      maxLines: maxLines,
      decoration: _decoration(),
    );
  }
}

class PhoneField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const PhoneField({
    super.key,
    required this.label,
    this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: c, width: 1),
    );

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      validator: validator,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(8),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: 'xxxxxxxx',
        prefixIcon: const Icon(Icons.phone_iphone, size: 20),
        prefix: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('+9665', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: border(Colors.grey.shade300),
        enabledBorder: border(Colors.grey.shade300),
        focusedBorder: border(_kPrimary),
        errorBorder: border(Colors.red.shade300),
        focusedErrorBorder: border(Colors.red.shade400),
      ),
    );
  }
}

class NotesField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const NotesField({
    super.key,
    this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: c, width: 1),
    );

    return TextFormField(
      controller: controller,
      maxLines: 4,
      validator: validator,
      maxLength: 500,
      decoration: InputDecoration(
        labelText: tr(context, 'notes'),
        hintText: tr(context, 'enter_additional_notes'),
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: border(Colors.grey.shade300),
        enabledBorder: border(Colors.grey.shade300),
        focusedBorder: border(_kPrimary),
        errorBorder: border(Colors.red.shade300),
        focusedErrorBorder: border(Colors.red.shade400),
      ),
    );
  }
}

class AppDropdown extends StatelessWidget {
  final String label;
  final IconData? icon;

  final String? value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  final String? Function(String?)? validator;

  const AppDropdown({
    super.key,
    required this.label,
    this.icon,
    required this.items,
    required this.onChanged,
    this.value,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: c, width: 1),
    );

    return DropdownButtonFormField<String>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: border(Colors.grey.shade300),
        enabledBorder: border(Colors.grey.shade300),
        focusedBorder: border(_kPrimary),
        errorBorder: border(Colors.red.shade300),
        focusedErrorBorder: border(Colors.red.shade400),
      ),
    );
  }
}
