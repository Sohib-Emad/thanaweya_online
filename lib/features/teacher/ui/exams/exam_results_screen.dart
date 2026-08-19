import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_exams_repo.dart';
import 'package:thanaweya_online/features/teacher/logic/teacher_exam_results_cubit.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/widgets/widgets.dart';

/// Screen showing all student submissions for a single exam.
class ExamResultsScreen extends StatefulWidget {
  const ExamResultsScreen({super.key, required this.examId, required this.examTitle});

  final String examId;
  final String examTitle;

  @override
  State<ExamResultsScreen> createState() => _ExamResultsScreenState();
}

class _ExamResultsScreenState extends State<ExamResultsScreen> {
  late final TeacherExamResultsCubit _cubit;

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
        appBar: DeskTopBar(title: 'نتائج الامتحان', subtitle: widget.examTitle),
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

    final groups = ExamResultsHelpers.groupByStudent(state.submissions);

    return RefreshIndicator(
      onRefresh: _load,
      color: DeskColors.primary,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        children: [
          ResultsSummaryBar(groups: groups),
          SizedBox(height: 16.h),
          if (groups.isNotEmpty) ...[
            TopPerformersSection(groups: groups),
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
          ...groups.entries.map((entry) => Padding(
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
}
