import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';

/// A notebook-styled password field with a visibility toggle icon.
class NotebookPasswordField extends StatelessWidget {
  /// Creates a [NotebookPasswordField].
  const NotebookPasswordField({
    super.key,
    required this.label,
    required this.controller,
    required this.obscure,
    required this.onToggleVisibility,
    this.validator,
    this.onFieldSubmitted,
  });

  /// The label displayed above the field.
  final String label;

  /// The text editing controller.
  final TextEditingController controller;

  /// Whether the text is obscured.
  final bool obscure;

  /// Callback when the visibility icon is tapped.
  final VoidCallback onToggleVisibility;

  /// Optional validator for the [TextFormField].
  final String? Function(String?)? validator;

  /// Called when the user submits the field.
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: NotebookText.strong(12.sp)),
        SizedBox(height: 4.h),
        Row(
          children: [
            Icon(
              Icons.password_rounded,
              color: NotebookColors.pencil,
              size: 18.r,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: TextFormField(
                controller: controller,
                obscureText: obscure,
                validator: validator,
                autofillHints: const [AutofillHints.password],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: onFieldSubmitted,
                style: NotebookText.body(13.sp),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 6),
                ),
              ),
            ),
            GestureDetector(
              onTap: onToggleVisibility,
              child: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: NotebookColors.pencil,
                size: 18.r,
              ),
            ),
          ],
        ),
        Container(height: 1.4, color: NotebookColors.ink.withAlpha(70)),
      ],
    );
  }
}
