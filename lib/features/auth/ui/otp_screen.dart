import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/features/auth/data/repos/auth_repo.dart';
import 'package:thanaweya_online/features/auth/logic/auth_cubit.dart';
import 'package:thanaweya_online/features/auth/logic/auth_state.dart' as local;
import 'package:thanaweya_online/features/shared/widgets/app_button.dart';

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  late final AuthCubit _authCubit;

  @override
  void initState() {
    super.initState();
    _authCubit = AuthCubit(authRepo: AuthRepo());
  }

  @override
  void dispose() {
    _authCubit.close();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authCubit,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: Text(AppStrings.otpVerification)),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
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
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (widget.email.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Text(
                      widget.email,
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.studentPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  SizedBox(height: 36.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      return Container(
                        width: 48.w,
                        height: 52.h,
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        child: TextFormField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: AppTextStyles.h2,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            counterText: '',
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty && index < 5) {
                              _focusNodes[index + 1].requestFocus();
                            } else if (value.isEmpty && index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }
                          },
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 32.h),
                    BlocConsumer<AuthCubit, local.AuthState>(
                      listener: (context, state) {
                        switch (state.status) {
                          case local.AuthStatus.authenticated:
                            final user = _authCubit.authRepo.getCurrentUserModel();
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
                        text: AppStrings.verify,
                        isLoading: isLoading,
                        onPressed: isLoading ? null : _onVerify,
                      );
                    },
                  ),
                  SizedBox(height: 16.h),
                  TextButton(
                    onPressed: _onResend,
                    child: Text(
                      AppStrings.resendCode,
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.studentPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onVerify() {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length == 6) {
      HapticFeedback.lightImpact();
      _authCubit.verifyOtp(
            email: widget.email,
            token: otp,
          );
    }
  }

  void _onResend() {
    _authCubit.resetPassword(widget.email);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إعادة إرسال الرمز'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
