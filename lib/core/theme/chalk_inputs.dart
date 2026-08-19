import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'chalk_colors.dart';
import 'chalk_text.dart';

/// A chalk segment switcher (two or more options).
class ChalkSegmentedControl extends StatelessWidget {
  const ChalkSegmentedControl({
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
        color: ChalkboardColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: ChalkboardColors.ink.withAlpha(50)),
      ),
      child: Row(
        children: List.generate(options.length, (i) {
          final selected = i == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 9.h),
                decoration: BoxDecoration(
                  color: selected ? ChalkboardColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Text(
                    options[i],
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                      color: selected
                          ? ChalkboardColors.onAccent
                          : ChalkboardColors.chalkSoft,
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

/// A chalk-underline input field with a label.
class ChalkInputField extends StatelessWidget {
  const ChalkInputField({
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
        Text(label, style: ChalkboardText.strong(12.sp)),
        SizedBox(height: 4.h),
        Row(
          crossAxisAlignment: maxLines > 1
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: ChalkboardColors.chalkSoft, size: 18.r),
              SizedBox(width: 10.w),
            ],
            Expanded(
              child: TextFormField(
                controller: controller,
                style: ChalkboardText.body(13.sp),
                cursorColor: ChalkboardColors.accent,
                obscureText: obscureText,
                keyboardType: keyboardType,
                maxLines: maxLines,
                readOnly: readOnly,
                onChanged: onChanged,
                validator: validator,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: ChalkboardText.note(12.sp)
                      .copyWith(color: ChalkboardColors.chalkFaint),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 6.h),
                ),
              ),
            ),
          ],
        ),
        Container(height: 1.4, color: ChalkboardColors.ink.withAlpha(90)),
      ],
    );
  }
}
