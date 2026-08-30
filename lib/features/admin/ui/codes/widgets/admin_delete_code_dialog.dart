import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';

void showConfirmDeleteCodeDialog({
  required BuildContext context,
  required String code,
  required VoidCallback onConfirm,
}) {
  HapticFeedback.mediumImpact();
  showDialog(
    context: context,
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            SizedBox(width: 8.w),
            Text('حذف كود التفعيل', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
          ],
        ),
        content: Text(
          'هل أنت متأكد من حذف الكود «$code»؟ لن يتمكن أي طالب من استخدامه بعد الحذف.',
          style: GoogleFonts.cairo(fontSize: 13.sp),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('حذف الكود'),
          ),
        ],
      ),
    ),
  );
}
