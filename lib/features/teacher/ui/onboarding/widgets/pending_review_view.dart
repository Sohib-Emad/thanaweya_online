import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/onboarding/widgets/status_step_row.dart';

/// The pending review view showing a waiting animation,
/// status steps card, and home button.
class PendingReviewView extends StatelessWidget {
  final VoidCallback onHomePressed;

  const PendingReviewView({super.key, required this.onHomePressed});

  @override
  Widget build(BuildContext context) {
    return DeskSurface(
      child: SingleChildScrollView(
        key: const ValueKey('pending_view'),
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Column(
          children: [
            SizedBox(height: 8.h),
            DeskStatusChip(
              label: 'قيد المراجعة',
              color: DeskColors.accent,
              icon: Icons.hourglass_top_rounded,
            ),
            SizedBox(height: 16.h),
            Center(
              child: Container(
                width: 260.r,
                height: 260.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DeskColors.primarySoft,
                  border: Border.all(
                    color: DeskColors.primary.withAlpha(90),
                    width: 1.4,
                  ),
                ),
                child: Lottie.asset(
                  'assets/json/wait.json',
                  fit: BoxFit.contain,
                  repeat: true,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'تم استلام طلبك بنجاح',
              style: DeskText.heading(24.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.h),
            Text(
              'تم استلام طلبك ومستنداتك بنجاح. يقوم فريق الإدارة بمراجعة البيانات والتأكد منها، وسنرسل لك إشعاراً فور التفعيل.',
              style: DeskText.body(13.sp, color: DeskColors.muted)
                  .copyWith(height: 1.6),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            DeskCard(
              padding: const EdgeInsets.all(16),
              accent: DeskColors.accent,
              child: Column(
                children: [
                  const StatusStepRow(
                    title: 'تقديم بيانات ومعلومات المعلم',
                    statusText: 'تم التسجيل',
                    isDone: true,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Container(height: 1, color: DeskColors.line),
                  ),
                  const StatusStepRow(
                    title: 'مراجعة المستندات وإثبات الهوية',
                    statusText: 'جاري التحقق',
                    isInProgress: true,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Container(height: 1, color: DeskColors.line),
                  ),
                  const StatusStepRow(
                    title: 'تفعيل حساب المعلم ودخول اللوحة',
                    statusText: 'قريباً',
                    isPending: true,
                  ),
                ],
              ),
            ),
            SizedBox(height: 28.h),
            DeskPrimaryButton(
              label: 'الرئيسية',
              icon: Icons.home_rounded,
              onPressed: () {
                HapticFeedback.lightImpact();
                onHomePressed();
              },
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
