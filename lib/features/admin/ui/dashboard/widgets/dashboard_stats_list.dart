import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/features/shared/widgets/stat_card.dart';

import '../../../../../core/constants/app_colors.dart';

/// Renders the primary stat cards for the admin dashboard.
class DashboardStatsList extends StatelessWidget {
  final Map<String, dynamic> stats;

  const DashboardStatsList({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () =>
              Navigator.pushNamed(context, AppRouter.adminTeacherRequests),
          child: StatCard(
            title: 'طلبات معلمين معلقة (اضغط للمراجعة)',
            value: (stats['pending_requests'] ?? 0).toString(),
            icon: Icons.pending_actions_rounded,
            color: AppColors.warning,
          ),
        ),
        GestureDetector(
          onTap: () =>
              Navigator.pushNamed(context, AppRouter.adminAllTeachers),
          child: StatCard(
            title: 'إجمالي المعلمين',
            value: (stats['total_teachers'] ?? 0).toString(),
            icon: Icons.workspace_premium_rounded,
            color: AppColors.teacherPrimary,
          ),
        ),
        GestureDetector(
          onTap: () =>
              Navigator.pushNamed(context, AppRouter.adminStudents),
          child: StatCard(
            title: 'طلاب المعلمين والاشتراكات (فتح/قفل)',
            value: (stats['total_students'] ?? 0).toString(),
            icon: Icons.school_rounded,
            color: AppColors.studentPrimary,
          ),
        ),
        GestureDetector(
          onTap: () =>
              Navigator.pushNamed(context, AppRouter.adminActiveCodes),
          child: StatCard(
            title: 'الأكواد النشطة للمعلمين (استعراض وتوليد)',
            value: 'إدارة الأكواد',
            icon: Icons.vpn_key_rounded,
            color: const Color(0xFF16A34A),
          ),
        ),
        SizedBox(height: 12.h),
      ],
    );
  }
}
