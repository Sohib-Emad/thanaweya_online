import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Card displaying homework title, course, submission progress, and status.
class HomeworkCard extends StatelessWidget {
  const HomeworkCard({
    super.key,
    required this.title,
    required this.course,
    required this.submissions,
    required this.totalStudents,
  });

  final String title;
  final String course;
  final int submissions;
  final int totalStudents;

  @override
  Widget build(BuildContext context) {
    final double ratio = totalStudents > 0 ? submissions / totalStudents : 0;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: DeskColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: DeskText.strong(13.5.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DeskStatusChip(label: 'نشط', color: DeskColors.primary),
            ],
          ),
          SizedBox(height: 4.h),
          Text(course, style: DeskText.note(11.5.sp)),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: ratio,
                    backgroundColor: DeskColors.line,
                    color: DeskColors.primary,
                    minHeight: 6.h,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                '$submissions من $totalStudents طالب تسلموا الواجب',
                style: DeskText.strong(11.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
