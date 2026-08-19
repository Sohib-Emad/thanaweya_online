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
import 'widgets/otp_widgets.dart';

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
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
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
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
                  OtpIconHeader(email: widget.email),
                  OtpPinRow(controllers: _controllers, focusNodes: _focusNodes),
                  SizedBox(height: 32.h),
                  BlocConsumer<AuthCubit, local.AuthState>(
                    listener: _onAuthChanged,
                    builder: (context, state) {
                      final isLoading = state.status == local.AuthStatus.loading;
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
                      style: AppTextStyles.body2.copyWith(color: AppColors.studentPrimary),
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
      _authCubit.verifyOtp(email: widget.email, token: otp);
    }
  }

  void _onResend() {
    _authCubit.resetPassword(widget.email);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إعادة إرسال الرمز'), backgroundColor: AppColors.success),
    );
  }

  void _onAuthChanged(BuildContext context, local.AuthState state) {
    switch (state.status) {
      case local.AuthStatus.authenticated:
        final user = _authCubit.authRepo.getCurrentUserModel();
        if (user != null) {
          Navigator.pushReplacementNamed(context, AppRouter.homeForRole(user.role));
        }
        break;
      case local.AuthStatus.error:
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!), backgroundColor: AppColors.error),
          );
        }
        break;
      default:
        break;
    }
  }
}
