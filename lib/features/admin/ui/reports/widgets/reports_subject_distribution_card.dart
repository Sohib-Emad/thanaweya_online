import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/features/shared/widgets/app_card.dart';
import 'report_stat_row.dart';

class ReportsSubjectDistributionCard extends StatelessWidget {
  final List<Map<String, dynamic>> subjectDistribution;

  const ReportsSubjectDistributionCard({super.key, required this.subjectDistribution});

  @override
  Widget build(BuildContext context) {
    if (subjectDistribution.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text('توزيع المعلمين حسب المواد', style: AppTextStyles.h3),
        ),
        SizedBox(height: 10.h),
        AppCard(
          child: Column(
            children: [
              for (int i = 0; i < subjectDistribution.length; i++) ...[
                if (i > 0) Divider(height: 18.h),
                ReportStatRow(
                  label: subjectDistribution[i]['name'] as String? ?? 'مادة',
                  value: '${subjectDistribution[i]['count']} معلم',
                  badgeColor: AppColors.studentPrimary,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
