import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';

class AdminCodeCardItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onDelete;

  const AdminCodeCardItem({super.key, required this.item, required this.onDelete});

  void _copyCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم نسخ الكود: $code'), backgroundColor: AppColors.textPrimary, duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final code = item['code'] as String? ?? '';
    final teacher = item['teachers'] as Map<String, dynamic>? ?? {};
    final teacherUsers = teacher['users'] as Map<String, dynamic>? ?? {};
    final teacherName = teacherUsers['full_name'] as String? ?? 'معلم';
    final subject = (teacher['subjects'] as Map<String, dynamic>?)?['name_ar'] as String? ?? 'مادة عامة';
    final course = item['courses'] as Map<String, dynamic>? ?? {};
    final courseTitle = course['title'] as String? ?? 'كافة كورسات المعلم (اشتراك عام)';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFF16A34A).withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      padding: EdgeInsets.all(14.r),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(10.r)),
            child: const Icon(Icons.vpn_key_rounded, color: Color(0xFF16A34A), size: 22),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SelectableText(
                      code,
                      style: GoogleFonts.sourceCodePro(fontSize: 15.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A), letterSpacing: 1.1),
                    ),
                    SizedBox(width: 8.w),
                    InkWell(
                      onTap: () => _copyCode(context, code),
                      borderRadius: BorderRadius.circular(4.r),
                      child: const Padding(padding: EdgeInsets.all(4.0), child: Icon(Icons.copy_rounded, size: 16, color: AppColors.adminPrimary)),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text('$teacherName ($subject)', style: GoogleFonts.cairo(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Text('الكورس: $courseTitle', style: GoogleFonts.cairo(fontSize: 11.sp, color: AppColors.textSecondary)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20), tooltip: 'إلغاء وحذف الكود', onPressed: onDelete),
        ],
      ),
    );
  }
}
