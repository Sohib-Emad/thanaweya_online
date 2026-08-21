import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/shared/models/exam_model.dart';
import 'package:thanaweya_online/features/teacher/logic/teacher_exams_cubit.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/widgets/exam_card.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/widgets/exam_grades_summary.dart';

/// The searchable, filterable, scrollable list body of the exams screen.
class ExamListBody extends StatefulWidget {
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
  State<ExamListBody> createState() => _ExamListBodyState();
}

class _ExamListBodyState extends State<ExamListBody> {
  int _filterIndex = 0;

  @override
  Widget build(BuildContext context) {
    final publishedCount = widget.exams.where((e) => e.isPublished).length;
    final draftCount = widget.exams.where((e) => !e.isPublished).length;

    final filtered = widget.exams.where((e) {
      final q = widget.searchQuery.toLowerCase();
      final ct = (widget.courseTitles[e.courseId] ?? '').toLowerCase();
      final matchesSearch =
          e.title.toLowerCase().contains(q) || ct.contains(q);
      if (!matchesSearch) return false;
      if (_filterIndex == 1) return e.isPublished;
      if (_filterIndex == 2) return !e.isPublished;
      return true;
    }).toList();

    return Column(
      children: [
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: _buildSearchField(),
        ),
        SizedBox(height: 10.h),
        _buildFilterChips(
          totalCount: widget.exams.length,
          publishedCount: publishedCount,
          draftCount: draftCount,
        ),
        SizedBox(height: 10.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'إجمالي ${filtered.length} اختبار متاح',
                style: GoogleFonts.cairo(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                ),
              ),
              Text(
                'اضغط على الامتحان لإدارة الأسئلة',
                style: GoogleFonts.cairo(
                  fontSize: 10.5.sp,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Expanded(
          child: filtered.isEmpty
              ? const DeskEmptyNote(
                  message: 'لا توجد امتحانات مطابقة لنتائج البحث',
                  icon: Icons.search_off_rounded,
                )
              : RefreshIndicator(
                  onRefresh: () async => widget.onRefresh(),
                  color: const Color(0xFF0284C7),
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 80.h),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => SizedBox(height: 12.h),
                    itemBuilder: (ctx, i) {
                      final exam = filtered[i];
                      final stats = widget.state.questionStats[exam.id] ??
                          widget.state.examQuestionStats[exam.id];
                      final grades =
                          widget.gradesSummaryByExam[exam.id] ??
                          const ExamGradesSummary(0, 0, 0);
                      return ExamCard(
                        exam: exam,
                        courseTitle: widget.courseTitles[exam.courseId],
                        questionCount: stats?['count'] ?? 0,
                        totalPoints: stats?['points'] ?? 0,
                        grades: grades,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          widget.onExamTap(exam);
                        },
                        onEdit: () => widget.onExamEdit(exam),
                        onDelete: () => widget.onExamDelete(exam),
                        onResults: () => widget.onExamResults(exam),
                        onTogglePublish: () => widget.onTogglePublish(exam),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: widget.searchController,
      onChanged: widget.onSearchChanged,
      style: GoogleFonts.cairo(
        fontSize: 13.sp,
        color: const Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        hintText: 'ابحث باسم الامتحان أو الكورس المرتبط...',
        hintStyle: GoogleFonts.cairo(
          fontSize: 13.sp,
          color: const Color(0xFF94A3B8),
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: Color(0xFF94A3B8),
          size: 22,
        ),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFilterChips({
    required int totalCount,
    required int publishedCount,
    required int draftCount,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          _chip(0, 'الكل ($totalCount)', Icons.grid_view_rounded),
          SizedBox(width: 8.w),
          _chip(
            1,
            'المنشورة ($publishedCount)',
            Icons.check_circle_outline_rounded,
          ),
          SizedBox(width: 8.w),
          _chip(2, 'المسودات ($draftCount)', Icons.edit_note_rounded),
        ],
      ),
    );
  }

  Widget _chip(int index, String label, IconData icon) {
    final isSelected = _filterIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _filterIndex = index);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0284C7) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0284C7)
                : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0284C7).withAlpha(30),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16.r,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
