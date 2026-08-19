import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Action buttons row: WhatsApp send, report preview, and copy to clipboard.
class ReportActionBar extends StatelessWidget {
  const ReportActionBar({
    super.key,
    required this.onWhatsApp,
    required this.onPreview,
    required this.onCopy,
  });

  final VoidCallback onWhatsApp;
  final VoidCallback onPreview;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: onWhatsApp,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              elevation: 2,
            ),
            icon: Icon(Icons.send_rounded, size: 18.r),
            label: Text(
              'إرسال بالواتساب',
              style: GoogleFonts.cairo(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        IconButton(
          onPressed: onPreview,
          tooltip: 'معاينة كارت التقرير',
          style: IconButton.styleFrom(
            backgroundColor: DeskColors.primarySoft,
            padding: EdgeInsets.all(12.r),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
          icon: Icon(Icons.badge_rounded, color: DeskColors.primary, size: 22.r),
        ),
        SizedBox(width: 6.w),
        IconButton(
          onPressed: onCopy,
          tooltip: 'نسخ التقرير',
          style: IconButton.styleFrom(
            backgroundColor: DeskColors.surfaceAlt,
            padding: EdgeInsets.all(12.r),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
          icon: Icon(Icons.copy_rounded, color: DeskColors.ink, size: 20.r),
        ),
      ],
    );
  }
}
