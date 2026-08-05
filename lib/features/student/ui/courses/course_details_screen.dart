import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/notebook_theme.dart';
import '../../../../core/utils/formatters.dart';
import 'package:thanaweya_online/features/shared/models/lesson_model.dart';
import 'package:thanaweya_online/features/student/data/repos/student_courses_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_courses_cubit.dart';

class CourseDetailsScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailsScreen({super.key, required this.courseId});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  int _selectedTab = 0; // 0 = About, 1 = Curriculum
  bool _isDescriptionExpanded = false;

  late final StudentCoursesCubit _coursesCubit;

  @override
  void initState() {
    super.initState();
    _coursesCubit = StudentCoursesCubit(repo: StudentCoursesRepo());
    _coursesCubit.loadCourse(widget.courseId);
    _coursesCubit.loadCourseLessons(widget.courseId);
  }

  @override
  void dispose() {
    _coursesCubit.close();
    super.dispose();
  }

  int _lessonCountOf(dynamic lessons) {
    if (lessons is Map) return (lessons['count'] as int?) ?? 0;
    if (lessons is List && lessons.isNotEmpty) {
      final first = lessons.first;
      if (first is Map) return (first['count'] as int?) ?? 0;
    }
    return 0;
  }

  List<Map<String, dynamic>> _buildCurriculumSections(
    List<LessonModel> lessons,
  ) {
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
                      (lessons[i].durationSeconds! / 60).ceil(),
                    )
                  : '',
              'isUnlocked': true,
            },
        ],
      },
    ];
  }

  // Truthful capability list — only what the platform really offers.
  final List<Map<String, dynamic>> _whatYouGetList = [
    {
      'icon': Icons.video_collection_outlined,
      'text': 'الوصول لدروس الكورس كاملة',
    },
    {
      'icon': Icons.devices_rounded,
      'text': 'مشاهدة على الموبايل والتابلت والكمبيوتر',
    },
    {'icon': Icons.menu_book_rounded, 'text': 'ملخصات ومذكرات للمراجعة'},
    {'icon': Icons.quiz_outlined, 'text': 'كويزات وامتحانات تجريبية'},
    {
      'icon': Icons.bar_chart_rounded,
      'text': 'متابعة تقدمك درساً بدرس',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentCoursesCubit, StudentCoursesState>(
      bloc: _coursesCubit,
      builder: (context, state) {
        if (state.courseStatus == StudentCoursesStatus.loading &&
            state.course == null) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              backgroundColor: NotebookColors.ground,
              body: Center(
                child: CircularProgressIndicator(color: NotebookColors.green),
              ),
            ),
          );
        }
        return _buildScreen(context, state);
      },
    );
  }

  Widget _buildScreen(BuildContext context, StudentCoursesState state) {
    final course = state.course ?? const <String, dynamic>{};
    final teachers = course['teachers'] as Map<String, dynamic>? ?? const {};
    final users = teachers['users'] as Map<String, dynamic>? ?? const {};
    final subjects = teachers['subjects'] as Map<String, dynamic>? ?? const {};
    final teacherName = users['full_name'] as String? ?? 'مدرس';
    final teacherAvatarUrl = users['avatar_url'] as String?;
    final teacherId = teachers['id'] as String? ?? '';
    final subjectName = subjects['name_ar'] as String? ?? '';
    final lessonCount = _lessonCountOf(course['lessons']);
    final description = course['description'] as String? ?? '';
    final totalSeconds = state.lessons.fold<int>(
      0,
      (sum, l) => sum + (l.durationSeconds ?? 0),
    );
    final totalDurationText = totalSeconds > 0
        ? Formatters.formatDurationMinutes((totalSeconds / 60).ceil())
        : '';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: NotebookColors.ground,
        body: Stack(
          children: [
            NotebookPaper(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(bottom: 100.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Course cover — an ink page in the دفتر
                    Container(
                      height: 210.h,
                      width: double.infinity,
                      color: NotebookColors.ink,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: RuledLinesPainter(
                                lineGap: 30,
                                color: Colors.white.withAlpha(22),
                              ),
                            ),
                          ),
                          // red margin line on the cover
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: 6,
                              color: NotebookColors.marginRed.withAlpha(90),
                            ),
                          ),
                          Center(
                            child: Container(
                              width: 64.r,
                              height: 64.r,
                              decoration: BoxDecoration(
                                color: NotebookColors.green,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 30.r,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 18.h,
                            right: 16.w,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 40.r,
                                height: 40.r,
                                decoration: BoxDecoration(
                                  color: NotebookColors.surfaceBright,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: NotebookColors.marginRed
                                        .withAlpha(140),
                                    width: 1.4,
                                  ),
                                ),
                                child: Icon(
                                  Icons.arrow_forward_rounded,
                                  color: NotebookColors.marginRed,
                                  size: 20.r,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 14.h,
                            left: 16.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 5.h,
                              ),
                              decoration: BoxDecoration(
                                color: NotebookColors.surfaceBright,
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(
                                  color: NotebookColors.ink.withAlpha(40),
                                ),
                              ),
                              child: Text(
                                subjectName.isEmpty
                                    ? 'فيديو الدرس'
                                    : 'فيديو $subjectName',
                                style: NotebookText.strong(11.sp),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 2. Course Meta — written under the title
                    Padding(
                      padding: EdgeInsets.fromLTRB(24.w, 18.h, 24.w, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (subjectName.isNotEmpty)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 3.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: NotebookColors.green,
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    subjectName,
                                    style: GoogleFonts.cairo(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              SizedBox(width: 10.w),
                              Text(
                                course['stage'] as String? ?? '',
                                style: NotebookText.note(11.sp),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            course['title'] as String? ?? '',
                            style: NotebookText.heading(19.sp),
                          ),
                          SizedBox(height: 10.h),

                          // Stats line (real data only)
                          Row(
                            children: [
                              Icon(
                                Icons.video_collection_outlined,
                                size: 15.r,
                                color: NotebookColors.pencil,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '$lessonCount درس',
                                style: NotebookText.body(12.sp),
                              ),
                              if (totalDurationText.isNotEmpty) ...[
                                SizedBox(width: 14.w),
                                Container(
                                  width: 1,
                                  height: 14.h,
                                  color: NotebookColors.ink.withAlpha(40),
                                ),
                                SizedBox(width: 14.w),
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 15.r,
                                  color: NotebookColors.pencil,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  totalDurationText,
                                  style: NotebookText.body(12.sp),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // 3. About / Curriculum segments
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: NotebookSegmentControl(
                        options: const ['عن الكورس', 'المنهج'],
                        index: _selectedTab,
                        onChanged: (i) {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedTab = i);
                        },
                      ),
                    ),

                    SizedBox(height: 22.h),

                    // 4. Tab Body Content
                    _selectedTab == 0
                        ? _buildAboutTabContent(
                            description: description,
                            teacherName: teacherName,
                            teacherAvatarUrl: teacherAvatarUrl,
                            teacherId: teacherId,
                            subjectName: subjectName,
                          )
                        : _buildCurriculumTabContent(state),
                  ],
                ),
              ),
            ),

            // Sticky Bottom Enroll Bar
            Positioned(
              left: 20.w,
              right: 20.w,
              bottom: 20.h,
              child: SafeArea(
                child: NotebookPrimaryButton(
                  label: 'الاشتراك في الكورس',
                  icon: Icons.edit_rounded,
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    Navigator.pushNamed(
                      context,
                      AppRouter.studentPaymentMethods,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── ABOUT TAB ──
  Widget _buildAboutTabContent({
    required String description,
    required String teacherName,
    required String? teacherAvatarUrl,
    required String teacherId,
    required String subjectName,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description — body copy on the page
          Text(
            description.isEmpty
                ? 'يشرح هذا الكورس منهج المادة خطوة بخطوة مع حلول المسائل ومراجعات شاملة تساعدك على الاستعداد للامتحان.'
                : description,
            style: NotebookText.body(13.sp),
            maxLines: _isDescriptionExpanded ? null : 4,
            overflow: _isDescriptionExpanded
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
          ),
          GestureDetector(
            onTap: () => setState(
              () => _isDescriptionExpanded = !_isDescriptionExpanded,
            ),
            child: Text(
              _isDescriptionExpanded ? 'عرض أقل' : 'اقرأ المزيد...',
              style: NotebookText.strong(12.sp, color: NotebookColors.green),
            ),
          ),

          SizedBox(height: 24.h),

          // Instructor — signed teacher card
          const NotebookSectionHeader(title: 'المحاضر'),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              AppRouter.studentTeacherPage,
              arguments: {
                'teacherId': teacherId,
                'title': teacherName,
                'avatarUrl': teacherAvatarUrl,
              },
            ),
            child: NotebookCard(
              ruled: true,
              ruledStartY: 72,
              onTap: null,
              child: Row(
                children: [
                  NotebookTeacherAvatar(
                    avatarUrl: teacherAvatarUrl,
                    name: teacherName,
                    size: 52.r,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          teacherName,
                          style: NotebookText.heading(14.sp),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          subjectName.isEmpty ? 'مدرس' : subjectName,
                          style: NotebookText.note(11.sp),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      color: NotebookColors.surfaceBright,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: NotebookColors.marginRed.withAlpha(120),
                        width: 1.4,
                      ),
                    ),
                    child: Icon(
                      Icons.chevron_left_rounded,
                      color: NotebookColors.marginRed,
                      size: 18.r,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // What You'll Get
          const NotebookSectionHeader(title: 'ماذا ستتعلم وتأخذ في الكورس؟'),
          SizedBox(height: 10.h),
          ..._whatYouGetList.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                children: [
                  Container(
                    width: 26.r,
                    height: 26.r,
                    decoration: BoxDecoration(
                      color: NotebookColors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 15.r,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      item['text'] as String,
                      style: NotebookText.body(13.sp),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // Reviews — entry to the real reviews page
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'آراء الطلاب',
                style: NotebookText.heading(16.sp),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRouter.studentReviews,
                  arguments: widget.courseId,
                ),
                child: Row(
                  children: [
                    Text(
                      'عرض الكل',
                      style: NotebookText.strong(12.sp,
                          color: NotebookColors.green),
                    ),
                    Icon(
                      Icons.chevron_left_rounded,
                      color: NotebookColors.green,
                      size: 16.r,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          NotebookEmptyNote(
            icon: Icons.star_border_rounded,
            message: 'تقييمات الطلاب متاحة في صفحة الكورس',
          ),
        ],
      ),
    );
  }

  // ── CURRICULUM TAB ──
  Widget _buildCurriculumTabContent(StudentCoursesState state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildCurriculumSections(state.lessons).map((sec) {
          final sectionNumber = sec['sectionNumber'] as String;
          final title = sec['title'] as String;
          final totalDuration = sec['totalDuration'] as String;
          final lessons = sec['lessons'] as List<Map<String, dynamic>>;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$sectionNumber : $title',
                    style: NotebookText.heading(14.sp),
                  ),
                  if (totalDuration.isNotEmpty)
                    Text(
                      totalDuration,
                      style: NotebookText.strong(12.sp,
                          color: NotebookColors.green),
                    ),
                ],
              ),
              SizedBox(height: 12.h),

              ...lessons.map((les) {
                final num = les['number'] as String;
                final lesTitle = les['title'] as String;
                final dur = les['duration'] as String;
                final unlocked = les['isUnlocked'] as bool;

                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: NotebookCard(
                    ruled: true,
                    ruledStartY: 64,
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
                          width: 34.r,
                          height: 34.r,
                          decoration: BoxDecoration(
                            color: NotebookColors.surfaceBright,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: unlocked
                                  ? NotebookColors.green.withAlpha(90)
                                  : NotebookColors.ink.withAlpha(30),
                              width: 1.2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              num,
                              style: GoogleFonts.cairo(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w900,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lesTitle,
                                style: NotebookText.body(13.sp),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (dur.isNotEmpty) ...[
                                SizedBox(height: 2.h),
                                Text(
                                  dur,
                                  style: NotebookText.note(10.sp),
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
                                : NotebookColors.ink.withAlpha(40),
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
              SizedBox(height: 16.h),
            ],
          );
        }).toList(),
      ),
    );
  }
}
