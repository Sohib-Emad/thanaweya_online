import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_students_repo.dart';

class StudentCoursesSheet extends StatefulWidget {
  final Map<String, dynamic> student;
  final List<Map<String, dynamic>> teachers;
  final String? initialTeacherId;

  const StudentCoursesSheet({
    super.key,
    required this.student,
    required this.teachers,
    this.initialTeacherId,
  });

  @override
  State<StudentCoursesSheet> createState() => _StudentCoursesSheetState();
}

class _StudentCoursesSheetState extends State<StudentCoursesSheet> {
  final _repo = AdminStudentsRepo();
  String? _selectedTeacherId;
  bool _isLoading = true;
  List<Map<String, dynamic>> _courses = [];
  final Set<String> _processingCourseIds = {};

  @override
  void initState() {
    super.initState();
    // Default to initial teacher or first available teacher
    if (widget.initialTeacherId != null && widget.initialTeacherId!.isNotEmpty) {
      _selectedTeacherId = widget.initialTeacherId;
    } else if (widget.teachers.isNotEmpty) {
      _selectedTeacherId = widget.teachers.first['id'] as String?;
    }
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final tid = _selectedTeacherId;
    final sid = widget.student['student_id'] as String? ??
        widget.student['id'] as String? ??
        '';

    if (tid == null || tid.isEmpty || sid.isEmpty) {
      setState(() {
        _isLoading = false;
        _courses = [];
      });
      return;
    }

    setState(() => _isLoading = true);

    final res = await _repo.getStudentCoursesWithStatus(
      studentId: sid,
      teacherId: tid,
    );

    if (!mounted) return;

    res.when(
      success: (courses) {
        setState(() {
          _courses = courses;
          _isLoading = false;
        });
      },
      failure: (_, _) {
        setState(() {
          _courses = [];
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _toggleCourseAccess(Map<String, dynamic> course) async {
    final courseId = course['id'] as String? ?? '';
    final isCurrentlyUnlocked = course['is_unlocked'] == true;
    final sid = widget.student['student_id'] as String? ??
        widget.student['id'] as String? ??
        '';
    final tid = _selectedTeacherId;

    if (courseId.isEmpty || sid.isEmpty || tid == null) return;

    HapticFeedback.mediumImpact();
    setState(() => _processingCourseIds.add(courseId));

    if (isCurrentlyUnlocked) {
      // Lock course
      final res = await _repo.lockCourse(
        studentId: sid,
        teacherId: tid,
        courseId: courseId,
      );
      if (!mounted) return;
      res.when(
        success: (_) {
          setState(() {
            course['is_unlocked'] = false;
            _processingCourseIds.remove(courseId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم قفل الكورس عن الطالب بنجاح 🔒'),
              backgroundColor: Color(0xFFDC2626),
              duration: Duration(seconds: 2),
            ),
          );
        },
        failure: (msg, _) {
          setState(() => _processingCourseIds.remove(courseId));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل قفل الكورس: $msg'),
              backgroundColor: AppColors.error,
            ),
          );
        },
      );
    } else {
      // Unlock course
      final res = await _repo.unlockCourse(
        studentId: sid,
        teacherId: tid,
        courseId: courseId,
      );
      if (!mounted) return;
      res.when(
        success: (_) {
          setState(() {
            course['is_unlocked'] = true;
            _processingCourseIds.remove(courseId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم فتح الكورس للطالب وتفعيل الاشتراك بنجاح ✅'),
              backgroundColor: Color(0xFF16A34A),
              duration: Duration(seconds: 2),
            ),
          );
        },
        failure: (msg, _) {
          setState(() => _processingCourseIds.remove(courseId));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل فتح الكورس: $msg'),
              backgroundColor: AppColors.error,
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.student['users'] as Map<String, dynamic>? ?? {};
    final studentName = user['full_name'] as String? ?? 'الطالب';
    final studentPhone = user['phone'] as String? ?? '';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: 0.85.sh,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          children: [
            // Handle bar
            SizedBox(height: 12.h),
            Container(
              width: 44.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 16.h),

            // Header info
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24.r,
                    backgroundColor: AppColors.adminPrimaryLight,
                    child: Text(
                      studentName.isNotEmpty ? studentName[0] : 'ط',
                      style: GoogleFonts.cairo(
                        color: AppColors.adminPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 18.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إدارة كورسات $studentName',
                          style: AppTextStyles.h3.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 16.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (studentPhone.isNotEmpty)
                          Text(
                            'هاتف الطالب: $studentPhone',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            SizedBox(height: 14.h),
            const Divider(height: 1),

            // Teacher selector
            if (widget.teachers.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 8.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_pin_rounded,
                      size: 20.r,
                      color: AppColors.adminPrimary,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'اختر المعلم لعرض كورساته:',
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 42.h,
                margin: EdgeInsets.only(bottom: 12.h),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: widget.teachers.length,
                  separatorBuilder: (_, _) => SizedBox(width: 8.w),
                  itemBuilder: (context, index) {
                    final t = widget.teachers[index];
                    final tid = t['id'] as String? ?? '';
                    final users = t['users'] as Map<String, dynamic>? ?? {};
                    final tName = users['full_name'] as String? ?? 'معلم';
                    final isSelected = _selectedTeacherId == tid;

                    return ChoiceChip(
                      label: Text(tName),
                      selected: isSelected,
                      labelStyle: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                      selectedColor: AppColors.adminPrimary,
                      backgroundColor: AppColors.surface,
                      showCheckmark: false,
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.adminPrimary
                            : AppColors.cardBorder,
                      ),
                      onSelected: (selected) {
                        if (selected && _selectedTeacherId != tid) {
                          setState(() {
                            _selectedTeacherId = tid;
                          });
                          _loadCourses();
                        }
                      },
                    );
                  },
                ),
              ),
            ],

            const Divider(height: 1),

            // Courses list
            Expanded(
              child: _buildCoursesContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 54.r,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: 12.h),
            Text(
              'لا توجد كورسات مضافة لهذا المعلم حالياً',
              style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(20.r),
      itemCount: _courses.length,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final course = _courses[index];
        final courseId = course['id'] as String? ?? '';
        final title = course['title'] as String? ?? 'كورس تعليمي';
        final coverUrl = course['cover_image_url'] as String? ?? '';
        final price = course['price'];
        final isUnlocked = course['is_unlocked'] == true;
        final isProcessing = _processingCourseIds.contains(courseId);

        return Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isUnlocked
                  ? const Color(0xFF16A34A).withValues(alpha: 0.5)
                  : AppColors.cardBorder,
              width: isUnlocked ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isUnlocked ? const Color(0xFF16A34A) : Colors.black)
                    .withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Course thumbnail
              Container(
                width: 52.r,
                height: 52.r,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? const Color(0xFFDCFCE7)
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: coverUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: coverUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => const Center(
                          child: CircularProgressIndicator(color: Color(0xFF16A34A), strokeWidth: 2),
                        ),
                        errorWidget: (_, _, _) => Icon(
                          Icons.menu_book_rounded,
                          color: isUnlocked
                              ? const Color(0xFF16A34A)
                              : AppColors.textTertiary,
                          size: 26.r,
                        ),
                      )
                    : Icon(
                        Icons.menu_book_rounded,
                        color: isUnlocked
                            ? const Color(0xFF16A34A)
                            : AppColors.textTertiary,
                        size: 26.r,
                      ),
              ),
              SizedBox(width: 12.w),

              // Course Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 4.h,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: isUnlocked
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isUnlocked
                                    ? Icons.lock_open_rounded
                                    : Icons.lock_rounded,
                                size: 12.r,
                                color: isUnlocked
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFFDC2626),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                isUnlocked ? 'مفتوح للطالب' : 'مغلق',
                                style: GoogleFonts.cairo(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w800,
                                  color: isUnlocked
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFDC2626),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (price != null)
                          Text(
                            '$price ج.م',
                            style: GoogleFonts.cairo(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action button (فتح / قفل)
              isProcessing
                  ? SizedBox(
                      width: 32.r,
                      height: 32.r,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: () => _toggleCourseAccess(course),
                      icon: Icon(
                        isUnlocked
                            ? Icons.lock_outline_rounded
                            : Icons.lock_open_rounded,
                        size: 15.r,
                      ),
                      label: Text(
                        isUnlocked ? 'قفل الكورس' : 'فتح الكورس',
                        style: GoogleFonts.cairo(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isUnlocked
                            ? const Color(0xFFDC2626)
                            : const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 6.h),
                        minimumSize: Size.zero,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}
