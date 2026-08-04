import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/features/shared/widgets/app_card.dart';
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
        appBar: AppBar(title: const Text(AppStrings.gradesTab)),
        body: BlocBuilder<StudentExamsCubit, StudentExamsState>(
          bloc: _cubit,
          builder: (context, state) {
            if (state.submissionsStatus == StudentExamsStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.submissionsStatus == StudentExamsStatus.error) {
              return Center(
                child: Text(state.errorMessage ?? 'حدث خطأ', style: AppTextStyles.body1),
              );
            }
            if (state.submissions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.score_outlined, size: 64, color: AppColors.textTertiary),
                    SizedBox(height: 16.h),
                    Text('لا توجد درجات بعد', style: AppTextStyles.h3),
                    SizedBox(height: 8.h),
                    Text('قم بحل امتحان لتظهر نتيجتك هنا', style: AppTextStyles.caption),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: _loadSubmissions,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                itemCount: state.submissions.length,
                itemBuilder: (context, index) {
                  final sub = state.submissions[index];
                  final exam = sub['exams'] as Map<String, dynamic>? ?? {};
                  final score = sub['score'] as int? ?? 0;
                  final total = sub['total_points'] as int? ?? 0;
                  final percent = total > 0 ? (score / total * 100).toInt() : 0;
                  final isPass = percent >= 50;

                  return AppCard(
                    child: Row(
                      children: [
                        Container(
                          width: 44.r,
                          height: 44.r,
                          decoration: BoxDecoration(
                            color: isPass
                                ? AppColors.success.withValues(alpha: 0.1)
                                : AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Center(
                            child: Text(
                              '$percent%',
                              style: TextStyle(
                                color: isPass ? AppColors.success : AppColors.error,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(exam['title'] as String? ?? '', style: AppTextStyles.h3),
                              SizedBox(height: 2.h),
                              Text('$score / $total', style: AppTextStyles.caption),
                            ],
                          ),
                        ),
                      ],
                    ),
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
