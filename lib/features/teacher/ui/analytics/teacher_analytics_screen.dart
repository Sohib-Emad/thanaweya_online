import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/analytics/widgets/widgets.dart';

/// Analytics dashboard showing student performance metrics,
/// trend charts, challenging exams, and score distribution.
class TeacherAnalyticsScreen extends StatefulWidget {
  const TeacherAnalyticsScreen({super.key});
  @override
  State<TeacherAnalyticsScreen> createState() =>
      _TeacherAnalyticsScreenState();
}

class _TeacherAnalyticsScreenState extends State<TeacherAnalyticsScreen> {
  int _selectedRange = 2;
  static const _ranges = ['اليوم', 'هذا الأسبوع', 'هذا الشهر', 'هذا الفصل'];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: DeskColors.ground,
        appBar: DeskTopBar(
          title: 'التحليلات ومؤشرات الأداء',
          subtitle:
              'معدلات نجاح الطلاب، الامتحانات الصعبة، وتوزيع الدرجات',
          automaticallyImplyBack: true,
        ),
        body: DeskSurface(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(18.r),
            children: [
              RangeFilter(
                selectedIndex: _selectedRange,
                ranges: _ranges,
                onSelected: (i) => setState(() => _selectedRange = i),
              ),
              SizedBox(height: 16.h),
              _buildTopMetricsGrid(),
              SizedBox(height: 18.h),
              const PerformanceTrendChart(),
              SizedBox(height: 18.h),
              const ChallengingExamsList(),
              SizedBox(height: 18.h),
              const ScoreDistributionChart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopMetricsGrid() {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: MetricTile(
                title: 'متوسط درجات الطلاب',
                value: '84.6%',
                subtitle: '+3.2% عن الشهر السابق',
                icon: Icons.trending_up_rounded,
                color: Color(0xFF0284C7),
              ),
            ),
            SizedBox(width: 10.w),
            const Expanded(
              child: MetricTile(
                title: 'نسبة النجاح العامة',
                value: '91.2%',
                subtitle: 'نسبة اجتياز ممتازة',
                icon: Icons.verified_outlined,
                color: Color(0xFF0284C7),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            const Expanded(
              child: MetricTile(
                title: 'إكمال المشاهدة',
                value: '76.4%',
                subtitle: 'متابعة المحتوى',
                icon: Icons.play_circle_outline_rounded,
                color: Color(0xFF9333EA),
              ),
            ),
            SizedBox(width: 10.w),
            const Expanded(
              child: MetricTile(
                title: 'نسبة تسليم الامتحانات',
                value: '89.0%',
                subtitle: 'التزام بالمواعيد ⏰',
                icon: Icons.task_alt_rounded,
                color: Color(0xFFD97706),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
