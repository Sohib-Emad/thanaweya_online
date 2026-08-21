import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:thanaweya_online/core/services/app_system_config_repo.dart';

/// Full-screen unbypassable force update screen.
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

  @override
  Widget build(BuildContext context) {
    final config = AppSystemConfigRepo().cachedConfig;
    final message = customMessage ?? config.updateMessage;
    final url = updateUrl ?? config.updateUrl;

    return PopScope(
      canPop: false, // Strict blocker
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          body: Stack(
            children: [
              // Ambient gradient circle
              Positioned(
                top: -80.h,
                right: -80.w,
                child: Container(
                  width: 280.r,
                  height: 280.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF0284C7).withValues(alpha: 0.2),
                  ),
                ),
              ),
              Positioned(
                bottom: -90.h,
                left: -90.w,
                child: Container(
                  width: 270.r,
                  height: 270.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF9333EA).withValues(alpha: 0.15),
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

                      // Rocket / Update Icon
                      Container(
                        width: 110.r,
                        height: 110.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1E293B),
                          border: Border.all(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.system_update_rounded,
                          size: 56,
                          color: Color(0xFF38BDF8),
                        ),
                      ),
                      SizedBox(height: 28.h),

                      Text(
                        'تحديث إجباري للتطبيق 🚀',
                        style: GoogleFonts.cairo(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12.h),

                      Text(
                        message,
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
                            horizontal: 16.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: const Color(0xFF334155),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified_rounded,
                              size: 16,
                              color: Color(0xFF10B981),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'يتضمن التحديث تحسينات أمنية وإصلاحات هامة',
                              style: GoogleFonts.cairo(
                                fontSize: 11.5.sp,
                                color: const Color(0xFFCBD5E1),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Update Button
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton.icon(
                          onPressed: () => _launchUpdate(context, url),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0284C7),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.download_rounded, size: 22),
                          label: Text(
                            'تحديث التطبيق الآن',
                            style: GoogleFonts.cairo(
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.w800,
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
