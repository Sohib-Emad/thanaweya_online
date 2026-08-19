import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_students_repo.dart';
import 'package:thanaweya_online/features/teacher/ui/students/widgets/grant_views_dialog.dart';
import 'package:thanaweya_online/features/teacher/ui/students/widgets/progress_row.dart';

/// Section that shows per-lesson progress grouped by course, including
/// watch time, completion status, view counts, and an "extra views" action.
class ProgressSection extends StatefulWidget {
  final List<Map<String, dynamic>> lessons;
  final String studentId;
  final VoidCallback onRefresh;

  const ProgressSection({
    super.key,
    required this.lessons,
    required this.studentId,
    required this.onRefresh,
  });

  @override
  State<ProgressSection> createState() => _ProgressSectionState();
}

class _ProgressSectionState extends State<ProgressSection> {
  final _repo = TeacherStudentsRepo();

  @override
  Widget build(BuildContext context) {
    if (widget.lessons.isEmpty) {
      return const DeskEmptyNote(
        message: 'لا توجد دروس مضافة لهذا المعلم بعد',
        subMessage: 'أضف دروساً للكورسات لتتم متابعة إنجاز الطالب',
        icon: Icons.assignment_outlined,
      );
    }
    return _buildGroupedList();
  }

  Widget _buildGroupedList() {
    final courses = <String, List<Map<String, dynamic>>>{};
    for (final row in widget.lessons) {
      final t = row['course_title'] as String? ?? 'دروس الدورة التعليمية';
      courses.putIfAbsent(t, () => []).add(row);
    }
    final children = <Widget>[];
    courses.forEach((title, rows) {
      final done = rows.where((r) => r['is_completed'] == true).length;
      children.add(DeskCard(
        padding: EdgeInsets.all(14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: Text(title, style: DeskText.strong(14.sp), maxLines: 1, overflow: TextOverflow.ellipsis)),
              DeskStatusChip(label: '$done/${rows.length} مكتمل', color: DeskColors.primary),
            ]),
            SizedBox(height: 8.h),
            for (final row in rows)
              ProgressRow(row: row, onGrantViews: () => _grantExtraViews(row)),
          ],
        ),
      ));
      children.add(SizedBox(height: 12.h));
    });
    return Column(children: children);
  }

  Future<void> _grantExtraViews(Map<String, dynamic> row) async {
    final title = row['title'] as String? ?? 'درس';
    final viewCount = (row['view_count'] as num?)?.toInt() ?? 0;
    final lessonId = row['lesson_id'] as String? ?? '';

    final confirmed = await GrantViewsDialog.show(context,
        lessonTitle: title, currentViewCount: viewCount);
    if (confirmed != true || !mounted) return;

    final res = await _repo.progress.detail.resetStudentLessonViews(
        studentId: widget.studentId, lessonId: lessonId, newCount: 0);
    if (!mounted) return;

    res.when(
      success: (_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('✅ تم تجديد وفتح 5 مشاهدات جديدة لهذا الدرس بنجاح للطالب!',
              style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
        ));
        widget.onRefresh();
      },
      failure: (msg, _) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('حدث خطأ: $msg', style: GoogleFonts.cairo()),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ));
      },
    );
  }
}
