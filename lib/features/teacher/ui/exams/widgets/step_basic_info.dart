import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Step 1 of the exam builder wizard: basic exam information.
///
/// Collects title, description, duration, and linked course.
class StepBasicInfo extends StatelessWidget {
  const StepBasicInfo({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.timeLimitController,
    required this.selectedCourseId,
    required this.teacherCourses,
    required this.onCourseChanged,
  });

  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController timeLimitController;
  final String? selectedCourseId;
  final List<Map<String, dynamic>> teacherCourses;
  final ValueChanged<String?> onCourseChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('الخطوة 1: تفاصيل الامتحان الأساسية', style: DeskText.heading(15.sp)),
        SizedBox(height: 4.h),
        Text('أدخل اسم الامتحان والكورس التابع له والمدة الزمنية', style: DeskText.note(12.sp)),
        SizedBox(height: 16.h),
        DeskInputField(
          label: 'اسم الامتحان',
          controller: titleController,
          hint: 'مثال: اختبار المراجعة الشاملة على الفصل الأول',
          icon: Icons.title_rounded,
        ),
        SizedBox(height: 14.h),
        Text('الكورس المرتبط بالامتحان', style: DeskText.strong(12.sp)),
        SizedBox(height: 6.h),
        _CourseDropdown(
          selectedCourseId: selectedCourseId,
          teacherCourses: teacherCourses,
          onChanged: onCourseChanged,
        ),
        SizedBox(height: 14.h),
        DeskInputField(
          label: 'وصف الامتحان (اختياري)',
          controller: descriptionController,
          hint: 'اكتب تعليمات هامة للطالب قبل البدء في حل الأسئلة...',
          icon: Icons.notes_rounded,
          maxLines: 2,
        ),
        SizedBox(height: 14.h),
        DeskInputField(
          label: 'مدة الامتحان (بالدقائق)',
          controller: timeLimitController,
          hint: 'مثال: 45',
          icon: Icons.timer_outlined,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}

class _CourseDropdown extends StatelessWidget {
  const _CourseDropdown({
    required this.selectedCourseId,
    required this.teacherCourses,
    required this.onChanged,
  });

  final String? selectedCourseId;
  final List<Map<String, dynamic>> teacherCourses;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: DeskColors.line),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedCourseId,
          hint: Text('اختر الكورس', style: GoogleFonts.cairo(fontSize: 12.sp)),
          items: teacherCourses.map((c) {
            return DropdownMenuItem<String>(
              value: c['id'] as String?,
              child: Text(c['title'] as String? ?? '',
                  style: GoogleFonts.cairo(fontSize: 12.5.sp)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
