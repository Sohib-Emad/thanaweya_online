import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/features/shared/widgets/app_card.dart';
import 'package:thanaweya_online/features/shared/widgets/stat_card.dart';

class PlatformReportsScreen extends StatelessWidget {
  const PlatformReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text(AppStrings.platformReports)),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: 24.h)),
            const SliverToBoxAdapter(
              child: StatCard(
                title: 'إجمالي المستخدمين',
                value: '101',
                icon: Icons.people_outlined,
                color: AppColors.teacherPrimary,
              ),
            ),
            const SliverToBoxAdapter(
              child: StatCard(
                title: 'الاشتراكات النشطة',
                value: '67',
                icon: Icons.card_membership,
                color: AppColors.success,
              ),
            ),
            const SliverToBoxAdapter(
              child: StatCard(
                title: 'الامتحانات المكتملة',
                value: '234',
                icon: Icons.quiz_outlined,
                color: AppColors.studentPrimary,
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 24.h)),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text('ملخص الأداء', style: AppTextStyles.h3),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 12.h)),
            SliverToBoxAdapter(
              child: AppCard(
                child: Column(
                  children: [
                    _ReportRow(label: 'معدل إتمام الدورات', value: '78%'),
                    Divider(height: 24.h),
                    _ReportRow(label: 'معدل نجاح الطلاب', value: '82%'),
                    Divider(height: 24.h),
                    _ReportRow(label: 'متوسط الدرجات', value: '15.2 / 20'),
                    Divider(height: 24.h),
                    _ReportRow(label: 'عدد الدورات النشطة', value: '24'),
                    Divider(height: 24.h),
                    _ReportRow(label: 'عدد الدروس', value: '156'),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 100.h)),
          ],
        ),
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReportRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body2),
        Text(value, style: AppTextStyles.h3),
      ],
    );
  }
}
