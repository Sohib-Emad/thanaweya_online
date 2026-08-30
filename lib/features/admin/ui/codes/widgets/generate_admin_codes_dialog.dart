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
  final Function(String teacherId, String? courseId, int count, double price) onGenerate;

  const GenerateAdminCodesDialog({
    super.key,
    required this.teachers,
    this.initialTeacherId,
    required this.onGenerate,
  });

  @override
  State<GenerateAdminCodesDialog> createState() => _GenerateAdminCodesDialogState();
}

class _GenerateAdminCodesDialogState extends State<GenerateAdminCodesDialog> {
  final _repo = AdminActiveCodesRepo();
  final _priceController = TextEditingController(text: '100');

  String? _selectedTeacherId, _selectedCourseId;
  int _count = 10;
  List<Map<String, dynamic>> _courses = [];
  bool _loadingCourses = false, _generating = false;

  final List<double> _quickPrices = [50, 100, 150, 200, 300, 500];

  @override
  void initState() {
    super.initState();
    _selectedTeacherId = widget.initialTeacherId?.isNotEmpty == true
        ? widget.initialTeacherId
        : (widget.teachers.isNotEmpty ? widget.teachers.first['id'] as String? : null);
    _loadCourses();
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    if (_selectedTeacherId == null || _selectedTeacherId!.isEmpty) return;
    setState(() => _loadingCourses = true);
    final res = await _repo.getCourses(_selectedTeacherId!);
    if (mounted) {
      res.when(
        success: (c) => setState(() {
          _courses = c;
          _loadingCourses = false;
        }),
        failure: (_, _) => setState(() {
          _courses = [];
          _loadingCourses = false;
        }),
      );
    }
  }

  void _onCourseChanged(String? val) {
    setState(() {
      _selectedCourseId = val;
      if (val != null) {
        final course = _courses.firstWhere((c) => c['id'] == val, orElse: () => {});
        final price = (course['price'] as num?)?.toDouble();
        if (price != null && price > 0) {
          _priceController.text = price.toInt().toString();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: AppColors.adminPrimaryLight,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.card_membership_rounded, color: AppColors.adminPrimary, size: 22.r),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'توليد وتسعير أكواد تفعيل جديدة',
                style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 15.sp, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. اختيار المعلم
              Text('اختر المعلم:', style: GoogleFonts.cairo(fontSize: 12.sp, fontWeight: FontWeight.w700)),
              SizedBox(height: 6.h),
              DropdownButtonFormField<String>(
                initialValue: _selectedTeacherId,
                isExpanded: true,
                items: widget.teachers.map((t) {
                  final name = (t['users'] as Map<String, dynamic>?)?['full_name'] ?? 'معلم';
                  final sub = (t['subjects'] as Map<String, dynamic>?)?['name_ar'] ?? '';
                  return DropdownMenuItem<String>(
                    value: t['id'] as String? ?? '',
                    child: Text('$name ($sub)', overflow: TextOverflow.ellipsis),
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
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
              ),

              SizedBox(height: 14.h),

              // 2. اختيار الكورس
              Text('الكورس المخصص (اختياري):', style: GoogleFonts.cairo(fontSize: 12.sp, fontWeight: FontWeight.w700)),
              SizedBox(height: 6.h),
              if (_loadingCourses)
                const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(strokeWidth: 2)))
              else
                DropdownButtonFormField<String?>(
                  initialValue: _selectedCourseId,
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('كافة كورسات المعلم (اشتراك عام / شحن)', overflow: TextOverflow.ellipsis),
                    ),
                    ..._courses.map((c) {
                      final title = c['title'] as String? ?? 'كورس';
                      final pr = (c['price'] as num?)?.toDouble() ?? 0.0;
                      return DropdownMenuItem<String?>(
                        value: c['id'] as String? ?? '',
                        child: Text(pr > 0 ? '$title ($pr ج.م)' : title, overflow: TextOverflow.ellipsis),
                      );
                    }),
                  ],
                  onChanged: _onCourseChanged,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                ),

              SizedBox(height: 14.h),

              // 3. تسعير الكود (سعر الكود بالجنيه)
              Text('سعر / قيمة الكود (ج.م):', style: GoogleFonts.cairo(fontSize: 12.sp, fontWeight: FontWeight.w700)),
              SizedBox(height: 2.h),
              Text('سيُضاف لرصيد الطالب في الخزنة أو يُغطي سعر الكورس', style: GoogleFonts.cairo(fontSize: 10.sp, color: const Color(0xFF64748B))),
              SizedBox(height: 6.h),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.w800, color: const Color(0xFF16A34A)),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.payments_rounded, color: Color(0xFF16A34A), size: 20),
                  suffixText: 'ج.م',
                  suffixStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12.sp),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 6.w,
                runSpacing: 4.h,
                children: _quickPrices.map((p) {
                  return InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _priceController.text = p.toInt().toString());
                    },
                    borderRadius: BorderRadius.circular(6.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Text(
                        '${p.toInt()} ج.م',
                        style: GoogleFonts.cairo(fontSize: 10.5.sp, fontWeight: FontWeight.w700, color: const Color(0xFF334155)),
                      ),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: 14.h),

              // 4. اختيار عدد الأكواد
              GenerateCodesCountSelector(selectedCount: _count, onSelectCount: (val) => setState(() => _count = val)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _generating ? null : () => Navigator.pop(context),
            child: Text('إلغاء', style: GoogleFonts.cairo(fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: _generating || _selectedTeacherId == null
                ? null
                : () async {
                    final nav = Navigator.of(context);
                    final enteredPrice = double.tryParse(_priceController.text.trim()) ?? 0.0;
                    HapticFeedback.mediumImpact();
                    setState(() => _generating = true);
                    await widget.onGenerate(_selectedTeacherId!, _selectedCourseId, _count, enteredPrice);
                    if (mounted) nav.pop();
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.adminPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            child: _generating
                ? SizedBox(width: 18.r, height: 18.r, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('توليد $_count كود', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
