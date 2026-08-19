import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/features/shared/models/course_model.dart';

/// Content section of the course card with title, description, meta, and actions.
class CourseCardContent extends StatelessWidget {
  final CourseModel course;
  final int lessonCount;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CourseCardContent({
    super.key,
    required this.course,
    required this.lessonCount,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(14.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            course.title,
            style: GoogleFonts.cairo(fontSize: 15.sp, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A), height: 1.3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (course.description?.isNotEmpty == true) ...[
            SizedBox(height: 4.h),
            Text(course.description!, style: GoogleFonts.cairo(fontSize: 11.5.sp, color: const Color(0xFF64748B), height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          SizedBox(height: 12.h),
          _buildMetaRow(),
          SizedBox(height: 14.h),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildMetaRow() {
    return Row(
      children: [
        CourseCardMetaPill(icon: Icons.ondemand_video_rounded, label: '$lessonCount محاضرة', color: const Color(0xFF0284C7)),
        SizedBox(width: 8.w),
        CourseCardMetaPill(icon: Icons.quiz_outlined, label: 'امتحانات', color: const Color(0xFF9333EA)),
        if (course.introVideoUrl?.isNotEmpty == true) ...[
          SizedBox(width: 8.w),
          CourseCardMetaPill(icon: Icons.movie_filter_outlined, label: 'فيديو تعريفي', color: const Color(0xFF0EA5E9)),
        ],
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: Size.zero,
              padding: EdgeInsets.symmetric(vertical: 10.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: Text('إدارة الكورس والدروس', style: GoogleFonts.cairo(fontSize: 12.sp, fontWeight: FontWeight.w800)),
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12.r), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: IconButton(icon: const Icon(Icons.edit_outlined, color: Color(0xFF0284C7), size: 18), tooltip: 'تعديل', onPressed: onEdit),
        ),
        SizedBox(width: 6.w),
        Container(
          decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(12.r), border: Border.all(color: const Color(0xFFFEE2E2))),
          child: IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE11D48), size: 18), tooltip: 'حذف', onPressed: onDelete),
        ),
      ],
    );
  }
}

/// Meta pill widget for course card info badges.
class CourseCardMetaPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const CourseCardMetaPill({super.key, required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(color: color.withAlpha(16), borderRadius: BorderRadius.circular(8.r)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.r, color: color),
          SizedBox(width: 4.w),
          Text(label, style: GoogleFonts.cairo(fontSize: 11.sp, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}
