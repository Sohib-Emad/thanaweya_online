import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/notebook_theme.dart';

/// Notebook-styled dropdown form field used in the registration form.
class DesignDropdown extends StatelessWidget {
  final String? value;
  final String hintText;
  final IconData? prefixIcon;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const DesignDropdown({
    super.key,
    required this.value,
    required this.hintText,
    this.prefixIcon,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: NotebookColors.pencil,
        size: 22.r,
      ),
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
