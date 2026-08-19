import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/shared/models/lesson_model.dart';
import 'package:thanaweya_online/features/student/data/repos/student_courses_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_courses_cubit.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/widgets.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Screen showing the list of lessons within a course.
class CourseLessonsScreen extends StatefulWidget {
  final String courseId;
  const CourseLessonsScreen({super.key, required this.courseId});
  @override
  State<CourseLessonsScreen> createState() => _CourseLessonsScreenState();
}

class _CourseLessonsScreenState extends State<CourseLessonsScreen> {
  late final StudentCoursesCubit _coursesCubit;
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    _coursesCubit = StudentCoursesCubit(repo: StudentCoursesRepo());
    _coursesCubit.loadCourseLessons(widget.courseId);
    _loadProgressAndSubscription();
  }

  Future<void> _checkSubscription() async {
    String? uid = Supabase.instance.client.auth.currentUser?.id ??
        Supabase.instance.client.auth.currentSession?.user.id;
    if (uid == null) {
      for (int i = 0; i < 5; i++) {
        await Future.delayed(Duration(milliseconds: 150 * (i + 1)));
        if (!mounted) return;
        uid = Supabase.instance.client.auth.currentUser?.id ??
            Supabase.instance.client.auth.currentSession?.user.id;
        if (uid != null) break;
      }
    }
    if (uid == null || !mounted) return;
    final res = await StudentCoursesRepo().subscription.checkIsSubscribed(studentId: uid, courseId: widget.courseId);
    if (!mounted) return;
    res.when(success: (isSub) => setState(() => _isSubscribed = isSub), failure: (_, _) {});
  }

  Future<void> _loadProgressAndSubscription() async {
    final uid = Supabase.instance.client.auth.currentUser?.id ??
        Supabase.instance.client.auth.currentSession?.user.id;
    if (uid != null && mounted) _coursesCubit.loadProgress(uid);
    await _checkSubscription();
  }

  @override
  void dispose() { _coursesCubit.close(); super.dispose(); }

  Map<String, dynamic> _videoArgs(LessonModel lesson) => {
    'lessonId': lesson.id, 'videoUrl': lesson.videoUrlOrId,
    'videoSourceType': lesson.videoSourceType.name, 'title': lesson.title,
    'description': lesson.description ?? '', 'courseId': widget.courseId,
  };

  Future<void> _openLesson(LessonModel lesson) async {
    HapticFeedback.lightImpact();
    if (!_isSubscribed) {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final res = await StudentCoursesRepo()
            .subscription.checkIsSubscribed(studentId: userId, courseId: widget.courseId);
        final isSub = res.when(success: (v) => v, failure: (_, _) => false);
        if (isSub) {
          if (mounted) setState(() => _isSubscribed = true);
          if (!mounted) return;
          _goToVideo(lesson);
          return;
        }
      }
      _showLockedLessonDialog(lesson.title);
      return;
    }
    _goToVideo(lesson);
  }

  void _goToVideo(LessonModel lesson) {
    Navigator.pushNamed(context, AppRouter.studentVideoPlayer,
        arguments: _videoArgs(lesson)).then((_) => _checkSubscription());
  }

  void _showLockedLessonDialog(String lessonTitle) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (_) => LessonLockedDialog(
        lessonTitle: lessonTitle,
        onActivate: () => Navigator.pushNamed(context, AppRouter.studentPaymentMethods,
            arguments: {'courseId': widget.courseId}).then((_) => _checkSubscription()),
      ),
    );
  }

  Set<String> get _completedIds => {
    for (final p in _coursesCubit.state.progress)
      if (p.isCompleted || p.watchedSeconds > 0) p.lessonId,
  };

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: NotebookColors.ground,
        appBar: NotebookTopBar(
            title: context.l10n.courseLessonsTitle, subtitle: context.l10n.courseLessonsSubtitle),
        body: NotebookPaper(
          child: Column(children: [
            Expanded(
              child: BlocBuilder<StudentCoursesCubit, StudentCoursesState>(
                bloc: _coursesCubit,
                builder: (_, state) => LessonListView(
                    state: state, completedIds: _completedIds,
                    isSubscribed: _isSubscribed, onOpenLesson: _openLesson),
              ),
            ),
            BlocBuilder<StudentCoursesCubit, StudentCoursesState>(
              bloc: _coursesCubit,
              builder: (context, state) {
                if (state.lessons.isEmpty) return const SizedBox.shrink();
                return Container(
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                  decoration: BoxDecoration(
                    color: NotebookColors.surface,
                    border: Border(top: BorderSide(color: NotebookColors.ink.withAlpha(30))),
                  ),
                  child: NotebookPrimaryButton(
                      label: context.l10n.startFirstLesson,
                      onPressed: () => _openLesson(state.lessons.first)),
                );
              },
            ),
          ]),
        ),
      ),
    );
  }
}
