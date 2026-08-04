import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/router/app_router.dart';

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
        backgroundColor: _isApproved ? Colors.white : const Color(0xFFF8FAFC),
        body: SafeArea(
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

  // View A: Pending Review View (with wait.json Lottie)
  Widget _buildPendingView() {
    return SingleChildScrollView(
      key: const ValueKey('pending_view'),
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        children: [
          SizedBox(height: 12.h),

          // Top Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.hourglass_top_rounded,
                  color: const Color(0xFFD97706),
                  size: 16.r,
                ),
                SizedBox(width: 6.w),
                Text(
                  'طلبك قيد المراجعة الآن',
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFD97706),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Hero Lottie Animation (wait.json)
          Center(
            child: Container(
              width: 320.r,
              height: 320.r,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: Lottie.asset(
                'assets/json/wait.json',
                fit: BoxFit.contain,
                repeat: true,
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Title & Description
          Text(
            AppStrings.pendingReview,
            style: GoogleFonts.cairo(
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 10.h),

          Text(
            'تم استلام طلبك ومستنداتك بنجاح. يقوم فريق الإدارة بمراجعة البيانات والتأكد منها، وسنرسل لك إشعاراً فور التفعيل.',
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 24.h),

          // Status Steps Card
          Container(
            padding: EdgeInsets.all(18.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x080F172A),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _StatusStepRow(
                  title: 'تقديم بيانات ومعلومات المعلم',
                  statusText: 'تم التسجيل',
                  isDone: true,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: const Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),
                _StatusStepRow(
                  title: 'مراجعة المستندات وإثبات الهوية',
                  statusText: 'جاري التحقق',
                  isInProgress: true,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: const Divider(height: 1, color: Color(0xFFF1F5F9)),
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
          SizedBox(
            width: double.infinity,
            height: 54.h,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.studentPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_rounded, color: Colors.white, size: 20.r),
                  SizedBox(width: 8.w),
                  Text(
                    AppStrings.home,
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  // View B: Rejected View
  Widget _buildRejectedView() {
    return SingleChildScrollView(
      key: const ValueKey('rejected_view'),
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: const BoxDecoration(
              color: Color(0xFFFEF2F2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cancel_rounded,
              color: const Color(0xFFEF4444),
              size: 64.r,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'تم رفض طلبك',
            style: GoogleFonts.cairo(
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFEF4444),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          Text(
            _rejectionReason ?? 'لم تتم الموافقة على طلبك. يرجى مراجعة بياناتك والتقديم مرة أخرى.',
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),
          SizedBox(
            width: double.infinity,
            height: 54.h,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRouter.roleSelection,
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.studentPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              child: Text(
                'العودة للرئيسية',
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // View C: Approved Success View (Pure white screen with ONLY success.json Lottie)
  Widget _buildSuccessView() {
    return Center(
      key: const ValueKey('success_view'),
      child: Container(
        width: 320.r,
        height: 320.r,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: Lottie.asset(
          'assets/json/success.json',
          fit: BoxFit.contain,
          repeat: false,
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
    Color iconBg = const Color(0xFFF1F5F9);
    Color iconColor = const Color(0xFF94A3B8);
    IconData iconData = Icons.circle_outlined;

    if (isDone) {
      iconBg = const Color(0xFFECFDF5);
      iconColor = const Color(0xFF0FA37F);
      iconData = Icons.check_circle_rounded;
    } else if (isInProgress) {
      iconBg = const Color(0xFFFEF3C7);
      iconColor = const Color(0xFFD97706);
      iconData = Icons.hourglass_bottom_rounded;
    }

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.r),
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(iconData, color: iconColor, size: 18.r),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              fontWeight: isInProgress || isDone
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: isPending
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF0F172A),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            statusText,
            style: GoogleFonts.cairo(
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              color: iconColor,
            ),
          ),
        ),
      ],
    );
  }
}
