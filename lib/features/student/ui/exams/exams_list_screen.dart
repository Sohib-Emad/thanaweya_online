import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
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
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            'التقدم والامتحانات 📊',
            style: GoogleFonts.cairo(
              fontSize: 19.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        body: BlocBuilder<StudentExamsCubit, StudentExamsState>(
          bloc: _cubit,
          builder: (context, state) {
            if (state.status == StudentExamsStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == StudentExamsStatus.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
                    SizedBox(height: 12.h),
                    Text(state.errorMessage ?? 'حدث خطأ',
                        style: GoogleFonts.cairo(fontSize: 14.sp, color: const Color(0xFF64748B))),
                  ],
                ),
              );
            }
            if (state.availableExams.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.quiz_outlined, size: 64, color: const Color(0xFF94A3B8)),
                    SizedBox(height: 16.h),
                    Text('لا توجد امتحانات متاحة حالياً',
                        style: GoogleFonts.cairo(fontSize: 16.sp, color: const Color(0xFF64748B))),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: _loadExams,
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 100.h),
                itemCount: state.availableExams.length,
                itemBuilder: (context, index) {
                  final exam = state.availableExams[index];
                  final title = exam['title'] as String? ?? '';
                  final duration = exam['duration_minutes'] as int? ?? 0;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pushNamed(
                        context,
                        AppRouter.studentExamStart,
                        arguments: exam,
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                        boxShadow: const [
                          BoxShadow(color: Color(0x060F172A), blurRadius: 10, offset: Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12.r),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: Icon(Icons.quiz_rounded,
                                    color: const Color(0xFF2563EB), size: 22.r),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(title,
                                        style: GoogleFonts.cairo(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF0F172A)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    SizedBox(height: 2.h),
                                    Text(
                                      'مدة الامتحان: $duration دقيقة',
                                      style: GoogleFonts.cairo(
                                          fontSize: 11.sp, color: const Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          SizedBox(height: 12.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.timer_outlined, size: 14.r, color: const Color(0xFF64748B)),
                                  SizedBox(width: 4.w),
                                  Text('$duration دقيقة',
                                      style: GoogleFonts.cairo(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF64748B))),
                                ],
                              ),
                              Container(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Row(
                                  children: [
                                    Text('دخول الامتحان',
                                        style: GoogleFonts.cairo(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white)),
                                    SizedBox(width: 4.w),
                                    Icon(Icons.arrow_forward_rounded,
                                        color: Colors.white, size: 12.r),
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
            );
          },
        ),
      ),
    );
  }
}
