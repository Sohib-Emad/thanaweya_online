import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/shared/models/lesson_model.dart';

/// Step 1 of the exam builder wizard: comprehensive exam configuration.
class StepBasicInfo extends StatelessWidget {
  const StepBasicInfo({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.timeLimitController,
    required this.passingScoreController,
    required this.maxAttemptsController,
    required this.selectedCourseId,
    this.selectedLessonId,
    required this.teacherCourses,
    this.courseLessons = const [],
    required this.onCourseChanged,
    this.onLessonChanged,
    required this.startAt,
    required this.endAt,
    required this.onStartAtChanged,
    required this.onEndAtChanged,
    required this.allowRetake,
    required this.onAllowRetakeChanged,
    required this.shuffleQuestions,
    required this.onShuffleQuestionsChanged,
  });

  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController timeLimitController;
  final TextEditingController passingScoreController;
  final TextEditingController maxAttemptsController;
  final String? selectedCourseId;
  final String? selectedLessonId;
  final List<Map<String, dynamic>> teacherCourses;
  final List<LessonModel> courseLessons;
  final ValueChanged<String?> onCourseChanged;
  final ValueChanged<String?>? onLessonChanged;
  final DateTime? startAt;
  final DateTime? endAt;
  final ValueChanged<DateTime?> onStartAtChanged;
  final ValueChanged<DateTime?> onEndAtChanged;
  final bool allowRetake;
  final ValueChanged<bool> onAllowRetakeChanged;
  final bool shuffleQuestions;
  final ValueChanged<bool> onShuffleQuestionsChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('الخطوة 1: تفاصيل الامتحان الأساسية', style: DeskText.heading(15.sp)),
        SizedBox(height: 4.h),
        Text('أدخل اسم الامتحان والكورس والمدة وإعدادات التوقيت والدرجات', style: DeskText.note(12.sp)),
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
        if (courseLessons.isNotEmpty) ...[
          SizedBox(height: 14.h),
          Text('ربط الامتحان بدرس معين (شرط لاجتياز الدرس وفتح التالي)', style: DeskText.strong(12.sp)),
          SizedBox(height: 6.h),
          _LessonDropdown(
            selectedLessonId: selectedLessonId,
            courseLessons: courseLessons,
            onChanged: onLessonChanged ?? (_) {},
          ),
        ],
        SizedBox(height: 14.h),
        DeskInputField(
          label: 'مدة الامتحان (بالدقائق)',
          controller: timeLimitController,
          hint: 'مثال: 45',
          icon: Icons.timer_outlined,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 14.h),
        DeskInputField(
          label: 'درجة النجاح (%)',
          controller: passingScoreController,
          hint: 'مثال: 50 أو 60 (نسبة مئوية لفتح المحاضرة التالية)',
          icon: Icons.percent_rounded,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 16.h),

        // Date Window Pickers
        Text('فترة إتاحة الاختبار للطلاب (اختياري)', style: DeskText.strong(12.sp)),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: _DateTimePickerTile(
                label: 'تاريخ البداية',
                dateTime: startAt,
                onPicked: onStartAtChanged,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _DateTimePickerTile(
                label: 'تاريخ النهاية',
                dateTime: endAt,
                onPicked: onEndAtChanged,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // Switches
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: DeskColors.line),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('السماح بإعادة الاختبار', style: DeskText.strong(12.sp)),
                  Switch(
                    value: allowRetake,
                    activeThumbColor: DeskColors.primary,
                    onChanged: onAllowRetakeChanged,
                  ),
                ],
              ),
              if (allowRetake) ...[
                SizedBox(height: 8.h),
                DeskInputField(
                  label: 'الحد الأقصى للمحاولات',
                  controller: maxAttemptsController,
                  hint: 'مثال: 3',
                  icon: Icons.replay_rounded,
                  keyboardType: TextInputType.number,
                ),
              ],
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ترتيب الأسئلة عشوائياً للطالب', style: DeskText.strong(12.sp)),
                  Switch(
                    value: shuffleQuestions,
                    activeThumbColor: DeskColors.primary,
                    onChanged: onShuffleQuestionsChanged,
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 14.h),
        DeskInputField(
          label: 'وصف أو تعليمات الامتحان (اختياري)',
          controller: descriptionController,
          hint: 'اكتب تعليمات هامة للطالب قبل البدء في حل الأسئلة...',
          icon: Icons.notes_rounded,
          maxLines: 2,
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

class _LessonDropdown extends StatelessWidget {
  const _LessonDropdown({
    required this.selectedLessonId,
    required this.courseLessons,
    required this.onChanged,
  });

  final String? selectedLessonId;
  final List<LessonModel> courseLessons;
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
          value: selectedLessonId,
          hint: Text('اختر الدرس', style: GoogleFonts.cairo(fontSize: 12.sp)),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text('بدون درس (امتحان شامل على الكورس ككل)',
                  style: GoogleFonts.cairo(
                      fontSize: 12.sp, color: DeskColors.muted)),
            ),
            ...courseLessons.map((l) {
              return DropdownMenuItem<String>(
                value: l.id,
                child: Text('درس: ${l.title}',
                    style: GoogleFonts.cairo(
                        fontSize: 12.5.sp, fontWeight: FontWeight.w700)),
              );
            }),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _DateTimePickerTile extends StatelessWidget {
  const _DateTimePickerTile({
    required this.label,
    required this.dateTime,
    required this.onPicked,
  });

  final String label;
  final DateTime? dateTime;
  final ValueChanged<DateTime?> onPicked;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('yyyy/MM/dd\nhh:mm a');
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: dateTime ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2035),
        );
        if (date == null || !context.mounted) return;
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(dateTime ?? DateTime.now()),
        );
        if (time == null) return;
        onPicked(DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        ));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: DeskColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: DeskText.note(10.5.sp)),
            SizedBox(height: 4.h),
            Text(
              dateTime != null ? fmt.format(dateTime!) : 'غير محدد (متاح دائماً)',
              style: GoogleFonts.cairo(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w600,
                color: dateTime != null ? DeskColors.ink : DeskColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
