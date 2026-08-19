import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/shared/models/lesson_model.dart';

/// Dropdown for selecting a course and optional lesson link.
class CourseLessonDropdown extends StatelessWidget {
  /// Currently selected course ID.
  final String? selectedCourseId;

  /// Currently selected lesson ID.
  final String? selectedLessonId;

  /// Map of course IDs to titles.
  final Map<String, String> courseTitles;

  /// Lessons loaded for the selected course.
  final List<LessonModel> courseLessons;

  /// Callback when course selection changes.
  final ValueChanged<String?> onCourseChanged;

  /// Callback when lesson selection changes.
  final ValueChanged<String?> onLessonChanged;

  const CourseLessonDropdown({
    super.key,
    required this.selectedCourseId,
    required this.selectedLessonId,
    required this.courseTitles,
    required this.courseLessons,
    required this.onCourseChanged,
    required this.onLessonChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (courseTitles.isNotEmpty) ...[
          Text('اختر الدورة (اختياري)', style: DeskText.strong(12.sp)),
          SizedBox(height: 6.h),
          _DropdownContainer(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCourseId,
                isExpanded: true,
                dropdownColor: DeskColors.surface,
                hint: Text('بدون دورة', style: DeskText.note(12.sp)),
                style: DeskText.body(12.sp),
                items: [
                  const DropdownMenuItem<String>(value: null, child: Text('بدون دورة')),
                  ...courseTitles.entries.map((e) => DropdownMenuItem<String>(value: e.key, child: Text(e.value, maxLines: 1, overflow: TextOverflow.ellipsis))),
                ],
                onChanged: onCourseChanged,
              ),
            ),
          ),
          SizedBox(height: 18.h),
        ],
        if (selectedCourseId != null && courseLessons.isNotEmpty) ...[
          Text('اربط الامتحان بدرس (اختياري)', style: DeskText.strong(12.sp)),
          SizedBox(height: 6.h),
          _DropdownContainer(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedLessonId,
                isExpanded: true,
                dropdownColor: DeskColors.surface,
                hint: Text('بدون درس', style: DeskText.note(12.sp)),
                style: DeskText.body(12.sp),
                items: [
                  const DropdownMenuItem<String>(value: null, child: Text('بدون درس')),
                  ...courseLessons.map((l) => DropdownMenuItem<String>(value: l.id, child: Text(l.title, maxLines: 1, overflow: TextOverflow.ellipsis))),
                ],
                onChanged: onLessonChanged,
              ),
            ),
          ),
          SizedBox(height: 18.h),
        ],
      ],
    );
  }
}

class _DropdownContainer extends StatelessWidget {
  final Widget child;
  const _DropdownContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: DeskColors.surfaceAlt,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: DeskColors.line),
      ),
      child: child,
    );
  }
}
