import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_courses_repo.dart';
import 'package:thanaweya_online/features/teacher/logic/teacher_courses_cubit.dart';

class AddLessonScreen extends StatefulWidget {
  final String courseId;

  const AddLessonScreen({super.key, required this.courseId});

  @override
  State<AddLessonScreen> createState() => _AddLessonScreenState();
}

class _AddLessonScreenState extends State<AddLessonScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _youtubeController = TextEditingController();
  bool _isFreePreview = false;
  bool _isSaving = false;
  late final TeacherCoursesCubit _cubit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cubit = TeacherCoursesCubit(repo: TeacherCoursesRepo());
  }

  @override
  void dispose() {
    _cubit.close();
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _youtubeController.dispose();
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
            AppStrings.addLesson,
            style: GoogleFonts.outfit(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tab selector: Youtube vs Direct Upload
                  Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: AppColors.teacherPrimary,
                      unselectedLabelColor: const Color(0xFF64748B),
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      dividerColor: Colors.transparent,
                      labelStyle: GoogleFonts.outfit(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                      ),
                      unselectedLabelStyle: GoogleFonts.outfit(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      tabs: const [
                        Tab(text: AppStrings.youtubeLink),
                        Tab(text: AppStrings.uploadVideo),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  Text(
                    'عنوان الدرس*',
                    style: GoogleFonts.outfit(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  TextFormField(
                    controller: _titleController,
                    validator: (v) =>
                        v!.isEmpty ? AppStrings.fieldRequired : null,
                    decoration: InputDecoration(
                      hintText: 'أدخل اسم أو عنوان الدرس...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 14.h,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: const BorderSide(
                          color: AppColors.teacherPrimary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 18.h),

                  Text(
                    'وصف الدرس والتفاصيل',
                    style: GoogleFonts.outfit(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'اكتب الشرح المباشر والنقاط الهامة بالدرس...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 14.h,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: const BorderSide(
                          color: AppColors.teacherPrimary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 18.h),

                  Text(
                    'رابط الفيدو أو اليوتيوب*',
                    style: GoogleFonts.outfit(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  TextFormField(
                    controller: _youtubeController,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                      hintText: 'https://youtube.com/watch?v=...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 14.h,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: const BorderSide(
                          color: AppColors.teacherPrimary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Free Preview Switch Container
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: const BoxDecoration(
                            color: Color(0xFFECFDF5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.card_giftcard_rounded,
                            size: 20.r,
                            color: const Color(0xFF0FA37F),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.freePreview,
                                style: GoogleFonts.outfit(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                'السماح للطلاب غير المشتركين بمشاهدة هذا الدرس تجريبياً',
                                style: GoogleFonts.outfit(
                                  fontSize: 11.sp,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isFreePreview,
                          activeThumbColor: const Color(0xFF0FA37F),
                          onChanged: (v) {
                            HapticFeedback.selectionClick();
                            setState(() => _isFreePreview = v);
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32.h),

                  SizedBox(
                    width: double.infinity,
                    height: 54.h,
                    child: ElevatedButton(
                      onPressed: _isSaving
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                HapticFeedback.mediumImpact();
                                setState(() => _isSaving = true);

                                final videoType =
                                    _tabController.index == 0 ? 'youtube' : 'upload';
                                final userId = Supabase.instance.client
                                    .auth.currentUser?.id;

                                if (userId == null) {
                                  setState(() => _isSaving = false);
                                  return;
                                }

                                await _cubit.addLesson(
                                  courseId: widget.courseId,
                                  title: _titleController.text.trim(),
                                  description:
                                      _descriptionController.text.trim().isNotEmpty
                                          ? _descriptionController.text.trim()
                                          : null,
                                  videoSourceType: videoType,
                                  videoUrlOrId:
                                      _youtubeController.text.trim(),
                                  isFreePreview: _isFreePreview,
                                );

                                if (mounted) {
                                  setState(() => _isSaving = false);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('تم حفظ وإضافة الدرس بنجاح'),
                                      backgroundColor: Color(0xFF10B981),
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teacherPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                      child: _isSaving
                          ? SizedBox(
                              width: 24.r,
                              height: 24.r,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              AppStrings.save,
                              style: GoogleFonts.outfit(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
