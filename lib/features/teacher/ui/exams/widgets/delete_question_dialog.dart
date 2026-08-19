import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Shows a confirmation dialog before deleting a question.
Future<bool> showDeleteQuestionDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: DeskColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r)),
        title: Text('حذف السؤال؟', style: DeskText.heading(16.sp)),
        content: Text('سيتم حذف هذا السؤال من الاختبار.',
            style: DeskText.body(12.sp)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('إلغاء',
                style:
                    DeskText.strong(12.sp, color: DeskColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('حذف',
                style:
                    DeskText.strong(12.sp, color: DeskColors.danger)),
          ),
        ],
      ),
    ),
  );
  return confirmed ?? false;
}
