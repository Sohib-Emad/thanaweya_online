import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_reports_repo.dart';
import 'package:thanaweya_online/features/shared/widgets/app_card.dart';
import 'report_stat_row.dart';

class ReportsPerformanceCard extends StatelessWidget {
  final AdminReportsData data;

  const ReportsPerformanceCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final publishedRate = data.totalCourses > 0 ? ((data.publishedCourses / data.totalCourses) * 100).toInt() : 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text('مؤشرات أداء المنصة', style: AppTextStyles.h3),
        ),
        SizedBox(height: 10.h),
        AppCard(
          child: Column(
            children: [
              ReportStatRow(label: 'الدورات المنشورة', value: '${data.publishedCourses} من ${data.totalCourses} ($publishedRate%)'),
              Divider(height: 20.h),
              ReportStatRow(label: 'إجمالي الدروس المرفوعة', value: '${data.totalLessons} درس'),
              Divider(height: 20.h),
              ReportStatRow(label: 'إجمالي الاختبارات المنشأة', value: '${data.totalExams} اختبار'),
              Divider(height: 20.h),
              ReportStatRow(label: 'إجمالي حلول الطلاب للاختبارات', value: '${data.totalSubmissions} إجابة'),
            ],
          ),
        ),
      ],
    );
  }
}
