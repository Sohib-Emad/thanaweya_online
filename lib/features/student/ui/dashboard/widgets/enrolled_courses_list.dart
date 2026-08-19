import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'enrolled_course_card.dart';

/// A horizontal list of the student's enrolled courses with progress bars.
class EnrolledCoursesList extends StatelessWidget {
  /// Creates an [EnrolledCoursesList].
  const EnrolledCoursesList({
    super.key,
    required this.courses,
    required this.onNavigateToCourses,
    required this.onCourseTap,
  });

  /// The raw enrolled-course maps from the cubit state.
  final List<Map<String, dynamic>> courses;

  /// Called when the user taps the section action to navigate to all courses.
  final VoidCallback onNavigateToCourses;

  /// Called when the user taps a course card, receiving the raw course map.
  final ValueChanged<Map<String, dynamic>> onCourseTap;

  static const _palette = [
    Color(0xFF0FA37F),
    Color(0xFF2563EB),
    Color(0xFFEF4444),
    Color(0xFFD97706),
    Color(0xFF9333EA),
    Color(0xFF0284C7),
  ];

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NotebookSectionHeader(
          title: 'متابعة دراستك',
          onAction: onNavigateToCourses,
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 140.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            itemCount: courses.length,
            separatorBuilder: (_, _) => SizedBox(width: 14.w),
            itemBuilder: (context, index) {
              final c = courses[index];
              return EnrolledCourseCard(
                title: c['title'] as String? ?? '',
                teacher: c['teacher_name'] as String? ?? 'مدرس',
                subject: c['subject_name'] as String? ?? '',
                coverUrl: c['cover_image_url'] as String? ?? '',
                color: _palette[index % _palette.length],
                progress: (c['progress'] as double?) ?? 0.0,
                done: (c['completedCount'] as int?) ?? 0,
                total: (c['totalCount'] as int?) ?? 0,
                onTap: () => onCourseTap(c),
              );
            },
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }
}
