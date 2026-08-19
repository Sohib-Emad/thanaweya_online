import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/shared/models/lesson_model.dart';

/// Shows a confirmation dialog before resetting lesson view counts.
Future<bool> showResetViewsDialog(
  BuildContext context, {
  required LessonModel lesson,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: DeskColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text('إعادة فتح الفيديو', style: DeskText.heading(16.sp)),
        content: Text(
          'سيتم تصفير عدد مشاهدات «${lesson.title}» لكل الطلاب ليتمكنوا من مشاهدة الفيديو من جديد. هل أنت متأكد؟',
          style: DeskText.body(12.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'إلغاء',
              style: DeskText.strong(12.sp, color: DeskColors.muted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'إعادة الفتح',
              style: DeskText.strong(12.sp, color: DeskColors.primary),
            ),
          ),
        ],
      ),
    ),
  );
  return confirmed ?? false;
}
