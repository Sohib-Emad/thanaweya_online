import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 48.h),

                  // App Logo Header
                  Center(
                    child: Container(
                      width: 84.r,
                      height: 84.r,
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(22.r),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.cardShadow,
                            blurRadius: 18,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        AppAssets.logo,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  Text(
                    AppStrings.appName,
                    style: AppTextStyles.h1.copyWith(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 36.h),

                  Text(
                    AppStrings.login,
                    style: AppTextStyles.h2.copyWith(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'مرحباً بك مجدداً! أدخل بياناتك للمتابعة',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  AppTextField(
                    controller: _emailController,
                    labelText: AppStrings.email,
                    prefixIcon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                    validator: (v) =>
                        v == null || v.isEmpty ? AppStrings.fieldRequired : null,
                  ),
                  SizedBox(height: 16.h),

                  AppTextField(
                    controller: _passwordController,
                    labelText: AppStrings.password,
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: _obscurePassword,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                    validator: (v) =>
                        v == null || v.isEmpty ? AppStrings.fieldRequired : null,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20.r,
                        color: AppColors.textTertiary,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRouter.forgotPassword),
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

                  AppButton(
                    text: AppStrings.login,
                    isLoading: _isLoading,
                    icon: Icons.login_rounded,
                    onPressed: _onLogin,
                  ),
                  SizedBox(height: 28.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ليس لديك حساب؟ ',
                        style: AppTextStyles.body2
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, AppRouter.roleSelection),
                        child: Text(
                          AppStrings.register,
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.studentPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 48.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      setState(() => _isLoading = true);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() => _isLoading = false);
        Navigator.pushReplacementNamed(context, AppRouter.studentHome);
      });
    }
  }
}
