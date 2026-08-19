import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
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

  const LessonListView({
    super.key,
    required this.state,
    required this.completedIds,
    required this.isSubscribed,
    required this.onOpenLesson,
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
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(context.l10n.noLessonsYet,
              style: NotebookText.body(13.sp), textAlign: TextAlign.center),
        ),
      );
    }
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 20.h),
      itemCount: state.lessons.length,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (_, index) {
        final lesson = state.lessons[index];
        return LessonCard(
          title: lesson.title,
          description: lesson.description,
          number: (index + 1).toString().padLeft(2, '0'),
          isCompleted: completedIds.contains(lesson.id),
          isSubscribed: isSubscribed,
          durationSeconds: lesson.durationSeconds,
          onTap: () => onOpenLesson(lesson),
        );
      },
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
