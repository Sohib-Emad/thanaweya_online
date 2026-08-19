import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/core/utils/formatters.dart';
import 'package:thanaweya_online/features/shared/models/lesson_model.dart';
import 'package:thanaweya_online/features/shared/models/lesson_progress_model.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/curriculum_lesson_tile.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Curriculum tab body: lists course sections and their lesson tiles.
class CurriculumTabContent extends StatelessWidget {
  final List<LessonModel> lessons;
  final List<LessonProgressModel> progress;
  final String courseId;
  final bool isSubscribed;
  final void Function(String lessonTitle)? onLocked;
  final VoidCallback? onComplete;

  const CurriculumTabContent({
    super.key,
    required this.lessons,
    required this.progress,
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
                (les) => CurriculumLessonTile(
                  lesson: les,
                  courseId: courseId,
                  onLocked: (title) => onLocked?.call(title),
                  onComplete: () => onComplete?.call(),
                ),
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
    final completedIds = {
      for (final p in progress)
        if (p.isCompleted || p.watchedSeconds > 0) p.lessonId,
    };
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
              'isUnlocked': isSubscribed,
              'isCompleted': completedIds.contains(lessons[i].id),
            },
        ],
      },
    ];
  }
}
