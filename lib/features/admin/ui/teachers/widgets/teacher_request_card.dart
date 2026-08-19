import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thanaweya_online/features/shared/widgets/app_card.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import 'action_icon_button.dart';

/// Card widget displaying a single pending teacher request with full document inspection.
class TeacherRequestCard extends StatelessWidget {
  final String name;
  final String initials;
  final String subject;
  final String? phone;
  final String? plan;
  final num? amount;
  final String? receiptUrl;
  final String? idFrontUrl;
  final String? idBackUrl;
  final String? proofUrl;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const TeacherRequestCard({
    super.key,
    required this.name,
    required this.initials,
    required this.subject,
    this.phone,
    this.plan,
    this.amount,
    this.receiptUrl,
    this.idFrontUrl,
    this.idBackUrl,
    this.proofUrl,
    required this.onApprove,
    required this.onReject,
  });

  String get _planDisplayName => switch (plan) {
        'monthly' => 'باقة شهرية',
        'term' => 'باقة ترم',
        'annual' => 'باقة سنوية',
        _ => plan ?? 'غير محدد',
      };

  void _showDetailsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 14.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(name, style: AppTextStyles.h2),
                  if (phone != null && phone!.isNotEmpty)
                    Text(phone!, style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary)),
                ],
              ),
              SizedBox(height: 6.h),
              Text('المادة: ${subject.isNotEmpty ? subject : "عام"} | الباقة: $_planDisplayName ${amount != null ? "($amount ج.م)" : ""}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.adminPrimary, fontWeight: FontWeight.w700)),
              const Divider(height: 24),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (receiptUrl != null && receiptUrl!.isNotEmpty) ...[
                        Text('صورة إيصال التحويل (InstaPay):', style: AppTextStyles.h3),
                        SizedBox(height: 8.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.network(
                            receiptUrl!,
                            height: 220.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 120.h,
                              color: Colors.grey.shade100,
                              child: const Center(child: Text('تعذر تحميل صورة الإيصال')),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                      ],
                      if (idFrontUrl != null && idFrontUrl!.isNotEmpty) ...[
                        Text('بطاقة الرقم القومي (وجه):', style: AppTextStyles.h3),
                        SizedBox(height: 8.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.network(
                            idFrontUrl!,
                            height: 180.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                        SizedBox(height: 16.h),
                      ],
                      if (proofUrl != null && proofUrl!.isNotEmpty) ...[
                        Text('إثبات التدريس / الكارنيه:', style: AppTextStyles.h3),
                        SizedBox(height: 8.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.network(
                            proofUrl!,
                            height: 180.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                        SizedBox(height: 16.h),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onApprove();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      icon: const Icon(Icons.check_circle_rounded),
                      label: const Text('قبول وتفعيل الحساب', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onReject();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('رفض الطلب', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetailsModal(context),
      child: AppCard(
        child: Row(
          children: [
            CircleAvatar(
              radius: 22.r,
              backgroundColor: AppColors.warning.withAlpha(25),
              child: Text(
                initials,
                style: TextStyle(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: AppTextStyles.h3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (receiptUrl != null && receiptUrl!.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'تم الدفع 🧾',
                            style: TextStyle(fontSize: 10.sp, color: const Color(0xFF15803D), fontWeight: FontWeight.w700),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${subject.isNotEmpty ? subject : "مادة غير محددة"} • $_planDisplayName ${amount != null ? "($amount ج.م)" : ""}',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ActionIconButton(
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                  onTap: onApprove,
                ),
                SizedBox(width: 4.w),
                ActionIconButton(
                  icon: Icons.cancel_outlined,
                  color: AppColors.error,
                  onTap: onReject,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
