import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_active_codes_repo.dart';
import 'package:thanaweya_online/features/admin/logic/admin_active_codes_cubit.dart';
import 'package:thanaweya_online/features/admin/ui/codes/widgets/generate_admin_codes_dialog.dart';

class AdminActiveCodesScreen extends StatefulWidget {
  final String? initialTeacherId;

  const AdminActiveCodesScreen({super.key, this.initialTeacherId});

  @override
  State<AdminActiveCodesScreen> createState() => _AdminActiveCodesScreenState();
}

class _AdminActiveCodesScreenState extends State<AdminActiveCodesScreen> {
  late final AdminActiveCodesCubit _cubit;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cubit = AdminActiveCodesCubit(repo: AdminActiveCodesRepo());
    _cubit.loadCodes(initialTeacherId: widget.initialTeacherId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _openGenerateDialog() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (ctx) => GenerateAdminCodesDialog(
        teachers: _cubit.state.teachers,
        initialTeacherId: _cubit.state.selectedTeacherId,
        onGenerate: (teacherId, courseId, count) async {
          final ok = await _cubit.generateCodes(
            teacherId: teacherId,
            courseId: courseId,
            count: count,
          );
          if (mounted && ok) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم توليد $count كود بنجاح 🎉'),
                backgroundColor: const Color(0xFF16A34A),
              ),
            );
          }
        },
      ),
    );
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نسخ الكود: $code'),
        backgroundColor: AppColors.textPrimary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _confirmDeleteCode(String codeId, String code) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              SizedBox(width: 8.w),
              Text(
                'حذف كود التفعيل',
                style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          content: Text(
            'هل أنت متأكد من حذف الكود «$code»؟ لن يتمكن أي طالب من استخدامه بعد الحذف.',
            style: GoogleFonts.cairo(fontSize: 13.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final ok = await _cubit.deleteCode(codeId);
                if (mounted && ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم حذف الكود بنجاح'),
                      backgroundColor: Color(0xFFDC2626),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('حذف الكود'),
            ),
          ],
        ),
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
          title: const Text('الأكواد النشطة للمعلمين'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_card_rounded),
              tooltip: 'توليد أكواد جديدة',
              onPressed: _openGenerateDialog,
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'تحديث',
              onPressed: () => _cubit.loadCodes(
                initialTeacherId: _cubit.state.selectedTeacherId,
              ),
            ),
          ],
        ),
        body: BlocBuilder<AdminActiveCodesCubit, AdminActiveCodesState>(
          bloc: _cubit,
          builder: (context, state) {
            return Column(
              children: [
                // ─── Filter & Search Bar ─────────────────────────────────────
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
                          hintText: 'ابحث بالكود (TH-XXXX-YYYY) أو اسم المدرس أو الكورس...',
                          hintStyle: GoogleFonts.cairo(
                            fontSize: 12.sp,
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

                      // Teacher filter horizontal list
                      Row(
                        children: [
                          Icon(
                            Icons.person_pin_rounded,
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

                      // Course filter (if teacher has courses)
                      if (state.courses.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Icon(
                              Icons.menu_book_rounded,
                              size: 16.r,
                              color: AppColors.adminPrimary,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'الكورس:',
                              style: GoogleFonts.cairo(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
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
                                      label: const Text('كافة الكورسات'),
                                      selected: state.selectedCourseId == null,
                                      labelStyle: GoogleFonts.cairo(
                                        fontSize: 10.5.sp,
                                        fontWeight: state.selectedCourseId == null
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                        color: state.selectedCourseId == null
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                      ),
                                      selectedColor: AppColors.adminPrimary,
                                      backgroundColor: AppColors.background,
                                      showCheckmark: false,
                                      onSelected: (_) =>
                                          _cubit.selectCourse(null),
                                    ),
                                    SizedBox(width: 6.w),
                                    ...state.courses.map((c) {
                                      final cid = c['id'] as String? ?? '';
                                      final title =
                                          c['title'] as String? ?? 'كورس';
                                      final isSelected =
                                          state.selectedCourseId == cid;

                                      return Padding(
                                        padding: EdgeInsets.only(left: 6.w),
                                        child: ChoiceChip(
                                          label: Text(title),
                                          selected: isSelected,
                                          labelStyle: GoogleFonts.cairo(
                                            fontSize: 10.5.sp,
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
                                            _cubit.selectCourse(
                                                selected ? cid : null);
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
                      ],

                      SizedBox(height: 8.h),

                      // Counter bar & Generate Shortcut
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'الأكواد النشطة: ${state.filteredCodes.length} كود',
                            style: GoogleFonts.cairo(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF16A34A),
                            ),
                          ),
                          GestureDetector(
                            onTap: _openGenerateDialog,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.add_circle_outline_rounded,
                                  size: 15,
                                  color: AppColors.adminPrimary,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  '+ توليد أكواد جديدة',
                                  style: GoogleFonts.cairo(
                                    fontSize: 11.5.sp,
                                    color: AppColors.adminPrimary,
                                    fontWeight: FontWeight.w800,
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

                // ─── Codes List ──────────────────────────────────────────────
                Expanded(
                  child: _buildCodesList(state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCodesList(AdminActiveCodesState state) {
    if (state.status == AdminActiveCodesStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == AdminActiveCodesStatus.failure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 54.r, color: AppColors.error),
            SizedBox(height: 12.h),
            Text(
              state.errorMessage ?? 'حدث خطأ أثناء تحميل الأكواد',
              style: AppTextStyles.body2,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: () => _cubit.loadCodes(
                initialTeacherId: state.selectedTeacherId,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (state.filteredCodes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.credit_card_off_rounded,
                size: 64.r, color: AppColors.textTertiary),
            SizedBox(height: 14.h),
            Text(
              'لا توجد أكواد نشطة مطابقة للبحث أو الفلتر',
              style: AppTextStyles.h3,
            ),
            SizedBox(height: 6.h),
            Text(
              'يمكنك توليد حزمة أكواد جديدة للمدرس بالضغط أدناه',
              style: AppTextStyles.caption,
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: _openGenerateDialog,
              icon: const Icon(Icons.add_card_rounded),
              label: const Text('توليد أكواد جديدة الآن'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.adminPrimary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _cubit.loadCodes(
        initialTeacherId: state.selectedTeacherId,
      ),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        itemCount: state.filteredCodes.length,
        separatorBuilder: (_, _) => SizedBox(height: 10.h),
        itemBuilder: (context, index) {
          final item = state.filteredCodes[index];
          final codeId = item['id'] as String? ?? '';
          final code = item['code'] as String? ?? '';
          final teacher = item['teachers'] as Map<String, dynamic>? ?? {};
          final teacherUsers = teacher['users'] as Map<String, dynamic>? ?? {};
          final teacherName = teacherUsers['full_name'] as String? ?? 'معلم';
          final subject =
              (teacher['subjects'] as Map<String, dynamic>?)?['name_ar'] as String? ??
                  'مادة عامة';
          final course = item['courses'] as Map<String, dynamic>? ?? {};
          final courseTitle = course['title'] as String? ??
              'كافة كورسات المعلم (اشتراك عام)';

          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: const Color(0xFF16A34A).withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.all(14.r),
            child: Row(
              children: [
                // Code Icon / Tag
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: const Icon(
                    Icons.vpn_key_rounded,
                    color: Color(0xFF16A34A),
                    size: 22,
                  ),
                ),
                SizedBox(width: 12.w),

                // Code and metadata
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Code String with Copy
                      Row(
                        children: [
                          SelectableText(
                            code,
                            style: GoogleFonts.sourceCodePro(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                              letterSpacing: 1.1,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          InkWell(
                            onTap: () => _copyCode(code),
                            borderRadius: BorderRadius.circular(4.r),
                            child: Padding(
                              padding: EdgeInsets.all(4.r),
                              child: const Icon(
                                Icons.copy_rounded,
                                size: 16,
                                color: AppColors.adminPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '$teacherName ($subject)',
                        style: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'الكورس: $courseTitle',
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Delete / Revoke Action
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                  tooltip: 'إلغاء وحذف الكود',
                  onPressed: () => _confirmDeleteCode(codeId, code),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
