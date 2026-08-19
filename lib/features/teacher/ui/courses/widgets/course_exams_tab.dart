import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/shared/models/exam_model.dart';

import 'exam_card_item.dart';

/// Exams list tab for the course details screen.
class CourseExamsTab extends StatelessWidget {
  final bool isLoading;
  final List<ExamModel> exams;
  final String courseId;
  final VoidCallback onRefresh;

  const CourseExamsTab({
    super.key,
    required this.isLoading,
    required this.exams,
    required this.courseId,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: DeskColors.primary));
    }
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: DeskColors.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: EdgeInsets.all(16.r),
        children: [
          _buildHeader(context),
          SizedBox(height: 12.h),
          if (exams.isEmpty) _buildEmptyState() else _buildList(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('الاختبارات الخاصة بالكورس (${exams.length})', style: DeskText.strong(14.sp)),
        ElevatedButton.icon(
          onPressed: () async {
            HapticFeedback.lightImpact();
            await Navigator.pushNamed(context, AppRouter.teacherExamBuilder, arguments: {'courseId': courseId});
            onRefresh();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: DeskColors.primary,
            foregroundColor: Colors.white,
            minimumSize: Size.zero,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
          icon: Icon(Icons.add_rounded, size: 16.r),
          label: Text('اختبار جديد', style: GoogleFonts.cairo(fontSize: 11.5.sp, fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(children: [
          Icon(Icons.quiz_outlined, size: 48.r, color: DeskColors.muted.withAlpha(120)),
          SizedBox(height: 10.h),
          Text('لا توجد اختبارات مرتبطة بهذا الكورس بعد', style: DeskText.body(13.sp)),
          SizedBox(height: 4.h),
          Text('اضغط على "اختبار جديد" لإنشاء أسئلة ونشر امتحان', style: DeskText.note(11.sp)),
        ]),
      ),
    );
  }

  Widget _buildList() {
    return Column(
      children: exams.map((exam) => Padding(padding: EdgeInsets.only(bottom: 10.h), child: ExamCardItem(exam: exam))).toList(),
    );
  }
}
