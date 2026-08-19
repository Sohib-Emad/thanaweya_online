import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

import 'package:thanaweya_online/features/student/ui/courses/widgets/instructor_card.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/what_you_get_section.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/reviews_entry.dart';

/// About-tab body: description, instructor, what you'll get, and reviews entry.
class CourseAboutTab extends StatelessWidget {
  final String description;
  final String teacherName;
  final String? teacherAvatarUrl;
  final String teacherId;
  final String subjectName;
  final String courseId;
  final bool isDescriptionExpanded;
  final VoidCallback onToggleDescription;

  const CourseAboutTab({
    super.key,
    required this.description,
    required this.teacherName,
    required this.teacherId,
    required this.courseId,
    required this.isDescriptionExpanded,
    required this.onToggleDescription,
    this.teacherAvatarUrl,
    this.subjectName = '',
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description.isEmpty ? l10n.courseIntroFallback : description,
            style: NotebookText.body(13.sp),
            maxLines: isDescriptionExpanded ? null : 4,
            overflow: isDescriptionExpanded
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onToggleDescription();
            },
            child: Text(
              isDescriptionExpanded ? l10n.showLess : l10n.readMore,
              style: NotebookText.strong(12.sp, color: NotebookColors.green),
            ),
          ),
          SizedBox(height: 24.h),
          NotebookSectionHeader(title: l10n.instructor),
          SizedBox(height: 12.h),
          InstructorCard(
            teacherName: teacherName,
            teacherAvatarUrl: teacherAvatarUrl,
            teacherId: teacherId,
            subjectName: subjectName,
          ),
          SizedBox(height: 24.h),
          const WhatYouGetSection(),
          SizedBox(height: 24.h),
          ReviewsEntry(courseId: courseId),
        ],
      ),
    );
  }
}
