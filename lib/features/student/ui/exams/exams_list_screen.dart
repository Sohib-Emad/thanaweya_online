import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/student/data/repos/student_exams_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_exams_cubit.dart';

class StudentExamsListScreen extends StatefulWidget {
  const StudentExamsListScreen({super.key});

  @override
  State<StudentExamsListScreen> createState() => _StudentExamsListScreenState();
}

class _StudentExamsListScreenState extends State<StudentExamsListScreen> {
  final _cubit = StudentExamsCubit(repo: StudentExamsRepo());

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _loadExams() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      _cubit.loadAvailableExams(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: NotebookColors.ground,
        appBar: NotebookTopBar(
          title: 'التقدم والامتحانات',
          subtitle: 'اختبر ما درسته على أوراق دفترك',
        ),
        body: BlocBuilder<StudentExamsCubit, StudentExamsState>(
          bloc: _cubit,
          builder: (context, state) {
            if (state.status == StudentExamsStatus.loading) {
              return Center(
                child: CircularProgressIndicator(color: NotebookColors.green),
              );
            }
            if (state.status == StudentExamsStatus.error) {
              return Padding(
                padding: EdgeInsets.all(24.w),
                child: NotebookEmptyNote(
                  icon: Icons.error_outline_rounded,
                  message: state.errorMessage ?? 'حدث خطأ في تحميل الامتحانات',
                ),
              );
            }
            if (state.availableExams.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: NotebookEmptyNote(
                  icon: Icons.quiz_outlined,
                  message: 'لا توجد امتحانات متاحة حالياً\nستظهر هنا امتحاناتك عندما يضيفها المدرسون',
                ),
              );
            }
            return NotebookPaper(
              child: RefreshIndicator(
                onRefresh: _loadExams,
                color: NotebookColors.green,
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 100.h),
                  itemCount: state.availableExams.length,
                  itemBuilder: (context, index) {
                    final exam = state.availableExams[index];
                    final title = exam['title'] as String? ?? '';
                    final duration = exam['duration_minutes'] as int? ?? 0;
                    final subject = (exam['subject_name'] as String?) ?? '';

                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: NotebookCard(
                        ruled: true,
                        ruledStartY: 92,
                        marginTab: true,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pushNamed(
                            context,
                            AppRouter.studentExamStart,
                            arguments: exam,
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (subject.isNotEmpty)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 3.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: NotebookColors.green,
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      subject,
                                      style: GoogleFonts.cairo(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                const Spacer(),
                                Icon(
                                  Icons.quiz_rounded,
                                  color: NotebookColors.pencil,
                                  size: 20.r,
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              title,
                              style: NotebookText.heading(14.sp),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'مدة الامتحان: $duration دقيقة',
                              style: NotebookText.note(11.sp),
                            ),
                            SizedBox(height: 14.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.timer_outlined,
                                      size: 14.r,
                                      color: NotebookColors.pencil,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      '$duration دقيقة',
                                      style: NotebookText.strong(
                                        11.sp,
                                        color: NotebookColors.pencil,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                    vertical: 7.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: NotebookColors.green,
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        'دخول الامتحان',
                                        style: NotebookText.strong(
                                          11.sp,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 12.r,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
