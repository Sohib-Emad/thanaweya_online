import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';

class PushTokensActionButtons extends StatelessWidget {
  final VoidCallback onSendInstant;
  final VoidCallback onCopyAll;

  const PushTokensActionButtons({
    super.key,
    required this.onSendInstant,
    required this.onCopyAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onSendInstant,
            icon: Icon(Icons.campaign_rounded, size: 18.r),
            label: Text('إرسال إشعار فوري', style: GoogleFonts.cairo(fontSize: 13.sp, fontWeight: FontWeight.w800)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.adminPrimary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              elevation: 0,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onCopyAll,
            icon: Icon(Icons.copy_all_rounded, size: 18.r),
            label: Text('نسخ كل التوكنز', style: GoogleFonts.cairo(fontSize: 13.sp, fontWeight: FontWeight.w800)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2563EB),
              backgroundColor: const Color(0xFFEFF6FF),
              side: const BorderSide(color: Color(0xFFBFDBFE)),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
          ),
        ),
      ],
    );
  }
}
