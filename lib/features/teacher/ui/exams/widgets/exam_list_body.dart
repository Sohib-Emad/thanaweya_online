import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/shared/models/exam_model.dart';
import 'package:thanaweya_online/features/teacher/logic/teacher_exams_cubit.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/widgets/exam_card.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/widgets/exam_grades_summary.dart';

/// The searchable, scrollable list body of the exams screen.
class ExamListBody extends StatelessWidget {
  final List<ExamModel> exams;
  final TeacherExamsState state;
  final Map<String, String> courseTitles;
  final Map<String, ExamGradesSummary> gradesSummaryByExam;
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onRefresh;
  final ValueChanged<ExamModel> onExamTap;
  final ValueChanged<ExamModel> onExamEdit;
  final ValueChanged<ExamModel> onExamDelete;
  final ValueChanged<ExamModel> onExamResults;
  final ValueChanged<ExamModel> onTogglePublish;

  const ExamListBody({
    super.key,
    required this.exams,
    required this.state,
    required this.courseTitles,
    required this.gradesSummaryByExam,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onRefresh,
    required this.onExamTap,
    required this.onExamEdit,
    required this.onExamDelete,
    required this.onExamResults,
    required this.onTogglePublish,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = exams.where((e) {
      final q = searchQuery.toLowerCase();
      final ct = (courseTitles[e.courseId] ?? '').toLowerCase();
      return e.title.toLowerCase().contains(q) || ct.contains(q);
    }).toList();
    return Column(
      children: [
        SizedBox(height: 14.h),
        DeskSearchField(controller: searchController, hint: 'ابحث باسم الامتحان أو الكورس المرتبط...', onChanged: onSearchChanged),
        SizedBox(height: 10.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('عرض ${filtered.length} اختبار', style: DeskText.note(12.sp)),
            Text('اضغط لعرض الأسئلة أو النتائج', style: DeskText.note(11.sp)),
          ]),
        ),
        SizedBox(height: 8.h),
        Expanded(
          child: filtered.isEmpty
              ? const DeskEmptyNote(message: 'لا توجد امتحانات مطابقة لنتائج البحث', icon: Icons.search_off_rounded)
              : RefreshIndicator(
                  onRefresh: () async => onRefresh(),
                  color: DeskColors.primary,
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 80.h),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => SizedBox(height: 14.h),
                    itemBuilder: (ctx, i) {
                      final exam = filtered[i];
                      final stats = state.examQuestionStats[exam.id];
                      final grades = gradesSummaryByExam[exam.id] ?? const ExamGradesSummary(0, 0, 0);
                      return ExamCard(
                        exam: exam,
                        courseTitle: courseTitles[exam.courseId],
                        questionCount: stats?['count'] ?? 0,
                        totalPoints: stats?['points'] ?? 0,
                        grades: grades,
                        onTap: () { HapticFeedback.lightImpact(); onExamTap(exam); },
                        onEdit: () => onExamEdit(exam),
                        onDelete: () => onExamDelete(exam),
                        onResults: () => onExamResults(exam),
                        onTogglePublish: () => onTogglePublish(exam),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
