import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/features/shared/models/exam_model.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_exams_repo.dart';
import 'package:thanaweya_online/features/teacher/logic/teacher_exams_cubit.dart';

class ExamsListScreen extends StatefulWidget {
  const ExamsListScreen({super.key});

  @override
  State<ExamsListScreen> createState() => _ExamsListScreenState();
}

class _ExamsListScreenState extends State<ExamsListScreen> {
  final _cubit = TeacherExamsCubit(repo: TeacherExamsRepo());

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
      _cubit.loadExams(userId);
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
          leading: IconButton(
            icon: Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFF0F172A),
              size: 28.r,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            'اختبارات المادة',
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        body: BlocBuilder<TeacherExamsCubit, TeacherExamsState>(
          bloc: _cubit,
          builder: (context, state) {
            if (state.status == TeacherExamsStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == TeacherExamsStatus.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 48.r, color: AppColors.error),
                    SizedBox(height: 12.h),
                    Text(
                      state.errorMessage ?? 'حدث خطأ أثناء تحميل الاختبارات',
                      style: GoogleFonts.cairo(fontSize: 14.sp, color: AppColors.textSecondary),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: _loadExams,
                      child: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
                    ),
                  ],
                ),
              );
            }
            if (state.exams.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.quiz_rounded, size: 64.r, color: AppColors.textTertiary),
                    SizedBox(height: 16.h),
                    Text(
                      'لا توجد اختبارات بعد',
                      style: GoogleFonts.cairo(fontSize: 16.sp, color: AppColors.textSecondary),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'اضغط على زر + لإنشاء أول اختبار',
                      style: GoogleFonts.cairo(fontSize: 13.sp, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: _loadExams,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                itemCount: state.exams.length,
                separatorBuilder: (_, __) => SizedBox(height: 14.h),
                itemBuilder: (context, index) {
                  final exam = state.exams[index];
                  return _ExamCard(
                    title: exam.title,
                    duration: exam.durationMinutes,
                    isPublished: exam.isPublished,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pushNamed(
                        context,
                        AppRouter.teacherAddQuestion,
                        arguments: exam.id,
                      );
                    },
                    onDelete: () => _cubit.deleteExam(exam.id),
                    onPublish: () => _cubit.publishExam(exam.id),
                  );
                },
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: null,
          onPressed: () {
            HapticFeedback.lightImpact();
            _showAddExamModal(context);
          },
          backgroundColor: AppColors.teacherPrimary,
          elevation: 4,
          icon: Icon(Icons.add_rounded, color: Colors.white, size: 22.r),
          label: Text(
            'إنشاء اختبار جديد',
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _showAddExamModal(BuildContext context) {
    final titleController = TextEditingController();
    final durationController = TextEditingController(text: '45');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: 24.h,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'إنشاء اختبار إلكتروني جديد',
                      style: GoogleFonts.cairo(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        color: const Color(0xFF94A3B8),
                        size: 22.r,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  'عنوان الاختبار*',
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 6.h),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'مثال: اختبار الفصل الأول - الكهربية والتكثيف',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  'مدة الاختبار بالدقائق*',
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 6.h),
                TextField(
                  controller: durationController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '45',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: () {
                      final title = titleController.text.trim();
                      final duration = int.tryParse(durationController.text) ?? 45;
                      if (title.isEmpty) return;

                      final userId = Supabase.instance.client.auth.currentUser?.id;
                      if (userId != null) {
                        _cubit.createExam(
                          teacherId: userId,
                          title: title,
                          durationMinutes: duration,
                          startAt: DateTime.now(),
                          endAt: DateTime.now().add(const Duration(days: 30)),
                        );
                      }
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('جاري إنشاء الاختبار...')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.teacherPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                    child: Text(
                      'متابعة وإضافة الأسئلة',
                      style: GoogleFonts.cairo(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ExamCard extends StatelessWidget {
  final String title;
  final int duration;
  final bool isPublished;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onPublish;

  const _ExamCard({
    required this.title,
    required this.duration,
    required this.isPublished,
    required this.onTap,
    required this.onDelete,
    required this.onPublish,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x060F172A),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52.r,
              height: 52.r,
              decoration: BoxDecoration(
                color: isPublished ? const Color(0xFFECFDF5) : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                Icons.assignment_turned_in_rounded,
                color: isPublished ? const Color(0xFF0FA37F) : const Color(0xFFD97706),
                size: 26.r,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: isPublished ? null : onPublish,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: isPublished ? const Color(0xFFECFDF5) : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            isPublished ? 'منشور ✓' : 'مسودة ⏳',
                            style: GoogleFonts.cairo(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w800,
                              color: isPublished ? const Color(0xFF0FA37F) : const Color(0xFFD97706),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.timer_outlined, size: 13.r, color: const Color(0xFF64748B)),
                      SizedBox(width: 4.w),
                      Text(
                        '$duration دقيقة',
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline_rounded, color: Colors.red[300], size: 20.r),
            ),
            Icon(Icons.chevron_left_rounded, size: 24.r, color: const Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}
