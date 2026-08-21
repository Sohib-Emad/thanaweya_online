import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_active_codes_repo.dart';

class GenerateAdminCodesDialog extends StatefulWidget {
  final List<Map<String, dynamic>> teachers;
  final String? initialTeacherId;
  final Function(String teacherId, String? courseId, int count) onGenerate;

  const GenerateAdminCodesDialog({
    super.key,
    required this.teachers,
    this.initialTeacherId,
    required this.onGenerate,
  });

  @override
  State<GenerateAdminCodesDialog> createState() =>
      _GenerateAdminCodesDialogState();
}

class _GenerateAdminCodesDialogState extends State<GenerateAdminCodesDialog> {
  final _repo = AdminActiveCodesRepo();
  String? _selectedTeacherId;
  String? _selectedCourseId;
  int _count = 10;
  List<Map<String, dynamic>> _courses = [];
  bool _loadingCourses = false;
  bool _generating = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialTeacherId != null &&
        widget.initialTeacherId!.isNotEmpty) {
      _selectedTeacherId = widget.initialTeacherId;
    } else if (widget.teachers.isNotEmpty) {
      _selectedTeacherId = widget.teachers.first['id'] as String?;
    }
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    if (_selectedTeacherId == null || _selectedTeacherId!.isEmpty) return;
    setState(() => _loadingCourses = true);
    final res = await _repo.getCourses(_selectedTeacherId!);
    if (!mounted) return;
    res.when(
      success: (courses) {
        setState(() {
          _courses = courses;
          _loadingCourses = false;
        });
      },
      failure: (_, _) {
        setState(() {
          _courses = [];
          _loadingCourses = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: AppColors.adminPrimaryLight,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.card_membership_rounded,
                color: AppColors.adminPrimary,
                size: 22.r,
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              'توليد أكواد تفعيل جديدة',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w800,
                fontSize: 16.sp,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Teacher Selection
              Text(
                'اختر المعلم:',
                style: GoogleFonts.cairo(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 6.h),
              DropdownButtonFormField<String>(
                value: _selectedTeacherId,
                items: widget.teachers.map((t) {
                  final tid = t['id'] as String? ?? '';
                  final users = t['users'] as Map<String, dynamic>? ?? {};
                  final name = users['full_name'] as String? ?? 'معلم';
                  final sub = (t['subjects'] as Map<String, dynamic>?)?['name_ar'] as String? ?? '';

                  return DropdownMenuItem<String>(
                    value: tid,
                    child: Text('$name ($sub)'),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedTeacherId = val;
                    _selectedCourseId = null;
                  });
                  _loadCourses();
                },
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 14.h),

              // Course Selection (Optional)
              Text(
                'الكورس المخصص (اختياري):',
                style: GoogleFonts.cairo(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 6.h),
              if (_loadingCourses)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                DropdownButtonFormField<String?>(
                  value: _selectedCourseId,
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('كافة كورسات المعلم (اشتراك عام)'),
                    ),
                    ..._courses.map((c) {
                      final cid = c['id'] as String? ?? '';
                      final title = c['title'] as String? ?? 'كورس';
                      return DropdownMenuItem<String?>(
                        value: cid,
                        child: Text(title),
                      );
                    }),
                  ],
                  onChanged: (val) => setState(() => _selectedCourseId = val),
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
              SizedBox(height: 14.h),

              // Count Selection
              Text(
                'عدد الأكواد المراد توليدها:',
                style: GoogleFonts.cairo(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                children: [5, 10, 20, 50, 100].map((itemCount) {
                  final isSel = _count == itemCount;
                  return ChoiceChip(
                    label: Text('$itemCount كود'),
                    selected: isSel,
                    selectedColor: AppColors.adminPrimary,
                    labelStyle: GoogleFonts.cairo(
                      color: isSel ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 11.5.sp,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _count = itemCount);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _generating ? null : () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _generating || _selectedTeacherId == null
                ? null
                : () async {
                    final nav = Navigator.of(context);
                    HapticFeedback.mediumImpact();
                    setState(() => _generating = true);
                    await widget.onGenerate(
                      _selectedTeacherId!,
                      _selectedCourseId,
                      _count,
                    );
                    if (mounted) nav.pop();
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.adminPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: _generating
                ? SizedBox(
                    width: 18.r,
                    height: 18.r,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'توليد $_count كود',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
                  ),
          ),
        ],
      ),
    );
  }
}
