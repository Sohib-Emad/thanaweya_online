import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/core/utils/formatters.dart';
import 'package:thanaweya_online/core/utils/lesson_progression_helper.dart';
import 'package:thanaweya_online/features/shared/models/lesson_model.dart';
import 'package:thanaweya_online/features/shared/models/lesson_progress_model.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/curriculum_lesson_tile.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/lesson_exam_required_dialog.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Curriculum tab body: lists course sections and their lesson tiles with
/// sequential unlocking and exam prerequisite checks.
class CurriculumTabContent extends StatelessWidget {
  final List<LessonModel> lessons;
  final List<LessonProgressModel> progress;
  final List<Map<String, dynamic>> courseExams;
  final List<Map<String, dynamic>> examSubmissions;
  final String courseId;
  final bool isSubscribed;
  final void Function(String lessonTitle)? onLocked;
  final VoidCallback? onComplete;

  const CurriculumTabContent({
    super.key,
    required this.lessons,
    required this.progress,
    this.courseExams = const [],
    this.examSubmissions = const [],
    required this.courseId,
    required this.isSubscribed,
    this.onLocked,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sections = _buildSections(l10n);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sections.map((sec) {
          final sectionNumber = sec['sectionNumber'] as String;
          final title = sec['title'] as String;
          final totalDuration = sec['totalDuration'] as String;
          final items = sec['lessons'] as List<Map<String, dynamic>>;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$sectionNumber : $title', style: NotebookText.heading(14.sp)),
                  if (totalDuration.isNotEmpty)
                    Text(
                      totalDuration,
                      style: NotebookText.strong(12.sp, color: NotebookColors.green),
                    ),
                ],
              ),
              SizedBox(height: 12.h),
              ...items.map(
                (les) {
                  final lockStatus = les['lockStatus'] as LessonLockStatus;
                  return CurriculumLessonTile(
                    lesson: les,
                    courseId: courseId,
                    lockStatus: lockStatus,
                    onLocked: (title) {
                      if (!isSubscribed) {
                        onLocked?.call(title);
                      } else {
                        LessonExamRequiredDialog.show(
                          context,
                          lessonTitle: title,
                          lockStatus: lockStatus,
                          courseId: courseId,
                          onRefresh: onComplete,
                        );
                      }
                    },
                    onComplete: () => onComplete?.call(),
                  );
                },
              ),
              SizedBox(height: 16.h),
            ],
          );
        }).toList(),
      ),
    );
  }

  List<Map<String, dynamic>> _buildSections(AppLocalizations l10n) {
    if (lessons.isEmpty) return const [];

    final statusMap = LessonProgressionHelper.evaluateLessons(
      lessons: lessons,
      progress: progress,
      isSubscribed: isSubscribed,
      courseExams: courseExams,
      examSubmissions: examSubmissions,
    );

    final totalSeconds = lessons.fold<int>(
      0,
      (sum, l) => sum + (l.durationSeconds ?? 0),
    );

    return [
      {
        'sectionNumber': l10n.sectionLabel('01'),
        'title': l10n.courseSectionTitle,
        'totalDuration': totalSeconds > 0
            ? Formatters.formatDurationMinutes((totalSeconds / 60).ceil())
            : '',
        'lessons': [
          for (var i = 0; i < lessons.length; i++)
            {
              'id': lessons[i].id,
              'videoUrl': lessons[i].videoUrlOrId,
              'number': (i + 1).toString().padLeft(2, '0'),
              'title': lessons[i].title,
              'duration': lessons[i].durationSeconds != null
                  ? Formatters.formatDurationMinutes(
                      (lessons[i].durationSeconds! / 60).ceil(),
                    )
                  : '',
              'isUnlocked': statusMap[lessons[i].id]?.isUnlocked ?? false,
              'isCompleted': statusMap[lessons[i].id]?.isCompleted ?? false,
              'lockStatus': statusMap[lessons[i].id] ??
                  const LessonLockStatus(isUnlocked: false, isCompleted: false),
            },
        ],
      },
    ];
  }
}
