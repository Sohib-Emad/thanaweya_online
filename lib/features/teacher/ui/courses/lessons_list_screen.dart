import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_courses_repo.dart';
import 'package:thanaweya_online/features/teacher/logic/teacher_courses_cubit.dart';
import 'package:thanaweya_online/features/teacher/ui/courses/widgets/widgets.dart';

/// Screen displaying all lessons for a given course with add/edit/delete
/// and document management capabilities.
class LessonsListScreen extends StatefulWidget {
  final String courseId;
  const LessonsListScreen({super.key, required this.courseId});
  @override
  State<LessonsListScreen> createState() => _LessonsListScreenState();
}

class _LessonsListScreenState extends State<LessonsListScreen> {
  final _cubit = TeacherCoursesCubit(repo: TeacherCoursesRepo());

  @override
  void initState() {
    super.initState();
    _cubit.loadLessons(widget.courseId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _showDeskSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: DeskColors.primaryDeep,
        content: Text(message, style: DeskText.strong(12.sp)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: DeskColors.ground,
        appBar: DeskTopBar(
            title: 'دروس الدورة',
            subtitle: 'أضف الدروس ورتبها في مكتبك'),
        body: DeskSurface(
          child: BlocBuilder<TeacherCoursesCubit, TeacherCoursesState>(
            bloc: _cubit,
            builder: (context, state) {
              return LessonBodyContent(
                isLoading: state.lessonsStatus ==
                    TeacherCoursesStatus.loading,
                hasError: state.lessonsStatus ==
                    TeacherCoursesStatus.error,
                errorMessage: state.errorMessage,
                isEmpty: state.lessons.isEmpty,
                lessons: state.lessons,
                onRetry: () => _cubit.loadLessons(widget.courseId),
                onAddFirst: () => Navigator.pushNamed(
                    context, AppRouter.teacherAddLesson,
                    arguments: widget.courseId),
                onRefresh: () =>
                    _cubit.loadLessons(widget.courseId),
                itemBuilder: (context, index) {
                  final lesson = state.lessons[index];
                  return LessonCard(
                    lesson: lesson,
                    onEdit: () => showEditLessonSheet(
                      context: context,
                      lesson: lesson,
                      onUpdate: _cubit.updateLesson,
                    ),
                    onDelete: () async {
                      if (await showDeleteLessonDialog(
                          context, lesson: lesson)) {
                        await _cubit.deleteLesson(lesson.id);
                        if (mounted) _showDeskSnack('تم حذف الدرس');
                      }
                    },
                    onDocuments: () => showDocumentsSheet(
                      context: context,
                      lesson: lesson,
                      showSnack: _showDeskSnack,
                    ),
                    onResetViews: () async {
                      if (await showResetViewsDialog(
                          context, lesson: lesson)) {
                        HapticFeedback.mediumImpact();
                        final res = await TeacherCoursesRepo()
                            .resetLessonViews(lesson.id);
                        res.when(
                          success: (_) => _showDeskSnack(
                              'تم إعادة فتح الفيديو للطلاب'),
                          failure: (m, _) => _showDeskSnack(m),
                        );
                      }
                    },
                    onToggleFree: () => _cubit.updateLesson(
                      lessonId: lesson.id,
                      title: lesson.title,
                      description: lesson.description,
                      videoUrlOrId: lesson.videoUrlOrId,
                      isFreePreview: !lesson.isFreePreview,
                    ),
                  );
                },
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: null,
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pushNamed(context, AppRouter.teacherAddLesson,
                arguments: widget.courseId);
          },
          backgroundColor: DeskColors.primary,
          foregroundColor: DeskColors.onPrimary,
          elevation: 4,
          icon: const Icon(Icons.video_call_rounded, size: 22),
          label: Text('إضافة درس جديد',
              style: DeskText.strong(13.sp)),
        ),
      ),
    );
  }
}
