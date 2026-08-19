import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Tab bar for switching between course detail tabs.
class CourseTabBar extends StatelessWidget {
  final TabController controller;
  final int lessonsCount;
  final int studentsCount;
  final int examsCount;

  const CourseTabBar({
    super.key,
    required this.controller,
    required this.lessonsCount,
    required this.studentsCount,
    required this.examsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: DeskColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: DeskColors.primary,
          borderRadius: BorderRadius.circular(12.r),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: DeskColors.muted,
        labelStyle: GoogleFonts.cairo(
          fontSize: 11.5.sp,
          fontWeight: FontWeight.w800,
        ),
        unselectedLabelStyle: GoogleFonts.cairo(
          fontSize: 11.5.sp,
          fontWeight: FontWeight.w600,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: 'المحاضرات ($lessonsCount)'),
          Tab(text: 'الطلاب ($studentsCount)'),
          Tab(text: 'الاختبارات ($examsCount)'),
          const Tab(text: 'الإحصائيات'),
        ],
      ),
    );
  }
}
