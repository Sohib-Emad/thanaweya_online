import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/features/teacher/ui/dashboard/widgets/teacher_quick_action_btn.dart';

/// Horizontal scrollable bar of quick-action buttons.
class TeacherQuickActionsBar extends StatelessWidget {
  const TeacherQuickActionsBar({
    super.key,
    required this.onTabSwitch,
    required this.onReportTap,
  });

  final void Function(int index) onTabSwitch;
  final VoidCallback onReportTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.bolt_rounded,
                size: 18.r, color: const Color(0xFF0284C7)),
            SizedBox(width: 6.w),
            Text(
              'إجراءات سريعة ومباشرة',
              style: GoogleFonts.cairo(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              TeacherQuickActionBtn(
                label: '+ إضافة كورس',
                icon: Icons.add_circle_outline_rounded,
                color: const Color(0xFF0284C7),
                onTap: () => onTabSwitch(1),
              ),
              SizedBox(width: 8.w),
              TeacherQuickActionBtn(
                label: '+ إنشاء امتحان',
                icon: Icons.quiz_outlined,
                color: const Color(0xFF9333EA),
                onTap: () => Navigator.pushNamed(
                    context, AppRouter.teacherExamBuilder),
              ),
              SizedBox(width: 8.w),
              TeacherQuickActionBtn(
                label: 'عرض الطلاب',
                icon: Icons.people_outline_rounded,
                color: const Color(0xFF16A34A),
                onTap: () => onTabSwitch(3),
              ),
              SizedBox(width: 8.w),
              TeacherQuickActionBtn(
                label: 'تقرير طالب',
                icon: Icons.analytics_outlined,
                color: const Color(0xFFE11D48),
                onTap: onReportTap,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
