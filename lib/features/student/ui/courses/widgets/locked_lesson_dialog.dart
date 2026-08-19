import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Shows a dialog prompting the user to activate the course to unlock the lesson.
void showLockedLessonDialog({
  required BuildContext context,
  required String lessonTitle,
  required String courseId,
  required Map<String, dynamic> course,
  required VoidCallback onComplete,
}) {
  HapticFeedback.heavyImpact();
  final teachers = course['teachers'] as Map<String, dynamic>? ?? {};
  final teacherId = teachers['id'] as String? ?? '';
  final price = (course['price'] as num?)?.toDouble();
  final l10n = context.l10n;

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      backgroundColor: NotebookColors.ground,
      title: Row(
        children: [
          Icon(Icons.lock_rounded, color: NotebookColors.marginRed, size: 24.r),
          SizedBox(width: 8.w),
          Text(l10n.lockedLessonTitle, style: NotebookText.heading(16.sp)),
        ],
      ),
      content: Text(l10n.lockedLessonMessage(lessonTitle), style: NotebookText.body(13.sp)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l10n.cancel, style: NotebookText.strong(13.sp)),
        ),
        NotebookPrimaryButton(
          label: l10n.payAndActivate,
          onPressed: () {
            Navigator.pop(ctx);
            Navigator.pushNamed(
              context,
              AppRouter.studentPaymentMethods,
              arguments: {
                'courseId': courseId,
                'teacherId': teacherId,
                'courseTitle': course['title'] ?? '',
                'price': price,
              },
            ).then((_) => onComplete());
          },
        ),
      ],
    ),
  );
}
