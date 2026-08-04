import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
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

  final List<Color> _courseColors = const [
    Color(0xFF0FA37F),
    Color(0xFFEA580C),
    Color(0xFF2563EB),
    Color(0xFF7C3AED),
  ];

  final List<Map<String, dynamic>> _completedCourses = [
    {
      'subject': 'الكيمياء العضوية',
      'title': 'تفاعلات المركبات العضوية والهيدروكربونات',
      'progress': 1.0,
      'completedCount': 100,
      'totalCount': 100,
      'rating': '4.9',
      'enrolledCount': '15200 طالب',
      'color': const Color(0xFF0FA37F),
    },
  ];

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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: const Color(0xFF0F172A),
              size: 20.r,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: false,
          title: Text(
            'دوراتي التعليمية (My Courses)',
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        body: Column(
          children: [
            // Search Bar + Filter Icon
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: 'ابحث في دوراتك...',
                          hintStyle: GoogleFonts.cairo(
                            fontSize: 13.sp,
                            color: const Color(0xFF94A3B8),
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: const Color(0xFF94A3B8),
                            size: 20.r,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 14.w),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      final result = await Navigator.pushNamed<CourseFilters>(
                        context,
                        AppRouter.studentFilter,
                      );
                      if (!mounted) return;
                      setState(() => _activeFilters = result);
                    },
                    child: Container(
                      width: 48.r,
                      height: 48.r,
                      decoration: BoxDecoration(
                        color: AppColors.studentPrimary,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x200FA37F),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: Colors.white,
                        size: 22.r,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Pills Tab Switcher (Completed / Ongoing)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0
                                ? AppColors.studentPrimary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(26.r),
                          ),
                          child: Text(
                            'المكتملة (Completed)',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w800,
                              color: _selectedTab == 0
                                  ? Colors.white
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          decoration: BoxDecoration(
                            color: _selectedTab == 1
                                ? AppColors.studentPrimary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(26.r),
                          ),
                          child: Text(
                            'مستمر (Ongoing)',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w800,
                              color: _selectedTab == 1
                                  ? Colors.white
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Active filter banner
            if (_activeFilters != null &&
                _activeFilters!.isActive &&
                _selectedTab == 1)
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F7F2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_alt_rounded,
                        color: AppColors.studentPrimary,
                        size: 16.r,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'تم التصفية: ${_coursesCubit.state.myCourses.where(_activeFilters!.matches).length} دورة',
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F766E),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _activeFilters = null),
                        child: Text(
                          'مسح',
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.studentPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (currentList.isEmpty) {
                    return Center(
                      child: Text(
                        'لا توجد دورات مطابقة',
                        style: GoogleFonts.cairo(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 30.h),
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
                      final subject = (course['subject_name'] as String?) ??
                          (course['subject'] as String?) ??
                          '';
                      final title = course['title'] as String? ?? '';
                      final teacherName =
                          course['teacher_name'] as String? ?? '';

                      return GestureDetector(
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
                    child: Container(
                      margin: EdgeInsets.only(bottom: 14.h),
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x080F172A),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Thumbnail Box
                          Container(
                            width: 86.r,
                            height: 86.r,
                            decoration: BoxDecoration(
                              color: color.withAlpha(20),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.play_circle_fill_rounded,
                                color: color,
                                size: 36.r,
                              ),
                            ),
                          ),

                          SizedBox(width: 14.w),

                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subject,
                                  style: GoogleFonts.cairo(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                    color: color,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  title,
                                  style: GoogleFonts.cairo(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 6.h),

                                // Progress Line + Ratio
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(6.r),
                                        child: LinearProgressIndicator(
                                          value: progress,
                                          minHeight: 6.h,
                                          backgroundColor:
                                              const Color(0xFFE2E8F0),
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            color,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Text(
                                      '$done/$total',
                                      style: GoogleFonts.cairo(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 6.h),

                                Row(
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      color: const Color(0xFFF59E0B),
                                      size: 14.r,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      '4.8',
                                      style: GoogleFonts.cairo(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Icon(
                                      Icons.person_outline_rounded,
                                      color: const Color(0xFF94A3B8),
                                      size: 14.r,
                                    ),
                                    SizedBox(width: 4.w),
                                    Expanded(
                                      child: Text(
                                        teacherName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.cairo(
                                          fontSize: 11.sp,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
    );
  }
}
