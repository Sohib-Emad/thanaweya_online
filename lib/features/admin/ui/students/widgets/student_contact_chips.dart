import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';

class StudentContactChips extends StatelessWidget {
  final String phone;
  final String parentPhone;
  final String email;

  const StudentContactChips({
    super.key,
    required this.phone,
    required this.parentPhone,
    required this.email,
  });

  void _copy(BuildContext context, String text, String label) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم نسخ $label: $text'), duration: const Duration(seconds: 2), backgroundColor: AppColors.textPrimary),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12.w,
      runSpacing: 6.h,
      children: [
        if (phone.isNotEmpty)
          InkWell(
            onTap: () => _copy(context, phone, 'هاتف الطالب'),
            borderRadius: BorderRadius.circular(6.r),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.phone_android_rounded, size: 14.r, color: AppColors.textTertiary),
                SizedBox(width: 4.w),
                Text(phone, style: GoogleFonts.cairo(fontSize: 11.5.sp, fontWeight: FontWeight.w600)),
                SizedBox(width: 2.w),
                Icon(Icons.copy_rounded, size: 11.r, color: AppColors.textTertiary),
              ],
            ),
          ),
        if (parentPhone.isNotEmpty)
          InkWell(
            onTap: () => _copy(context, parentPhone, 'هاتف ولي الأمر'),
            borderRadius: BorderRadius.circular(6.r),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.family_restroom_rounded, size: 14, color: Color(0xFFD97706)),
                SizedBox(width: 4.w),
                Text('ولي الأمر: $parentPhone', style: GoogleFonts.cairo(fontSize: 11.5.sp, fontWeight: FontWeight.w600, color: const Color(0xFF92400E))),
                SizedBox(width: 2.w),
                const Icon(Icons.copy_rounded, size: 11, color: Color(0xFFD97706)),
              ],
            ),
          ),
        if (email.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.email_outlined, size: 14.r, color: AppColors.textTertiary),
              SizedBox(width: 4.w),
              Text(email, style: GoogleFonts.cairo(fontSize: 11.sp, color: AppColors.textSecondary)),
            ],
          ),
      ],
    );
  }
}
