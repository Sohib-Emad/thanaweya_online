import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'desk_colors.dart';
import 'desk_text.dart';

/// A modern segmented switcher.
class DeskSegmentedControl extends StatelessWidget {
  const DeskSegmentedControl({
    super.key,
    required this.options,
    required this.index,
    required this.onChanged,
  });

  final List<String> options;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: DeskColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: DeskColors.line, width: 1),
      ),
      child: Row(
        children: List.generate(options.length, (i) {
          final selected = i == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: selected ? DeskColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withAlpha(20),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    options[i],
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                      color: selected ? DeskColors.primary : DeskColors.muted,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// A labeled input field on a soft recessed fill.
class DeskInputField extends StatelessWidget {
  const DeskInputField({
    super.key,
    required this.label,
    required this.controller,
    this.icon,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.readOnly = false,
  });

  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: DeskText.strong(12.sp)),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: DeskColors.surfaceAlt,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: DeskColors.line, width: 1),
          ),
          child: Row(
            crossAxisAlignment: maxLines > 1
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: DeskColors.faint, size: 18.r),
                SizedBox(width: 10.w),
              ],
              Expanded(
                child: TextFormField(
                  controller: controller,
                  style: DeskText.body(13.sp),
                  cursorColor: DeskColors.primary,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  maxLines: maxLines,
                  readOnly: readOnly,
                  onChanged: onChanged,
                  validator: validator,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: DeskText.note(12.sp)
                        .copyWith(color: DeskColors.faint),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
