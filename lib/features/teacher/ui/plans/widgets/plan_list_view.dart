import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thanaweya_online/core/theme/desk_text.dart';
import 'package:thanaweya_online/features/shared/models/subscription_plan_item.dart';
import 'package:thanaweya_online/features/teacher/ui/plans/widgets/instapay_info_card.dart';
import 'package:thanaweya_online/features/teacher/ui/plans/widgets/plan_card.dart';
import 'package:thanaweya_online/features/teacher/ui/plans/widgets/receipt_upload_box.dart';

/// The scrollable plan list showing the current subscribed plan banner
/// and only revealing the renewal/upgrade options when renewal alert is enabled.
class PlanListView extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onPlanSelected;
  final List<SubscriptionPlanItem> plans;
  final String? currentSubscribedPlanKey;
  final String? currentSubscriptionStatus;
  final double? currentSubscriptionAmount;
  final bool requiresRenewal;
  final Widget? activationCodeBox;
  final XFile? receiptFile;
  final VoidCallback? onPickReceipt;
  final VoidCallback? onRemoveReceipt;

  const PlanListView({
    super.key,
    required this.selectedIndex,
    required this.onPlanSelected,
    this.plans = const [],
    this.currentSubscribedPlanKey,
    this.currentSubscriptionStatus,
    this.currentSubscriptionAmount,
    this.requiresRenewal = false,
    this.activationCodeBox,
    this.receiptFile,
    this.onPickReceipt,
    this.onRemoveReceipt,
  });

  List<SubscriptionPlanItem> get _activePlans =>
      plans.isNotEmpty ? plans : SubscriptionPlanItem.defaultPlans;

  SubscriptionPlanItem get _currentPlan {
    if (selectedIndex >= 0 && selectedIndex < _activePlans.length) {
      return _activePlans[selectedIndex];
    }
    return _activePlans.first;
  }

  String get _selectedPlanName => _currentPlan.name;

  String get _selectedPlanAmount => _currentPlan.formattedPrice;

  SubscriptionPlanItem? get _userSubscribedPlan {
    if (currentSubscribedPlanKey == null || currentSubscribedPlanKey!.isEmpty) {
      return null;
    }
    return _activePlans.firstWhere(
      (p) =>
          p.billingPeriod == currentSubscribedPlanKey ||
          (currentSubscribedPlanKey == 'annual' && p.billingPeriod == 'yearly'),
      orElse: () => _activePlans.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _activePlans;
    final hasCurrentPlan = currentSubscribedPlanKey != null && currentSubscribedPlanKey!.isNotEmpty;
    final isApproved = currentSubscriptionStatus == 'approved';
    final userPlan = _userSubscribedPlan;

    // Show renewal options only if requiresRenewal is enabled by admin OR if the user is not subscribed yet
    final bool showRenewalOptions = requiresRenewal || !hasCurrentPlan;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(20.r),
      children: [
        // ─── Current Active Plan Banner ────────────────────────────────────
        if (hasCurrentPlan) ...[
          Container(
            padding: EdgeInsets.all(18.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isApproved
                    ? [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)]
                    : [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isApproved ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isApproved ? const Color(0xFF10B981) : const Color(0xFFF59E0B))
                      .withValues(alpha: 0.12),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: isApproved ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                              isApproved ? Icons.verified_rounded : Icons.hourglass_top_rounded,
                              color: Colors.white,
                              size: 20.r,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'باقتك المشترك بها حالياً',
                                  style: GoogleFonts.cairo(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                    color: isApproved ? const Color(0xFF065F46) : const Color(0xFF92400E),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  userPlan?.name ?? 'الباقة الحالية',
                                  style: GoogleFonts.cairo(
                                    fontSize: 14.5.sp,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF0F172A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: isApproved ? const Color(0xFF059669) : const Color(0xFFD97706),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Text(
                        isApproved ? 'مفعلة ✅' : 'قيد المراجعة ⏳',
                        style: GoogleFonts.cairo(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                if (currentSubscriptionAmount != null && currentSubscriptionAmount! > 0) ...[
                  SizedBox(height: 12.h),
                  const Divider(height: 1),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'قيمة الاشتراك المحصلة:',
                        style: GoogleFonts.cairo(fontSize: 12.5.sp, color: const Color(0xFF475569)),
                      ),
                      Text(
                        '${currentSubscriptionAmount!.toInt()} ج.م',
                        style: GoogleFonts.cairo(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: isApproved ? const Color(0xFF059669) : const Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 16.h),
        ],

        // ─── Case 1: Subscription is active and no renewal required ────────
        if (!showRenewalOptions && userPlan != null) ...[
          Container(
            padding: EdgeInsets.all(18.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x080F172A),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: const Icon(Icons.star_rounded, color: Color(0xFF059669)),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'ميزات باقتك الحالية',
                      style: GoogleFonts.cairo(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                for (final feat in userPlan.features) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_rounded, color: const Color(0xFF10B981), size: 18.r),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            feat,
                            style: GoogleFonts.cairo(
                              fontSize: 12.5.sp,
                              color: const Color(0xFF334155),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Color(0xFF64748B)),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'حسابك مفعل واشتراكك سارٍ. سيتم إظهار باقات التجديد تلقائياً عند اقتراب موعد انتهاء الاشتراك.',
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      color: const Color(0xFF475569),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // ─── Case 2: Renewal is required by admin (Show full payment flow) ──
        if (showRenewalOptions) ...[
          if (requiresRenewal) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFEF4444), width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626)),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'تنبيه: اقتراب موعد انتهاء الاشتراك، يرجى اختيار الباقة وتجديد الاشتراك الآن.',
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF991B1B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
          ],

          Text(
            'تجديد أو ترقية باقة الاشتراك',
            style: DeskText.heading(15.sp),
          ),
          SizedBox(height: 4.h),
          Text(
            'يمكنك اختيار باقة أعلى أو تجديد اشتراكك وتحويل الرسوم عبر InstaPay:',
            style: GoogleFonts.cairo(fontSize: 12.sp, color: const Color(0xFF64748B)),
          ),
          SizedBox(height: 14.h),

          // Plans Cards List
          for (int i = 0; i < list.length; i++) ...[
            if (i > 0) SizedBox(height: 14.h),
            PlanCard(
              index: i,
              icon: list[i].icon,
              title: list[i].name,
              price: list[i].formattedPrice,
              originalPrice: list[i].originalPrice,
              period: list[i].periodLabel,
              badge: (list[i].billingPeriod == currentSubscribedPlanKey ||
                      (currentSubscribedPlanKey == 'annual' && list[i].billingPeriod == 'yearly'))
                  ? 'باقتك الحالية ⭐'
                  : list[i].badge,
              badgeBgColor: (list[i].billingPeriod == currentSubscribedPlanKey ||
                      (currentSubscribedPlanKey == 'annual' && list[i].billingPeriod == 'yearly'))
                  ? const Color(0xFFE0F2FE)
                  : (list[i].billingPeriod == 'yearly' ? const Color(0xFFDCFCE7) : null),
              badgeTextColor: (list[i].billingPeriod == currentSubscribedPlanKey ||
                      (currentSubscribedPlanKey == 'annual' && list[i].billingPeriod == 'yearly'))
                  ? const Color(0xFF0369A1)
                  : (list[i].billingPeriod == 'yearly' ? const Color(0xFF15803D) : null),
              features: list[i].features,
              isSelected: selectedIndex == i,
              onTap: () {
                HapticFeedback.selectionClick();
                onPlanSelected(i);
              },
            ),
          ],
          SizedBox(height: 24.h),

          // InstaPay Payment Details
          Text(
            'بيانات الدفع عبر InstaPay',
            style: DeskText.heading(15.sp),
          ),
          SizedBox(height: 10.h),
          InstaPayInfoCard(
            amount: _selectedPlanAmount,
            planName: _selectedPlanName,
          ),
          SizedBox(height: 20.h),

          // Receipt Upload Section
          if (onPickReceipt != null) ...[
            Text(
              'إرفاق صورة إيصال التحويل',
              style: DeskText.heading(15.sp),
            ),
            SizedBox(height: 10.h),
            ReceiptUploadBox(
              receiptFile: receiptFile,
              onPick: onPickReceipt!,
              onRemove: onRemoveReceipt ?? () {},
            ),
            SizedBox(height: 20.h),
          ],

          if (activationCodeBox != null) ...[
            activationCodeBox!,
            SizedBox(height: 16.h),
          ],
        ],
      ],
    );
  }
}
