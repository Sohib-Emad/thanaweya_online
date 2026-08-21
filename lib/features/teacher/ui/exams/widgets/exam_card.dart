import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/features/shared/models/exam_model.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/widgets/exam_grades_summary.dart';

/// A clean, modern card displaying an exam's details, metadata, and teacher actions.
class ExamCard extends StatelessWidget {
  final ExamModel exam;
  final String? courseTitle;
  final int questionCount;
  final int totalPoints;
  final ExamGradesSummary grades;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onResults;
  final VoidCallback onTogglePublish;

  const ExamCard({
    super.key,
    required this.exam,
    required this.courseTitle,
    required this.questionCount,
    required this.totalPoints,
    required this.grades,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onResults,
    required this.onTogglePublish,
  });

  @override
  Widget build(BuildContext context) {
    final published = exam.isPublished;
    final statusColor =
        published ? const Color(0xFF059669) : const Color(0xFFD97706);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18.r),
          splashColor: const Color(0xFF0284C7).withAlpha(15),
          highlightColor: const Color(0xFF0284C7).withAlpha(8),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(published, statusColor),
                SizedBox(height: 12.h),
                _buildMetaRow(),
                if (grades.participants > 0) ...[
                  SizedBox(height: 10.h),
                  _buildGradesBar(),
                ],
                SizedBox(height: 14.h),
                _buildActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool published, Color statusColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44.r,
          height: 44.r,
          decoration: BoxDecoration(
            color: const Color(0xFF0284C7).withAlpha(18),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFF0284C7).withAlpha(40)),
          ),
          child: const Icon(
            Icons.quiz_outlined,
            color: Color(0xFF0284C7),
            size: 22,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exam.title,
                style: GoogleFonts.cairo(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 3.h),
              Row(
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    size: 13.r,
                    color: const Color(0xFF64748B),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      courseTitle ?? 'بدون كورس مرتبط',
                      style: GoogleFonts.cairo(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        _buildStatusBadge(published, statusColor),
        SizedBox(width: 4.w),
        _buildMenu(published),
      ],
    );
  }

  Widget _buildStatusBadge(bool published, Color statusColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(16),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: statusColor.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5.r,
            height: 5.r,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            published ? 'منشور' : 'مسودة',
            style: GoogleFonts.cairo(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w800,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenu(bool published) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.more_vert_rounded,
        color: Color(0xFF64748B),
        size: 20,
      ),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      onSelected: (v) {
        if (v == 'edit') onEdit();
        if (v == 'publish') onTogglePublish();
        if (v == 'delete') onDelete();
      },
      itemBuilder: (_) => [
        _mi(
          'edit',
          Icons.edit_outlined,
          const Color(0xFF0284C7),
          'تعديل بيانات الامتحان',
        ),
        _mi(
          'publish',
          published ? Icons.visibility_off_outlined : Icons.publish_rounded,
          published ? const Color(0xFFD97706) : const Color(0xFF059669),
          published ? 'إلغاء النشر' : 'نشر للطلاب',
        ),
        const PopupMenuDivider(),
        _mi(
          'delete',
          Icons.delete_outline_rounded,
          const Color(0xFFE11D48),
          'حذف الامتحان',
        ),
      ],
    );
  }

  PopupMenuItem<String> _mi(String v, IconData i, Color c, String l) =>
      PopupMenuItem(
        value: v,
        child: Row(
          children: [
            Icon(i, size: 18, color: c),
            SizedBox(width: 8.w),
            Text(
              l,
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );

  Widget _buildMetaRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _metaPill(
            Icons.timer_outlined,
            '${exam.durationMinutes} دقيقة',
            const Color(0xFF0284C7),
          ),
          SizedBox(width: 6.w),
          _metaPill(
            Icons.help_outline_rounded,
            '$questionCount سؤال',
            const Color(0xFF9333EA),
          ),
          if (totalPoints > 0) ...[
            SizedBox(width: 6.w),
            _metaPill(
              Icons.stars_outlined,
              '$totalPoints درجة',
              const Color(0xFFD97706),
            ),
          ],
          if (grades.participants > 0) ...[
            SizedBox(width: 6.w),
            _metaPill(
              Icons.people_alt_outlined,
              '${grades.participants} مشارك',
              const Color(0xFF059669),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metaPill(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withAlpha(14),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.r, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradesBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _miniStat(
            'المشاركون',
            '${grades.participants}',
            const Color(0xFF059669),
          ),
          Container(width: 1, height: 16.h, color: const Color(0xFF86EFAC)),
          _miniStat(
            'المتوسط',
            '${grades.averagePercent.toStringAsFixed(1)}%',
            const Color(0xFF0284C7),
          ),
          Container(width: 1, height: 16.h, color: const Color(0xFF86EFAC)),
          _miniStat(
            'أعلى درجة',
            '${grades.bestPercent.toStringAsFixed(0)}%',
            const Color(0xFFD97706),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: GoogleFonts.cairo(
            fontSize: 10.5.sp,
            color: const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 11.sp,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
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
              padding: EdgeInsets.symmetric(vertical: 9.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: Text(
              'إدارة الأسئلة',
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        ElevatedButton.icon(
          onPressed: onResults,
          style: ElevatedButton.styleFrom(
            backgroundColor: grades.participants > 0
                ? const Color(0xFF059669).withAlpha(18)
                : const Color(0xFFF1F5F9),
            foregroundColor: grades.participants > 0
                ? const Color(0xFF059669)
                : const Color(0xFF475569),
            elevation: 0,
            side: BorderSide(
              color: grades.participants > 0
                  ? const Color(0xFF059669).withAlpha(60)
                  : const Color(0xFFE2E8F0),
            ),
            minimumSize: Size.zero,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          icon: Icon(
            Icons.bar_chart_rounded,
            size: 16,
            color: grades.participants > 0
                ? const Color(0xFF059669)
                : const Color(0xFF475569),
          ),
          label: Text(
            grades.participants > 0
                ? 'النتائج (${grades.participants})'
                : 'النتائج',
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: grades.participants > 0
                  ? const Color(0xFF059669)
                  : const Color(0xFF475569),
            ),
          ),
        ),
        SizedBox(width: 6.w),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: Color(0xFF0284C7),
              size: 18,
            ),
            tooltip: 'تعديل',
            padding: EdgeInsets.all(8.r),
            constraints: const BoxConstraints(),
            onPressed: onEdit,
          ),
        ),
        SizedBox(width: 6.w),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFFEE2E2)),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFE11D48),
              size: 18,
            ),
            tooltip: 'حذف',
            padding: EdgeInsets.all(8.r),
            constraints: const BoxConstraints(),
            onPressed: onDelete,
          ),
        ),
      ],
    );
  }
}
