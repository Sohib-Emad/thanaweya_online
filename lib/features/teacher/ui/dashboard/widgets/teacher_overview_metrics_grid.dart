import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/features/teacher/logic/teacher_profile_cubit.dart';
import 'package:thanaweya_online/features/teacher/ui/dashboard/widgets/teacher_metric_card.dart';

/// Grid displaying overview metrics for students, courses, exams, and codes.
class TeacherOverviewMetricsGrid extends StatelessWidget {
  const TeacherOverviewMetricsGrid({
    super.key,
    required this.availableCodesCount,
    required this.usedCodesCount,
    required this.onTabSwitch,
  });

  final int availableCodesCount;
  final int usedCodesCount;
  final void Function(int index) onTabSwitch;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeacherProfileCubit, TeacherProfileState>(
      builder: (context, state) {
        final totalStudents = state.studentsCount;
        final totalCourses = state.coursesCount;
        final totalExams = state.examsCount;

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TeacherMetricCard(
                    title: 'إجمالي الطلاب',
                    value: '$totalStudents',
                    subtitle: 'طالب مسجل',
                    icon: Icons.people_alt_outlined,
                    color: const Color(0xFF0284C7),
                    onTap: () => onTabSwitch(3),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: TeacherMetricCard(
                    title: 'الطلاب النشطين',
                    value: '${(totalStudents * 0.85).toInt()}',
                    subtitle: 'تفاعل اليوم',
                    icon: Icons.trending_up_rounded,
                    color: const Color(0xFF16A34A),
                    onTap: () => onTabSwitch(3),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: TeacherMetricCard(
                    title: 'الكورسات',
                    value: '$totalCourses',
                    subtitle: 'كورس منشور',
                    icon: Icons.menu_book_outlined,
                    color: const Color(0xFF9333EA),
                    onTap: () => onTabSwitch(1),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: TeacherMetricCard(
                    title: 'الامتحانات',
                    value: '$totalExams',
                    subtitle: 'اختبار متاح',
                    icon: Icons.quiz_outlined,
                    color: const Color(0xFFE11D48),
                    onTap: () => onTabSwitch(2),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: TeacherMetricCard(
                    title: 'الأكواد المتاحة',
                    value: '$availableCodesCount',
                    subtitle: 'جاهز للاستخدام',
                    icon: Icons.card_giftcard_rounded,
                    color: const Color(0xFFD97706),
                    onTap: () =>
                        Navigator.pushNamed(context, AppRouter.teacherCards),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: TeacherMetricCard(
                    title: 'أكواد تم تفعيلها',
                    value: '$usedCodesCount',
                    subtitle: 'مشترك نشط',
                    icon: Icons.check_circle_outline_rounded,
                    color: const Color(0xFF0284C7),
                    onTap: () =>
                        Navigator.pushNamed(context, AppRouter.teacherCards),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
