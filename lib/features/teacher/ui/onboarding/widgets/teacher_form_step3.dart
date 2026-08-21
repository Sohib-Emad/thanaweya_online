import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/shared/models/subscription_plan_item.dart';
import 'package:thanaweya_online/features/teacher/ui/onboarding/widgets/field_label.dart';
import 'package:thanaweya_online/features/teacher/ui/plans/widgets/plan_card.dart';

/// Step 3: Subscription plan selection loaded dynamically.
class TeacherFormStep3 extends StatelessWidget {
  final int selectedPlanIndex;
  final ValueChanged<int> onPlanChanged;
  final List<SubscriptionPlanItem> plans;

  const TeacherFormStep3({
    super.key,
    required this.selectedPlanIndex,
    required this.onPlanChanged,
    required this.plans,
  });

  @override
  Widget build(BuildContext context) {
    final activePlans = plans.isNotEmpty
        ? plans
        : SubscriptionPlanItem.defaultPlans;

    return Column(
      key: const ValueKey(3),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DeskSectionHeader(title: 'اختر باقة الاشتراك'),
        SizedBox(height: 8.h),
        Text(
          'اختر الباقة المناسبة لتفعيل حسابك والبدء في نشر كورساتك واختباراتك للطلاب.',
          style: DeskText.body(
            12.5.sp,
            color: DeskColors.muted,
          ).copyWith(height: 1.4),
        ),
        SizedBox(height: 18.h),

        const FieldLabel(label: 'الباقات المتاحة*'),
        SizedBox(height: 10.h),

        for (int i = 0; i < activePlans.length; i++) ...[
          if (i > 0) SizedBox(height: 12.h),
          PlanCard(
            index: i,
            icon: activePlans[i].icon,
            title: activePlans[i].name,
            price: activePlans[i].formattedPrice,
            originalPrice: activePlans[i].originalPrice,
            period: activePlans[i].periodLabel,
            badge: activePlans[i].badge,
            badgeBgColor: activePlans[i].billingPeriod == 'yearly'
                ? const Color(0xFFDCFCE7)
                : null,
            badgeTextColor: activePlans[i].billingPeriod == 'yearly'
                ? const Color(0xFF15803D)
                : null,
            features: activePlans[i].features,
            isSelected: selectedPlanIndex == i,
            onTap: () {
              HapticFeedback.selectionClick();
              onPlanChanged(i);
            },
          ),
        ],
      ],
    );
  }
}
