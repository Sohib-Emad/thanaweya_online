import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';

class StudentCoursesTeacherFilter extends StatelessWidget {
  final List<Map<String, dynamic>> teachers;
  final String? selectedTeacherId;
  final ValueChanged<String> onSelectTeacher;

  const StudentCoursesTeacherFilter({
    super.key,
    required this.teachers,
    required this.selectedTeacherId,
    required this.onSelectTeacher,
  });

  @override
  Widget build(BuildContext context) {
    if (teachers.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 38.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: teachers.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (_, i) {
          final t = teachers[i], tid = t['id'] as String? ?? '';
          final isSel = selectedTeacherId == tid;
          final name = (t['users'] as Map<String, dynamic>?)?['full_name'] as String? ?? 'معلم';

          return ChoiceChip(
            label: Text(name),
            selected: isSel,
            selectedColor: AppColors.adminPrimary,
            backgroundColor: AppColors.surface,
            showCheckmark: false,
            labelStyle: GoogleFonts.cairo(
              fontSize: 12.sp,
              fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
              color: isSel ? Colors.white : AppColors.textPrimary,
            ),
            onSelected: (s) { if (s && selectedTeacherId != tid) onSelectTeacher(tid); },
          );
        },
      ),
    );
  }
}
