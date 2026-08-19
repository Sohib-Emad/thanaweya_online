import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// The masthead area showing app branding, welcome greeting, and notification bell.
class HomeMasthead extends StatelessWidget {
  /// Creates a [HomeMasthead].
  const HomeMasthead({
    super.key,
    required this.firstName,
    required this.onNotificationsTap,
  });

  /// The student's first name displayed in the greeting.
  final String firstName;

  /// Called when the notification bell is tapped.
  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 18.h, 24.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.appName,
                style: GoogleFonts.cairo(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w900,
                  color: NotebookColors.green,
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                width: 1,
                height: 12.h,
                color: NotebookColors.ink.withAlpha(45),
              ),
              SizedBox(width: 10.w),
              Text(l10n.studentNotebook, style: NotebookText.note(12.sp)),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.welcomeBack(firstName),
                      style: NotebookText.heading(21.sp),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      l10n.whatToLearnToday,
                      style: NotebookText.note(12.sp),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onNotificationsTap,
                child: Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: NotebookColors.surfaceBright,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: NotebookColors.marginRed.withAlpha(120),
                      width: 1.4,
                    ),
                  ),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: NotebookColors.marginRed,
                    size: 20.r,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
