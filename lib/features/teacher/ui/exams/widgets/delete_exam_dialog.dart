import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/shared/models/exam_model.dart';

/// Shows a confirmation dialog before deleting an exam.
///
/// Returns `true` if the user confirmed deletion.
Future<bool> showDeleteExamDialog(BuildContext context, ExamModel exam) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (d) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: DeskColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('حذف الاختبار؟', style: DeskText.heading(16.sp)),
        content: Text(
          'سيتم حذف «${exam.title}» مع كل أسئلته، ولا يمكن التراجع.',
          style: DeskText.body(12.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d, false),
            child: Text('إلغاء', style: DeskText.strong(12.sp, color: DeskColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(d, true),
            child: Text('حذف', style: DeskText.strong(12.sp, color: DeskColors.danger)),
          ),
        ],
      ),
    ),
  );
  return confirmed ?? false;
}
