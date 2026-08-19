import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/notebook_theme.dart';

/// Gender dropdown selector displayed in a notebook-styled card.
class EditProfileGenderDropdown extends StatelessWidget {
  final String selectedValue;
  final ValueChanged<String?> onChanged;

  const EditProfileGenderDropdown({
    super.key,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selectedValue,
        isExpanded: true,
        icon: const Icon(Icons.arrow_drop_down_rounded),
        style: NotebookText.body(13.sp),
        dropdownColor: NotebookColors.surface,
        items: const [
          DropdownMenuItem(
            value: 'ذكر (Male)',
            child: Text('ذكر (Male)'),
          ),
          DropdownMenuItem(
            value: 'أنثى (Female)',
            child: Text('أنثى (Female)'),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
