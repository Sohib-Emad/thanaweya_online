import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/onboarding/widgets/field_label.dart';
import 'package:thanaweya_online/features/teacher/ui/plans/widgets/plan_card.dart';

/// Step 3: Subscription plan selection only.
class TeacherFormStep3 extends StatelessWidget {
  final int selectedPlanIndex;
  final ValueChanged<int> onPlanChanged;

  const TeacherFormStep3({
    super.key,
    required this.selectedPlanIndex,
    required this.onPlanChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey(3),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DeskSectionHeader(title: 'اختر باقة الاشتراك'),
        SizedBox(height: 8.h),
        Text(
          'اختر الباقة المناسبة لتفعيل حسابك والبدء في نشر كورساتك واختباراتك للطلاب.',
          style: DeskText.body(12.5.sp, color: DeskColors.muted).copyWith(height: 1.4),
        ),
        SizedBox(height: 18.h),

        const FieldLabel(label: 'الباقات المتاحة*'),
        SizedBox(height: 10.h),

        // 1. Monthly Plan
        PlanCard(
          index: 0,
          icon: Icons.calendar_month_outlined,
          title: 'الباقة الشهرية',
          price: '1,000 ج.م',
          period: '/ شهرياً',
          features: const [
            'كورس دراسي ومتابعة دورية',
            'حتى 100 طالب مشترك',
            'اختبارات إلكترونية ومتابعة الواجبات',
            'التقارير والإحصائيات الأساسية',
            'دعم فني خلال أوقات العمل',
          ],
          isSelected: selectedPlanIndex == 0,
          onTap: () {
            HapticFeedback.selectionClick();
            onPlanChanged(0);
          },
        ),
        SizedBox(height: 12.h),

        // 2. Term Plan
        PlanCard(
          index: 1,
          icon: Icons.school_outlined,
          title: 'باقة الترم الدراسي',
          price: '5,000 ج.م',
          period: '/ للترم (5 أشهر)',
          badge: 'الأكثر طلباً',
          features: const [
            'عدد غير محدود من الكورسات والدروس للترم',
            'حتى 500 طالب مشترك',
            'امتحانات واختبارات وبنوك أسئلة غير محدودة',
            'تقارير أولياء الأمور عبر الواتساب',
            'تحليلات وإحصائيات متقدمة للأداء',
            'دعم فني مخصص وسريع',
          ],
          isSelected: selectedPlanIndex == 1,
          onTap: () {
            HapticFeedback.selectionClick();
            onPlanChanged(1);
          },
        ),
        SizedBox(height: 12.h),

        // 3. Annual Plan with 2 months discount
        PlanCard(
          index: 2,
          icon: Icons.workspace_premium_outlined,
          title: 'الباقة السنوية الشاملة',
          price: '10,000 ج.م',
          originalPrice: '12,000 ج.م',
          period: '/ سنوياً (12 شهر)',
          badge: 'وفر شهرين 🎁',
          badgeBgColor: const Color(0xFFDCFCE7),
          badgeTextColor: const Color(0xFF15803D),
          features: const [
            'خصم شهرين كاملين (ادفع 10 شهور فقط واحصل على سنة كاملة)',
            'عدد غير محدود من الطلاب والكورسات والدروس',
            'امتحانات إلكترونية وبنوك أسئلة متكاملة',
            'إشعارات وتقارير أولياء الأمور عبر الواتساب',
            'كروت وتفعيل غير محدود مع توثيق مميز للمدرس',
            'أولوية مطلقة ودعم VIP على مدار الساعة',
          ],
          isSelected: selectedPlanIndex == 2,
          onTap: () {
            HapticFeedback.selectionClick();
            onPlanChanged(2);
          },
        ),

        SizedBox(height: 24.h),
      ],
    );
  }
}
