import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/features/student/data/repos/student_courses_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_courses_cubit.dart';

class CourseLessonsScreen extends StatefulWidget {
  final String courseId;

  const CourseLessonsScreen({super.key, required this.courseId});

  @override
  State<CourseLessonsScreen> createState() => _CourseLessonsScreenState();
}

class _CourseLessonsScreenState extends State<CourseLessonsScreen> {
  int _selectedGradeIndex = 2;

  late final StudentCoursesCubit _coursesCubit;

  final List<String> _grades = [
    'الصف 9',
    'الصف 10',
    'الصف 11',
    'الصف 12 (ثانوية)',
  ];

  final List<IconData> _chapterIcons = const [
    Icons.bubble_chart_rounded,
    Icons.eco_rounded,
    Icons.biotech_rounded,
    Icons.grain_rounded,
    Icons.science_rounded,
    Icons.water_drop_rounded,
    Icons.calculate_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _coursesCubit = StudentCoursesCubit(repo: StudentCoursesRepo());
    _coursesCubit.loadCourseLessons(widget.courseId);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      _coursesCubit.loadProgress(userId);
    }
  }

  @override
  void dispose() {
    _coursesCubit.close();
    super.dispose();
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
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFF0F172A),
              size: 30.r,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            'علم الأحياء 🔬',
            style: GoogleFonts.cairo(
              fontSize: 19.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Hero Illustration Graphic
                    Container(
                      width: double.infinity,
                      height: 150.h,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0FA37F), Color(0xFF10B981)],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x200FA37F),
                            blurRadius: 12,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 16.w,
                            bottom: 16.h,
                            top: 16.h,
                            child: Icon(
                              Icons.biotech_rounded,
                              size: 110.r,
                              color: Colors.white.withAlpha(50),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(20.r),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 3.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(50),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Text(
                                    'منهج الثانوية العامة 📚',
                                    style: GoogleFonts.cairo(
                                      fontSize: 11.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'شرح وتجارب الأحياء الممتعة',
                                  style: GoogleFonts.cairo(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Grade Level Filter Chips
                    SizedBox(
                      height: 36.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _grades.length,
                        separatorBuilder: (_, _) => SizedBox(width: 8.w),
                        itemBuilder: (context, index) {
                          final isSelected = _selectedGradeIndex == index;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedGradeIndex = index);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.studentPrimary
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(18.r),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.studentPrimary
                                      : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _grades[index],
                                  style: GoogleFonts.cairo(
                                    fontSize: 12.sp,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Title & Description
                    Text(
                      'علم الأحياء • ${_grades[_selectedGradeIndex]}',
                      style: GoogleFonts.cairo(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'استكشف الفصول والدروس الشاملة مع أفضل الأسئلة والتجارب.',
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Chapters List
                    BlocBuilder<StudentCoursesCubit, StudentCoursesState>(
                      bloc: _coursesCubit,
                      builder: (context, state) {
                        if (state.lessonsStatus ==
                                StudentCoursesStatus.loading &&
                            state.lessons.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final completedIds = {
                          for (final p in state.progress)
                            if (p.isCompleted) p.lessonId,
                        };

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.lessons.length,
                          separatorBuilder: (_, _) => SizedBox(height: 12.h),
                          itemBuilder: (context, index) {
                            final lesson = state.lessons[index];
                            final isCompleted =
                                completedIds.contains(lesson.id);
                            final number =
                                'الدرس ${(index + 1).toString().padLeft(2, '0')}';
                            final icon =
                                _chapterIcons[index % _chapterIcons.length];

                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.pushNamed(
                                  context,
                                  AppRouter.studentVideoPlayer,
                                  arguments: {
                                    'lessonId': lesson.id,
                                    'videoUrl': lesson.videoUrlOrId,
                                    'title': lesson.title,
                                    'courseId': widget.courseId,
                                  },
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.all(16.r),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: const Color(0xFFF1F5F9),
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x060F172A),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(12.r),
                                      decoration: BoxDecoration(
                                        color: isCompleted
                                            ? const Color(0xFFECFDF5)
                                            : AppColors.studentPrimaryLight,
                                        borderRadius:
                                            BorderRadius.circular(16.r),
                                      ),
                                      child: Icon(
                                        isCompleted
                                            ? Icons.check_circle_rounded
                                            : icon,
                                        color: isCompleted
                                            ? const Color(0xFF10B981)
                                            : AppColors.studentPrimary,
                                        size: 24.r,
                                      ),
                                    ),
                                    SizedBox(width: 14.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$number • ${lesson.title}',
                                            style: GoogleFonts.cairo(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFF0F172A),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 3.h),
                                          Text(
                                            lesson.description ?? '',
                                            style: GoogleFonts.cairo(
                                              fontSize: 11.sp,
                                              color: const Color(0xFF64748B),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 34.r,
                                      height: 34.r,
                                      decoration: BoxDecoration(
                                        color: isCompleted
                                            ? const Color(0xFFECFDF5)
                                            : const Color(0xFFF1F5F9),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isCompleted
                                            ? Icons.check_circle_rounded
                                            : Icons.play_arrow_rounded,
                                        color: isCompleted
                                            ? const Color(0xFF10B981)
                                            : AppColors.studentPrimary,
                                        size: 22.r,
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
                  ],
                ),
              ),
            ),

            // Sticky Bottom Primary Button (06 Detail Start Button)
            Container(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0A0F172A),
                    blurRadius: 10,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pushNamed(
                      context,
                      AppRouter.studentTeacherPage,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.studentPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26.r),
                    ),
                  ),
                  child: Text(
                    'ابدأ الدرس 🚀',
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
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
