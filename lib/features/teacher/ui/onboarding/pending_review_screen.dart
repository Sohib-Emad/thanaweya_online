// ────────────────────────────────────────────────────────────
// THESIS — قيد المراجعة بعد تقديم طلب الالتحاق
//   Polls teachers.approval_status every 5s and swaps between three
//   chalkboard states: pending (مراجعة), rejected (رفض), approved
//   (تفعيل → teacher home).
// OWN-WORLD — Chalkboard (سبورة): green board ground, chalk-white
//   ink, mint = approved, yellow = pending, red = rejected.
// STORY — The teacher hands in the chalk application and waits by
//   the board. The board turns yellow "قيد المراجعة", then either
//   stamps "تم التفعيل" in mint or marks the request in red chalk.
// FIRST VIEWPORT — Chalkboard ground, yellow chalk stamp "قيد
//   المراجعة", the wait lottie, title, description, status steps.
// FORM — No inputs; only a "الرئيسية" action + a poller.
// FINISH — approved → 3s → AppRouter.teacherHome; rejected → action
//   to role selection; pending → keeps polling every 5s.
// ────────────────────────────────────────────────────────────
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/chalkboard_theme.dart';

class PendingReviewScreen extends StatefulWidget {
  const PendingReviewScreen({super.key});

  @override
  State<PendingReviewScreen> createState() => _PendingReviewScreenState();
}

