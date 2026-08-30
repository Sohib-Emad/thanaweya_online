import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';

class StudentCardHeader extends StatelessWidget {
  final String name;
  final String grade;
  final int subsCount;

  const StudentCardHeader({
    super.key,
    required this.name,
    required this.grade,
    required this.subsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22.r,
          backgroundColor: AppColors.studentPrimaryLight,
          child: Text(name.isNotEmpty ? name[0] : 'ط', style: GoogleFonts.cairo(color: AppColors.studentPrimary, fontWeight: FontWeight.w900, fontSize: 16.sp)),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800, fontSize: 15.sp)),
              SizedBox(height: 2.h),
              Text(grade, style: GoogleFonts.cairo(fontSize: 11.5.sp, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(color: AppColors.adminPrimaryLight, borderRadius: BorderRadius.circular(8.r)),
          child: Text('$subsCount اشتراك', style: GoogleFonts.cairo(fontSize: 11.sp, color: AppColors.adminPrimary, fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }
}
