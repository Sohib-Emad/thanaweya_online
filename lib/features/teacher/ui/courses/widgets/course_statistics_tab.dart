import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/shared/models/course_model.dart';

import 'stat_metric_card.dart';

/// Statistics tab showing course metrics and a bar chart.
class CourseStatisticsTab extends StatelessWidget {
  final int lessonsCount;
  final int examsCount;
  final int studentsCount;
  final CourseModel course;

  const CourseStatisticsTab({
    super.key,
    required this.lessonsCount,
    required this.examsCount,
    required this.studentsCount,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    final priceLabel = course.price != null && course.price! > 0 ? '${course.price} ج.م' : 'مجاني';
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(16.r),
      children: [
        Text('إحصائيات الكورس الشاملة', style: DeskText.strong(14.sp)),
        SizedBox(height: 12.h),
        Row(children: [
          Expanded(child: StatMetricCard(title: 'إجمالي المحاضرات', value: '$lessonsCount', icon: Icons.ondemand_video_rounded, color: DeskColors.primary)),
          SizedBox(width: 10.w),
          Expanded(child: StatMetricCard(title: 'إجمالي الامتحانات', value: '$examsCount', icon: Icons.quiz_outlined, color: DeskColors.accent)),
        ]),
        SizedBox(height: 10.h),
        Row(children: [
          Expanded(child: StatMetricCard(title: 'الطلاب المسجلين', value: '$studentsCount', icon: Icons.people_outline_rounded, color: DeskColors.info)),
          SizedBox(width: 10.w),
          Expanded(child: StatMetricCard(title: 'سعر الكورس', value: priceLabel, icon: Icons.payments_outlined, color: DeskColors.success)),
        ]),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(color: DeskColors.surface, borderRadius: BorderRadius.circular(18.r), border: Border.all(color: DeskColors.line)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('معدل النشاط والمتابعة', style: DeskText.strong(13.sp)),
              SizedBox(height: 16.h),
              SizedBox(
                height: 120.h,
                child: BarChart(BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 85, color: DeskColors.primary, width: 14)]),
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 70, color: DeskColors.primaryDeep, width: 14)]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 90, color: DeskColors.primary, width: 14)]),
                    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 60, color: DeskColors.primaryDeep, width: 14)]),
                  ],
                )),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
