import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/notebook_theme.dart';
import '../../../../core/utils/formatters.dart';
import 'package:thanaweya_online/features/shared/models/lesson_model.dart';
import 'package:thanaweya_online/features/student/data/repos/student_courses_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_courses_cubit.dart';

class CourseCurriculumScreen extends StatefulWidget {
  final String courseId;
  final bool isCompleted;

  const CourseCurriculumScreen({
    super.key,
    required this.courseId,
    this.isCompleted = false,
  });

  @override
  State<CourseCurriculumScreen> createState() => _CourseCurriculumScreenState();
}

class _CourseCurriculumScreenState extends State<CourseCurriculumScreen> {
  late final StudentCoursesCubit _coursesCubit;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _coursesCubit = StudentCoursesCubit(repo: StudentCoursesRepo());
    _coursesCubit.loadCourseLessons(widget.courseId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _coursesCubit.close();
    super.dispose();
  }

  List<Map<String, dynamic>> _buildSections(List<LessonModel> lessons) {
    if (lessons.isEmpty) return const [];
    final totalSeconds = lessons.fold<int>(
      0,
      (sum, l) => sum + (l.durationSeconds ?? 0),
    );
    return [
      {
        'sectionNumber': 'القسم 01',
        'title': 'دروس الكورس',
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
                      (lessons[i].durationSeconds! / 60).ceil())
                  : '',
              'isUnlocked': true,
            },
        ],
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: NotebookColors.ground,
        appBar: NotebookTopBar(
          title: 'منهج الكورس',
          subtitle: 'دروسك على صفحات الدفتر',
        ),
        body: Stack(
          children: [
            NotebookPaper(
              child: Column(
                children: [
                  SizedBox(height: 14.h),
                  NotebookSearchField(
                    controller: _searchController,
                    hint: 'ابحث عن درس أو محتوى...',
                    onFilter: () {
                      HapticFeedback.lightImpact();
                      Navigator.pushNamed(context, AppRouter.studentFilter);
                    },
                  ),
                  SizedBox(height: 8.h),

                  // Curriculum Sections List
                  Expanded(
                    child:
                        BlocBuilder<StudentCoursesCubit, StudentCoursesState>(
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
                        final sections = _buildSections(state.lessons);
                        if (sections.isEmpty) {
                          return Padding(
                            padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0),
                            child: NotebookEmptyNote(
                              message: 'لا توجد دروس في هذا الكورس بعد',
                            ),
                          );
                        }
                        return ListView.builder(
                          padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 110.h),
                          physics: const BouncingScrollPhysics(),
                          itemCount: sections.length,
                          itemBuilder: (context, sectionIndex) {
                            final sec = sections[sectionIndex];
                            final sectionNumber =
                                sec['sectionNumber'] as String;
                            final title = sec['title'] as String;
                            final totalDuration =
                                sec['totalDuration'] as String;
                            final lessons =
                                sec['lessons'] as List<Map<String, dynamic>>;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '$sectionNumber : $title',
                                        style: NotebookText.heading(14.sp),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (totalDuration.isNotEmpty) ...[
                                      SizedBox(width: 8.w),
                                      Text(
                                        totalDuration,
                                        style: NotebookText.note(11.sp),
                                      ),
                                    ],
                                  ],
                                ),
                                SizedBox(height: 12.h),

                                ...lessons.map((les) {
                                  final num = les['number'] as String;
                                  final lesTitle = les['title'] as String;
                                  final dur = les['duration'] as String;
                                  final unlocked = les['isUnlocked'] as bool;

                                  return Padding(
                                    padding:
                                        EdgeInsets.only(bottom: 12.h),
                                    child: NotebookCard(
                                      ruled: true,
                                      ruledStartY: 60,
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        Navigator.pushNamed(
                                          context,
                                          AppRouter.studentVideoPlayer,
                                          arguments: {
                                            'lessonId': les['id'],
                                            'videoUrl': les['videoUrl'],
                                            'title': lesTitle,
                                            'courseId': widget.courseId,
                                          },
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 36.r,
                                            height: 36.r,
                                            decoration: BoxDecoration(
                                              color:
                                                  NotebookColors.surfaceBright,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: unlocked
                                                    ? NotebookColors.green
                                                        .withAlpha(90)
                                                    : NotebookColors.ink
                                                        .withAlpha(30),
                                                width: 1.2,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                num,
                                                style: NotebookText.strong(
                                                  12.sp,
                                                  color: unlocked
                                                      ? NotebookColors.ink
                                                      : NotebookColors.pencil,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  lesTitle,
                                                  style:
                                                      NotebookText.body(13.sp),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                if (dur.isNotEmpty) ...[
                                                  SizedBox(height: 2.h),
                                                  Text(
                                                    dur,
                                                    style:
                                                        NotebookText.note(10.sp),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: 30.r,
                                            height: 30.r,
                                            decoration: BoxDecoration(
                                              color: unlocked
                                                  ? NotebookColors.green
                                                  : NotebookColors.ink
                                                      .withAlpha(40),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              unlocked
                                                  ? Icons.play_arrow_rounded
                                                  : Icons.lock_outline_rounded,
                                              color: Colors.white,
                                              size: 16.r,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                                SizedBox(height: 14.h),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Action Sheet
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
                decoration: BoxDecoration(
                  color: NotebookColors.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: NotebookColors.ink.withAlpha(38),
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: NotebookColors.ink.withAlpha(24),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      if (widget.isCompleted) ...[
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            Navigator.pushNamed(
                              context,
                              AppRouter.studentCertificate,
                            );
                          },
                          child: Container(
                            width: 52.r,
                            height: 52.r,
                            decoration: BoxDecoration(
                              color: NotebookColors.surfaceBright,
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(
                                color:
                                    NotebookColors.marginRed.withAlpha(140),
                                width: 1.4,
                              ),
                            ),
                            child: Icon(
                              Icons.workspace_premium_rounded,
                              color: NotebookColors.marginRed,
                              size: 26.r,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                      ],
                      Expanded(
                        child: BlocBuilder<StudentCoursesCubit,
                            StudentCoursesState>(
                          bloc: _coursesCubit,
                          builder: (context, state) {
                            final firstLesson = state.lessons.isNotEmpty
                                ? state.lessons.first
                                : null;
                            return NotebookPrimaryButton(
                              label: widget.isCompleted
                                  ? 'إعادة بدء الكورس'
                                  : 'متابعة التعلم',
                              icon: widget.isCompleted
                                  ? Icons.refresh_rounded
                                  : Icons.play_arrow_rounded,
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                Navigator.pushNamed(
                                  context,
                                  AppRouter.studentVideoPlayer,
                                  arguments: {
                                    'lessonId': firstLesson?.id ?? '',
                                    'videoUrl':
                                        firstLesson?.videoUrlOrId ?? '',
                                    'title': firstLesson?.title ?? 'درس',
                                    'courseId': widget.courseId,
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
