import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/shared/models/course_model.dart';

import 'meta_pill.dart';

/// Header section displaying course cover, title, description, and metadata pills.
class CourseHeader extends StatelessWidget {
  final CourseModel course;
  final int studentsCount;
  final int lessonsCount;
  final int examsCount;

  const CourseHeader({
    super.key,
    required this.course,
    required this.studentsCount,
    required this.lessonsCount,
    required this.examsCount,
  });

  @override
  Widget build(BuildContext context) {
    final isPublished = course.isPublished;
    final priceLabel = course.price != null && course.price! > 0 ? '${course.price} ج.م' : 'مجاني';
    return Container(
      margin: EdgeInsets.all(16.r),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: DeskColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: DeskColors.line),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCoverThumbnail(),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(course.title, style: DeskText.heading(15.sp), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    DeskStatusChip(label: isPublished ? 'منشور' : 'مسودة', color: isPublished ? DeskColors.primary : DeskColors.accent),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(course.description ?? 'لا يوجد وصف مدخل لهذا الكورس', style: DeskText.note(11.5.sp), maxLines: 2, overflow: TextOverflow.ellipsis),
                SizedBox(height: 10.h),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    MetaPill(icon: Icons.people_outline_rounded, label: '$studentsCount طالب', color: DeskColors.info),
                    SizedBox(width: 8.w),
                    MetaPill(icon: Icons.ondemand_video_rounded, label: '$lessonsCount محاضرة', color: DeskColors.primary),
                    SizedBox(width: 8.w),
                    MetaPill(icon: Icons.quiz_outlined, label: '$examsCount امتحان', color: DeskColors.accent),
                    SizedBox(width: 8.w),
                    MetaPill(icon: Icons.payments_outlined, label: priceLabel, color: DeskColors.success),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverThumbnail() {
    return Container(
      width: 76.r,
      height: 76.r,
      decoration: BoxDecoration(gradient: DeskColors.primaryGradient, borderRadius: BorderRadius.circular(16.r)),
      child: course.coverImageUrl != null && course.coverImageUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: CachedNetworkImage(
                imageUrl: course.coverImageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => const Center(
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                ),
                errorWidget: (_, _, _) => Icon(Icons.menu_book_rounded, color: Colors.white, size: 32.r),
              ),
            )
          : Icon(Icons.menu_book_rounded, color: Colors.white, size: 32.r),
    );
  }
}
