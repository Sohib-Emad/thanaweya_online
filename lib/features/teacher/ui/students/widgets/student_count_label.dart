import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Count label shown above the student list.
class StudentCountLabel extends StatelessWidget {
  final int count;
  const StudentCountLabel({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Text(
        'عرض $count طالب مسجل',
        style: GoogleFonts.cairo(
          fontSize: 11.5.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF64748B),
        ),
      ),
    );
  }
}
