import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/features/shared/widgets/app_text_field.dart';



/// Email, password fields and forgot-password link.
class LoginFormFields extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final ValueChanged<bool> onToggleObscure;
  final VoidCallback onForgotPassword;

  const LoginFormFields({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppTextField(
          controller: emailController,
          labelText: 'البريد الإلكتروني أو اسم المستخدم',
          prefixIcon: Icons.person_outline_rounded,
          keyboardType: TextInputType.text,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          validator: (v) =>
              v == null || v.isEmpty ? AppStrings.fieldRequired : null,
        ),
        SizedBox(height: 16.h),
        AppTextField(
          controller: passwordController,
          labelText: AppStrings.password,
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: obscurePassword,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          validator: (v) =>
              v == null || v.isEmpty ? AppStrings.fieldRequired : null,
          suffixIcon: IconButton(
            icon: Icon(
              obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 20.r,
              color: AppColors.textTertiary,
            ),
            onPressed: () => onToggleObscure(!obscurePassword),
          ),
        ),
        SizedBox(height: 8.h),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: onForgotPassword,
            child: Text(
              AppStrings.forgotPassword,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.studentPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }
}
