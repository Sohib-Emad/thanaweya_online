import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Header row of an exam card showing an accent icon, title, and course name.
class ExamCardHeader extends StatelessWidget {
  /// The exam title.
  final String title;

  /// The course title, if linked.
  final String? courseTitle;

  /// Accent color derived from publish state.
  final Color accent;

  const ExamCardHeader({
    super.key,
    required this.title,
    required this.courseTitle,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48.r,
          height: 48.r,
          decoration: BoxDecoration(
            color: accent.withAlpha(26),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: accent.withAlpha(110), width: 1.2),
          ),
          child: Icon(Icons.assignment_turned_in_outlined, color: accent, size: 24.r),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: DeskText.strong(15.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
              SizedBox(height: 3.h),
              Text(courseTitle ?? 'بدون دورة مرتبطة', style: DeskText.note(12.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}
