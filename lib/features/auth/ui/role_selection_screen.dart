import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/router/app_router.dart';
import 'widgets/role_selection_widgets.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 40.h),
                    const _RoleSelectionHeader(),
                    const Spacer(flex: 2),
                    SleekRoleCard(
                      title: 'أنا طالب',
                      badge: 'الطلاب',
                      description:
                          'احصل على الكورسات، حل الامتحانات، وتابع تقدمك.',
                      lottieAsset: 'assets/json/Reading book.json',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0FA37F), Color(0xFF059669)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      accentColor: const Color(0xFF0FA37F),
                      bgColor: const Color(0xFFECFDF5),
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRouter.studentSubjects,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    SleekRoleCard(
                      title: 'أنا معلم',
                      badge: 'المعلمون',
                      description:
                          'أنشئ الكورسات، ارفع الحصص، وأدر طلابك واختباراتك.',
                      lottieAsset: 'assets/json/Teacher.json',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      accentColor: const Color(0xFF2563EB),
                      bgColor: const Color(0xFFEFF6FF),
                      onTap: () =>
                          Navigator.pushNamed(context, AppRouter.teacherForm),
                    ),
                    const Spacer(flex: 3),
                    RoleSelectionLoginFooter(
                      onLogin: () =>
                          Navigator.pushNamed(context, AppRouter.login),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleSelectionHeader extends StatelessWidget {
  const _RoleSelectionHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/icons/icon_Thanaweya_Online.png',
          width: 80.r,
          height: 80.r,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 16.h),
        Text(
          'ثانوية أونلاين',
          style: GoogleFonts.outfit(
            fontSize: 26.sp,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'اختر نوع الحساب لبدء الاستخدام',
          style: GoogleFonts.outfit(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
