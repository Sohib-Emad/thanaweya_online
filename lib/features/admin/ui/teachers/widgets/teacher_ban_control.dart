import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';

class TeacherBanControl extends StatelessWidget {
  final bool isBanned;
  final VoidCallback onToggleBan;

  const TeacherBanControl({
    super.key,
    required this.isBanned,
    required this.onToggleBan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isBanned ? const Color(0xFFFEF2F2) : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10.r),
        border: isBanned ? Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.5)) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isBanned ? Icons.block_rounded : Icons.check_circle_outline_rounded,
                color: isBanned ? const Color(0xFFDC2626) : AppColors.textTertiary,
                size: 20.r,
              ),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBanned ? 'الحساب محظور حالياً 🚫' : 'حالة الحساب طبيعية',
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      color: isBanned ? const Color(0xFF991B1B) : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    isBanned ? 'يتم منع المعلم من الدخول للتطبيق فوراً' : 'حظر المعلم لمنعه من استخدام التطبيق',
                    style: GoogleFonts.cairo(
                      fontSize: 10.5.sp,
                      color: isBanned ? const Color(0xFFB91C1C) : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: onToggleBan,
            style: ElevatedButton.styleFrom(
              backgroundColor: isBanned ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              elevation: 0,
            ),
            child: Text(
              isBanned ? 'فك الحظر' : 'حظر الحساب',
              style: GoogleFonts.cairo(fontSize: 11.sp, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
