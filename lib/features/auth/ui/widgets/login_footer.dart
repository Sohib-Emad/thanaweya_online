import 'package:flutter/material.dart';
import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';



/// "Don't have an account? Register" row.
class LoginFooter extends StatelessWidget {
  final VoidCallback onRegister;

  const LoginFooter({super.key, required this.onRegister});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'ليس لديك حساب؟ ',
          style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
        ),
        GestureDetector(
          onTap: onRegister,
          child: Text(
            AppStrings.register,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.studentPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
