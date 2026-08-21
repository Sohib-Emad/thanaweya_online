import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/shared/models/course_model.dart';

class TeacherCoursesTab extends StatelessWidget {
  final List<CourseModel> courses;
  final bool isLoading;
  final VoidCallback onRefresh;

  const TeacherCoursesTab({
    super.key,
    required this.courses,
    this.isLoading = false,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && courses.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: CircularProgressIndicator(color: NotebookColors.green),
        ),
      );
    }

    if (courses.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 30.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(18.r),
                decoration: BoxDecoration(
                  color: NotebookColors.green.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.menu_book_outlined,
                  size: 48.r,
                  color: NotebookColors.green,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'لا توجد كورسات منشورة لهذا المعلم حالياً',
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'تابع المعلم لتصلك إشعارات فور إضافة أي دورات أو دروس جديدة',
                style: GoogleFonts.cairo(
                  fontSize: 11.5.sp,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: courses.length,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final course = courses[index];
        return _buildCourseCard(context, course);
      },
    );
  }

  Widget _buildCourseCard(BuildContext context, CourseModel course) {
    final coverUrl = course.coverImageUrl ?? '';
    final price = course.price;
    final isFree = price == null || price == 0;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pushNamed(
          context,
          AppRouter.studentCourseDetails,
          arguments: course.id,
        );
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.all(12.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image Thumbnail
            Container(
              width: 80.r,
              height: 80.r,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: NotebookColors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: coverUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: coverUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Center(
                        child: CircularProgressIndicator(color: NotebookColors.green, strokeWidth: 2),
                      ),
                      errorWidget: (_, _, _) => Icon(
                        Icons.menu_book_rounded,
                        color: NotebookColors.green,
                        size: 32.r,
                      ),
                    )
                  : Icon(
                      Icons.menu_book_rounded,
                      color: NotebookColors.green,
                      size: 32.r,
                    ),
            ),
            SizedBox(width: 14.w),

            // Course Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (course.description != null &&
                      course.description!.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      course.description!,
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: isFree
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          isFree ? 'مجاناً' : '$price ج.م',
                          style: GoogleFonts.cairo(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w800,
                            color: isFree
                                ? const Color(0xFF16A34A)
                                : const Color(0xFF2563EB),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'عرض الكورس',
                            style: GoogleFonts.cairo(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w700,
                              color: NotebookColors.green,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 11.r,
                            color: NotebookColors.green,
                          ),
                        ],
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
