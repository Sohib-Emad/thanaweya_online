import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_students_repo.dart';

void showStudentGiftPointsDialog({
  required BuildContext context,
  required Map<String, dynamic> student,
}) {
  final studentId = student['student_id'] as String? ?? student['id'] as String? ?? '';
  final user = student['users'] as Map<String, dynamic>? ?? {};
  final studentName = user['full_name'] as String? ?? 'الطالب';
  final pointsController = TextEditingController(text: '50');
  final reasonController = TextEditingController(text: 'مكافأة تفوق واجتهاد 🌟');
  bool isSubmitting = false;

  showDialog(
    context: context,
    builder: (dialogCtx) => StatefulBuilder(
      builder: (context, setDialogState) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Row(children: [
            const Icon(Icons.card_giftcard_rounded, color: Color(0xFFD97706)),
            SizedBox(width: 8.w),
            Text('منح نقاط مكافأة', style: GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.w800)),
          ]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الطالب: $studentName', style: GoogleFonts.cairo(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
              SizedBox(height: 14.h),
              Text('عدد النقاط الممنوحة:', style: AppTextStyles.caption),
              SizedBox(height: 6.h),
              TextField(
                controller: pointsController, keyboardType: TextInputType.number,
                decoration: InputDecoration(prefixIcon: const Icon(Icons.stars_rounded, color: Color(0xFFD97706)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)), contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h)),
              ),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 6.w,
                children: [20, 50, 100, 200].map((p) => ActionChip(label: Text('+$p'), onPressed: () => setDialogState(() => pointsController.text = '$p'))).toList(),
              ),
              SizedBox(height: 14.h),
              Text('سبب أو مناسبة المكافأة:', style: AppTextStyles.caption),
              SizedBox(height: 6.h),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(hintText: 'مثال: حل واجب ممتاز...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)), contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h)),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: isSubmitting ? null : () async {
                final pts = int.tryParse(pointsController.text.trim()) ?? 0;
                if (pts <= 0) return;
                setDialogState(() => isSubmitting = true);
                final res = await AdminStudentsRepo().grantStudentBonusPoints(studentId: studentId, points: pts, reason: reasonController.text.trim());
                if (!context.mounted) return;
                Navigator.pop(dialogCtx);
                res.when(
                  success: (_) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم منح $pts نقطة للطالب $studentName بنجاح 🎉'), backgroundColor: const Color(0xFF059669))),
                  failure: (err, _) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل: $err'), backgroundColor: AppColors.error)),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706), foregroundColor: Colors.white),
              child: isSubmitting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('منح النقاط الآن'),
            ),
          ],
        ),
      ),
    ),
  );
}
