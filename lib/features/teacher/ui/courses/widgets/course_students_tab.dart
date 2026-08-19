import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

import 'student_card_item.dart';

/// Students list tab for the course details screen.
class CourseStudentsTab extends StatelessWidget {
  final bool isLoading;
  final List<Map<String, dynamic>> students;
  final VoidCallback onRefresh;

  const CourseStudentsTab({
    super.key,
    required this.isLoading,
    required this.students,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: DeskColors.primary),
      );
    }
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: DeskColors.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.all(16.r),
        children: [
          Text(
            'الطلاب المنضمين للكورس (${students.length})',
            style: DeskText.strong(14.sp),
          ),
          SizedBox(height: 12.h),
          if (students.isEmpty) _buildEmptyState() else _buildStudentList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 48.r,
              color: DeskColors.muted.withAlpha(120),
            ),
            SizedBox(height: 10.h),
            Text(
              'لا يوجد طلاب مسجلين في هذا الكورس حتى الآن',
              style: DeskText.body(13.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentList() {
    return Column(
      children: students.map((studentRow) {
        final users = studentRow['users'] as Map<String, dynamic>? ?? {};
        final name = users['full_name'] as String? ?? 'طالب جديد';
        final phone = users['phone'] as String? ?? '';
        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: StudentCardItem(name: name, phone: phone),
        );
      }).toList(),
    );
  }
}
