import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/firebase/notification_storage.dart';
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
              ValueListenableBuilder<int>(
                valueListenable: NotificationStorage.unreadCountNotifier,
                builder: (context, unreadCount, _) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
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
                      if (unreadCount > 0)
                        Positioned(
                          top: -3,
                          right: -3,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: unreadCount > 9 ? 5.w : 0,
                            ),
                            constraints: BoxConstraints(
                              minWidth: 18.r,
                              minHeight: 18.r,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              shape: unreadCount > 9
                                  ? BoxShape.rectangle
                                  : BoxShape.circle,
                              borderRadius: unreadCount > 9
                                  ? BorderRadius.circular(10.r)
                                  : null,
                              border: Border.all(color: Colors.white, width: 1.8),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFEF4444).withAlpha(120),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              unreadCount > 99 ? '99+' : '$unreadCount',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
