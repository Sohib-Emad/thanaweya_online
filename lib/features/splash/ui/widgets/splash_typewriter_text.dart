import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thanaweya_online/core/constants/app_colors.dart';

 
/// Two-line typewriter text showing "Thanaweya" and "Online".
class SplashTypewriterText extends StatelessWidget {
  final String line1;
  final String line2;

  const SplashTypewriterText({
    super.key,
    required this.line1,
    required this.line2,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 42.h,
          child: Text(
            line1,
            style: GoogleFonts.outfit(
              fontSize: 34.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
              height: 1.1,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          height: 38.h,
          child: Text(
            line2,
            style: GoogleFonts.outfit(
              fontSize: 30.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.studentPrimary,
              height: 1.1,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
