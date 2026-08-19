import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/my_course_card.dart';

/// Displays the courses list or loading/error/empty states.
class CoursesListView extends StatelessWidget {
  final dynamic state;
  final bool isOngoing;
  final VoidCallback onRefresh;
  final String emptyOngoingText;
  final String emptyCompletedText;

  const CoursesListView({
    super.key,
    required this.state,
    required this.isOngoing,
    required this.onRefresh,
    required this.emptyOngoingText,
    required this.emptyCompletedText,
  });

  @override
  Widget build(BuildContext context) {
    final allCourses = isOngoing ? state.myCourses : <Map<String, dynamic>>[];

    if (isOngoing &&
        (state.myCoursesStatus.toString().contains('loading') ||
            state.myCoursesStatus.toString().contains('initial')) &&
        state.myCourses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: NotebookColors.green),
            SizedBox(height: 16.h),
            Text('جاري تحميل كورساتك...', style: NotebookText.body(13.sp)),
          ],
        ),
      );
    }

    if (isOngoing &&
        state.myCoursesStatus.toString().contains('error') &&
        state.myCourses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, size: 40.r, color: NotebookColors.marginRed),
            SizedBox(height: 12.h),
            Text('تعذر تحميل الكورسات', style: NotebookText.body(14.sp)),
            SizedBox(height: 12.h),
            ElevatedButton.icon(
              onPressed: onRefresh,
              style: ElevatedButton.styleFrom(
                  backgroundColor: NotebookColors.green, foregroundColor: Colors.white),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (allCourses.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => onRefresh(),
        color: NotebookColors.green,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 40.h, 24.w, 0),
              child: NotebookEmptyNote(
                message: isOngoing ? emptyOngoingText : emptyCompletedText,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: NotebookColors.green,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 30.h),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: allCourses.length,
        itemBuilder: (_, index) => MyCourseCard(
          course: allCourses[index],
          color: const [
            Color(0xFF0FA37F), Color(0xFFEA580C),
            Color(0xFF2563EB), Color(0xFF7C3AED),
          ][index % 4],
          selectedTab: isOngoing ? 1 : 0,
        ),
      ),
    );
  }
}
