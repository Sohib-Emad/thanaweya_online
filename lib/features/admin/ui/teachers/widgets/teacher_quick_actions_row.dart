import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/router/app_router.dart';

class TeacherQuickActionsRow extends StatelessWidget {
  final String teacherId;

  const TeacherQuickActionsRow({super.key, required this.teacherId});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, AppRouter.adminStudents, arguments: teacherId);
            },
            icon: const Icon(Icons.school_outlined, size: 16),
            label: Text('طلاب المعلم', style: GoogleFonts.cairo(fontSize: 11.5.sp, fontWeight: FontWeight.w800)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.studentPrimary,
              side: BorderSide(color: AppColors.studentPrimary.withValues(alpha: 0.5)),
              padding: EdgeInsets.symmetric(vertical: 6.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, AppRouter.adminActiveCodes, arguments: teacherId);
            },
            icon: const Icon(Icons.vpn_key_outlined, size: 16),
            label: Text('الأكواد النشطة', style: GoogleFonts.cairo(fontSize: 11.5.sp, fontWeight: FontWeight.w800)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF16A34A),
              side: BorderSide(color: const Color(0xFF16A34A).withValues(alpha: 0.5)),
              padding: EdgeInsets.symmetric(vertical: 6.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
          ),
        ),
      ],
    );
  }
}
