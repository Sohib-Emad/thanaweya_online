import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/notebook_theme.dart';

/// Notebook-styled text form field used in the registration form.
class DesignTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextDirection? textDirection;
  final int maxLines;
  final String? Function(String?)? validator;

  const DesignTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textDirection,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textDirection: textDirection,
      maxLines: maxLines,
      validator: validator,
      style: NotebookText.body(14.sp),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: NotebookText.note(13.sp),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: NotebookColors.pencil, size: 20.r)
            : null,
        border: InputBorder.none,
        isDense: true,
      ),
    );
  }
}
