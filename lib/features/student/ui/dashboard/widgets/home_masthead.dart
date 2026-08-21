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
    this.points = 0,
    this.canClaimDaily = true,
    this.onPointsTap,
  });

  /// The student's first name displayed in the greeting.
  final String firstName;

  /// Called when the notification bell is tapped.
  final VoidCallback onNotificationsTap;

  /// Current points balance.
  final int points;

  /// Whether the student can claim today's daily gift.
  final bool canClaimDaily;

  /// Called when points button is tapped.
  final VoidCallback? onPointsTap;

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
              if (onPointsTap != null) ...[
                GestureDetector(
                  onTap: onPointsTap,
                  child: Container(
                    height: 40.r,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: canClaimDaily
                            ? [const Color(0xFFF59E0B), const Color(0xFFD97706)]
                            : [const Color(0xFFFEF3C7), const Color(0xFFFDE68A)],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: const Color(0xFFF59E0B),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withAlpha(canClaimDaily ? 80 : 30),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          canClaimDaily ? Icons.card_giftcard_rounded : Icons.stars_rounded,
                          color: canClaimDaily ? Colors.white : const Color(0xFFB45309),
                          size: 18.r,
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          '$points',
                          style: GoogleFonts.cairo(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w900,
                            color: canClaimDaily ? Colors.white : const Color(0xFF92400E),
                          ),
                        ),
                        if (canClaimDaily) ...[
                          SizedBox(width: 4.w),
                          Container(
                            width: 6.r,
                            height: 6.r,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
              ],
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
