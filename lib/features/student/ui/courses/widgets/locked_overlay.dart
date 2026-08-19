import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// A full-size overlay displayed when the user is not subscribed to the course.
class LockedOverlay extends StatelessWidget {
  const LockedOverlay({
    super.key,
    required this.courseId,
    required this.onSubscriptionChecked,
  });

  /// The course ID used for the payment/activation flow.
  final String courseId;

  /// Called after the user returns from the subscription screen.
  final VoidCallback onSubscriptionChecked;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.all(16.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LockIcon(radius: 44.r, iconSize: 24.r),
          SizedBox(height: 8.h),
          Text(
            context.l10n.videoLockedForSubscribers,
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            context.l10n.videoLockedSubMessage,
            style: GoogleFonts.cairo(
              fontSize: 10.sp,
              color: Colors.white.withAlpha(180),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10.h),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(
                context,
                AppRouter.studentPaymentMethods,
                arguments: {'courseId': courseId},
              ).then((_) => onSubscriptionChecked());
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: NotebookColors.green,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.vpn_key_rounded, color: Colors.white, size: 14.r),
                  SizedBox(width: 6.w),
                  Text(
                    context.l10n.activateCode,
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LockIcon extends StatelessWidget {
  const _LockIcon({required this.radius, required this.iconSize});

  final double radius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        color: NotebookColors.marginRed.withAlpha(40),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.lock_rounded,
        color: NotebookColors.marginRed,
        size: iconSize,
      ),
    );
  }
}
