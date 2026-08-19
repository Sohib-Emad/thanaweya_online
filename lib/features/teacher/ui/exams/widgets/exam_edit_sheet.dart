import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/core/utils/formatters.dart';
import 'package:thanaweya_online/features/shared/models/exam_model.dart';
import 'package:thanaweya_online/features/shared/models/lesson_model.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_courses_repo.dart';
import 'package:thanaweya_online/features/teacher/logic/teacher_exams_cubit.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/widgets/course_lesson_dropdown.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/widgets/date_pick_tile.dart';

/// Bottom sheet for creating or editing an exam.
class ExamEditSheet extends StatefulWidget {
  /// The exam to edit, or null to create a new one.
  final ExamModel? exam;
  /// Pre-built course title map.
  final Map<String, String> courseTitles;
  /// The cubit to persist changes.
  final TeacherExamsCubit cubit;
  const ExamEditSheet({super.key, this.exam, required this.courseTitles, required this.cubit});
  @override
  State<ExamEditSheet> createState() => _ExamEditSheetState();
}

class _ExamEditSheetState extends State<ExamEditSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _durationCtrl;
  String? _selectedCourseId;
  String? _selectedLessonId;
  List<LessonModel> _courseLessons = [];
  bool _lessonTouched = false;
  late DateTime _startAt;
  late DateTime _endAt;

  @override
  void initState() {
    super.initState();
    final exam = widget.exam;
    _titleCtrl = TextEditingController(text: exam?.title ?? '');
    _durationCtrl = TextEditingController(text: '${exam?.durationMinutes ?? 45}');
    _selectedCourseId = exam?.courseId;
    _startAt = exam?.startAt ?? DateTime.now();
    _endAt = exam?.endAt ?? DateTime.now().add(const Duration(days: 7));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 24.h, bottom: MediaQuery.of(context).viewInsets.bottom + 24.h),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.exam == null ? 'إنشاء اختبار جديد' : 'تعديل الاختبار', style: DeskText.heading(17.sp)),
            SizedBox(height: 20.h),
            DeskInputField(label: 'عنوان الاختبار', controller: _titleCtrl, icon: Icons.quiz_outlined, hint: 'مثال: اختبار الفصل الأول - الكهربية'),
            SizedBox(height: 18.h),
            DeskInputField(label: 'مدة الاختبار بالدقائق', controller: _durationCtrl, icon: Icons.timer_outlined, hint: '45', keyboardType: TextInputType.number),
            SizedBox(height: 18.h),
            CourseLessonDropdown(
              selectedCourseId: _selectedCourseId,
              selectedLessonId: _selectedLessonId,
              courseTitles: widget.courseTitles,
              courseLessons: _courseLessons,
              onCourseChanged: _onCourseChanged,
              onLessonChanged: (v) => setState(() { _selectedLessonId = v; _lessonTouched = true; }),
            ),
            _buildDateRow(),
            SizedBox(height: 24.h),
            DeskPrimaryButton(label: widget.exam == null ? 'حفظ ومتابعة' : 'حفظ التعديلات', icon: Icons.check_rounded, onPressed: _onSave),
          ],
        ),
      ),
    );
  }

  Future<void> _onCourseChanged(String? v) async {
    setState(() { _selectedCourseId = v; _selectedLessonId = null; _lessonTouched = false; _courseLessons = []; });
    if (v == null) return;
    final res = await TeacherCoursesRepo().lessonsRepo.getLessons(v);
    res.when(success: (l) { if (mounted) setState(() => _courseLessons = l); }, failure: (_, _) {});
  }

  Widget _buildDateRow() {
    return Row(children: [
      Expanded(child: DatePickTile(label: 'بداية الاختبار', value: Formatters.formatDateTime(_startAt), icon: Icons.event_available_outlined, onTap: () async {
        final p = await _pickDate(initial: _startAt, last: _endAt);
        if (p != null) setState(() => _startAt = p);
      })),
      SizedBox(width: 10.w),
      Expanded(child: DatePickTile(label: 'نهاية الاختبار', value: Formatters.formatDateTime(_endAt), icon: Icons.event_busy_outlined, onTap: () async {
        final p = await _pickDate(initial: _endAt, first: _startAt);
        if (p != null) setState(() => _endAt = p);
      })),
    ]);
  }

  Future<DateTime?> _pickDate({required DateTime initial, DateTime? first, DateTime? last}) {
    return showDatePicker(
      context: context, initialDate: initial, firstDate: first ?? DateTime(2020), lastDate: last ?? DateTime(2030),
      builder: (c, child) => Directionality(textDirection: TextDirection.rtl, child: Theme(data: Theme.of(c).copyWith(colorScheme: ColorScheme.fromSeed(seedColor: DeskColors.primary)), child: child!)),
    );
  }

  void _onSave() {
    final title = _titleCtrl.text.trim();
    final duration = int.tryParse(_durationCtrl.text.trim());
    if (title.isEmpty || duration == null || duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: DeskColors.surface, content: Text('أدخل عنواناً ومدة صحيحة', style: DeskText.strong(12.sp))));
      return;
    }
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final exam = widget.exam;
    if (exam == null) {
      widget.cubit.createExam(teacherId: userId, title: title, durationMinutes: duration, startAt: _startAt, endAt: _endAt, courseId: _selectedCourseId, lessonId: _selectedLessonId);
    } else {
      widget.cubit.updateExam(examId: exam.id, title: title, durationMinutes: duration, startAt: _startAt, endAt: _endAt, courseId: _selectedCourseId, lessonId: _lessonTouched ? _selectedLessonId : null, clearLesson: _lessonTouched && _selectedLessonId == null, isPublished: exam.isPublished);
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: DeskColors.primaryDeep, content: Text(exam == null ? 'تم إنشاء الاختبار في مكتبك' : 'تم حفظ تعديلات الاختبار', style: DeskText.strong(12.sp))));
  }
}
