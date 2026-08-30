import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:thanaweya_online/core/services/app_system_config_repo.dart';

/// Full-screen unbypassable force update screen with clean white theme and Lottie animation.
class ForceUpdateScreen extends StatelessWidget {
  final String? customMessage;
  final String? updateUrl;

  const ForceUpdateScreen({
    super.key,
    this.customMessage,
    this.updateUrl,
  });

  Future<void> _launchUpdate(BuildContext context, String url) async {
    HapticFeedback.mediumImpact();
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تعذر فتح رابط التحديث تلقائياً'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching update url: $e');
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    HapticFeedback.lightImpact();
    try {
      final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
      final uri = Uri.parse('https://wa.me/$clean?text=${Uri.encodeComponent('مرحباً، أواجه مشكلة في تحديث التطبيق.')}');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final config = AppSystemConfigRepo().cachedConfig;
    final message = customMessage ?? config.updateMessage;
    final url = updateUrl ?? config.updateUrl;
    final supportPhone = config.supportPhone;

    return PopScope(
      canPop: false, // Strict blocker
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // 1. Lottie Animation
                  Center(
                    child: SizedBox(
                      width: 250.r,
                      height: 250.r,
                      child: Lottie.asset(
                        'assets/json/update.json',
                        fit: BoxFit.contain,
                        repeat: true,
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // 2. Title & Status Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.system_update_rounded, size: 16.r, color: const Color(0xFF0284C7)),
                        SizedBox(width: 6.w),
                        Text(
                          'تحديث إجباري متوفر',
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0284C7),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 14.h),

                  Text(
                    'هذه النسخة ليست متاحة الآن 🚀',
                    style: GoogleFonts.cairo(
                      fontSize: 21.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 10.h),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      message.isNotEmpty
                          ? message
                          : 'يرجى التحديث إلى أحدث إصدار لمتابعة استخدام التطبيق والاستمتاع بكافة الميزات الجديدة والمحتوى الدراسي.',
                      style: GoogleFonts.cairo(
                        fontSize: 13.5.sp,
                        color: const Color(0xFF475569),
                        height: 1.65,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const Spacer(),

                  // 3. Update Button
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchUpdate(context, url),
                      icon: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 20),
                      label: Text(
                        'تحديث التطبيق الآن ⚡',
                        style: GoogleFonts.cairo(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: const Color(0xFF0284C7).withValues(alpha: 0.35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // 4. Contact Support Link
                  TextButton.icon(
                    onPressed: () => _launchWhatsApp(supportPhone),
                    icon: Icon(Icons.support_agent_rounded, size: 18.r, color: const Color(0xFF64748B)),
                    label: Text(
                      'تواجه مشكلة؟ تواصل مع الدعم الفني',
                      style: GoogleFonts.cairo(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),

                  SizedBox(height: 8.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
