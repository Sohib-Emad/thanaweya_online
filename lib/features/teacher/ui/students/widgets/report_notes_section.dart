import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Notes section with preset chips and a custom text field.
class ReportNotesSection extends StatelessWidget {
  const ReportNotesSection({
    super.key,
    required this.controller,
    required this.onPresetSelected,
  });

  final TextEditingController controller;
  final ValueChanged<String> onPresetSelected;

  static const _presets = [
    'طالب ممتاز ومجتهد جداً',
    'أداء رائع بالامتحانات',
    'يرجى حثه على إكمال باقي الفيديوهات',
    'يحتاج لمتابعة حل الواجبات والاختبارات',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ملاحظات وتوصيات المعلم:', style: DeskText.strong(13.sp)),
            Text('عبارات جاهزة', style: DeskText.note(11.sp)),
          ],
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 6.w,
          runSpacing: 6.h,
          children: _presets.map((preset) {
            return ActionChip(
              label: Text(
                preset,
                style: GoogleFonts.cairo(
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w700,
                  color: DeskColors.primary,
                ),
              ),
              backgroundColor: DeskColors.primarySoft,
              side: BorderSide(color: DeskColors.primary.withAlpha(50)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              onPressed: () {
                HapticFeedback.selectionClick();
                onPresetSelected(preset);
              },
            );
          }).toList(),
        ),
        SizedBox(height: 10.h),
        TextField(
          controller: controller,
          maxLines: 3,
          style: GoogleFonts.cairo(fontSize: 13.sp),
          decoration: InputDecoration(
            hintText:
                'اكتب ملاحظتك المخصصة لولي الأمر أو اختر من العبارات الجاهزة أعلاه...',
            hintStyle: DeskText.note(11.5.sp),
            fillColor: DeskColors.surfaceAlt,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: DeskColors.line),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: DeskColors.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: DeskColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
