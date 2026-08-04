import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
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

  @override
  void initState() {
    super.initState();
    _coursesCubit = StudentCoursesCubit(repo: StudentCoursesRepo());
    _coursesCubit.loadCourseLessons(widget.courseId);
  }

  @override
  void dispose() {
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
            'منهج الكورس (My Courses)',
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                // Top Search Input & Filter Button (Matching Screens 37 & 40)
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
                              hintText: 'البحث عن درس أو محتوى...',
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
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pushNamed(context, AppRouter.studentFilter);
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

                // Curriculum Sections List
                Expanded(
                  child: BlocBuilder<StudentCoursesCubit, StudentCoursesState>(
                    bloc: _coursesCubit,
                    builder: (context, state) {
                      if (state.lessonsStatus ==
                              StudentCoursesStatus.loading &&
                          state.lessons.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final sections = _buildSections(state.lessons);
                      return ListView.builder(
                        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 110.h),
                        physics: const BouncingScrollPhysics(),
                        itemCount: sections.length,
                        itemBuilder: (context, sectionIndex) {
                          final sec = sections[sectionIndex];
                      final sectionNumber = sec['sectionNumber'] as String;
                      final title = sec['title'] as String;
                      final totalDuration = sec['totalDuration'] as String;
                      final lessons =
                          sec['lessons'] as List<Map<String, dynamic>>;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '$sectionNumber - $title',
                                  style: GoogleFonts.cairo(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF2563EB),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                totalDuration,
                                style: GoogleFonts.cairo(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),

                          ...lessons.map((les) {
                            final num = les['number'] as String;
                            final lesTitle = les['title'] as String;
                            final dur = les['duration'] as String;
                            final unlocked = les['isUnlocked'] as bool;

                            return GestureDetector(
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
                              child: Container(
                                margin: EdgeInsets.only(bottom: 12.h),
                                padding: EdgeInsets.all(12.r),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(
                                    color: const Color(0xFFF1F5F9),
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x060F172A),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38.r,
                                      height: 38.r,
                                      decoration: BoxDecoration(
                                        color: unlocked
                                            ? const Color(0xFFECFDF5)
                                            : const Color(0xFFF1F5F9),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          num,
                                          style: GoogleFonts.cairo(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w800,
                                            color: unlocked
                                                ? const Color(0xFF0FA37F)
                                                : const Color(0xFF94A3B8),
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
                                            style: GoogleFonts.cairo(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF0F172A),
                                            ),
                                          ),
                                          Text(
                                            dur,
                                            style: GoogleFonts.cairo(
                                              fontSize: 11.sp,
                                              color: const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 32.r,
                                      height: 32.r,
                                      decoration: BoxDecoration(
                                        color: unlocked
                                            ? const Color(0xFF2563EB)
                                            : const Color(0xFFCBD5E1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        unlocked
                                            ? Icons.play_arrow_rounded
                                            : Icons.lock_outline_rounded,
                                        color: Colors.white,
                                        size: 18.r,
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

            // Bottom Floating Action Sheet (Matching Screen 37 & Screen 40)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x150F172A),
                      blurRadius: 16,
                      offset: Offset(0, -4),
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
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: const Color(0xFFBFDBFE),
                              ),
                            ),
                            child: Icon(
                              Icons.workspace_premium_rounded,
                              color: const Color(0xFF2563EB),
                              size: 26.r,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                      ],
                      Expanded(
                        child: SizedBox(
                          height: 52.h,
                          child: BlocBuilder<
                              StudentCoursesCubit, StudentCoursesState>(
                            bloc: _coursesCubit,
                            builder: (context, state) {
                              final firstLesson = state.lessons.isNotEmpty
                                  ? state.lessons.first
                                  : null;
                              return ElevatedButton(
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              elevation: 4,
                              shadowColor: const Color(0x332563EB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.r),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.isCompleted
                                      ? 'إعادة بدء الكورس (Start Course Again)'
                                      : 'متابعة التعلم (Continue Course)',
                                  style: GoogleFonts.cairo(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Container(
                                  width: 32.r,
                                  height: 32.r,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    color: const Color(0xFF2563EB),
                                    size: 18.r,
                                  ),
                                ),
                              ],
                            
                            
                        
                            ),
                          );
                        },
                      ),
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
