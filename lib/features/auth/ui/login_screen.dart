import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../data/repos/auth_repo.dart';
import '../logic/auth_cubit.dart';
import '../logic/auth_state.dart' as local;
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
  late final AuthCubit _authCubit;

  @override
  void initState() {
    super.initState();
    _authCubit = AuthCubit(authRepo: AuthRepo());
  }

  @override
  void dispose() {
    _authCubit.close();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authCubit,
      child: Directionality(
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
                      validator: (v) => v == null || v.isEmpty
                          ? AppStrings.fieldRequired
                          : null,
                    ),
                    SizedBox(height: 16.h),

                    AppTextField(
                      controller: _passwordController,
                      labelText: AppStrings.password,
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                      validator: (v) => v == null || v.isEmpty
                          ? AppStrings.fieldRequired
                          : null,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20.r,
                          color: AppColors.textTertiary,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRouter.forgotPassword,
                        ),
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

                    BlocConsumer<AuthCubit, local.AuthState>(
                      listener: (context, state) {
                        switch (state.status) {
                          case local.AuthStatus.authenticated:
                            final user = _authCubit.authRepo
                                .getCurrentUserModel();
                            if (user != null) {
                              Navigator.pushReplacementNamed(
                                context,
                                AppRouter.homeForRole(user.role),
                              );
                            }
                            break;
                          case local.AuthStatus.error:
                            if (state.errorMessage != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(state.errorMessage!),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                            break;
                          default:
                            break;
                        }
                      },
                      builder: (context, state) {
                        final isLoading =
                            state.status == local.AuthStatus.loading;
                        return AppButton(
                          text: AppStrings.login,
                          isLoading: isLoading,
                          icon: Icons.login_rounded,
                          onPressed: isLoading ? null : _onLogin,
                        );
                      },
                    ),
                    SizedBox(height: 28.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ليس لديك حساب؟ ',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRouter.roleSelection,
                          ),
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
      ),
    );
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      _authCubit.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }
}
