import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/core/utils/validators.dart';
import 'package:thanaweya_online/features/auth/data/repos/auth_repo.dart';
import 'package:thanaweya_online/features/auth/logic/auth_cubit.dart';
import 'package:thanaweya_online/features/auth/logic/auth_state.dart' as local;
import 'package:thanaweya_online/features/shared/widgets/app_button.dart';
import 'package:thanaweya_online/features/shared/widgets/app_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authCubit,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: Text(AppStrings.resetPassword)),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 40.h),
                    Center(
                      child: Container(
                        width: 72.r,
                        height: 72.r,
                        decoration: BoxDecoration(
                          color: AppColors.studentPrimaryLight,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Icon(
                          Icons.lock_reset_rounded,
                          size: 36.r,
                          color: AppColors.studentPrimary,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      AppStrings.forgotPassword,
                      style: AppTextStyles.h2,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'أدخل بريدك الإلكتروني وسنرسل لك رمز إعادة تعيين كلمة المرور',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40.h),
                    AppTextField(
                      controller: _emailController,
                      labelText: AppStrings.email,
                      prefixIcon: Icons.mail_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                      validator: Validators.email,
                    ),
                    SizedBox(height: 24.h),
                    BlocConsumer<AuthCubit, local.AuthState>(
                      listener: (context, state) {
                        switch (state.status) {
                          case local.AuthStatus.unauthenticated:
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'تم إرسال رمز إعادة التعيين إلى بريدك الإلكتروني'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                            Navigator.pop(context);
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
                          text: AppStrings.resetPassword,
                          isLoading: isLoading,
                          onPressed: isLoading ? null : _onSubmit,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      _authCubit.resetPassword(_emailController.text.trim());
    }
  }
}
