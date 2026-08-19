import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../shared/models/user_model.dart';
import '../../teacher/data/repos/teacher_profile_repo.dart';
import '../data/repos/auth_repo.dart';
import '../logic/auth_cubit.dart';
import '../logic/auth_state.dart' as local;
import '../../shared/widgets/app_button.dart';
import 'widgets/widgets.dart';

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
                    const LoginFormHeader(),
                    LoginFormFields(
                      emailController: _emailController,
                      passwordController: _passwordController,
                      obscurePassword: _obscurePassword,
                      onToggleObscure: (v) => setState(() => _obscurePassword = v),
                      onForgotPassword: () => Navigator.pushNamed(context, AppRouter.forgotPassword),
                    ),
                    BlocConsumer<AuthCubit, local.AuthState>(
                      listener: _onAuthChanged,
                      builder: (context, state) {
                        final isLoading = state.status == local.AuthStatus.loading;
                        return AppButton(
                          text: 'تسجيل الدخول',
                          isLoading: isLoading,
                          icon: Icons.login_rounded,
                          onPressed: isLoading ? null : _onLogin,
                        );
                      },
                    ),
                    SizedBox(height: 28.h),
                    LoginFooter(
                      onRegister: () => Navigator.pushNamed(context, AppRouter.roleSelection),
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
      final input = _emailController.text.trim();
      final email = input.contains('@')
          ? input
          : (input.toLowerCase() == 'sohib'
              ? 'sohib@admin.com'
              : '$input@thanaweya.com');
      _authCubit.signIn(
        email: email,
        password: _passwordController.text,
      );
    }
  }

  void _onAuthChanged(BuildContext context, local.AuthState state) async {
    switch (state.status) {
      case local.AuthStatus.authenticated:
        final user = _authCubit.authRepo.getCurrentUserModel();
        if (user == null) return;
        if (user.role == UserRole.teacher) {
          final result = await TeacherProfileRepo().getApprovalStatus(user.id);
          final approved = result.when(
            success: (status) => status == 'approved',
            failure: (_, _) => false,
          );
          if (!context.mounted) return;
          Navigator.pushReplacementNamed(context, approved ? AppRouter.teacherHome : AppRouter.teacherPending);
        } else {
          Navigator.pushReplacementNamed(context, AppRouter.homeForRole(user.role));
        }
        break;
      case local.AuthStatus.error:
        if (state.errorMessage != null && context.mounted) {
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
