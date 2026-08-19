import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/notebook_theme.dart';
import '../../../../../l10n/l10n.dart';

/// Shows a success dialog after course activation.
void showPaymentSuccessDialog({
  required BuildContext context,
  required String message,
  required VoidCallback onOpenLessons,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.r),
      ),
      backgroundColor: NotebookColors.surface,
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.r,
              height: 64.r,
              decoration: BoxDecoration(
                color: NotebookColors.green.withAlpha(24),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: NotebookColors.green,
                size: 40.r,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'تم الاشتراك بنجاح!',
              style: NotebookText.heading(17.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: NotebookText.body(12.sp),
            ),
            SizedBox(height: 24.h),
            NotebookPrimaryButton(
              label: 'الانتقال لدروس الكورس الآن',
              icon: Icons.play_circle_fill_rounded,
              onPressed: onOpenLessons,
            ),
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
              },
              child: Text(
                ctx.l10n.backToHome,
                style: NotebookText.strong(
                  13.sp,
                  color: NotebookColors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
