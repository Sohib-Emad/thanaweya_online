import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thanaweya_online/core/constants/app_colors.dart';


/// Animated pill-style dot indicator for onboarding pages.
class OnboardingDotIndicator extends StatelessWidget {
  final int itemCount;
  final int currentPage;
  final Color activeColor;

  const OnboardingDotIndicator({
    super.key,
    required this.itemCount,
    required this.currentPage,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        itemCount,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: currentPage == index ? 28.w : 8.w,
          height: 8.h,
          decoration: BoxDecoration(
            color: currentPage == index ? activeColor : AppColors.divider,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      ),
    );
  }
}
