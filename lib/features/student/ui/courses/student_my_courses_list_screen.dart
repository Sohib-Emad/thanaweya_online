import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/student/data/repos/student_courses_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_courses_cubit.dart';
import 'package:thanaweya_online/features/student/ui/courses/course_filter_screen.dart';

class StudentMyCoursesListScreen extends StatefulWidget {
  const StudentMyCoursesListScreen({super.key});

  @override
  State<StudentMyCoursesListScreen> createState() =>
      _StudentMyCoursesListScreenState();
}

class _StudentMyCoursesListScreenState
    extends State<StudentMyCoursesListScreen> {
  int _selectedTab = 1; // 0 = Completed, 1 = Ongoing

  late final StudentCoursesCubit _coursesCubit;

  CourseFilters? _activeFilters;

  final TextEditingController _searchController = TextEditingController();

  final List<Color> _courseColors = const [
    Color(0xFF0FA37F),
    Color(0xFFEA580C),
    Color(0xFF2563EB),
    Color(0xFF7C3AED),
  ];

  final List<Map<String, dynamic>> _completedCourses = [];

  @override
  void initState() {
    super.initState();
    _coursesCubit = StudentCoursesCubit(repo: StudentCoursesRepo());
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      _coursesCubit.loadMyCourses(userId);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
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

  Future<void> _openFilter() async {
    HapticFeedback.lightImpact();
    final result = await Navigator.pushNamed<CourseFilters>(
      context,
      AppRouter.studentFilter,
    );
    if (!mounted) return;
    setState(() => _activeFilters = result);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: NotebookColors.ground,
        appBar: NotebookTopBar(
          title: 'دوراتي التعليمية',
          subtitle: 'كورساتك على صفحات الدفتر',
        ),
        body: NotebookPaper(
          child: Column(
            children: [
              // Search + Filter (ruled line)
              SizedBox(height: 14.h),
              NotebookSearchField(
                controller: _searchController,
                hint: 'ابحث في دوراتك...',
                onFilter: _openFilter,
              ),
              SizedBox(height: 16.h),

              // Completed / Ongoing segments
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: NotebookSegmentControl(
                  options: const ['المكتملة', 'مستمر'],
                  index: _selectedTab,
                  onChanged: (i) => setState(() => _selectedTab = i),
                ),
              ),

              // Active filter banner
              if (_activeFilters != null &&
                  _activeFilters!.isActive &&
                  _selectedTab == 1)
                NotebookHighlightNote(
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_alt_rounded,
                        color: NotebookColors.ink,
                        size: 16.r,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'تم التصفية: ${_coursesCubit.state.myCourses.where(_activeFilters!.matches).length} دورة',
                          style: NotebookText.strong(12.sp),
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _activeFilters = null),
                        child: Text(
                          'مسح',
                          style: NotebookText.strong(12.sp,
                              color: NotebookColors.marginRed),
                        ),
                      ),
                    ],
                  ),
                ),

              // Courses List
              Expanded(
                child: BlocBuilder<StudentCoursesCubit, StudentCoursesState>(
                  bloc: _coursesCubit,
                  builder: (context, state) {
                    final allCourses = _selectedTab == 1
                        ? state.myCourses
                        : _completedCourses;
                    final currentList =
                        (_activeFilters != null && _activeFilters!.isActive)
                            ? allCourses.where(_activeFilters!.matches).toList()
                            : allCourses;

                    if (_selectedTab == 1 &&
                        state.myCoursesStatus == StudentCoursesStatus.loading &&
                        state.myCourses.isEmpty) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: NotebookColors.green,
                        ),
                      );
                    }

                    if (currentList.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0),
                        child: NotebookEmptyNote(
                          message: _selectedTab == 1
                              ? 'لا توجد دورات مطابقة — جرّب تعديل الفلاتر'
                              : 'لا توجد دورات مكتملة بعد',
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 30.h),
                      physics: const BouncingScrollPhysics(),
                      itemCount: currentList.length,
                      itemBuilder: (context, index) {
                        final course = currentList[index];
                        final color =
                            _courseColors[index % _courseColors.length];
                        final double progress =
                            (course['progress'] as double?) ?? 0.0;
                        final int done =
                            (course['completedCount'] as int?) ?? 0;
                        final int total = (course['totalCount'] as int?) ??
                            _lessonCountOf(course['lessons']);
                        final subject =
                            (course['subject_name'] as String?) ??
                                (course['subject'] as String?) ??
                                '';
                        final title = course['title'] as String? ?? '';
                        final teacherName =
                            course['teacher_name'] as String? ?? '';
                        final coverUrl =
                            course['cover_image_url'] as String? ?? '';
                        final teacherLine =
                            teacherName.startsWith('أ.')
                                ? teacherName
                                : 'أ. $teacherName';

                        return Padding(
                          padding: EdgeInsets.only(bottom: 14.h),
                          child: NotebookCard(
                            ruled: true,
                            ruledStartY: 118,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              if (_selectedTab == 0) {
                                Navigator.pushNamed(
                                  context,
                                  AppRouter.studentCertificate,
                                );
                              } else {
                                Navigator.pushNamed(
                                  context,
                                  AppRouter.studentCurriculum,
                                  arguments: course['id'] as String,
                                );
                              }
                            },
                            child: Row(
                              children: [
                                // Course cover box
                                Container(
                                  width: 72.r,
                                  height: 72.r,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    color: color.withAlpha(18),
                                    borderRadius: BorderRadius.circular(10.r),
                                    border: Border.all(
                                      color: color.withAlpha(90),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: coverUrl.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: coverUrl,
                                          fit: BoxFit.cover,
                                          placeholder: (_, __) => _coverPlaceholder(color, subject),
                                          errorWidget: (_, __, ___) => _coverPlaceholder(color, subject),
                                        )
                                      : _coverPlaceholder(color, subject),
                                ),

                                SizedBox(width: 14.w),

                                // Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        teacherLine,
                                        style: NotebookText.note(10.sp),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        title,
                                        style: NotebookText.heading(13.sp),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 8.h),

                                      // Progress line + ratio
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(4.r),
                                              child: LinearProgressIndicator(
                                                value: progress,
                                                minHeight: 5.h,
                                                backgroundColor: NotebookColors
                                                    .ink
                                                    .withAlpha(22),
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(color),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          Text(
                                            '$done/$total',
                                            style: NotebookText.strong(
                                              11.sp,
                                              color: NotebookColors.pencil,
                                            ),
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 8.h),

                                      Row(
                                        children: [
                                          Icon(
                                            Icons.star_rounded,
                                            color: const Color(0xFFF59E0B),
                                            size: 13.r,
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            '${course['rating'] ?? '4.8'}',
                                            style:
                                                NotebookText.strong(11.sp),
                                          ),
                                          SizedBox(width: 12.w),
                                          Icon(
                                            Icons.person_outline_rounded,
                                            color: NotebookColors.pencil,
                                            size: 13.r,
                                          ),
                                          SizedBox(width: 4.w),
                                          Expanded(
                                            child: Text(
                                              subject,
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                              style: NotebookText.note(10.sp),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(width: 6.w),

                                // Action arrow in a green circle
                                Container(
                                  width: 28.r,
                                  height: 28.r,
                                  decoration: BoxDecoration(
                                    color: NotebookColors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 15.r,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
    );
  }

  Widget _coverPlaceholder(Color color, String subject) {
    return Center(
      child: Text(
        subject.isNotEmpty ? subject[0] : '؟',
        style: GoogleFonts.cairo(
          fontSize: 22.sp,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}
