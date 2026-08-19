import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'notebook_colors.dart';
import 'notebook_text.dart';

/// A ruled search line: pencil icon, invisible-bordered field, and an
/// optional red filter button, all resting on a single ruled underline.
class NotebookSearchField extends StatelessWidget {
  const NotebookSearchField({
    super.key,
    required this.controller,
    required this.hint,
    this.onFilter,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback? onFilter;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 0),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.search_rounded, color: NotebookColors.pencil, size: 20.r),
              SizedBox(width: 10.w),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: NotebookText.body(13.sp),
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: NotebookText.note(12.sp)
                        .copyWith(color: NotebookColors.pencil.withAlpha(180)),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              if (onFilter != null)
                GestureDetector(
                  onTap: onFilter,
                  child: Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: NotebookColors.surfaceBright,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: NotebookColors.marginRed.withAlpha(140),
                        width: 1.4,
                      ),
                    ),
                    child: Icon(Icons.tune_rounded, color: NotebookColors.marginRed, size: 18.r),
                  ),
                ),
            ],
          ),
          SizedBox(height: 4.h),
          Container(height: 1.4, color: NotebookColors.ink.withAlpha(70)),
        ],
      ),
    );
  }
}
