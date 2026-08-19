import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// The rejected review view showing a rejection icon,
/// reason, and return button.
class RejectedReviewView extends StatelessWidget {
  final String? rejectionReason;

  const RejectedReviewView({super.key, this.rejectionReason});

  @override
  Widget build(BuildContext context) {
    return DeskSurface(
      child: SingleChildScrollView(
        key: const ValueKey('rejected_view'),
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: DeskColors.danger.withAlpha(22),
                shape: BoxShape.circle,
                border: Border.all(
                  color: DeskColors.danger.withAlpha(120),
                  width: 1.6,
                ),
              ),
              child: Icon(
                Icons.cancel_rounded,
                color: DeskColors.danger,
                size: 64.r,
              ),
            ),
            SizedBox(height: 20.h),
            DeskStatusChip(
              label: 'تم الرفض',
              color: DeskColors.danger,
              icon: Icons.block_rounded,
            ),
            SizedBox(height: 20.h),
            Text(
              'تم رفض طلبك',
              style: DeskText.heading(24.sp, color: DeskColors.danger),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              rejectionReason ??
                  'لم تتم الموافقة على طلبك. يرجى مراجعة بياناتك والتقديم مرة أخرى.',
              style: DeskText.body(14.sp, color: DeskColors.muted)
                  .copyWith(height: 1.6),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            DeskPrimaryButton(
              label: 'العودة للرئيسية',
              icon: Icons.arrow_back_rounded,
              color: DeskColors.danger,
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRouter.roleSelection,
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
