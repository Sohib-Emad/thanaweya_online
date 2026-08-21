import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/services/app_system_config_repo.dart';

/// Full-screen unbypassable teacher ban screen.
class TeacherBannedScreen extends StatelessWidget {
  final String? banReason;

  const TeacherBannedScreen({super.key, this.banReason});

  Future<void> _contactSupport(BuildContext context) async {
    HapticFeedback.mediumImpact();
    final phone = AppSystemConfigRepo().cachedConfig.supportPhone;
    final url = 'https://wa.me/$phone?text=${Uri.encodeComponent('مرحباً، أود الاستفسار بخصوص حظر حساب المعلم الخاص بي في تطبيق ثانوية أونلاين.')}';
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تعذر فتح تطبيق واتساب'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching support WhatsApp: $e');
    }
  }

  Future<void> _logout(BuildContext context) async {
    HapticFeedback.mediumImpact();
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {}
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.login,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reason = banReason ??
        'تم تعطيل أو حظر حسابك لمخالفة شروط الاستخدام أو سياسات منصة ثانوية أونلاين.';

    return PopScope(
      canPop: false, // Strict blocker
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          body: Stack(
            children: [
              // Ambient red glow
              Positioned(
                top: -100.h,
                right: -100.w,
                child: Container(
                  width: 320.r,
                  height: 320.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFDC2626).withValues(alpha: 0.18),
                  ),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),

                      // Blocked Avatar / Shield Icon
                      Container(
                        width: 110.r,
                        height: 110.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1E293B),
                          border: Border.all(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFDC2626).withValues(alpha: 0.25),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.block_rounded,
                          size: 58,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                      SizedBox(height: 28.h),

                      Text(
                        'تم حظر حسابك 🚫',
                        style: GoogleFonts.cairo(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12.h),

                      Text(
                        reason,
                        style: GoogleFonts.cairo(
                          fontSize: 13.5.sp,
                          height: 1.6,
                          color: const Color(0xFF94A3B8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20.h),

                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 18,
                              color: Color(0xFFEF4444),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                'إذا كنت تعتقد أن هذا الإجراء تم عن طريق الخطأ، يرجى التواصل مع إدارة التطبيق فوراً.',
                                style: GoogleFonts.cairo(
                                  fontSize: 11.5.sp,
                                  color: const Color(0xFFCBD5E1),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // WhatsApp Support Button
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton.icon(
                          onPressed: () => _contactSupport(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16A34A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.chat_bubble_outline_rounded,
                              size: 20),
                          label: Text(
                            'تواصل مع الدعم الفني والإدارة',
                            style: GoogleFonts.cairo(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: OutlinedButton.icon(
                          onPressed: () => _logout(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF94A3B8),
                            side: const BorderSide(color: Color(0xFF334155)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          icon: const Icon(Icons.logout_rounded, size: 18),
                          label: Text(
                            'تسجيل الخروج من الحساب',
                            style: GoogleFonts.cairo(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
