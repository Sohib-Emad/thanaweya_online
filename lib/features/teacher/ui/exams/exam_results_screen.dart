// ────────────────────────────────────────────────────────────
// DIRECTION CONTRACT — معلم · السبورة الطباشير (the chalkboard)
// EXAM RESULTS BOARD: the submissions of one exam are pinned to the
//   board as chalk rows — each student's name, score/total, percentage
//   and submission time, stamped ناجح (mint) or راسب (red) or لم يكتمل
//   (yellow). Rows load from the real `exam_submissions` table (joined
//   with students→users), no mock data.
// FIRST VIEWPORT — chalkboard ground, top bar with the exam title, a
//   summary line (عدد المشاركين / متوسط الدرجات), then the rows.
// FINISH — loading/error/empty states handled; ends flutter analyze clean.
// ────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/chalkboard_theme.dart';
import 'package:thanaweya_online/core/utils/formatters.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_exams_repo.dart';
import 'package:thanaweya_online/features/teacher/logic/teacher_exam_results_cubit.dart';

class ExamResultsScreen extends StatefulWidget {
  final String examId;
  final String examTitle;

  const ExamResultsScreen({
    super.key,
    required this.examId,
    required this.examTitle,
  });

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

  Future<void> _load() async {
    _cubit.loadSubmissions(widget.examId);
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
          title: 'نتائج الامتحان',
          subtitle: widget.examTitle,
        ),
        body: ChalkboardSurface(
          child: BlocBuilder<TeacherExamResultsCubit, TeacherExamResultsState>(
            bloc: _cubit,
            builder: (context, state) {
              if (state.status == TeacherExamResultsStatus.loading &&
                  state.submissions.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: ChalkboardColors.accent,
                  ),
                );
              }
              if (state.status == TeacherExamResultsStatus.error &&
                  state.submissions.isEmpty) {
                return Center(
                  child: ChalkEmptyNote(
                    message:
                        state.errorMessage ?? 'حدث خطأ أثناء تحميل النتائج',
                    icon: Icons.error_outline_rounded,
                    actionLabel: 'إعادة المحاولة',
                    onAction: _load,
                  ),
                );
              }
              if (state.submissions.isEmpty) {
                return ChalkEmptyNote(
                  message: 'لا توجد مشاركات بعد',
                  subMessage: 'لم يشارك أي طالب في هذا الامتحان حتى الآن',
                  icon: Icons.how_to_reg_outlined,
                );
              }
              final best = _bestScore(state.submissions);
              final average = _averageScore(state.submissions);
              return RefreshIndicator(
                onRefresh: _load,
                color: ChalkboardColors.accent,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                  children: [
                    ChalkCard(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      child: Row(
                        children: [
                          _SummaryCell(
                            icon: Icons.people_alt_outlined,
                            label: 'المشاركون',
                            value: '${state.submissions.length}',
                            color: ChalkboardColors.chalkBlue,
                          ),
                          Container(
                            width: 1,
                            height: 30.h,
                            color: ChalkboardColors.ink.withAlpha(45),
                          ),
                          _SummaryCell(
                            icon: Icons.stars_outlined,
                            label: 'أعلى درجة',
                            value: '$best',
                            color: ChalkboardColors.chalkYellow,
                          ),
                          Container(
                            width: 1,
                            height: 30.h,
                            color: ChalkboardColors.ink.withAlpha(45),
                          ),
                          _SummaryCell(
                            icon: Icons.analytics_outlined,
                            label: 'المتوسط',
                            value: average.toStringAsFixed(1),
                            color: ChalkboardColors.accent,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ...state.submissions.asMap().entries.map((entry) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _ResultRow(
                          submission: entry.value,
                          index: entry.key + 1,
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  double _bestScore(List<Map<String, dynamic>> submissions) {
    double best = 0;
    for (final s in submissions) {
      final score = (s['score'] as num?)?.toDouble();
      final total = (s['total_points'] as num?)?.toDouble() ?? 0;
      if (score != null && total > 0) {
        final pct = score / total * 100;
        if (pct > best) best = pct;
      }
    }
    return best;
  }

  double _averageScore(List<Map<String, dynamic>> submissions) {
    if (submissions.isEmpty) return 0;
    double sum = 0;
    int counted = 0;
    for (final s in submissions) {
      final score = (s['score'] as num?)?.toDouble();
      final total = (s['total_points'] as num?)?.toDouble() ?? 0;
      if (score != null && total > 0) {
        sum += score / total * 100;
        counted++;
      }
    }
    return counted == 0 ? 0 : sum / counted;
  }
}

class _SummaryCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryCell({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14.r, color: color),
              SizedBox(width: 4.w),
              Text(
                value,
                style: ChalkboardText.heading(16.sp, color: color),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(label, style: ChalkboardText.note(10.sp)),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final Map<String, dynamic> submission;
  final int index;

  const _ResultRow({required this.submission, required this.index});

  @override
  Widget build(BuildContext context) {
    final students = submission['students'] as Map<String, dynamic>? ?? {};
    final users = students['users'] as Map<String, dynamic>? ?? {};
    final name = users['full_name'] as String? ?? 'طالب';
    final score = (submission['score'] as num?)?.toDouble();
    final total = (submission['total_points'] as num?)?.toInt() ?? 0;
    final submittedAt = submission['submitted_at'] as String?;

    final completed = score != null && submittedAt != null;
    final percentage = completed && total > 0
        ? (score / total * 100).clamp(0, 100)
        : 0.0;
    final passed = completed && percentage >= 50;

    final Color statusColor = !completed
        ? ChalkboardColors.chalkYellow
        : passed
            ? ChalkboardColors.accent
            : ChalkboardColors.chalkRed;
    final String statusLabel = !completed
        ? 'لم يكتمل'
        : passed
            ? 'ناجح'
            : 'راسب';

    return ChalkCard(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 26.r,
            height: 26.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: statusColor.withAlpha(22),
              shape: BoxShape.circle,
              border: Border.all(color: statusColor.withAlpha(120)),
            ),
            child: Text(
              '$index',
              style: ChalkboardText.strong(11.sp, color: statusColor),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: ChalkboardText.strong(13.5.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3.h),
                Text(
                  completed
                      ? Formatters.formatDateTime(
                          DateTime.parse(submittedAt))
                      : 'بدأ ولم يسلم الإجابة',
                  style: ChalkboardText.note(10.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                completed
                    ? '${score.toStringAsFixed(0)} / $total'
                    : '$total نقطة',
                style: ChalkboardText.strong(13.sp),
              ),
              SizedBox(height: 4.h),
              ChalkStatusChip(
                label: completed
                    ? '$percentage%'
                    : statusLabel,
                color: statusColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
