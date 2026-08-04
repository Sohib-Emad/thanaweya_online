import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/features/shared/models/course_model.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_courses_repo.dart';
import 'package:thanaweya_online/features/teacher/logic/teacher_courses_cubit.dart';

class CoursesListScreen extends StatefulWidget {
  const CoursesListScreen({super.key});

  @override
  State<CoursesListScreen> createState() => _CoursesListScreenState();
}

class _CoursesListScreenState extends State<CoursesListScreen> {
  final _cubit = TeacherCoursesCubit(repo: TeacherCoursesRepo());

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      _cubit.loadCourses(userId);
    }
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
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Navigator.canPop(context)
              ? IconButton(
                  icon: Icon(
                    Icons.chevron_right_rounded,
                    color: const Color(0xFF0F172A),
                    size: 28.r,
                  ),
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                )
              : null,
          centerTitle: true,
          title: Text(
            AppStrings.myCourses,
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        body: BlocBuilder<TeacherCoursesCubit, TeacherCoursesState>(
          bloc: _cubit,
          builder: (context, state) {
            if (state.status == TeacherCoursesStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == TeacherCoursesStatus.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 48.r, color: AppColors.error),
                    SizedBox(height: 12.h),
                    Text(
                      state.errorMessage ?? 'حدث خطأ أثناء تحميل الدورات',
                      style: GoogleFonts.cairo(fontSize: 14.sp, color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: _loadCourses,
                      child: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
                    ),
                  ],
                ),
              );
            }
            if (state.courses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.menu_book_rounded, size: 64.r, color: AppColors.textTertiary),
                    SizedBox(height: 16.h),
                    Text(
                      'لا توجد دورات بعد',
                      style: GoogleFonts.cairo(fontSize: 16.sp, color: AppColors.textSecondary),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'اضغط على زر + لإنشاء أول دورة',
                      style: GoogleFonts.cairo(fontSize: 13.sp, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: _loadCourses,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                itemCount: state.courses.length,
                separatorBuilder: (_, __) => SizedBox(height: 14.h),
                itemBuilder: (context, index) {
                  final course = state.courses[index];
                  return _CourseCard(
                    title: course.title,
                    description: course.description ?? '',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pushNamed(
                        context,
                        AppRouter.teacherLessons,
                        arguments: course.id,
                      );
                    },
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
            _showAddCourseBottomSheet(context);
          },
          backgroundColor: AppColors.teacherPrimary,
          elevation: 4,
          icon: Icon(Icons.add_rounded, color: Colors.white, size: 22.r),
          label: Text(
            AppStrings.createCourse,
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

  void _showAddCourseBottomSheet(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

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
                      'إنشاء دورة تعليمية جديدة',
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
                  'عنوان الدورة*',
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 6.h),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'مثال: مراجعة الفيزياء للثانوية العامة...',
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
                  'وصف الدورة*',
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 6.h),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'اكتب وصفاً موجزاً لما تتضمنه الكورس...',
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
                      final description = descController.text.trim();
                      if (title.isEmpty) return;

                      final userId = Supabase.instance.client.auth.currentUser?.id;
                      if (userId != null) {
                        _cubit.createCourse(
                          teacherId: userId,
                          title: title,
                          description: description.isNotEmpty ? description : null,
                        );
                      }
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('جاري إنشاء الدورة...')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.teacherPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                    child: Text(
                      'حفظ الدورة',
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

class _CourseCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onTap;

  const _CourseCard({
    required this.title,
    required this.description,
    required this.onTap,
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
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                Icons.auto_stories_rounded,
                color: const Color(0xFF2563EB),
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
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      color: const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_left_rounded,
              size: 24.r,
              color: const Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }
}
