import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/shared/models/lesson_model.dart';

import 'lesson_tile.dart';

/// Lessons list tab for the course details screen.
class CourseLessonsTab extends StatelessWidget {
  final bool isLoading;
  final List<LessonModel> lessons;
  final String courseId;
  final VoidCallback onRefresh;
  final void Function(LessonModel) onShowDocuments;
  final void Function(LessonModel) onConfirmDelete;

  const CourseLessonsTab({
    super.key,
    required this.isLoading,
    required this.lessons,
    required this.courseId,
    required this.onRefresh,
    required this.onShowDocuments,
    required this.onConfirmDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: DeskColors.primary),
      );
    }
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: DeskColors.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.all(16.r),
        children: [
          _buildHeader(context),
          SizedBox(height: 12.h),
          if (lessons.isEmpty) _buildEmptyState() else _buildLessonList(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'محاضرات الكورس (${lessons.length})',
          style: DeskText.strong(14.sp),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            HapticFeedback.lightImpact();
            await Navigator.pushNamed(
              context,
              AppRouter.teacherAddLesson,
              arguments: courseId,
            );
            onRefresh();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: DeskColors.primary,
            foregroundColor: Colors.white,
            minimumSize: Size.zero,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          icon: Icon(Icons.add_rounded, size: 16.r),
          label: Text(
            'إضافة محاضرة',
            style: GoogleFonts.cairo(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          children: [
            Icon(
              Icons.ondemand_video_outlined,
              size: 48.r,
              color: DeskColors.muted.withAlpha(120),
            ),
            SizedBox(height: 10.h),
            Text(
              'لا توجد محاضرات في هذا الكورس بعد',
              style: DeskText.body(13.sp),
            ),
            SizedBox(height: 4.h),
            Text(
              'اضغط على "إضافة محاضرة" لرفع فيديو أو إضافة رابط يوتيوب',
              style: DeskText.note(11.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonList() {
    return Column(
      children: lessons.asMap().entries.map((entry) {
        final idx = entry.key + 1;
        final lesson = entry.value;
        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: LessonTile(
            lesson: lesson,
            number: idx,
            onAttachments: () => onShowDocuments(lesson),
            onDelete: () => onConfirmDelete(lesson),
          ),
        );
      }).toList(),
    );
  }
}
