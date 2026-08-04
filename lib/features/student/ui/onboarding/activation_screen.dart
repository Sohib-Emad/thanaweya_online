import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/features/shared/widgets/app_button.dart';
import 'package:thanaweya_online/features/shared/widgets/app_text_field.dart';
import 'package:thanaweya_online/features/student/data/repos/student_onboarding_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_onboarding_cubit.dart';

class ActivationScreen extends StatefulWidget {
  const ActivationScreen({super.key});

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final _codeController = TextEditingController();
  late final StudentOnboardingCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = StudentOnboardingCubit(repo: StudentOnboardingRepo());
  }

  @override
  void dispose() {
    _cubit.close();
    _codeController.dispose();
    super.dispose();
  }

  void _activate() {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'الرجاء إدخال كود التفعيل',
            style: AppTextStyles.body2.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يجب تسجيل الدخول أولاً',
            style: AppTextStyles.body2.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    _cubit.activateSubscription(
      studentId: userId,
      activationCode: code,
    );
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
                BlocConsumer<StudentOnboardingCubit, StudentOnboardingState>(
                  bloc: _cubit,
                  listener: (context, state) {
                    if (state.activationStatus ==
                        StudentOnboardingStatus.loaded) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRouter.studentHome,
                        (route) => false,
                      );
                    } else if (state.activationStatus ==
                        StudentOnboardingStatus.error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            state.activationError ?? 'فشل التفعيل، حاول مرة أخرى',
                            style: AppTextStyles.body2.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    final isLoading =
                        state.activationStatus == StudentOnboardingStatus.loading;
                    return AppButton(
                      text: isLoading ? 'جاري التفعيل...' : AppStrings.activate,
                      onPressed: isLoading ? null : _activate,
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
