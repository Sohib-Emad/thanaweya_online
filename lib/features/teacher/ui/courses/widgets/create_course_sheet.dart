import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/services/teacher_realtime_service.dart';
import 'package:thanaweya_online/core/supabase/storage_helper.dart';
import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_courses_repo.dart';

/// Modal bottom sheet for creating a new course.
class CreateCourseSheet extends StatefulWidget {
  final VoidCallback onCourseCreated;

  const CreateCourseSheet({super.key, required this.onCourseCreated});

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onCourseCreated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateCourseSheet(onCourseCreated: onCourseCreated),
    );
  }

  @override
  State<CreateCourseSheet> createState() => _CreateCourseSheetState();
}

class _CreateCourseSheetState extends State<CreateCourseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _introVideoController = TextEditingController();

  final _picker = ImagePicker();
  XFile? _coverImage;
  bool _isPublished = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _introVideoController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    HapticFeedback.lightImpact();
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file != null && mounted) {
        setState(() => _coverImage = file);
      }
    } catch (e) {
      debugPrint('Error picking cover: $e');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final uid =
        Supabase.instance.client.auth.currentUser?.id ??
        Supabase.instance.client.auth.currentSession?.user.id;

    if (uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى تسجيل الدخول أولاً')));
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);

    try {
      String? coverUrl;
      final tempCourseId = DateTime.now().millisecondsSinceEpoch.toString();

      if (_coverImage != null) {
        try {
          coverUrl = await StorageHelper.uploadCourseCover(
            teacherId: uid,
            courseId: tempCourseId,
            file: _coverImage!,
          );
        } catch (e) {
          debugPrint('Failed to upload cover: $e');
        }
      }

      final priceVal = double.tryParse(_priceController.text.trim());
      final introVal = _introVideoController.text.trim();

      final result = await TeacherCoursesRepo().createCourse(
        teacherId: uid,
        title: _titleController.text.trim(),
        description: _descController.text.trim().isNotEmpty
            ? _descController.text.trim()
            : null,
        price: priceVal,
        coverImageUrl: coverUrl,
        introVideoUrl: introVal.isNotEmpty ? introVal : null,
        introVideoSourceType: introVal.isNotEmpty ? 'youtube' : null,
        isPublished: _isPublished,
      );

      result.when(
        success: (_) {
          if (mounted) {
            Navigator.pop(context);
            widget.onCourseCreated();
            TeacherRealtimeService.instance.notifyCoursesChanged();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم إنشاء الدورة بنجاح 🎉'),
                backgroundColor: DeskColors.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        failure: (message, _) {
          if (mounted) {
            setState(() => _isSaving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء إنشاء الدورة: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(
          20.w,
          16.h,
          20.w,
          MediaQuery.of(context).viewInsets.bottom + 20.h,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 44.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: const Icon(
                            Icons.video_library_rounded,
                            color: Color(0xFF0284C7),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'إنشاء دورة تعليمية جديدة',
                          style: GoogleFonts.cairo(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                const Divider(height: 1),
                SizedBox(height: 16.h),

                // Cover Image Picker
                Text(
                  'صورة غلاف الكورس',
                  style: GoogleFonts.cairo(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF334155),
                  ),
                ),
                SizedBox(height: 8.h),
                GestureDetector(
                  onTap: _pickCoverImage,
                  child: Container(
                    height: 120.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: _coverImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14.r),
                            child: Image.file(
                              File(_coverImage!.path),
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 36.r,
                                color: const Color(0xFF0284C7),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                'اضغط لاختيار صورة الغلاف',
                                style: GoogleFonts.cairo(
                                  fontSize: 11.5.sp,
                                  color: const Color(0xFF64748B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                SizedBox(height: 16.h),

                // Course Title
                Text(
                  'عنوان الكورس / الدورة *',
                  style: GoogleFonts.cairo(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF334155),
                  ),
                ),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: _titleController,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'برجاء إدخال عنوان الكورس'
                      : null,
                  style: GoogleFonts.cairo(fontSize: 13.sp),
                  decoration: InputDecoration(
                    hintText: 'مثال: مراجعة الفيزياء العامة - الفصل الأول',
                    hintStyle: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      color: const Color(0xFF94A3B8),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
                SizedBox(height: 14.h),

                // Course Description
                Text(
                  'وصف الكورس والأهداف التعليمية',
                  style: GoogleFonts.cairo(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF334155),
                  ),
                ),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  style: GoogleFonts.cairo(fontSize: 13.sp),
                  decoration: InputDecoration(
                    hintText: 'شرح مختصر لمحتوى الدورة وما سيتعلمه الطالب...',
                    hintStyle: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      color: const Color(0xFF94A3B8),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
                SizedBox(height: 14.h),

                // Course Price & Video URL
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'السعر (ج.م)',
                            style: GoogleFonts.cairo(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF334155),
                            ),
                          ),
                          SizedBox(height: 6.h),
                          TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.cairo(fontSize: 13.sp),
                            decoration: InputDecoration(
                              hintText: '0 = مجاني/باقة',
                              hintStyle: GoogleFonts.cairo(
                                fontSize: 11.5.sp,
                                color: const Color(0xFF94A3B8),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 12.h,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'رابط فيديو المقدمة',
                            style: GoogleFonts.cairo(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF334155),
                            ),
                          ),
                          SizedBox(height: 6.h),
                          TextFormField(
                            controller: _introVideoController,
                            style: GoogleFonts.cairo(fontSize: 13.sp),
                            decoration: InputDecoration(
                              hintText: 'YouTube URL',
                              hintStyle: GoogleFonts.cairo(
                                fontSize: 11.5.sp,
                                color: const Color(0xFF94A3B8),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 12.h,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),

                // Publish Switch
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isPublished
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: _isPublished
                                ? const Color(0xFF059669)
                                : const Color(0xFF64748B),
                            size: 20.r,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            _isPublished
                                ? 'نشر الدورة فوراً للطلاب'
                                : 'حفظ كمسودة فقط',
                            style: GoogleFonts.cairo(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _isPublished,
                        activeThumbColor: const Color(0xFF0284C7),
                        onChanged: (v) => setState(() => _isPublished = v),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'إنشاء ونشر الدورة الآن',
                            style: GoogleFonts.cairo(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
