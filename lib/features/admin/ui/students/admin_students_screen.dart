import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_students_repo.dart';
import 'package:thanaweya_online/features/admin/logic/admin_students_cubit.dart';
import 'package:thanaweya_online/features/admin/ui/students/widgets/student_courses_sheet.dart';

class AdminStudentsScreen extends StatefulWidget {
  final String? initialTeacherId;

  const AdminStudentsScreen({super.key, this.initialTeacherId});

  @override
  State<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen> {
  late final AdminStudentsCubit _cubit;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cubit = AdminStudentsCubit(repo: AdminStudentsRepo());
    _cubit.loadData(initialTeacherId: widget.initialTeacherId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  String _formatGrade(String? grade) {
    switch (grade) {
      case 'first':
        return 'الصف الأول الثانوي';
      case 'second':
        return 'الصف الثاني الثانوي';
      case 'third':
        return 'الصف الثالث الثانوي';
      default:
        return 'طالب ثانوي';
    }
  }

  void _openStudentCourses(Map<String, dynamic> student, List<Map<String, dynamic>> teachers) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StudentCoursesSheet(
        student: student,
        teachers: teachers,
        initialTeacherId: _cubit.state.selectedTeacherId,
      ),
    );
  }

  void _copyToClipboard(String text, String label) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نسخ $label: $text'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.textPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('إدارة طلاب المعلمين والاشتراكات'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'تحديث',
              onPressed: () => _cubit.loadData(
                initialTeacherId: _cubit.state.selectedTeacherId,
              ),
            ),
          ],
        ),
        body: BlocBuilder<AdminStudentsCubit, AdminStudentsState>(
          bloc: _cubit,
          builder: (context, state) {
            return Column(
              children: [
                // ─── Search & Filters Header ─────────────────────────────────
                Container(
                  color: AppColors.surface,
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h),
                  child: Column(
                    children: [
                      // Search field
                      TextField(
                        controller: _searchController,
                        onChanged: (val) => _cubit.setSearchQuery(val),
                        decoration: InputDecoration(
                          hintText: 'ابحث بالاسم، هاتف الطالب، أو هاتف ولي الأمر...',
                          hintStyle: GoogleFonts.cairo(
                            fontSize: 12.5.sp,
                            color: AppColors.textTertiary,
                          ),
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded),
                                  onPressed: () {
                                    _searchController.clear();
                                    _cubit.setSearchQuery('');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: AppColors.background,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 10.h),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),

                      // Teacher filter dropdown / horizontal chips
                      Row(
                        children: [
                          Icon(
                            Icons.filter_list_rounded,
                            size: 18.r,
                            color: AppColors.adminPrimary,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'المعلم:',
                            style: GoogleFonts.cairo(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: [
                                  ChoiceChip(
                                    label: const Text('جميع المعلمين'),
                                    selected: state.selectedTeacherId == null,
                                    labelStyle: GoogleFonts.cairo(
                                      fontSize: 11.sp,
                                      fontWeight: state.selectedTeacherId == null
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      color: state.selectedTeacherId == null
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                    ),
                                    selectedColor: AppColors.adminPrimary,
                                    backgroundColor: AppColors.background,
                                    showCheckmark: false,
                                    onSelected: (_) => _cubit.selectTeacher(null),
                                  ),
                                  SizedBox(width: 6.w),
                                  ...state.teachers.map((t) {
                                    final tid = t['id'] as String? ?? '';
                                    final users =
                                        t['users'] as Map<String, dynamic>? ?? {};
                                    final name =
                                        users['full_name'] as String? ?? 'معلم';
                                    final isSelected =
                                        state.selectedTeacherId == tid;

                                    return Padding(
                                      padding: EdgeInsets.only(left: 6.w),
                                      child: ChoiceChip(
                                        label: Text(name),
                                        selected: isSelected,
                                        labelStyle: GoogleFonts.cairo(
                                          fontSize: 11.sp,
                                          fontWeight: isSelected
                                              ? FontWeight.w800
                                              : FontWeight.w600,
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.textPrimary,
                                        ),
                                        selectedColor: AppColors.adminPrimary,
                                        backgroundColor: AppColors.background,
                                        showCheckmark: false,
                                        onSelected: (selected) {
                                          _cubit.selectTeacher(
                                              selected ? tid : null);
                                        },
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 8.h),

                      // Counter bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'إجمالي الطلاب: ${state.filteredStudents.length}',
                            style: GoogleFonts.cairo(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.adminPrimary,
                            ),
                          ),
                          if (state.selectedTeacherId != null)
                            GestureDetector(
                              onTap: () => _cubit.selectTeacher(null),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.close_rounded,
                                    size: 14.r,
                                    color: AppColors.error,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    'إلغاء فلتر المعلم',
                                    style: GoogleFonts.cairo(
                                      fontSize: 11.sp,
                                      color: AppColors.error,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ─── Students List ───────────────────────────────────────────
                Expanded(
                  child: _buildStudentsList(state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStudentsList(AdminStudentsState state) {
    if (state.status == AdminStudentsStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == AdminStudentsStatus.failure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 54.r, color: AppColors.error),
            SizedBox(height: 12.h),
            Text(
              state.errorMessage ?? 'حدث خطأ أثناء تحميل بيانات الطلاب',
              style: AppTextStyles.body2,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: () => _cubit.loadData(
                initialTeacherId: state.selectedTeacherId,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (state.filteredStudents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined,
                size: 64.r, color: AppColors.textTertiary),
            SizedBox(height: 14.h),
            Text(
              'لا يوجد طلاب مطابقين للبحث أو الفلتر',
              style: AppTextStyles.h3,
            ),
            SizedBox(height: 6.h),
            Text(
              'جرّب تغيير كلمات البحث أو إزالة فلتر المعلم',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _cubit.loadData(
        initialTeacherId: state.selectedTeacherId,
      ),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        itemCount: state.filteredStudents.length,
        separatorBuilder: (_, _) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final student = state.filteredStudents[index];
          final user = student['users'] as Map<String, dynamic>? ?? {};
          final name = user['full_name'] as String? ?? 'طالب';
          final phone = user['phone'] as String? ?? '';
          final email = user['email'] as String? ?? '';
          final parentPhone = student['parent_phone'] as String? ?? '';
          final grade = _formatGrade(student['grade_level'] as String?);
          final subs =
              (student['subscriptions'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
                  [];
          final initials = name.isNotEmpty ? name[0] : 'ط';

          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Avatar, Name, Grade badge
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22.r,
                      backgroundColor: AppColors.studentPrimaryLight,
                      child: Text(
                        initials,
                        style: GoogleFonts.cairo(
                          color: AppColors.studentPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: AppTextStyles.h3.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 15.sp,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            grade,
                            style: GoogleFonts.cairo(
                              fontSize: 11.5.sp,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.adminPrimaryLight,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '${subs.length} اشتراك',
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          color: AppColors.adminPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),
                const Divider(height: 1),
                SizedBox(height: 10.h),

                // Contact details with click-to-copy
                if (phone.isNotEmpty || parentPhone.isNotEmpty || email.isNotEmpty) ...[
                  Wrap(
                    spacing: 12.w,
                    runSpacing: 6.h,
                    children: [
                      if (phone.isNotEmpty)
                        InkWell(
                          onTap: () => _copyToClipboard(phone, 'هاتف الطالب'),
                          borderRadius: BorderRadius.circular(6.r),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.phone_android_rounded,
                                  size: 14.r, color: AppColors.textTertiary),
                              SizedBox(width: 4.w),
                              Text(phone,
                                  style: GoogleFonts.cairo(
                                      fontSize: 11.5.sp,
                                      fontWeight: FontWeight.w600)),
                              SizedBox(width: 2.w),
                              Icon(Icons.copy_rounded,
                                  size: 11.r, color: AppColors.textTertiary),
                            ],
                          ),
                        ),
                      if (parentPhone.isNotEmpty)
                        InkWell(
                          onTap: () =>
                              _copyToClipboard(parentPhone, 'هاتف ولي الأمر'),
                          borderRadius: BorderRadius.circular(6.r),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.family_restroom_rounded,
                                  size: 14.r,
                                  color: const Color(0xFFD97706)),
                              SizedBox(width: 4.w),
                              Text('ولي الأمر: $parentPhone',
                                  style: GoogleFonts.cairo(
                                      fontSize: 11.5.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF92400E))),
                              SizedBox(width: 2.w),
                              Icon(Icons.copy_rounded,
                                  size: 11.r,
                                  color: const Color(0xFFD97706)),
                            ],
                          ),
                        ),
                      if (email.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.email_outlined,
                                size: 14.r, color: AppColors.textTertiary),
                            SizedBox(width: 4.w),
                            Text(email,
                                style: GoogleFonts.cairo(
                                    fontSize: 11.sp,
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                ],

                // Action Bar: Manage Courses & Gift Points
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _openStudentCourses(student, state.teachers),
                        icon: const Icon(Icons.lock_open_rounded, size: 17),
                        label: Text(
                          'إدارة الكورسات (فتح/قفل)',
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.adminPrimary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 9.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    OutlinedButton.icon(
                      onPressed: () => _showGiftPointsDialog(student),
                      icon: const Icon(Icons.stars_rounded, size: 17, color: Color(0xFFD97706)),
                      label: Text(
                        'منح نقاط 🎁',
                        style: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFD97706),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFF59E0B)),
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showGiftPointsDialog(Map<String, dynamic> student) {
    final studentId = student['student_id'] as String? ?? student['id'] as String? ?? '';
    final user = student['users'] as Map<String, dynamic>? ?? {};
    final studentName = user['full_name'] as String? ?? 'الطالب';
    final pointsController = TextEditingController(text: '50');
    final reasonController = TextEditingController(text: 'مكافأة تفوق واجتهاد 🌟');
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              title: Row(
                children: [
                  const Icon(Icons.card_giftcard_rounded, color: Color(0xFFD97706)),
                  SizedBox(width: 8.w),
                  Text(
                    'منح نقاط مكافأة',
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الطالب: $studentName',
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Text('عدد النقاط الممنوحة:', style: AppTextStyles.caption),
                  SizedBox(height: 6.h),
                  TextField(
                    controller: pointsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.stars_rounded, color: Color(0xFFD97706)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 6.w,
                    children: [20, 50, 100, 200].map((p) {
                      return ActionChip(
                        label: Text('+$p'),
                        onPressed: () {
                          setDialogState(() => pointsController.text = '$p');
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 14.h),
                  Text('سبب أو مناسبة المكافأة:', style: AppTextStyles.caption),
                  SizedBox(height: 6.h),
                  TextField(
                    controller: reasonController,
                    decoration: InputDecoration(
                      hintText: 'مثال: حل واجب ممتاز، نشاط مميز...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final pts = int.tryParse(pointsController.text.trim()) ?? 0;
                          if (pts <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('يرجى إدخال عدد نقاط صحيح أكبر من صفر')),
                            );
                            return;
                          }

                          final messenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(dialogCtx);
                          setDialogState(() => isSubmitting = true);
                          final result = await AdminStudentsRepo().grantStudentBonusPoints(
                            studentId: studentId,
                            points: pts,
                            reason: reasonController.text.trim(),
                          );

                          navigator.pop();

                          result.when(
                            success: (newTotal) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text('تم منح $pts نقطة للطالب $studentName بنجاح 🎉'),
                                  backgroundColor: const Color(0xFF059669),
                                ),
                              );
                            },
                            failure: (err, _) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text('فشل منح النقاط: $err'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            },
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD97706),
                    foregroundColor: Colors.white,
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('منح النقاط الآن'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
