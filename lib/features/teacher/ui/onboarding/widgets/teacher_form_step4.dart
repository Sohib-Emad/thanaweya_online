import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thanaweya_online/features/shared/models/subscription_plan_item.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/onboarding/widgets/field_label.dart';
import 'package:thanaweya_online/features/teacher/ui/plans/widgets/instapay_info_card.dart';
import 'package:thanaweya_online/features/teacher/ui/plans/widgets/receipt_upload_box.dart';

/// Step 4: Payment details via InstaPay and transfer receipt upload
/// to confirm subscription and request activation.
class TeacherFormStep4 extends StatelessWidget {
  final int selectedPlanIndex;
  final List<SubscriptionPlanItem> plans;
  final XFile? paymentReceiptFile;
  final Future<void> Function({
    required String title,
    required Function(XFile?) onImageSelected,
  }) onPickImage;
  final ValueChanged<XFile?> onPaymentReceiptPicked;
  final VoidCallback onChangePlan;

  const TeacherFormStep4({
    super.key,
    required this.selectedPlanIndex,
    this.plans = const [],
    required this.paymentReceiptFile,
    required this.onPickImage,
    required this.onPaymentReceiptPicked,
    required this.onChangePlan,
  });

  SubscriptionPlanItem get _currentPlan {
    final list = plans.isNotEmpty ? plans : SubscriptionPlanItem.defaultPlans;
    if (selectedPlanIndex >= 0 && selectedPlanIndex < list.length) {
      return list[selectedPlanIndex];
    }
    return list.first;
  }

  String get _selectedPlanName => _currentPlan.name;

  String get _selectedPlanAmount => _currentPlan.formattedPrice;

  String get _selectedPlanPeriod => _currentPlan.periodLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey(4),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DeskSectionHeader(title: 'إرسال طلب التفعيل والدفع'),
        SizedBox(height: 8.h),
        Text(
          'قم بتحويل قيمة الاشتراك عبر تطبيق InstaPay ثم أرفق صورة إيصال التحويل لإرسال طلب تفعيل الحساب.',
          style: DeskText.body(12.5.sp, color: DeskColors.muted).copyWith(height: 1.4),
        ),
        SizedBox(height: 16.h),

        // Selected plan summary tile
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F9FF),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: DeskColors.primary.withAlpha(120), width: 1.2),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: DeskColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.workspace_premium_rounded,
                    color: Colors.white, size: 18.r),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedPlanName,
                      style: DeskText.strong(13.5.sp, color: DeskColors.primary),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '$_selectedPlanAmount / $_selectedPlanPeriod',
                      style: DeskText.note(11.sp),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onChangePlan,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'تغيير',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    color: DeskColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 20.h),

        // 1. InstaPay Payment Details
        const FieldLabel(label: '1. تفاصيل الدفع عبر InstaPay*'),
        SizedBox(height: 8.h),
        InstaPayInfoCard(
          amount: _selectedPlanAmount,
          planName: _selectedPlanName,
        ),

        SizedBox(height: 22.h),

        // 2. Receipt Upload Section
        const FieldLabel(label: '2. إرفاق صورة إيصال التحويل (إجباري)*'),
        SizedBox(height: 8.h),
        ReceiptUploadBox(
          receiptFile: paymentReceiptFile,
          onPick: () => onPickImage(
            title: 'إرفاق صورة إيصال التحويل (InstaPay)',
            onImageSelected: onPaymentReceiptPicked,
          ),
          onRemove: () => onPaymentReceiptPicked(null),
        ),

        SizedBox(height: 24.h),
      ],
    );
  }
}
