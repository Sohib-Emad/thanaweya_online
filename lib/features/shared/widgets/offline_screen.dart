import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import 'app_button.dart';

class OfflineScreen extends StatelessWidget {
  final VoidCallback? onRetry;

  const OfflineScreen({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96.r,
                height: 96.r,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(28.r),
                ),
                child: Icon(
                  Icons.wifi_off_rounded,
                  size: 44.r,
                  color: AppColors.textTertiary,
                ),
              ),
              SizedBox(height: 28.h),
              Text(
                AppStrings.offline,
                style: AppTextStyles.h1,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                AppStrings.offlineMessage,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              AppButton(
                text: AppStrings.retry,
                onPressed: onRetry,
                icon: Icons.refresh,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
