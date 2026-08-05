// ────────────────────────────────────────────────────────────
// DIRECTION CONTRACT — معلم · السبورة الطباشير (the chalkboard)
// EXAMS BOARD: the exams of the teacher are chalk frames pinned to the
//   board. Each frame is stamped منشور (mint) or مسودة (yellow), written
//   with its course, duration, exam window dates, question count and total
//   points in chalk, with publish/edit/delete actions at its foot. Creating
//   or editing an exam happens in a chalk modal: title, course picker,
//   duration, and real start/end date pickers (no fake 30-day windows).
// FINISH: unreviewed and undocumented is unfinished; this build ends with the
//   finish review, the verdict, and DESIGN.md.
// ────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/chalkboard_theme.dart';
import 'package:thanaweya_online/core/utils/formatters.dart';
import 'package:thanaweya_online/features/shared/models/course_model.dart';
import 'package:thanaweya_online/features/shared/models/exam_model.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_courses_repo.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_exams_repo.dart';
import 'package:thanaweya_online/features/teacher/logic/teacher_exams_cubit.dart';

class ExamsListScreen extends StatefulWidget {
  const ExamsListScreen({super.key});

  @override
  State<ExamsListScreen> createState() => _ExamsListScreenState();
}

class _ExamsListScreenState extends State<ExamsListScreen> {
  final _cubit = TeacherExamsCubit(repo: TeacherExamsRepo());
  List<CourseModel> _courses = [];
  Map<String, String> _courseTitles = {};

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  Future<void> _loadExams() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      _cubit.loadExams(userId);
      _cubit.loadExamQuestionStats(userId);
      await _loadCourses(userId);
    }
  }

  Future<void> _loadCourses(String teacherId) async {
    try {
      final result = await TeacherCoursesRepo().getCourses(teacherId);
      result.when(
        success: (courses) {
          if (mounted) {
            setState(() {
              _courses = courses;
              _courseTitles = {
                for (final c in courses) c.id: c.title,
              };
            });
          }
        },
        failure: (_, _) {},
      );
    } catch (e) {
      debugPrint('[ExamsList] load courses error: $e');
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ChalkboardColors.ground,
        appBar: ChalkTopBar(
          title: 'الامتحانات',
          subtitle: 'اختباراتك على السبورة',
        ),
        body: ChalkboardSurface(
          child: BlocBuilder<TeacherExamsCubit, TeacherExamsState>(
            bloc: _cubit,
            builder: (context, state) {
              if (state.status == TeacherExamsStatus.loading &&
                  state.exams.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: ChalkboardColors.accent,
                  ),
                );
              }
              if (state.status == TeacherExamsStatus.error &&
                  state.exams.isEmpty) {
                return Center(
                  child: ChalkEmptyNote(
                    message: state.errorMessage ?? 'حدث خطأ أثناء تحميل الاختبارات',
                    icon: Icons.error_outline_rounded,
                    actionLabel: 'إعادة المحاولة',
                    onAction: _loadExams,
                  ),
                );
              }
              if (state.exams.isEmpty) {
                return ChalkEmptyNote(
                  message: 'لا توجد اختبارات بعد',
                  subMessage: 'استخدم زر + لكتابة أول اختبار على السبورة',
                  icon: Icons.quiz_outlined,
                  actionLabel: 'إنشاء اختبار',
                  onAction: () => _showExamSheet(context, null),
                );
              }
              return RefreshIndicator(
                onRefresh: _loadExams,
                color: ChalkboardColors.accent,
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                  itemCount: state.exams.length,
                  separatorBuilder: (_, _) => SizedBox(height: 14.h),
                  itemBuilder: (context, index) {
                    final exam = state.exams[index];
                    final stats = state.examQuestionStats[exam.id];
                    final questionCount = stats?['count'] ?? 0;
                    final totalPoints = stats?['points'] ?? 0;
                    return _ExamCard(
                      exam: exam,
                      courseTitle: _courseTitles[exam.courseId],
                      questionCount: questionCount,
                      totalPoints: totalPoints,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pushNamed(
                          context,
                          AppRouter.teacherAddQuestion,
                          arguments: exam.id,
                        );
                      },
                      onEdit: () => _showExamSheet(context, exam),
                      onDelete: () => _confirmDeleteExam(context, exam),
                      onResults: () => Navigator.pushNamed(
                        context,
                        AppRouter.teacherExamResults,
                        arguments: {
                          'examId': exam.id,
                          'examTitle': exam.title,
                        },
                      ),
                      onTogglePublish: () =>
                          _cubit.setExamPublished(exam.id, !exam.isPublished),
                    );
                  },
                ),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: null,
          onPressed: () {
            HapticFeedback.lightImpact();
            _showExamSheet(context, null);
          },
          backgroundColor: ChalkboardColors.accent,
          foregroundColor: ChalkboardColors.onAccent,
          elevation: 4,
          icon: const Icon(Icons.add_rounded, size: 22),
          label: Text(
            'إنشاء اختبار',
            style: ChalkboardText.strong(13.sp),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteExam(
      BuildContext context, ExamModel exam) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: ChalkboardColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
              side: BorderSide(color: ChalkboardColors.ink.withAlpha(60)),
            ),
            title: Text('حذف الاختبار؟', style: ChalkboardText.heading(16.sp)),
            content: Text(
              'سيتم حذف «${exam.title}» مع كل أسئلته، ولا يمكن التراجع.',
              style: ChalkboardText.body(12.sp),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(
                  'إلغاء',
                  style: ChalkboardText.strong(12.sp,
                      color: ChalkboardColors.chalkSoft),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(
                  'حذف',
                  style: ChalkboardText.strong(12.sp,
                      color: ChalkboardColors.chalkRed),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (confirmed == true) {
      _cubit.deleteExam(exam.id);
    }
  }

  Future<DateTime?> _pickDate(
    BuildContext sheetContext, {
    required DateTime initial,
    DateTime? first,
    DateTime? last,
  }) async {
    return showDatePicker(
      context: sheetContext,
      initialDate: initial,
      firstDate: first ?? DateTime(2020),
      lastDate: last ?? DateTime(2030),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: ChalkboardColors.accent,
              ),
            ),
            child: child!,
          ),
        );
      },
    );
  }

  void _showExamSheet(BuildContext context, ExamModel? exam) {
    final titleController = TextEditingController(text: exam?.title ?? '');
    final durationController = TextEditingController(
      text: '${exam?.durationMinutes ?? 45}',
    );
    String? selectedCourseId = exam?.courseId;
    DateTime startAt = exam?.startAt ?? DateTime.now();
    DateTime endAt = exam?.endAt ?? DateTime.now().add(const Duration(days: 7));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ChalkboardColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        side: BorderSide(color: ChalkboardColors.ink.withAlpha(60)),
      ),
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (sheetContext, setSheetState) {
              return Padding(
                padding: EdgeInsets.only(
                  left: 20.w,
                  right: 20.w,
                  top: 24.h,
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24.h,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exam == null ? 'إنشاء اختبار جديد' : 'تعديل الاختبار',
                        style: ChalkboardText.heading(17.sp),
                      ),
                      SizedBox(height: 20.h),
                      ChalkInputField(
                        label: 'عنوان الاختبار',
                        controller: titleController,
                        icon: Icons.quiz_outlined,
                        hint: 'مثال: اختبار الفصل الأول - الكهربية',
                      ),
                      SizedBox(height: 18.h),
                      ChalkInputField(
                        label: 'مدة الاختبار بالدقائق',
                        controller: durationController,
                        icon: Icons.timer_outlined,
                        hint: '45',
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 18.h),
                      if (_courses.isNotEmpty) ...[
                        Text(
                          'اختر الدورة (اختياري)',
                          style: ChalkboardText.strong(12.sp),
                        ),
                        SizedBox(height: 6.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            color: ChalkboardColors.surface.withAlpha(180),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: ChalkboardColors.ink.withAlpha(60),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedCourseId,
                              isExpanded: true,
                              dropdownColor: ChalkboardColors.surface,
                              hint: Text(
                                'بدون دورة',
                                style: ChalkboardText.note(12.sp),
                              ),
                              style: ChalkboardText.body(12.sp),
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('بدون دورة'),
                                ),
                                ..._courses.map((c) => DropdownMenuItem<String>(
                                      value: c.id,
                                      child: Text(
                                        c.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )),
                              ],
                              onChanged: (v) => setSheetState(
                                  () => selectedCourseId = v),
                            ),
                          ),
                        ),
                        SizedBox(height: 18.h),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: _DatePickTile(
                              label: 'بداية الاختبار',
                              value: Formatters.formatDateTime(startAt),
                              icon: Icons.event_available_outlined,
                              onTap: () async {
                                final picked = await _pickDate(
                                  sheetContext,
                                  initial: startAt,
                                  last: endAt,
                                );
                                if (picked != null) {
                                  setSheetState(() => startAt = picked);
                                }
                              },
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: _DatePickTile(
                              label: 'نهاية الاختبار',
                              value: Formatters.formatDateTime(endAt),
                              icon: Icons.event_busy_outlined,
                              onTap: () async {
                                final picked = await _pickDate(
                                  sheetContext,
                                  initial: endAt,
                                  first: startAt,
                                );
                                if (picked != null) {
                                  setSheetState(() => endAt = picked);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      ChalkPrimaryButton(
                        label: exam == null ? 'حفظ ومتابعة' : 'حفظ التعديلات',
                        icon: Icons.check_rounded,
                        onPressed: () {
                          final title = titleController.text.trim();
                          final duration =
                              int.tryParse(durationController.text.trim());
                          if (title.isEmpty || duration == null || duration <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: ChalkboardColors.surface,
                                content: Text(
                                  'أدخل عنواناً ومدة صحيحة',
                                  style: ChalkboardText.strong(12.sp),
                                ),
                              ),
                            );
                            return;
                          }

                          final userId =
                              Supabase.instance.client.auth.currentUser?.id;
                          if (userId == null) return;

                          if (exam == null) {
                            _cubit.createExam(
                              teacherId: userId,
                              title: title,
                              durationMinutes: duration,
                              startAt: startAt,
                              endAt: endAt,
                              courseId: selectedCourseId,
                            );
                          } else {
                            _cubit.updateExam(
                              examId: exam.id,
                              title: title,
                              durationMinutes: duration,
                              startAt: startAt,
                              endAt: endAt,
                              courseId: selectedCourseId,
                              isPublished: exam.isPublished,
                            );
                          }
                          Navigator.pop(sheetContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: ChalkboardColors.accentDeep,
                              content: Text(
                                exam == null
                                    ? 'تم إنشاء الاختبار على السبورة'
                                    : 'تم حفظ تعديلات الاختبار',
                                style: ChalkboardText.strong(12.sp),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ExamCard extends StatelessWidget {
  final ExamModel exam;
  final String? courseTitle;
  final int questionCount;
  final int totalPoints;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onResults;
  final VoidCallback onTogglePublish;

  const _ExamCard({
    required this.exam,
    required this.courseTitle,
    required this.questionCount,
    required this.totalPoints,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onResults,
    required this.onTogglePublish,
  });

  @override
  Widget build(BuildContext context) {
    final published = exam.isPublished;
    final accent =
        published ? ChalkboardColors.accent : ChalkboardColors.chalkYellow;
    return ChalkCard(
      onTap: onTap,
      accent: accent,
      accentLabel: published ? 'منشور' : 'مسودة',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46.r,
                height: 46.r,
                decoration: BoxDecoration(
                  color: accent.withAlpha(30),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: accent.withAlpha(120), width: 1.2),
                ),
                child: Icon(
                  Icons.assignment_turned_in_outlined,
                  color: accent,
                  size: 24.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam.title,
                      style: ChalkboardText.strong(15.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      courseTitle ?? 'بدون دورة مرتبطة',
                      style: ChalkboardText.note(12.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(height: 1, color: ChalkboardColors.ink.withAlpha(35)),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 8.h,
            children: [
              _ExamMeta(
                icon: Icons.timer_outlined,
                text: '${exam.durationMinutes} دقيقة',
              ),
              _ExamMeta(
                icon: Icons.calendar_month_outlined,
                text:
                    '${Formatters.formatDate(exam.startAt)} إلى ${Formatters.formatDate(exam.endAt)}',
              ),
              _ExamMeta(
                icon: Icons.help_outline_rounded,
                text: '$questionCount سؤال',
              ),
              if (totalPoints > 0)
                _ExamMeta(
                  icon: Icons.stars_outlined,
                  text: '$totalPoints نقطة',
                ),
            ],
          ),
          SizedBox(height: 10.h),
          Container(height: 1, color: ChalkboardColors.ink.withAlpha(35)),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(
                Icons.edit_note_rounded,
                size: 15.r,
                color: ChalkboardColors.chalkSoft,
              ),
              SizedBox(width: 6.w),
              Text(
                'اضغط لإضافة الأسئلة',
                style: ChalkboardText.note(11.sp),
              ),
              const Spacer(),
              _IconAction(
                icon: Icons.bar_chart_rounded,
                color: ChalkboardColors.chalkBlue,
                tooltip: 'النتائج',
                onTap: onResults,
              ),
              SizedBox(width: 4.w),
              _IconAction(
                icon: Icons.publish_rounded,
                color: published
                    ? ChalkboardColors.chalkYellow
                    : ChalkboardColors.accent,
                tooltip: published ? 'إلغاء النشر' : 'نشر الاختبار',
                onTap: onTogglePublish,
              ),
              SizedBox(width: 4.w),
              _IconAction(
                icon: Icons.edit_outlined,
                color: ChalkboardColors.chalkBlue,
                tooltip: 'تعديل',
                onTap: onEdit,
              ),
              SizedBox(width: 4.w),
              _IconAction(
                icon: Icons.delete_outline_rounded,
                color: ChalkboardColors.chalkRed,
                tooltip: 'حذف',
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExamMeta extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ExamMeta({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.r, color: ChalkboardColors.chalkSoft),
        SizedBox(width: 4.w),
        Text(text, style: ChalkboardText.note(11.sp)),
      ],
    );
  }
}

class _DatePickTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _DatePickTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: ChalkboardColors.surface.withAlpha(180),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: ChalkboardColors.ink.withAlpha(60)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 15.r, color: ChalkboardColors.accent),
                SizedBox(width: 6.w),
                Text(label, style: ChalkboardText.note(11.sp)),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              value,
              style: ChalkboardText.strong(11.5.sp),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _IconAction({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(7.r),
          decoration: BoxDecoration(
            color: color.withAlpha(22),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: color.withAlpha(110), width: 1.1),
          ),
          child: Icon(icon, size: 17.r, color: color),
        ),
      ),
    );
  }
}
