import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';

class TeacherRenewalControl extends StatelessWidget {
  final bool requiresRenewal;
  final ValueChanged<bool> onToggle;

  const TeacherRenewalControl({
    super.key,
    required this.requiresRenewal,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: requiresRenewal ? const Color(0xFFFEF3C7) : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                requiresRenewal ? Icons.warning_amber_rounded : Icons.notifications_off_outlined,
                color: requiresRenewal ? const Color(0xFFD97706) : AppColors.textTertiary,
                size: 20.r,
              ),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    requiresRenewal ? 'إنذار التجديد مفعل لدى المعلم ⚠️' : 'تنبيه انتهاء الاشتراك (طلب التجديد)',
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      color: requiresRenewal ? const Color(0xFF92400E) : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    requiresRenewal ? 'يظهر تنبيه ثابت للمعلم لتجديد باقته فوراً' : 'تفعيل هذا الخيار سيظهر إنذاراً ثابتاً للمعلم',
                    style: GoogleFonts.cairo(
                      fontSize: 10.5.sp,
                      color: requiresRenewal ? const Color(0xFFB45309) : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: requiresRenewal,
            activeThumbColor: const Color(0xFFD97706),
            onChanged: (val) {
              HapticFeedback.selectionClick();
              onToggle(val);
            },
          ),
        ],
      ),
    );
  }
}
