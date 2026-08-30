import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_reports_repo.dart';
import 'package:thanaweya_online/features/shared/widgets/app_card.dart';
import 'report_stat_row.dart';

class ReportsTeacherStatusCard extends StatelessWidget {
  final AdminReportsData data;

  const ReportsTeacherStatusCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final rate = data.totalTeachers > 0 ? ((data.approvedTeachers / data.totalTeachers) * 100).toInt() : 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text('حالة طلبات المعلمين', style: AppTextStyles.h3),
        ),
        SizedBox(height: 10.h),
        AppCard(
          child: Column(
            children: [
              ReportStatRow(label: 'المعلمون المعتمدون', value: '${data.approvedTeachers}', badgeColor: AppColors.success),
              Divider(height: 20.h),
              ReportStatRow(label: 'طلبات قيد المراجعة', value: '${data.pendingTeachers}', badgeColor: AppColors.warning),
              Divider(height: 20.h),
              ReportStatRow(label: 'طلبات مرفوضة', value: '${data.rejectedTeachers}', badgeColor: AppColors.error),
              Divider(height: 20.h),
              ReportStatRow(label: 'معدل القبول والتفعيل', value: '$rate%', badgeColor: AppColors.adminPrimary),
            ],
          ),
        ),
      ],
    );
  }
}
