import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Dropdown built as a tappable field + bottom-sheet picker.
class DeskDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final String hint;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const DeskDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.hint,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _PickerSheet(
            label: label,
            value: value,
            options: options,
            onChanged: onChanged,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: DeskColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: DeskColors.line, width: 1.2),
        ),
        child: Row(children: [
          Icon(Icons.location_on_outlined, color: DeskColors.primary, size: 18.r),
          SizedBox(width: 10.w),
          Expanded(child: Text(value ?? hint,
            style: DeskText.body(13.sp, color: value != null ? DeskColors.ink : DeskColors.faint))),
          Icon(Icons.keyboard_arrow_down_rounded, color: DeskColors.muted, size: 22.r),
        ]),
      ),
    );
  }
}

class _PickerSheet extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const _PickerSheet({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.75;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: const BoxDecoration(
          color: DeskColors.ground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44.w,
                height: 4.h,
                margin: EdgeInsets.only(top: 8.h, bottom: 12.h),
                decoration: BoxDecoration(
                  color: DeskColors.faint,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            Text('اختر $label', style: DeskText.heading(16.sp)),
            SizedBox(height: 12.h),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: options.map((option) {
                    final sel = option == value;
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        onChanged(option);
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 8.h),
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 14.h),
                        decoration: BoxDecoration(
                          color: sel
                              ? DeskColors.primary.withAlpha(22)
                              : DeskColors.surface,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: sel
                                ? DeskColors.primary.withAlpha(180)
                                : DeskColors.line,
                            width: sel ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                option,
                                style: DeskText.body(13.sp,
                                    color: sel
                                        ? DeskColors.primary
                                        : DeskColors.ink),
                              ),
                            ),
                            if (sel)
                              Icon(Icons.check_circle_rounded,
                                  color: DeskColors.primary, size: 20.r),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
