import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/features/shared/models/course_model.dart';
import 'package:thanaweya_online/features/shared/models/exam_model.dart';
import 'package:thanaweya_online/features/teacher/ui/courses/course_details_screen.dart';
import 'package:thanaweya_online/features/teacher/ui/courses/widgets/create_course_sheet.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/exam_results_screen.dart';

/// Dashboard section displaying the teacher's recent courses and recent exams.
class TeacherRecentContentSection extends StatelessWidget {
  final List<CourseModel> recentCourses;
  final List<ExamModel> recentExams;
  final bool isLoading;
  final void Function(int index) onSwitchTab;
  final VoidCallback onRefresh;

  const TeacherRecentContentSection({
    super.key,
    required this.recentCourses,
    required this.recentExams,
    required this.isLoading,
    required this.onSwitchTab,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── 1. Recent Courses Section ────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.video_library_rounded,
                  size: 18.r,
                  color: const Color(0xFF0284C7),
                ),
                SizedBox(width: 6.w),
                Text(
                  'أحدث الدورات والكورسات',
                  style: GoogleFonts.cairo(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => onSwitchTab(1),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                children: [
                  Text(
                    'عرض الكل',
                    style: GoogleFonts.cairo(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0284C7),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_back_ios_rounded,
                    size: 11,
                    color: Color(0xFF0284C7),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        _buildCoursesList(context),

        SizedBox(height: 20.h),

        // ─── 2. Recent Exams Section ──────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.quiz_rounded,
                  size: 18.r,
                  color: const Color(0xFF9333EA),
                ),
                SizedBox(width: 6.w),
                Text(
                  'أحدث الاختبارات والامتحانات',
                  style: GoogleFonts.cairo(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => onSwitchTab(2),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                children: [
                  Text(
                    'عرض الكل',
                    style: GoogleFonts.cairo(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF9333EA),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_back_ios_rounded,
                    size: 11,
                    color: Color(0xFF9333EA),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        _buildExamsList(context),
      ],
    );
  }

  Widget _buildCoursesList(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 140.h,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color: Color(0xFF0284C7)),
      );
    }

    if (recentCourses.isEmpty) {
      return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          CreateCourseSheet.show(context, onCourseCreated: onRefresh);
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: const BoxDecoration(
                  color: Color(0xFFE0F2FE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Color(0xFF0284C7),
                  size: 20,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'لا توجد دورات مسجلة بعد — اضغط لإنشاء أول كورس',
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0284C7),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 165.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: recentCourses.length,
        separatorBuilder: (_, _) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final course = recentCourses[index];
          return _RecentCourseCard(
            course: course,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CourseDetailsScreen(course: course),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildExamsList(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 100.h,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color: Color(0xFF9333EA)),
      );
    }

    if (recentExams.isEmpty) {
      return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pushNamed(context, AppRouter.teacherExamBuilder);
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: const BoxDecoration(
                  color: Color(0xFFF3E8FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Color(0xFF9333EA),
                  size: 20,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'لا توجد امتحانات منشورة — اضغط لإنشاء امتحان جديد',
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF9333EA),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: recentExams.take(4).map((exam) {
        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: _RecentExamCard(
            exam: exam,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ExamResultsScreen(examId: exam.id, examTitle: exam.title),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}

class _RecentCourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback onTap;

  const _RecentCourseCard({required this.course, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasPrice = course.price != null && course.price! > 0;
    final priceLabel = hasPrice ? '${course.price!.toInt()} ج.م' : 'مجاني';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 190.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image
            Stack(
              children: [
                Container(
                  height: 85.h,
                  width: double.infinity,
                  color: const Color(0xFFF1F5F9),
                  child:
                      course.coverImageUrl != null &&
                          course.coverImageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: course.coverImageUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => const Icon(
                            Icons.menu_book_rounded,
                            color: Color(0xFF94A3B8),
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.menu_book_rounded,
                            color: Color(0xFF94A3B8),
                            size: 28,
                          ),
                        ),
                ),
                Positioned(
                  top: 6.h,
                  right: 6.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: course.isPublished
                          ? const Color(0xFF10B981)
                          : const Color(0xFF64748B),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      course.isPublished ? 'منشور' : 'مسودة',
                      style: GoogleFonts.cairo(
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(10.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        priceLabel,
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w800,
                          color: hasPrice
                              ? const Color(0xFF0284C7)
                              : const Color(0xFF16A34A),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10,
                        color: Color(0xFF94A3B8),
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
  }
}

class _RecentExamCard extends StatelessWidget {
  final ExamModel exam;
  final VoidCallback onTap;

  const _RecentExamCard({required this.exam, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x04000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: const Icon(
                Icons.quiz_outlined,
                color: Color(0xFF9333EA),
                size: 20,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exam.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 13.r,
                        color: const Color(0xFF64748B),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${exam.durationMinutes} دقيقة',
                        style: GoogleFonts.cairo(
                          fontSize: 10.5.sp,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: exam.isPublished
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          exam.isPublished ? 'منشور للطلاب' : 'مسودة',
                          style: GoogleFonts.cairo(
                            fontSize: 9.5.sp,
                            fontWeight: FontWeight.w700,
                            color: exam.isPublished
                                ? const Color(0xFF16A34A)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }
}
