import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/core/utils/formatters.dart';
import 'package:thanaweya_online/features/shared/models/lesson_model.dart';
import 'package:thanaweya_online/features/student/data/repos/student_courses_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_courses_cubit.dart';

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
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      _coursesCubit.loadProgress(userId);
    }
    _checkSubscription();
  }

  Future<void> _checkSubscription() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final res = await StudentCoursesRepo().checkIsSubscribed(
      studentId: userId,
      courseId: widget.courseId,
    );
    if (!mounted) return;
    res.when(
      success: (isSub) => setState(() => _isSubscribed = isSub),
      failure: (_, __) {},
    );
  }

  @override
  void dispose() {
    _coursesCubit.close();
    super.dispose();
  }

  void _showLockedLessonDialog(String lessonTitle) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          backgroundColor: NotebookColors.ground,
          title: Row(
            children: [
              Icon(
                Icons.lock_rounded,
                color: NotebookColors.marginRed,
                size: 24.r,
              ),
              SizedBox(width: 8.w),
              Text('الدرس مغلق', style: NotebookText.heading(16.sp)),
            ],
          ),
          content: Text(
            'عفواً، المنهج متاح للاطلاع فقط. لمشاهدة فيديو "$lessonTitle" يجب الدفع والاشتراك وتفعيل الكود أولاً.',
            style: NotebookText.body(13.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('إلغاء', style: NotebookText.strong(13.sp)),
            ),
            NotebookPrimaryButton(
              label: 'الدفع وتفعيل الكود',
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(
                  context,
                  AppRouter.studentPaymentMethods,
                  arguments: {
                    'courseId': widget.courseId,
                  },
                ).then((_) => _checkSubscription());
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openLesson(LessonModel lesson) {
    HapticFeedback.lightImpact();
    if (!_isSubscribed) {
      _showLockedLessonDialog(lesson.title);
      return;
    }
    Navigator.pushNamed(
      context,
      AppRouter.studentVideoPlayer,
      arguments: {
        'lessonId': lesson.id,
        'videoUrl': lesson.videoUrlOrId,
        'videoSourceType': lesson.videoSourceType.name,
        'title': lesson.title,
        'description': lesson.description ?? '',
        'courseId': widget.courseId,
      },
    ).then((_) => _checkSubscription());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: NotebookColors.ground,
        appBar: NotebookTopBar(
          title: 'دروس الكورس',
          subtitle: 'شاهد الحصص واكمل تقدمك',
        ),
        body: NotebookPaper(
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<StudentCoursesCubit, StudentCoursesState>(
                  bloc: _coursesCubit,
                  builder: (context, state) {
                    if (state.lessonsStatus ==
                            StudentCoursesStatus.loading &&
                        state.lessons.isEmpty) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: NotebookColors.green,
                        ),
                      );
                    }

                    if (state.lessons.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Text(
                            'لا توجد دروس في هذا الكورس بعد',
                            style: NotebookText.body(13.sp),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    final completedIds = {
                      for (final p in state.progress)
                        if (p.isCompleted) p.lessonId,
                    };

                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 20.h),
                      itemCount: state.lessons.length,
                      separatorBuilder: (_, _) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final lesson = state.lessons[index];
                        final isCompleted =
                            completedIds.contains(lesson.id);
                        final number =
                            (index + 1).toString().padLeft(2, '0');

                        return NotebookCard(
                          ruled: true,
                          ruledStartY: 76,
                          marginTab: isCompleted,
                          onTap: () => _openLesson(lesson),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.r),
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? NotebookColors.green.withAlpha(20)
                                      : NotebookColors.surfaceBright,
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: isCompleted
                                        ? NotebookColors.green.withAlpha(90)
                                        : NotebookColors.ink.withAlpha(30),
                                    width: 1.2,
                                  ),
                                ),
                                child: Icon(
                                  isCompleted
                                      ? Icons.check_circle_rounded
                                      : (!_isSubscribed
                                          ? Icons.lock_rounded
                                          : Icons.play_circle_outline_rounded),
                                  color: isCompleted
                                      ? NotebookColors.green
                                      : (!_isSubscribed
                                          ? NotebookColors.marginRed
                                          : NotebookColors.ink),
                                  size: 22.r,
                                ),
                              ),
                              SizedBox(width: 14.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 6.w,
                                            vertical: 1.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: NotebookColors.marginRed
                                                .withAlpha(22),
                                            borderRadius:
                                                BorderRadius.circular(4.r),
                                          ),
                                          child: Text(
                                            'الدرس $number',
                                            style: GoogleFonts.cairo(
                                              fontSize: 9.sp,
                                              fontWeight: FontWeight.w800,
                                              color: NotebookColors.marginRed,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: Text(
                                            lesson.title,
                                            style:
                                                NotebookText.body(13.sp),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if ((lesson.description ?? '')
                                        .isNotEmpty) ...[
                                      SizedBox(height: 3.h),
                                      Text(
                                        lesson.description!,
                                        style:
                                            NotebookText.note(10.sp),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                    if (lesson.durationSeconds != null) ...[
                                      SizedBox(height: 3.h),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.schedule_rounded,
                                            size: 11.r,
                                            color: NotebookColors.pencil,
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            Formatters.formatDurationMinutes(
                                              (lesson.durationSeconds! / 60)
                                                  .ceil(),
                                            ),
                                            style:
                                                NotebookText.note(10.sp),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Container(
                                width: 30.r,
                                height: 30.r,
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? NotebookColors.green
                                      : NotebookColors.ink.withAlpha(35),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isCompleted
                                      ? Icons.check_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 17.r,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              BlocBuilder<StudentCoursesCubit, StudentCoursesState>(
                bloc: _coursesCubit,
                builder: (context, state) {
                  if (state.lessons.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                    decoration: BoxDecoration(
                      color: NotebookColors.surface,
                      border: Border(
                        top: BorderSide(
                          color: NotebookColors.ink.withAlpha(30),
                        ),
                      ),
                    ),
                    child: NotebookPrimaryButton(
                      label: 'ابدأ الدرس الأول',
                      onPressed: () => _openLesson(state.lessons.first),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
