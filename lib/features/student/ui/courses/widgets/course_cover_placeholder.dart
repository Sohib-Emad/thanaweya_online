import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Placeholder widget showing the first letter of a subject.
class CourseCoverPlaceholder extends StatelessWidget {
  final Color color;
  final String subject;

  const CourseCoverPlaceholder({
    super.key,
    required this.color,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        subject.isNotEmpty ? subject[0] : '؟',
        style: GoogleFonts.cairo(
          fontSize: 22.sp,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}
