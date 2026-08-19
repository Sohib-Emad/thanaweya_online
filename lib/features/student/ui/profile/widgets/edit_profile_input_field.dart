import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/notebook_theme.dart';

/// Reusable labeled input field with an icon and underline divider.
class EditProfileInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool isReadOnly;
  final bool enabled;
  final VoidCallback? onTap;
  final TextInputType keyboardType;
  final String? prefixText;

  const EditProfileInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.isReadOnly = false,
    this.enabled = true,
    this.onTap,
    this.keyboardType = TextInputType.text,
    this.prefixText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: NotebookText.strong(12.sp)),
        SizedBox(height: 4.h),
        Row(
          children: [
            Icon(icon, color: NotebookColors.pencil, size: 18.r),
            SizedBox(width: 10.w),
            if (prefixText != null) ...[
              Text(prefixText!, style: NotebookText.strong(12.sp)),
              SizedBox(width: 8.w),
            ],
            Expanded(
              child: TextField(
                controller: controller,
                readOnly: isReadOnly,
                enabled: enabled,
                onTap: onTap,
                keyboardType: keyboardType,
                style: NotebookText.body(13.sp),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 6.h),
                ),
              ),
            ),
          ],
        ),
        Container(height: 1.4, color: NotebookColors.ink.withAlpha(70)),
      ],
    );
  }
}
