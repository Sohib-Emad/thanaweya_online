import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/router/app_router.dart';
import '../../../../../core/theme/notebook_theme.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../shared/models/lesson_model.dart';
import '../../../../student/logic/student_courses_cubit.dart';
import '../../../../../l10n/l10n.dart';

/// Builds the scrollable list of curriculum sections and lessons.
class CurriculumSectionsBuilder extends StatelessWidget {
  final StudentCoursesCubit coursesCubit;
  final String courseId;

  const CurriculumSectionsBuilder({super.key, required this.coursesCubit, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentCoursesCubit, StudentCoursesState>(
      bloc: coursesCubit,
      builder: (context, state) {
        if (state.lessonsStatus == StudentCoursesStatus.loading && state.lessons.isEmpty) {
          return Center(child: CircularProgressIndicator(color: NotebookColors.green));
        }
        final sections = _buildSections(state.lessons, context.l10n);
        if (sections.isEmpty) {
          return Padding(padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0), child: NotebookEmptyNote(message: context.l10n.noLessonsYet));
        }
        return _buildList(context, sections);
      },
    );
  }

  List<Map<String, dynamic>> _buildSections(List<LessonModel> lessons, AppLocalizations l10n) {
    if (lessons.isEmpty) return const [];
    final total = lessons.fold<int>(0, (s, l) => s + (l.durationSeconds ?? 0));
    return [{
      'sectionNumber': l10n.sectionLabel('01'), 'title': l10n.courseSectionTitle,
      'totalDuration': total > 0 ? Formatters.formatDurationMinutes((total / 60).ceil()) : '',
      'lessons': [for (var i = 0; i < lessons.length; i++) {
        'id': lessons[i].id, 'videoUrl': lessons[i].videoUrlOrId,
        'number': (i + 1).toString().padLeft(2, '0'), 'title': lessons[i].title,
        'duration': lessons[i].durationSeconds != null ? Formatters.formatDurationMinutes((lessons[i].durationSeconds! / 60).ceil()) : '',
        'isUnlocked': true,
      }],
    }];
  }

  Widget _buildList(BuildContext context, List<Map<String, dynamic>> sections) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 110.h),
      physics: const BouncingScrollPhysics(),
      itemCount: sections.length,
      itemBuilder: (context, i) {
        final sec = sections[i];
        final num = sec['sectionNumber'] as String;
        final title = sec['title'] as String;
        final dur = sec['totalDuration'] as String;
        final lessons = sec['lessons'] as List<Map<String, dynamic>>;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text('$num : $title', style: NotebookText.heading(14.sp), maxLines: 1, overflow: TextOverflow.ellipsis)),
            if (dur.isNotEmpty) ...[SizedBox(width: 8.w), Text(dur, style: NotebookText.note(11.sp))],
          ]),
          SizedBox(height: 12.h),
          ...lessons.map((l) => _tile(context, l)),
          SizedBox(height: 14.h),
        ]);
      },
    );
  }

  Widget _tile(BuildContext context, Map<String, dynamic> l) {
    final num = l['number'] as String;
    final title = l['title'] as String;
    final dur = l['duration'] as String;
    final ok = l['isUnlocked'] as bool;
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: NotebookCard(
        ruled: true, ruledStartY: 60,
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pushNamed(context, AppRouter.studentVideoPlayer, arguments: {'lessonId': l['id'], 'videoUrl': l['videoUrl'], 'title': title, 'courseId': courseId});
        },
        child: Row(children: [
          Container(
            width: 36.r, height: 36.r,
            decoration: BoxDecoration(color: NotebookColors.surfaceBright, shape: BoxShape.circle, border: Border.all(color: ok ? NotebookColors.green.withAlpha(90) : NotebookColors.ink.withAlpha(30), width: 1.2)),
            child: Center(child: Text(num, style: NotebookText.strong(12.sp, color: ok ? NotebookColors.ink : NotebookColors.pencil))),
          ),
          SizedBox(width: 12.w),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: NotebookText.body(13.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
            if (dur.isNotEmpty) ...[SizedBox(height: 2.h), Text(dur, style: NotebookText.note(10.sp))],
          ])),
          Container(
            width: 30.r, height: 30.r,
            decoration: BoxDecoration(color: ok ? NotebookColors.green : NotebookColors.ink.withAlpha(40), shape: BoxShape.circle),
            child: Icon(ok ? Icons.play_arrow_rounded : Icons.lock_outline_rounded, color: Colors.white, size: 16.r),
          ),
        ]),
      ),
    );
  }
}
