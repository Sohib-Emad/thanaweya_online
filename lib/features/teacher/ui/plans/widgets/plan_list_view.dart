import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thanaweya_online/core/theme/desk_text.dart';
import 'package:thanaweya_online/features/teacher/ui/plans/widgets/instapay_info_card.dart';

import 'package:thanaweya_online/features/teacher/ui/plans/widgets/plan_card.dart';
import 'package:thanaweya_online/features/teacher/ui/plans/widgets/receipt_upload_box.dart';

/// The scrollable plan list showing all three subscription
/// plan cards with selection state.
class PlanListView extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onPlanSelected;
  final Widget? activationCodeBox;
  final XFile? receiptFile;
  final VoidCallback? onPickReceipt;
  final VoidCallback? onRemoveReceipt;

  const PlanListView({
    super.key,
    required this.selectedIndex,
    required this.onPlanSelected,
    this.activationCodeBox,
    this.receiptFile,
    this.onPickReceipt,
    this.onRemoveReceipt,
  });

  String get _selectedPlanName => switch (selectedIndex) {
        0 => 'الباقة الشهرية',
        1 => 'باقة الترم الدراسي',
        2 => 'الباقة السنوية الشاملة',
        _ => 'الباقة المختارة',
      };

  String get _selectedPlanAmount => switch (selectedIndex) {
        0 => '1,000 ج.م',
        1 => '5,000 ج.م',
        2 => '10,000 ج.م',
        _ => '1,000 ج.م',
      };

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(20.r),
      children: [
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
          isSelected: selectedIndex == 0,
          onTap: () {
            HapticFeedback.selectionClick();
            onPlanSelected(0);
          },
        ),
        SizedBox(height: 14.h),
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
          isSelected: selectedIndex == 1,
          onTap: () {
            HapticFeedback.selectionClick();
            onPlanSelected(1);
          },
        ),
        SizedBox(height: 14.h),
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
          isSelected: selectedIndex == 2,
          onTap: () {
            HapticFeedback.selectionClick();
            onPlanSelected(2);
          },
        ),
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
    );
  }
}
