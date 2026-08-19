import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/features/shared/models/course_model.dart';
import 'package:thanaweya_online/features/teacher/ui/courses/widgets/course_card_banner.dart';
import 'package:thanaweya_online/features/teacher/ui/courses/widgets/course_card_content.dart';

/// Displays a single course as a card with banner, status badge, and actions.
///
/// Delegates visual sections to [CourseCardBanner] and [CourseCardContent].
class CourseCard extends StatelessWidget {
  final CourseModel course;
  final int lessonCount;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTogglePublish;

  const CourseCard({
    super.key,
    required this.course,
    required this.lessonCount,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onTogglePublish,
  });

  @override
  Widget build(BuildContext context) {
    final published = course.isPublished;
    final hasCover =
        course.coverImageUrl != null && course.coverImageUrl!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: const Color(0xFF0284C7).withAlpha(20),
          highlightColor: const Color(0xFF0284C7).withAlpha(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CourseCardBanner(
                course: course,
                published: published,
                hasCover: hasCover,
                onEdit: onEdit,
                onDelete: onDelete,
                onTogglePublish: onTogglePublish,
              ),
              CourseCardContent(
                course: course,
                lessonCount: lessonCount,
                onTap: onTap,
                onEdit: onEdit,
                onDelete: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
