import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_active_codes_repo.dart';
import 'generate_codes_count_selector.dart';

class GenerateAdminCodesDialog extends StatefulWidget {
  final List<Map<String, dynamic>> teachers;
  final String? initialTeacherId;
  final Function(String teacherId, String? courseId, int count) onGenerate;

  const GenerateAdminCodesDialog({super.key, required this.teachers, this.initialTeacherId, required this.onGenerate});

  @override
  State<GenerateAdminCodesDialog> createState() => _GenerateAdminCodesDialogState();
}

class _GenerateAdminCodesDialogState extends State<GenerateAdminCodesDialog> {
  final _repo = AdminActiveCodesRepo();
  String? _selectedTeacherId, _selectedCourseId;
  int _count = 10;
  List<Map<String, dynamic>> _courses = [];
  bool _loadingCourses = false, _generating = false;

  @override
  void initState() {
    super.initState();
    _selectedTeacherId = widget.initialTeacherId?.isNotEmpty == true ? widget.initialTeacherId : (widget.teachers.isNotEmpty ? widget.teachers.first['id'] as String? : null);
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    if (_selectedTeacherId == null || _selectedTeacherId!.isEmpty) return;
    setState(() => _loadingCourses = true);
    final res = await _repo.getCourses(_selectedTeacherId!);
    if (mounted) res.when(success: (c) => setState(() { _courses = c; _loadingCourses = false; }), failure: (_, __) => setState(() { _courses = []; _loadingCourses = false; }));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: AppColors.surface, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(children: [
          Container(padding: EdgeInsets.all(8.r), decoration: BoxDecoration(color: AppColors.adminPrimaryLight, borderRadius: BorderRadius.circular(10.r)), child: Icon(Icons.card_membership_rounded, color: AppColors.adminPrimary, size: 22.r)),
          SizedBox(width: 10.w),
          Text('توليد أكواد تفعيل جديدة', style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 16.sp, color: AppColors.textPrimary)),
        ]),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('اختر المعلم:', style: GoogleFonts.cairo(fontSize: 12.5.sp, fontWeight: FontWeight.w700)),
              SizedBox(height: 6.h),
              DropdownButtonFormField<String>(
                value: _selectedTeacherId, isExpanded: true,
                items: widget.teachers.map((t) => DropdownMenuItem<String>(value: t['id'] as String? ?? '', child: Text('${(t['users'] as Map<String, dynamic>?)?['full_name'] ?? 'معلم'} (${(t['subjects'] as Map<String, dynamic>?)?['name_ar'] ?? ''})', overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (val) { setState(() { _selectedTeacherId = val; _selectedCourseId = null; }); _loadCourses(); },
                decoration: InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r))),
              ),
              SizedBox(height: 14.h),
              Text('الكورس المخصص (اختياري):', style: GoogleFonts.cairo(fontSize: 12.5.sp, fontWeight: FontWeight.w700)),
              SizedBox(height: 6.h),
              if (_loadingCourses) const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(strokeWidth: 2)))
              else DropdownButtonFormField<String?>(
                value: _selectedCourseId, isExpanded: true,
                items: [
                  const DropdownMenuItem<String?>(value: null, child: Text('كافة كورسات المعلم (اشتراك عام)', overflow: TextOverflow.ellipsis)),
                  ..._courses.map((c) => DropdownMenuItem<String?>(value: c['id'] as String? ?? '', child: Text(c['title'] as String? ?? 'كورس', overflow: TextOverflow.ellipsis))),
                ],
                onChanged: (val) => setState(() => _selectedCourseId = val),
                decoration: InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r))),
              ),
              SizedBox(height: 14.h),
              GenerateCodesCountSelector(selectedCount: _count, onSelectCount: (val) => setState(() => _count = val)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: _generating ? null : () => Navigator.pop(context), child: Text('إلغاء', style: GoogleFonts.cairo(fontWeight: FontWeight.w700, color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: _generating || _selectedTeacherId == null ? null : () async {
              final nav = Navigator.of(context);
              HapticFeedback.mediumImpact();
              setState(() => _generating = true);
              await widget.onGenerate(_selectedTeacherId!, _selectedCourseId, _count);
              if (mounted) nav.pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminPrimary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r))),
            child: _generating ? SizedBox(width: 18.r, height: 18.r, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text('توليد $_count كود', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
