import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thanaweya_online/features/shared/widgets/app_card.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import 'action_icon_button.dart';
import 'teacher_request_details_sheet.dart';

class TeacherRequestCard extends StatelessWidget {
  final String name, initials, subject;
  final String? phone, plan, receiptUrl, idFrontUrl, idBackUrl, proofUrl;
  final num? amount;
  final VoidCallback onApprove, onReject;

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => TeacherRequestDetailsSheet(
          name: name, phone: phone, subject: subject, planDisplayName: _planDisplayName,
          amount: amount, receiptUrl: receiptUrl, idFrontUrl: idFrontUrl, idBackUrl: idBackUrl,
          proofUrl: proofUrl, onApprove: onApprove, onReject: onReject,
        ),
      ),
      child: AppCard(
        child: Row(
          children: [
            CircleAvatar(
              radius: 22.r,
              backgroundColor: AppColors.warning.withAlpha(25),
              child: Text(initials, style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600)),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(name, style: AppTextStyles.h3, overflow: TextOverflow.ellipsis)),
                      if (receiptUrl?.isNotEmpty == true)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(6.r)),
                          child: Text('تم الدفع 🧾', style: TextStyle(fontSize: 10.sp, color: const Color(0xFF15803D), fontWeight: FontWeight.w700)),
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
                ActionIconButton(icon: Icons.check_circle_outline, color: AppColors.success, onTap: onApprove),
                SizedBox(width: 4.w),
                ActionIconButton(icon: Icons.cancel_outlined, color: AppColors.error, onTap: onReject),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
