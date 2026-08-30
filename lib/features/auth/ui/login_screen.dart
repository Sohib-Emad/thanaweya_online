import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final _authCubit = AuthCubit(authRepo: AuthRepo());
  bool _obscurePassword = true;
  bool _isLoading = false;

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
      child: BlocListener<AuthCubit, local.AuthState>(
        listener: _onAuthChanged,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 40.h),
                    const LoginFormHeader(),
                    SizedBox(height: 32.h),
                    Form(
                      key: _formKey,
                      child: LoginFormFields(
                        emailController: _emailController,
                        passwordController: _passwordController,
                        obscurePassword: _obscurePassword,
                        onToggleObscure: (v) => setState(() => _obscurePassword = v),
                        onForgotPassword: () => Navigator.pushNamed(context, AppRouter.forgotPassword),
                      ),
                    ),
                    BlocBuilder<AuthCubit, local.AuthState>(
                      builder: (context, state) {
                        return AppButton(
                          text: 'تسجيل الدخول',
                          isLoading: _isLoading || state.status == local.AuthStatus.loading,
                          icon: Icons.login_rounded,
                          onPressed: (_isLoading || state.status == local.AuthStatus.loading) ? null : _onLogin,
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

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();

    final input = _emailController.text.trim().toLowerCase();
    final isSohib = input == 'sohib' || input == 'sohib@admin.com';
    final email = input.contains('@')
        ? input
        : (isSohib ? 'sohib@admin.com' : '$input@thanaweya.com');
    final password = _passwordController.text.trim();

    // Special auto-provisioning for super admin sohib
    if (isSohib && password == 'sohib2025') {
      setState(() => _isLoading = true);
      try {
        final res = await _authCubit.authRepo.signIn(email: email, password: password);
        final bool loggedIn = await res.when(
          success: (user) async {
            try {
              await Supabase.instance.client
                  .from('users')
                  .update({'role': 'super_admin'})
                  .eq('id', user.id);
            } catch (_) {}
            return true;
          },
          failure: (_, __) => false,
        );

        if (loggedIn) {
          if (mounted) {
            setState(() => _isLoading = false);
            Navigator.pushReplacementNamed(context, AppRouter.adminDashboard);
          }
          return;
        }
      } catch (_) {}

      // Fallback: create fresh cleanly via Supabase Auth API
      try {
        final signUpRes = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
          data: {
            'full_name': 'صهيب عماد',
            'role': 'super_admin',
            'phone': '01096462825',
            'username': 'sohib',
          },
        );
        if (signUpRes.user != null) {
          final uid = signUpRes.user!.id;
          try {
            await Supabase.instance.client.from('users').upsert({
              'id': uid,
              'email': email,
              'full_name': 'صهيب عماد',
              'phone': '01096462825',
              'role': 'super_admin',
            });
          } catch (_) {}
          if (mounted) {
            setState(() => _isLoading = false);
            Navigator.pushReplacementNamed(context, AppRouter.adminDashboard);
          }
          return;
        }
      } catch (e) {
        debugPrint('[Admin Provisioning] error: $e');
      }
      if (mounted) setState(() => _isLoading = false);
    }

    _authCubit.signIn(
      email: email,
      password: password,
    );
  }

  void _onAuthChanged(BuildContext context, local.AuthState state) async {
    switch (state.status) {
      case local.AuthStatus.authenticated:
        final user = state.user ?? _authCubit.authRepo.getCurrentUserModel();
        if (user == null) return;
        debugPrint('[LoginScreen] Authenticated as role=${user.role.name}');
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
