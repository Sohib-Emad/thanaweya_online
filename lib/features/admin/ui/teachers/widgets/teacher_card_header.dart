import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';

class TeacherCardHeader extends StatelessWidget {
  final String name;
  final String initials;
  final String subjectName;
  final String plan;
  final Color statusColor;
  final String statusText;

  const TeacherCardHeader({
    super.key,
    required this.name,
    required this.initials,
    required this.subjectName,
    required this.plan,
    required this.statusColor,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24.r,
          backgroundColor: AppColors.adminPrimaryLight,
          child: Text(initials, style: GoogleFonts.cairo(color: AppColors.adminPrimary, fontWeight: FontWeight.w900, fontSize: 16.sp)),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800)),
              SizedBox(height: 2.h),
              Text('$subjectName • $plan', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8.r)),
          child: Text(statusText, style: TextStyle(fontSize: 11.sp, color: statusColor, fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }
}
