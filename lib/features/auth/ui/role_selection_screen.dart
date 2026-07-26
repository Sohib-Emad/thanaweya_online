import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/router/app_router.dart';

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
        backgroundColor: const Color(0xFFF8FAFC), // Ultra clean soft background
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

                    // 1. Raw Logo Image (Simple & Pure)
                    Image.asset(
                      AppAssets.icon,
                      width: 80.r,
                      height: 80.r,
                      fit: BoxFit.contain,
                    ),

                    SizedBox(height: 16.h),

                    // App Title
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

                    // Clean Subtitle
                    Text(
                      'اختر نوع الحساب لبدء الاستخدام',
                      style: GoogleFonts.outfit(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const Spacer(flex: 2),

                    // 2. Student Role Card (with Reading book Lottie)
                    _SleekRoleCard(
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
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pushNamed(context, AppRouter.studentSubjects);
                      },
                    ),

                    SizedBox(height: 16.h),

                    // 3. Teacher Role Card (with Teacher Lottie)
                    _SleekRoleCard(
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
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pushNamed(context, AppRouter.teacherForm);
                      },
                    ),

                    const Spacer(flex: 3),

                    // 4. Already have an account row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'لديك حساب بالفعل؟ ',
                          style: GoogleFonts.outfit(
                            fontSize: 14.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.pushNamed(context, AppRouter.login);
                          },
                          child: Text(
                            'تسجيل الدخول',
                            style: GoogleFonts.outfit(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0FA37F),
                            ),
                          ),
                        ),
                      ],
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

class _SleekRoleCard extends StatefulWidget {
  final String title;
  final String badge;
  final String description;
  final String lottieAsset;
  final LinearGradient gradient;
  final Color accentColor;
  final Color bgColor;
  final VoidCallback onTap;

  const _SleekRoleCard({
    required this.title,
    required this.badge,
    required this.description,
    required this.lottieAsset,
    required this.gradient,
    required this.accentColor,
    required this.bgColor,
    required this.onTap,
  });

  @override
  State<_SleekRoleCard> createState() => _SleekRoleCardState();
}

class _SleekRoleCardState extends State<_SleekRoleCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: _isPressed
                ? widget.accentColor.withAlpha(150)
                : const Color(0xFFE2E8F0),
            width: _isPressed ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _isPressed
                  ? widget.accentColor.withAlpha(20)
                  : const Color(0x0A0F172A),
              blurRadius: _isPressed ? 16 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Lottie Icon Container
            Container(
              width: 64.r,
              height: 64.r,
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                color: widget.bgColor,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Lottie.asset(
                widget.lottieAsset,
                fit: BoxFit.contain,
                repeat: true,
                animate: true,
              ),
            ),

            SizedBox(width: 16.w),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.title,
                        style: GoogleFonts.outfit(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: widget.bgColor,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          widget.badge,
                          style: GoogleFonts.outfit(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w800,
                            color: widget.accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    widget.description,
                    style: GoogleFonts.outfit(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF64748B),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 8.w),

            // Minimal Chevron Arrow
            Icon(
              Icons.chevron_left_rounded,
              color: const Color(0xFF94A3B8),
              size: 22.r,
            ),
          ],
        ),
      ),
    );
  }
}
