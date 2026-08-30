import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminMaintenanceDialog extends StatelessWidget {
  final String initialMessage;
  final ValueChanged<String> onConfirm;

  const AdminMaintenanceDialog({
    super.key,
    required this.initialMessage,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final msgCtrl = TextEditingController(text: initialMessage);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            const Icon(Icons.build_circle_rounded, color: Color(0xFFF59E0B)),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'تفعيل وضع الصيانة والإصلاح 🛠️',
                style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 15.sp),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'عند تفعيل هذا الوضع، سيتم إغلاق التطبيق في وجه كافة المستخدمين وتوجيههم لشاشة الصيانة.',
              style: GoogleFonts.cairo(fontSize: 12.5.sp, color: const Color(0xFF475569)),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: msgCtrl,
              maxLines: 3,
              style: GoogleFonts.cairo(fontSize: 12.5.sp),
              decoration: InputDecoration(
                labelText: 'رسالة الصيانة للمستخدمين',
                labelStyle: GoogleFonts.cairo(fontSize: 12.sp),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: GoogleFonts.cairo(color: const Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm(msgCtrl.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            child: Text('تفعيل الصيانة الآن', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
