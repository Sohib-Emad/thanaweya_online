import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';

/// A notebook-styled text input field with an underline decoration.
class NotebookInputField extends StatelessWidget {
  /// Creates a [NotebookInputField].
  const NotebookInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.onChanged,
  });

  /// The label displayed above the field.
  final String label;

  /// The text editing controller.
  final TextEditingController controller;

  /// The placeholder hint text.
  final String hint;

  /// The keyboard type for the field.
  final TextInputType keyboardType;

  /// Whether the text should be obscured.
  final bool obscureText;

  /// Called when the field value changes.
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: NotebookText.strong(12.sp)),
        SizedBox(height: 4.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: onChanged,
          style: NotebookText.body(13.sp),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: NotebookText.note(12.sp)
                .copyWith(color: NotebookColors.pencil.withAlpha(180)),
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 6),
          ),
        ),
        Container(height: 1.4, color: NotebookColors.ink.withAlpha(70)),
      ],
    );
  }
}
