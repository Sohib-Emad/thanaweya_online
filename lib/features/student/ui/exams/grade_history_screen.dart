import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/student/data/repos/student_exams_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_exams_cubit.dart';
import 'package:thanaweya_online/features/student/ui/exams/widgets/grade_card.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Screen showing the student's full grade history across all exams.
class GradeHistoryScreen extends StatefulWidget {
  const GradeHistoryScreen({super.key});

  @override
  State<GradeHistoryScreen> createState() => _GradeHistoryScreenState();
}

class _GradeHistoryScreenState extends State<GradeHistoryScreen> {
  final _cubit = StudentExamsCubit(repo: StudentExamsRepo());

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _loadSubmissions() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      _cubit.loadSubmissions(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: NotebookColors.ground,
      appBar: NotebookTopBar(
        title: l10n.gradeHistoryTitle,
        subtitle: l10n.gradeHistorySubtitle,
      ),
      body: NotebookPaper(
        child: BlocBuilder<StudentExamsCubit, StudentExamsState>(
          bloc: _cubit,
          builder: (context, state) {
            if (state.submissionsStatus == StudentExamsStatus.loading) {
              return Center(
                child: CircularProgressIndicator(color: NotebookColors.green),
              );
            }
            if (state.submissionsStatus == StudentExamsStatus.error) {
              return Padding(
                padding: EdgeInsets.all(24.w),
                child: NotebookEmptyNote(
                  icon: Icons.error_outline_rounded,
                  message: state.errorMessage ?? l10n.loadGradesError,
                ),
              );
            }
            if (state.submissions.isEmpty) {
              return Padding(
                padding: EdgeInsets.all(24.w),
                child: NotebookEmptyNote(
                  icon: Icons.score_outlined,
                  message: l10n.noGradesYet,
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: _loadSubmissions,
              color: NotebookColors.green,
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 40.h),
                itemCount: state.submissions.length,
                itemBuilder: (context, index) {
                  final sub = state.submissions[index];
                  final exam =
                      sub['exams'] as Map<String, dynamic>? ?? {};
                  return GradeCard(
                    examTitle: exam['title'] as String? ?? '',
                    score: sub['score'] as int? ?? 0,
                    totalPoints: sub['total_points'] as int? ?? 0,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
