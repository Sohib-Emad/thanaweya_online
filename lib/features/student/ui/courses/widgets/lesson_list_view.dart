import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/core/utils/lesson_progression_helper.dart';
import 'package:thanaweya_online/features/shared/models/lesson_model.dart';
import 'package:thanaweya_online/features/student/logic/student_courses_cubit.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/lesson_card.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Displays the lesson list or loading/empty states.
class LessonListView extends StatelessWidget {
  final StudentCoursesState state;
  final Set<String> completedIds;
  final bool isSubscribed;
  final ValueChanged<LessonModel> onOpenLesson;
  final Future<void> Function()? onRefresh;

  const LessonListView({
    super.key,
    required this.state,
    required this.completedIds,
    required this.isSubscribed,
    required this.onOpenLesson,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if ((state.lessonsStatus == StudentCoursesStatus.loading ||
            state.lessonsStatus == StudentCoursesStatus.initial) &&
        state.lessons.isEmpty) {
      return _buildLoading();
    }
    if (state.lessonsStatus == StudentCoursesStatus.error && state.lessons.isEmpty) {
      return _buildLoading();
    }
    if (state.lessons.isEmpty) {
      return RefreshIndicator(
        color: NotebookColors.green,
        onRefresh: onRefresh ?? () async {},
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 80.h),
              child: Center(
                child: Text(
                  context.l10n.noLessonsYet,
                  style: NotebookText.body(13.sp),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      );
    }
    final statusMap = LessonProgressionHelper.evaluateLessons(
      lessons: state.lessons,
      progress: state.progress,
      isSubscribed: isSubscribed,
      courseExams: state.courseExams,
      examSubmissions: state.examSubmissions,
    );

    return RefreshIndicator(
      color: NotebookColors.green,
      onRefresh: onRefresh ?? () async {},
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 20.h),
        itemCount: state.lessons.length,
        separatorBuilder: (_, _) => SizedBox(height: 12.h),
        itemBuilder: (_, index) {
          final lesson = state.lessons[index];
          final lockStatus = statusMap[lesson.id];
          return LessonCard(
            title: lesson.title,
            description: lesson.description,
            number: (index + 1).toString().padLeft(2, '0'),
            isCompleted: lockStatus?.isCompleted ?? completedIds.contains(lesson.id),
            isSubscribed: isSubscribed,
            isUnlocked: lockStatus?.isUnlocked ?? true,
            lockReason: lockStatus?.lockReason,
            durationSeconds: lesson.durationSeconds,
            onTap: () => onOpenLesson(lesson),
          );
        },
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: NotebookColors.green),
          SizedBox(height: 16.h),
          Text('جاري تحميل الدروس...', style: NotebookText.body(13.sp)),
        ],
      ),
    );
  }
}
