import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// The approved success view showing a success animation
/// and welcome message.
class ApprovedSuccessView extends StatelessWidget {
  const ApprovedSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return DeskSurface(
      child: Center(
        key: const ValueKey('success_view'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 260.r,
              height: 260.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: DeskColors.primarySoft,
                border: Border.all(
                  color: DeskColors.primary.withAlpha(110),
                  width: 1.6,
                ),
              ),
              child: Lottie.asset(
                'assets/json/success.json',
                fit: BoxFit.contain,
                repeat: false,
              ),
            ),
            SizedBox(height: 16.h),
            DeskStatusChip(
              label: 'تم التفعيل',
              color: DeskColors.success,
              icon: Icons.verified_rounded,
            ),
            SizedBox(height: 10.h),
            Text(
              'أهلاً بك في مكتبك',
              style: DeskText.heading(22.sp, color: DeskColors.success),
            ),
          ],
        ),
      ),
    );
  }
}
