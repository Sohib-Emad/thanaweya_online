import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';


/// OTP screen icon, instructions and email display.
class OtpIconHeader extends StatelessWidget {
  final String email;

  const OtpIconHeader({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 48.h),
        Container(
          width: 72.r,
          height: 72.r,
          decoration: BoxDecoration(
            color: AppColors.studentPrimaryLight,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Icon(
            Icons.pin_outlined,
            size: 36.r,
            color: AppColors.studentPrimary,
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          AppStrings.enterOtp,
          style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        if (email.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Text(
            email,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.studentPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        SizedBox(height: 36.h),
      ],
    );
  }
}
