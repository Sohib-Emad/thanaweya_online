import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminForceUpdateDialog extends StatelessWidget {
  final String initialMessage;
  final String initialUrl;
  final void Function(String message, String url) onConfirm;

  const AdminForceUpdateDialog({
    super.key,
    required this.initialMessage,
    required this.initialUrl,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final msgCtrl = TextEditingController(text: initialMessage);
    final urlCtrl = TextEditingController(text: initialUrl);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            const Icon(Icons.system_update_rounded, color: Color(0xFF0284C7)),
            SizedBox(width: 8.w),
            Expanded(
              child: Text('تفعيل وضع التحديث الإجباري 🚀', style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 15.sp)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('عند تفعيل هذا الوضع، سيُلزم جميع المستخدمين بتحديث التطبيق ولن يتمكنوا من التخطي.',
                style: GoogleFonts.cairo(fontSize: 12.5.sp, color: const Color(0xFF475569))),
            SizedBox(height: 12.h),
            TextField(
              controller: msgCtrl,
              maxLines: 2,
              style: GoogleFonts.cairo(fontSize: 12.5.sp),
              decoration: InputDecoration(
                labelText: 'رسالة التحديث',
                labelStyle: GoogleFonts.cairo(fontSize: 12.sp),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
            ),
            SizedBox(height: 10.h),
            TextField(
              controller: urlCtrl,
              style: GoogleFonts.cairo(fontSize: 12.5.sp),
              decoration: InputDecoration(
                labelText: 'رابط التحديث / المتجر',
                labelStyle: GoogleFonts.cairo(fontSize: 12.sp),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء', style: GoogleFonts.cairo(color: const Color(0xFF64748B)))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm(msgCtrl.text.trim(), urlCtrl.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            child: Text('تفعيل التحديث الآن', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
