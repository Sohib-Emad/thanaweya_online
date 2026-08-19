import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// "Already have an account? Sign in" row for role selection.
class RoleSelectionLoginFooter extends StatelessWidget {
  final VoidCallback onLogin;

  const RoleSelectionLoginFooter({super.key, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Row(
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
            onLogin();
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
    );
  }
}
