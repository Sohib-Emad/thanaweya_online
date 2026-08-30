import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

void showTeacherBanDialog({
  required BuildContext context,
  required String teacherName,
  required bool isCurrentlyBanned,
  required void Function(String? reason) onConfirm,
}) {
  final reasonController = TextEditingController();

  showDialog(
    context: context,
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
        title: Row(
          children: [
            Icon(
              isCurrentlyBanned ? Icons.check_circle_outline_rounded : Icons.block_rounded,
              color: isCurrentlyBanned ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
            ),
            SizedBox(width: 8.w),
            Text(
              isCurrentlyBanned ? 'فك حظر المعلم' : 'حظر حساب المعلم 🚫',
              style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 16.sp, color: const Color(0xFF0F172A)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isCurrentlyBanned
                  ? 'هل أنت متأكد من فك الحظر عن المعلم «$teacherName» وتمكينه من الدخول مجدداً؟'
                  : 'هل أنت متأكد من حظر حساب المعلم «$teacherName»؟ سيتم منعه من الدخول فوراً وستظهر له شاشة الحظر.',
              style: GoogleFonts.cairo(fontSize: 13.sp, height: 1.5),
            ),
            if (!isCurrentlyBanned) ...[
              SizedBox(height: 14.h),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  hintText: 'سبب الحظر (اختياري)...',
                  hintStyle: GoogleFonts.cairo(fontSize: 12.sp),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء', style: GoogleFonts.cairo(color: const Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              final r = reasonController.text.trim();
              onConfirm(r.isNotEmpty ? r : null);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isCurrentlyBanned ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            child: Text(isCurrentlyBanned ? 'تأكيد فك الحظر' : 'تأكيد الحظر', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    ),
  );
}
