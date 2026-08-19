import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Title row with icon, title, subtitle, and close button for the report sheet.
class ReportSheetHeader extends StatelessWidget {
  const ReportSheetHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: DeskColors.primarySoft,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Icon(
            Icons.connect_without_contact_rounded,
            color: DeskColors.primary,
            size: 24.r,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('تقرير متابعة ولي الأمر', style: DeskText.heading(18.sp)),
              Text(
                'إرسال ملخص أداء الطالب مباشرة لولي الأمر',
                style: DeskText.note(12.sp),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close_rounded, color: DeskColors.muted, size: 22.r),
        ),
      ],
    );
  }
}
