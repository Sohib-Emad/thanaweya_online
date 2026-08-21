import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_exams_repo.dart';
import 'package:thanaweya_online/features/teacher/logic/teacher_exam_results_cubit.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/widgets/widgets.dart';

enum _SortBy { highestScore, lowestScore, newest, passedFirst }

/// Screen showing all student submissions for a single exam with sorting and reset actions.
class ExamResultsScreen extends StatefulWidget {
  const ExamResultsScreen({super.key, required this.examId, required this.examTitle});

  final String examId;
  final String examTitle;

  @override
  State<ExamResultsScreen> createState() => _ExamResultsScreenState();
}

class _ExamResultsScreenState extends State<ExamResultsScreen> {
  late final TeacherExamResultsCubit _cubit;
  _SortBy _sortBy = _SortBy.highestScore;

  @override
  void initState() {
    super.initState();
    _cubit = TeacherExamResultsCubit(repo: TeacherExamsRepo());
    _load();
  }

  Future<void> _load() => _cubit.loadSubmissions(widget.examId);

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
        backgroundColor: DeskColors.ground,
        appBar: DeskTopBar(title: 'نتائج وتفاصيل الاختبار', subtitle: widget.examTitle),
        body: DeskSurface(
          child: BlocBuilder<TeacherExamResultsCubit, TeacherExamResultsState>(
            bloc: _cubit,
            builder: (context, state) => _buildBody(state),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(TeacherExamResultsState state) {
    if (state.status == TeacherExamResultsStatus.loading && state.submissions.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: DeskColors.primary));
    }
    if (state.status == TeacherExamResultsStatus.error && state.submissions.isEmpty) {
      return Center(
        child: DeskEmptyNote(
          message: state.errorMessage ?? 'حدث خطأ أثناء تحميل النتائج',
          icon: Icons.error_outline_rounded,
          actionLabel: 'إعادة المحاولة',
          onAction: _load,
        ),
      );
    }
    if (state.submissions.isEmpty) {
      return DeskEmptyNote(
        message: 'لا توجد مشاركات بعد',
        subMessage: 'لم يشارك أي طالب في هذا الامتحان حتى الآن',
        icon: Icons.how_to_reg_outlined,
      );
    }

    final rawGroups = ExamResultsHelpers.groupByStudent(state.submissions);
    final sortedEntries = rawGroups.entries.toList();

    // Sort according to selection
    sortedEntries.sort((a, b) {
      final aBest = ExamResultsHelpers.bestPercent(a.value);
      final bBest = ExamResultsHelpers.bestPercent(b.value);
      switch (_sortBy) {
        case _SortBy.highestScore:
          return bBest.compareTo(aBest);
        case _SortBy.lowestScore:
          return aBest.compareTo(bBest);
        case _SortBy.passedFirst:
          final aPassed = aBest >= 50 ? 1 : 0;
          final bPassed = bBest >= 50 ? 1 : 0;
          return bPassed.compareTo(aPassed);
        case _SortBy.newest:
          final aTime = a.value.firstOrNull?['submitted_at'] as String? ?? '';
          final bTime = b.value.firstOrNull?['submitted_at'] as String? ?? '';
          return bTime.compareTo(aTime);
      }
    });

    return RefreshIndicator(
      onRefresh: _load,
      color: DeskColors.primary,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        children: [
          ResultsSummaryBar(groups: rawGroups),
          SizedBox(height: 14.h),

          // Sorting filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSortChip('الأعلى درجة', _SortBy.highestScore, Icons.arrow_downward_rounded),
                SizedBox(width: 8.w),
                _buildSortChip('الأقل درجة', _SortBy.lowestScore, Icons.arrow_upward_rounded),
                SizedBox(width: 8.w),
                _buildSortChip('الناجحين أولاً', _SortBy.passedFirst, Icons.check_circle_outline),
                SizedBox(width: 8.w),
                _buildSortChip('الأحدث حلاً', _SortBy.newest, Icons.schedule),
              ],
            ),
          ),
          SizedBox(height: 14.h),

          if (rawGroups.isNotEmpty) ...[
            TopPerformersSection(groups: rawGroups),
            SizedBox(height: 16.h),
          ],
          DeskOutlineButton(
            label: 'إعادة فتح الامتحان لجميع الطلاب',
            icon: Icons.lock_open_rounded,
            color: DeskColors.primary,
            onPressed: () => ExamResultsActions.resetAll(
                context, cubit: _cubit, examId: widget.examId),
          ),
          SizedBox(height: 16.h),
          ...sortedEntries.map((entry) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: StudentGroupCard(
              studentId: entry.key,
              attempts: entry.value,
              onReopen: () => ExamResultsActions.resetStudent(
                context,
                cubit: _cubit,
                examId: widget.examId,
                studentId: entry.key,
                studentName: ExamResultsHelpers.studentName(entry.value),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, _SortBy sort, IconData icon) {
    final isSelected = _sortBy == sort;
    return GestureDetector(
      onTap: () => setState(() => _sortBy = sort),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: isSelected ? DeskColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? DeskColors.primary : DeskColors.line,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14.r,
              color: isSelected ? Colors.white : DeskColors.muted,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : DeskColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
