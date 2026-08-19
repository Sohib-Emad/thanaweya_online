import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Dialog shown when a locked lesson is tapped without subscription.
class LessonLockedDialog extends StatelessWidget {
  final String lessonTitle;
  final VoidCallback onActivate;

  const LessonLockedDialog({
    super.key,
    required this.lessonTitle,
    required this.onActivate,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        backgroundColor: NotebookColors.ground,
        title: Row(
          children: [
            Icon(Icons.lock_rounded, color: NotebookColors.marginRed, size: 24.r),
            SizedBox(width: 8.w),
            Text(context.l10n.lessonLockedTitle, style: NotebookText.heading(16.sp)),
          ],
        ),
        content: Text(
          context.l10n.lessonLockedMessage(lessonTitle),
          style: NotebookText.body(13.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel, style: NotebookText.strong(13.sp)),
          ),
          NotebookPrimaryButton(
            label: 'تفعيل الكورس بكود المدرس',
            icon: Icons.vpn_key_rounded,
            onPressed: () {
              Navigator.pop(context);
              onActivate();
            },
          ),
        ],
      ),
    );
  }
}
