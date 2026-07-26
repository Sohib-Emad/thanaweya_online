import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/data/mock_data.dart';
import 'package:thanaweya_online/core/router/app_router.dart';

class LessonsListScreen extends StatelessWidget {
  final String courseId;

  const LessonsListScreen({super.key, required this.courseId});

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
            icon: Icon(Icons.chevron_right_rounded,
                color: const Color(0xFF0F172A), size: 28.r),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            AppStrings.lessonsCount,
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        body: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          itemCount: MockData.mockLessons.length,
          separatorBuilder: (_, __) => SizedBox(height: 14.h),
          itemBuilder: (context, index) {
            final lesson = MockData.mockLessons[index];
            final isFree = lesson['is_free_preview'] == true;

            return _LessonCard(
              title: lesson['title'] as String,
              description: lesson['description'] as String,
              isFree: isFree,
              onDelete: () {
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حذف الدرس')),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: null,
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pushNamed(
              context,
              AppRouter.teacherAddLesson,
              arguments: courseId,
            );
          },
          backgroundColor: AppColors.teacherPrimary,
          elevation: 4,
          icon: Icon(Icons.video_call_rounded, color: Colors.white, size: 22.r),
          label: Text(
            'إضافة درس جديد',
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isFree;
  final VoidCallback onDelete;

  const _LessonCard({
    required this.title,
    required this.description,
    required this.isFree,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x050F172A),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: isFree ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              isFree ? Icons.play_circle_fill_rounded : Icons.play_arrow_rounded,
              color: isFree ? const Color(0xFF0FA37F) : const Color(0xFF2563EB),
              size: 24.r,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  description,
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: isFree
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: isFree
                          ? const Color(0xFFA7F3D0)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Text(
                    isFree ? 'معاينة مجانية 🎁' : 'خاص بالمشتركين 🔒',
                    style: GoogleFonts.cairo(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      color: isFree
                          ? const Color(0xFF0FA37F)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(
              Icons.delete_outline_rounded,
              color: const Color(0xFFEF4444),
              size: 20.r,
            ),
          ),
        ],
      ),
    );
  }
}
