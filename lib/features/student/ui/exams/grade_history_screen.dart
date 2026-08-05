import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/student/data/repos/student_exams_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_exams_cubit.dart';

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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: NotebookColors.ground,
        appBar: NotebookTopBar(
          title: 'سجل الدرجات',
          subtitle: 'نتائج امتحاناتك على صفحات الدفتر',
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
                    message:
                        state.errorMessage ?? 'حدث خطأ في تحميل الدرجات',
                  ),
                );
              }
              if (state.submissions.isEmpty) {
                return Padding(
                  padding: EdgeInsets.all(24.w),
                  child: NotebookEmptyNote(
                    icon: Icons.score_outlined,
                    message: 'لا توجد درجات بعد\nقم بحل امتحان لتظهر نتيجتك هنا',
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
                    final exam = sub['exams'] as Map<String, dynamic>? ?? {};
                    final score = sub['score'] as int? ?? 0;
                    final total = sub['total_points'] as int? ?? 0;
                    final percent =
                        total > 0 ? (score / total * 100).toInt() : 0;
                    final isPass = percent >= 50;
                    final accent =
                        isPass
                            ? NotebookColors.green
                            : NotebookColors.marginRed;

                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: NotebookCard(
                        ruled: true,
                        ruledStartY: 64,
                        child: Row(
                          children: [
                            Container(
                              width: 44.r,
                              height: 44.r,
                              decoration: BoxDecoration(
                                color: accent.withAlpha(24),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: accent.withAlpha(90),
                                  width: 1.2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '$percent%',
                                  style: NotebookText.strong(
                                    12.sp,
                                    color: accent,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exam['title'] as String? ?? '',
                                    style: NotebookText.heading(13.sp),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    '$score / $total',
                                    style: NotebookText.note(11.sp),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
