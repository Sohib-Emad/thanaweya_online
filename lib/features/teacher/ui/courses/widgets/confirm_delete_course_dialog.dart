import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/shared/models/course_model.dart';

/// Shows a confirmation dialog before deleting a course.
Future<bool?> showConfirmDeleteCourseDialog(
  BuildContext context,
  CourseModel course,
) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: DeskColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text('حذف الدورة؟', style: DeskText.heading(16.sp)),
          content: Text(
            'سيتم حذف «${course.title}» مع كل دروسها، ولا يمكن التراجع.',
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
                'حذف',
                style: DeskText.strong(12.sp, color: DeskColors.danger),
              ),
            ),
          ],
        ),
      );
    },
  );
}
