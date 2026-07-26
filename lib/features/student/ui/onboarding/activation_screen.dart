import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/features/shared/widgets/app_button.dart';
import 'package:thanaweya_online/features/shared/widgets/app_text_field.dart';

class ActivationScreen extends StatefulWidget {
  const ActivationScreen({super.key});

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(AppStrings.activationCode)),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 40.h),
                Container(
                  width: 80.r,
                  height: 80.r,
                  decoration: BoxDecoration(
                    color: AppColors.studentPrimaryLight,
                    borderRadius: BorderRadius.circular(22.r),
                  ),
                  child: Icon(
                    Icons.vpn_key_outlined,
                    size: 36.r,
                    color: AppColors.studentPrimary,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  AppStrings.enterActivationCode,
                  style: AppTextStyles.h2,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'أدخل الكود الذي حصلت عليه من المعلم',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h),
                AppTextField(
                  controller: _codeController,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                  style: AppTextStyles.h2.copyWith(letterSpacing: 4),
                  hintText: 'XXXX-XXXX-XXXX',
                ),
                SizedBox(height: 32.h),
                AppButton(
                  text: AppStrings.activate,
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRouter.studentHome,
                      (route) => false,
                    );
                  },
                ),
                SizedBox(height: 12.h),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRouter.studentHome,
                      (route) => false,
                    );
                  },
                  child: Text(
                    'تخطي',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
