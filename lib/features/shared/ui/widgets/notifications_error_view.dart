import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Error state with retry button for the notifications screen.
class NotificationsErrorView extends StatelessWidget {
  const NotificationsErrorView({
    super.key,
    required this.message,
    required this.isTeacher,
    this.onRetry,
  });

  final String message;
  final bool isTeacher;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 42.r,
              color: isTeacher ? DeskColors.faint : NotebookColors.pencil,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: isTeacher ? DeskColors.muted : NotebookColors.pencil,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 14.h),
            if (isTeacher)
              DeskPrimaryButton(
                label: 'إعادة المحاولة',
                icon: Icons.refresh_rounded,
                expanded: false,
                onPressed: onRetry,
              )
            else
              NotebookPrimaryButton(
                label: 'إعادة المحاولة',
                icon: Icons.refresh_rounded,
                expanded: false,
                onPressed: onRetry,
              ),
          ],
        ),
      ),
    );
  }
}
