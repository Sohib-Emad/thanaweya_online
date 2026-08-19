import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'chalk_colors.dart';
import 'chalk_text.dart';

/// A chalk search line: search glyph + invisible field on a chalk underline.
class ChalkSearchField extends StatelessWidget {
  const ChalkSearchField({
    super.key,
    required this.controller,
    required this.hint,
    this.onChanged,
    this.onSubmitted,
    this.trailing,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.search_rounded, color: ChalkboardColors.chalkSoft, size: 20.r),
              SizedBox(width: 10.w),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: ChalkboardText.body(13.sp),
                  cursorColor: ChalkboardColors.accent,
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: ChalkboardText.note(12.sp)
                        .copyWith(color: ChalkboardColors.chalkFaint),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          SizedBox(height: 4.h),
          Container(height: 1.4, color: ChalkboardColors.ink.withAlpha(90)),
        ],
      ),
    );
  }
}
