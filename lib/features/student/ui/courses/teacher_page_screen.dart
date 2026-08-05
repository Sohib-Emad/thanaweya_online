import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/shared/models/course_model.dart';
import 'package:thanaweya_online/features/student/data/repos/student_courses_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_courses_cubit.dart';

class TeacherPageScreen extends StatefulWidget {
  final String teacherId;
  final String title;
  final String? avatarUrl;

  const TeacherPageScreen({
    super.key,
    this.teacherId = '',
    this.title = '',
    this.avatarUrl,
  });

  @override
  State<TeacherPageScreen> createState() => _TeacherPageScreenState();
}

class _TeacherPageScreenState extends State<TeacherPageScreen> {
  int _activeTab = 0; // 0 = Lessons, 1 = Quiz

  late final StudentCoursesCubit _coursesCubit;

  final List<IconData> _lessonIcons = const [
    Icons.eco_rounded,
    Icons.water_drop_rounded,
    Icons.wb_sunny_rounded,
    Icons.biotech_rounded,
    Icons.science_rounded,
    Icons.menu_book_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _coursesCubit = StudentCoursesCubit(repo: StudentCoursesRepo());
    if (widget.teacherId.isNotEmpty) {
      _coursesCubit.loadTeacherCourses(widget.teacherId);
    }
  }

  @override
  void dispose() {
    _coursesCubit.close();
    super.dispose();
  }

  String get _teacherDisplayName {
    final raw = widget.title.trim();
    if (raw.isEmpty) return 'صفحة المدرس';
    return raw.startsWith('أ.') ? raw : 'أ. $raw';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: NotebookColors.ground,
        appBar: NotebookTopBar(
          title: _teacherDisplayName,
          subtitle: 'دروس وكورسات المدرس على صفحات الدفتر',
        ),
        body: NotebookPaper(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Signed cover card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(18.r),
                        decoration: BoxDecoration(
                          color: NotebookColors.surfaceBright,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: NotebookColors.ink.withAlpha(35),
                          ),
                        ),
                        child: Row(
                          children: [
                            NotebookTeacherAvatar(
                              avatarUrl: widget.avatarUrl,
                              name: widget.title
                                  .trim()
                                  .replaceFirst('أ. ', ''),
                              size: 60.r,
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _teacherDisplayName,
                                    style: NotebookText.heading(16.sp),
                                  ),
                                  SizedBox(height: 3.h),
                                  Text(
                                    'مدرس معتمد على ثانوية أونلاين',
                                    style: NotebookText.note(11.sp),
                                  ),
                                  SizedBox(height: 7.h),
                                  // signature underline
                                  Container(
                                    width: 44.w,
                                    height: 2.h,
                                    color: NotebookColors.marginRed
                                        .withAlpha(160),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Segmented Tab Switcher (Lessons / Quiz)
                      NotebookSegmentControl(
                        options: const ['الدروس', 'الامتحانات'],
                        index: _activeTab,
                        onChanged: (i) {
                          HapticFeedback.selectionClick();
                          setState(() => _activeTab = i);
                        },
                      ),

                      SizedBox(height: 20.h),

                      // Active Tab Content
                      _activeTab == 0
                          ? BlocBuilder<StudentCoursesCubit,
                              StudentCoursesState>(
                              bloc: _coursesCubit,
                              builder: (context, state) {
                                if (state.coursesStatus ==
                                        StudentCoursesStatus.loading &&
                                    state.courses.isEmpty) {
                                  return Padding(
                                    padding: EdgeInsets.only(top: 40.h),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: NotebookColors.green,
                                      ),
                                    ),
                                  );
                                }
                                if (state.courses.isEmpty) {
                                  return const NotebookEmptyNote(
                                    icon: Icons.menu_book_outlined,
                                    message: 'لا توجد كورسات منشورة لهذا المدرس بعد',
                                  );
                                }
                                return _buildLessonsListView(
                                  context,
                                  state.courses,
                                );
                              },
                            )
                          : _buildQuizzesListView(context),
                    ],
                  ),
                ),
              ),

              // Sticky Bottom Primary Button
              Container(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                decoration: BoxDecoration(
                  color: NotebookColors.surface,
                  border: Border(
                    top: BorderSide(color: NotebookColors.ink.withAlpha(30)),
                  ),
                ),
                child: BlocBuilder<StudentCoursesCubit, StudentCoursesState>(
                  bloc: _coursesCubit,
                  builder: (context, state) {
                    final firstCourse = state.courses.isNotEmpty
                        ? state.courses.first
                        : null;
                    return NotebookPrimaryButton(
                      label: _activeTab == 0
                          ? 'ابدأ الدرس'
                          : 'ابدأ الاختبار',
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        if (_activeTab == 0) {
                          Navigator.pushNamed(
                            context,
                            AppRouter.studentCourseLessons,
                            arguments: firstCourse?.id ?? '',
                          );
                        } else {
                          Navigator.pushNamed(
                            context,
                            AppRouter.studentExamStart,
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLessonsListView(
    BuildContext context,
    List<CourseModel> courses,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: courses.length,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final course = courses[index];
        final number = (index + 1).toString().padLeft(2, '0');
        final icon = _lessonIcons[index % _lessonIcons.length];

        return NotebookCard(
          ruled: true,
          ruledStartY: 76,
          marginTab: true,
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pushNamed(
              context,
              AppRouter.studentCourseLessons,
              arguments: course.id,
            );
          },
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: NotebookColors.surfaceBright,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: NotebookColors.ink.withAlpha(30),
                    width: 1.2,
                  ),
                ),
                child: Icon(
                  icon,
                  color: NotebookColors.ink,
                  size: 22.r,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'كورس $number • ${course.title}',
                      style: NotebookText.body(13.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      course.description ?? '',
                      style: NotebookText.note(10.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                width: 30.r,
                height: 30.r,
                decoration: BoxDecoration(
                  color: NotebookColors.green,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 17.r,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuizzesListView(BuildContext context) {
    return const NotebookEmptyNote(
      icon: Icons.quiz_outlined,
      message: 'لا توجد امتحانات منشورة بعد\nستظهر هنا امتحانات المدرس عندما تكون متاحة',
    );
  }
}
