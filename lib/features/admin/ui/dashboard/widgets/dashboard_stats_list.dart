import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/features/shared/widgets/stat_card.dart';

import '../../../../../core/constants/app_colors.dart';

/// Renders the three stat cards for the admin dashboard.
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
              Navigator.pushNamed(context, AppRouter.adminPlatformReports),
          child: StatCard(
            title: 'إجمالي الطلاب',
            value: (stats['total_students'] ?? 0).toString(),
            icon: Icons.school_rounded,
            color: AppColors.studentPrimary,
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }
}
