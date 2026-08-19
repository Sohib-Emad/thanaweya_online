import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Tappable teacher card shown on the About tab.
class InstructorCard extends StatelessWidget {
  final String teacherName;
  final String? teacherAvatarUrl;
  final String teacherId;
  final String subjectName;

  const InstructorCard({
    super.key,
    required this.teacherName,
    required this.teacherId,
    this.teacherAvatarUrl,
    this.subjectName = '',
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return NotebookCard(
      ruled: true,
      ruledStartY: 72,
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pushNamed(
          context,
          AppRouter.studentTeacherPage,
          arguments: {
            'teacherId': teacherId,
            'title': teacherName,
            'avatarUrl': teacherAvatarUrl,
          },
        );
      },
      child: Row(
        children: [
          NotebookTeacherAvatar(
            avatarUrl: teacherAvatarUrl,
            name: teacherName,
            size: 52.r,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(teacherName, style: NotebookText.heading(14.sp)),
                SizedBox(height: 2.h),
                Text(
                  subjectName.isEmpty ? l10n.teacherRole : subjectName,
                  style: NotebookText.note(11.sp),
                ),
              ],
            ),
          ),
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: NotebookColors.surfaceBright,
              shape: BoxShape.circle,
              border: Border.all(
                color: NotebookColors.marginRed.withAlpha(120),
                width: 1.4,
              ),
            ),
            child: Icon(
              Icons.chevron_left_rounded,
              color: NotebookColors.marginRed,
              size: 18.r,
            ),
          ),
        ],
      ),
    );
  }
}
