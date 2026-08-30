import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import 'teacher_document_preview.dart';

class TeacherRequestDetailsSheet extends StatelessWidget {
  final String name, subject, planDisplayName;
  final String? phone, receiptUrl, idFrontUrl, idBackUrl, proofUrl;
  final num? amount;
  final VoidCallback onApprove, onReject;

  const TeacherRequestDetailsSheet({
    super.key,
    required this.name,
    this.phone,
    required this.subject,
    required this.planDisplayName,
    this.amount,
    this.receiptUrl,
    this.idFrontUrl,
    this.idBackUrl,
    this.proofUrl,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40.w, height: 4.h, margin: EdgeInsets.only(bottom: 14.h), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2.r)))),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name, style: AppTextStyles.h2),
                if (phone?.isNotEmpty == true) Text(phone!, style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary)),
              ],
            ),
            SizedBox(height: 6.h),
            Text('المادة: ${subject.isNotEmpty ? subject : "عام"} | الباقة: $planDisplayName ${amount != null ? "($amount ج.م)" : ""}',
                style: AppTextStyles.caption.copyWith(color: AppColors.adminPrimary, fontWeight: FontWeight.w700)),
            const Divider(height: 24),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (receiptUrl?.isNotEmpty == true) TeacherDocumentPreview(title: 'صورة إيصال التحويل (InstaPay):', imageUrl: receiptUrl!, height: 220),
                    if (idFrontUrl?.isNotEmpty == true) TeacherDocumentPreview(title: 'بطاقة الرقم القومي (وجه):', imageUrl: idFrontUrl!),
                    if (idBackUrl?.isNotEmpty == true) TeacherDocumentPreview(title: 'بطاقة الرقم القومي (ظهر):', imageUrl: idBackUrl!),
                    if (proofUrl?.isNotEmpty == true) TeacherDocumentPreview(title: 'إثبات التدريس / الكارنيه:', imageUrl: proofUrl!),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () { Navigator.pop(context); onApprove(); },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: 12.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                    icon: const Icon(Icons.check_circle_rounded),
                    label: const Text('قبول وتفعيل الحساب', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () { Navigator.pop(context); onReject(); },
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error), padding: EdgeInsets.symmetric(vertical: 12.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('رفض الطلب', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
