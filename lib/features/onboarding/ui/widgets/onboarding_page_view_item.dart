import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';

import 'onboarding_lottie_data.dart';

/// Single onboarding page content with Lottie animation, title and description.
class OnboardingPageViewItem extends StatelessWidget {
  final OnboardingLottieData item;

  const OnboardingPageViewItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: item.height,
            width: double.infinity,
            child: OverflowBox(
              maxHeight: item.height * item.scale,
              maxWidth: 360.w * item.scale,
              child: Transform.scale(
                scale: item.scale,
                child: Lottie.asset(
                  item.lottieAsset,
                  fit: BoxFit.contain,
                  repeat: true,
                  animate: true,
                ),
              ),
            ),
          ),
          SizedBox(height: 28.h),
          Text(
            item.title,
            style: AppTextStyles.h1.copyWith(
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              item.description,
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14.sp,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