class _PendingReviewScreenState extends State<PendingReviewScreen> {
  Timer? _pollTimer;
  Timer? _navigationTimer;
  bool _isApproved = false;
  bool _isRejected = false;
  String? _rejectionReason;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!mounted) return;
      await _checkApprovalStatus();
    });
    _checkApprovalStatus();
  }

  Future<void> _checkApprovalStatus() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final data = await Supabase.instance.client
          .from('teachers')
          .select('approval_status, rejection_reason')
          .eq('id', userId)
          .maybeSingle();

      if (data == null || !mounted) return;

      final status = data['approval_status'] as String?;

      if (status == 'approved') {
        _pollTimer?.cancel();
        HapticFeedback.heavyImpact();
        setState(() => _isApproved = true);
        _navigationTimer = Timer(const Duration(seconds: 3), () {
          if (!mounted) return;
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRouter.teacherHome,
            (route) => false,
          );
        });
      } else if (status == 'rejected') {
        _pollTimer?.cancel();
        setState(() {
          _isRejected = true;
          _rejectionReason = data['rejection_reason'] as String?;
        });
      }
    } catch (e) {
      debugPrint('[PendingReview] poll error: $e');
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ChalkboardColors.ground,
        body: SafeArea(
          bottom: false,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _isApproved
                ? _buildSuccessView()
                : _isRejected
                    ? _buildRejectedView()
                    : _buildPendingView(),
          ),
        ),
      ),
    );
  }

  // View A: Pending Review View (chalkboard + wait Lottie)
  Widget _buildPendingView() {
    return ChalkboardSurface(
      child: SingleChildScrollView(
        key: const ValueKey('pending_view'),
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Column(
          children: [
            SizedBox(height: 8.h),

            const ChalkStamp(
              label: 'قيد المراجعة',
              color: ChalkboardColors.chalkYellow,
              angle: -0.04,
            ),

            SizedBox(height: 12.h),

            // Hero Lottie Animation (wait.json)
            Center(
              child: Container(
                width: 300.r,
                height: 300.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ChalkboardColors.surface.withAlpha(90),
                  border: Border.all(
                    color: ChalkboardColors.chalkYellow.withAlpha(90),
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

            // Title & Description
            Text(
              AppStrings.pendingReview,
              style: ChalkboardText.heading(24.sp),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 10.h),

            Text(
              'تم استلام طلبك ومستنداتك بنجاح. يقوم فريق الإدارة بمراجعة البيانات والتأكد منها، وسنرسل لك إشعاراً فور التفعيل.',
              style: ChalkboardText.body(13.sp,
                      color: ChalkboardColors.chalkSoft)
                  .copyWith(height: 1.6),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 24.h),

            // Status Steps Card
            ChalkCard(
              padding: const EdgeInsets.all(16),
              accent: ChalkboardColors.chalkYellow,
              child: Column(
                children: [
                  _StatusStepRow(
                    title: 'تقديم بيانات ومعلومات المعلم',
                    statusText: 'تم التسجيل',
                    isDone: true,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Container(
                      height: 1,
                      color: ChalkboardColors.ink.withAlpha(40),
                    ),
                  ),
                  _StatusStepRow(
                    title: 'مراجعة المستندات وإثبات الهوية',
                    statusText: 'جاري التحقق',
                    isInProgress: true,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Container(
                      height: 1,
                      color: ChalkboardColors.ink.withAlpha(40),
                    ),
                  ),
                  _StatusStepRow(
                    title: 'تفعيل حساب المعلم ودخول اللوحة',
                    statusText: 'قريباً',
                    isPending: true,
                  ),
                ],
              ),
            ),

            SizedBox(height: 28.h),

            // Home Button
            ChalkPrimaryButton(
              label: AppStrings.home,
              icon: Icons.home_rounded,
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),

            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  // View B: Rejected View (red chalk)
  Widget _buildRejectedView() {
    return ChalkboardSurface(
      child: SingleChildScrollView(
        key: const ValueKey('rejected_view'),
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: ChalkboardColors.chalkRed.withAlpha(22),
                shape: BoxShape.circle,
                border: Border.all(
                  color: ChalkboardColors.chalkRed.withAlpha(120),
                  width: 1.6,
                ),
              ),
              child: Icon(
                Icons.cancel_rounded,
                color: ChalkboardColors.chalkRed,
                size: 64.r,
              ),
            ),
            SizedBox(height: 20.h),
            const ChalkStamp(
              label: 'تم الرفض',
              color: ChalkboardColors.chalkRed,
              angle: -0.04,
            ),
            SizedBox(height: 20.h),
            Text(
              'تم رفض طلبك',
              style: ChalkboardText.heading(24.sp,
                  color: ChalkboardColors.chalkRed),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              _rejectionReason ??
                  'لم تتم الموافقة على طلبك. يرجى مراجعة بياناتك والتقديم مرة أخرى.',
              style: ChalkboardText.body(14.sp,
                      color: ChalkboardColors.chalkSoft)
                  .copyWith(height: 1.6),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            ChalkPrimaryButton(
              label: 'العودة للرئيسية',
              icon: Icons.arrow_back_rounded,
              color: ChalkboardColors.chalkRed,
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

  // View C: Approved Success View (success Lottie on the board)
  Widget _buildSuccessView() {
    return ChalkboardSurface(
      child: Center(
        key: const ValueKey('success_view'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 300.r,
              height: 300.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ChalkboardColors.surface.withAlpha(90),
                border: Border.all(
                  color: ChalkboardColors.accent.withAlpha(110),
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
            const ChalkStamp(
              label: 'تم التفعيل',
              color: ChalkboardColors.accent,
              angle: -0.05,
            ),
            SizedBox(height: 10.h),
            Text(
              'أهلاً بك في السبورة',
              style: ChalkboardText.heading(22.sp,
                  color: ChalkboardColors.accent),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusStepRow extends StatelessWidget {
  final String title;
  final String statusText;
  final bool isDone;
  final bool isInProgress;
  final bool isPending;

  const _StatusStepRow({
    required this.title,
    required this.statusText,
    this.isDone = false,
    this.isInProgress = false,
    this.isPending = false,
  });

  @override
  Widget build(BuildContext context) {
    Color iconColor = ChalkboardColors.chalkFaint;
    IconData iconData = Icons.circle_outlined;

    if (isDone) {
      iconColor = ChalkboardColors.accent;
      iconData = Icons.check_circle_rounded;
    } else if (isInProgress) {
      iconColor = ChalkboardColors.chalkYellow;
      iconData = Icons.hourglass_bottom_rounded;
    }

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.r),
          decoration: BoxDecoration(
            color: iconColor.withAlpha(24),
            shape: BoxShape.circle,
          ),
          child: Icon(iconData, color: iconColor, size: 18.r),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            title,
            style: ChalkboardText.body(13.sp,
                color: isPending
                    ? ChalkboardColors.chalkFaint
                    : ChalkboardColors.ink),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: iconColor.withAlpha(20),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: iconColor.withAlpha(90), width: 1),
          ),
          child: Text(
            statusText,
            style: ChalkboardText.strong(11.sp, color: iconColor),
          ),
        ),
      ],
    );
  }
}
