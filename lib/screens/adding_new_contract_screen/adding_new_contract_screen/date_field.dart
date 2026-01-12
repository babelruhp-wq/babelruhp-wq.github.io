import 'package:flutter/material.dart';
import '../../../localization/translator.dart';
import 'form_fields.dart';

class DateField extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime? value;
  final VoidCallback onPick;

  final bool required;
  final TextEditingController controller;

  /// optional clear
  final VoidCallback? onClear;

  const DateField({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.onPick,
    required this.controller,
    this.required = false,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final showClear = onClear != null && value != null;

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: onPick,
            child: IgnorePointer(
              child: AppFormField(
                controller: controller,
                label: required ? '$label *' : label,
                hint: tr(context, 'date_format_hint'),
                icon: icon,
                enabled: false,
                validator: required
                    ? (_) {
                  if (value == null) return tr(context, 'select_date');
                  return null;
                }
                    : null,
              ),
            ),
          ),
        ),
        if (showClear) ...[
          const SizedBox(width: 8),
          Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: InkWell(
              onTap: onClear,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(Icons.close, size: 18, color: Colors.red.shade400),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
