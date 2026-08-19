import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/student/data/repos/student_exams_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_exams_cubit.dart';
import 'package:thanaweya_online/features/student/ui/exams/widgets/attempt_card.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Shows the student's attempts (results) for one exam.
class ExamAttemptsScreen extends StatefulWidget {
  final String examId;
  final String examTitle;

  const ExamAttemptsScreen({
    super.key,
    required this.examId,
    required this.examTitle,
  });

  @override
  State<ExamAttemptsScreen> createState() => _ExamAttemptsScreenState();
}

class _ExamAttemptsScreenState extends State<ExamAttemptsScreen> {
  final _cubit = StudentExamsCubit(repo: StudentExamsRepo());

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _load() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      _cubit.loadExamAttempts(examId: widget.examId, studentId: userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: NotebookColors.ground,
      appBar: NotebookTopBar(
        title: l10n.examResultsTitle,
        subtitle: widget.examTitle,
      ),
      body: NotebookPaper(
        child: BlocBuilder<StudentExamsCubit, StudentExamsState>(
          bloc: _cubit,
          builder: (context, state) {
            if (state.attemptsStatus == StudentExamsStatus.loading) {
              return Center(
                child: CircularProgressIndicator(color: NotebookColors.green),
              );
            }
            if (state.attemptsStatus == StudentExamsStatus.error) {
              return Padding(
                padding: EdgeInsets.all(24.w),
                child: NotebookEmptyNote(
                  icon: Icons.error_outline_rounded,
                  message: state.errorMessage ?? l10n.loadResultsError,
                ),
              );
            }
            if (state.attempts.isEmpty) {
              return _buildEmptyState(l10n);
            }
            return _buildAttemptsList(l10n, state.attempts);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return RefreshIndicator(
      onRefresh: _load,
      color: NotebookColors.green,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 100.h),
            child: NotebookEmptyNote(
              icon: Icons.quiz_outlined,
              message: l10n.noAttemptsYet,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttemptsList(
    AppLocalizations l10n,
    List<Map<String, dynamic>> attempts,
  ) {
    return RefreshIndicator(
      onRefresh: _load,
      color: NotebookColors.green,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 40.h),
        itemCount: attempts.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: EdgeInsets.only(bottom: 14.h),
              child: NotebookHighlightNote(
                margin: EdgeInsets.zero,
                child: Text(
                  l10n.attemptsCountLabel(attempts.length),
                  style: NotebookText.strong(12.sp),
                ),
              ),
            );
          }
          final attempt = attempts[index - 1];
          return AttemptCard(
            index: index,
            score: attempt['score'] as int? ?? 0,
            totalPoints: attempt['total_points'] as int? ?? 0,
            submittedAt: attempt['submitted_at'] as String?,
            dateFormatter: _formatDate,
          );
        },
      ),
    );
  }

  String _formatDate(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final local = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)}/${local.year} - '
        '${two(local.hour)}:${two(local.minute)}';
  }
}
