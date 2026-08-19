import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/core/utils/formatters.dart';
import 'package:thanaweya_online/features/student/logic/student_courses_cubit.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/course_about_tab.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/course_cover_section.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/course_meta_section.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/curriculum_tab_content.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/enroll_bar.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Assembles the full scrollable body of the course detail screen.
class CourseDetailsBody extends StatelessWidget {
  final StudentCoursesState state;
  final String courseId;
  final int selectedTab;
  final bool isDescriptionExpanded;
  final bool isSubscribed;
  final dynamic youtubeController;
  final dynamic videoController;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onToggleDescription;
  final void Function(String) onLocked;
  final VoidCallback onComplete;
  final VoidCallback onEnroll;
  final VoidCallback onBack;

  const CourseDetailsBody({
    super.key,
    required this.state,
    required this.courseId,
    required this.selectedTab,
    required this.isDescriptionExpanded,
    required this.isSubscribed,
    required this.onTabChanged,
    required this.onToggleDescription,
    required this.onLocked,
    required this.onComplete,
    required this.onEnroll,
    required this.onBack,
    this.youtubeController,
    this.videoController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final course = state.course ?? const <String, dynamic>{};
    final teachers = course['teachers'] as Map<String, dynamic>? ?? const {};
    final users = teachers['users'] as Map<String, dynamic>? ?? const {};
    final subjects = teachers['subjects'] as Map<String, dynamic>? ?? const {};
    final teacherName = users['full_name'] as String? ?? l10n.teacherRole;
    final teacherAvatarUrl = users['avatar_url'] as String?;
    final teacherId = teachers['id'] as String? ?? '';
    final subjectName = subjects['name_ar'] as String? ?? '';
    final description = course['description'] as String? ?? '';
    final introVideoUrl = course['intro_video_url'] as String? ?? '';
    final introSourceType = course['intro_video_source_type'] as String? ?? 'youtube';
    final coverUrl = course['cover_image_url'] as String? ?? '';
    final totalSecs = state.lessons.fold<int>(0, (s, l) => s + (l.durationSeconds ?? 0));
    final totalDuration = totalSecs > 0 ? Formatters.formatDurationMinutes((totalSecs / 60).ceil()) : '';
    final lessonCount = _lessonCountOf(course['lessons']);

    return Scaffold(
      backgroundColor: NotebookColors.ground,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            NotebookPaper(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(bottom: 100.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CourseCoverSection(
                      introVideoUrl: introVideoUrl, introVideoSourceType: introSourceType,
                      coverUrl: coverUrl, subjectName: subjectName,
                      youtubeController: youtubeController, videoController: videoController,
                      onBack: onBack,
                    ),
                    CourseMetaSection(course: course, lessonCount: lessonCount, totalDurationText: totalDuration, subjectName: subjectName),
                    SizedBox(height: 20.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: NotebookSegmentControl(
                        options: [l10n.aboutTab, l10n.curriculumTab],
                        index: selectedTab,
                        onChanged: onTabChanged,
                      ),
                    ),
                    SizedBox(height: 22.h),
                    selectedTab == 0
                        ? CourseAboutTab(
                            description: description, teacherName: teacherName,
                            teacherAvatarUrl: teacherAvatarUrl, teacherId: teacherId,
                            subjectName: subjectName, courseId: courseId,
                            isDescriptionExpanded: isDescriptionExpanded,
                            onToggleDescription: onToggleDescription,
                          )
                        : CurriculumTabContent(
                            lessons: state.lessons, progress: state.progress,
                            courseId: courseId, isSubscribed: isSubscribed,
                            onLocked: onLocked, onComplete: onComplete,
                          ),
                  ],
                ),
              ),
            ),
            EnrollBar(isSubscribed: isSubscribed, onPressed: onEnroll),
          ],
        ),
      ),
    );
  }

  int _lessonCountOf(dynamic lessons) {
    if (lessons is Map) return (lessons['count'] as int?) ?? 0;
    if (lessons is List && lessons.isNotEmpty) {
      final first = lessons.first;
      if (first is Map) return (first['count'] as int?) ?? 0;
    }
    return 0;
  }
}
