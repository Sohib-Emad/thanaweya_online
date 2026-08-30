import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';

class AdminCodeCardItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onDelete;
  final VoidCallback onPrint;

  const AdminCodeCardItem({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onPrint,
  });

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
    final price = (item['price'] as num?)?.toDouble() ?? ((course['price'] as num?)?.toDouble() ?? 0.0);

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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: SelectableText(
                              code,
                              style: GoogleFonts.sourceCodePro(fontSize: 13.5.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A), letterSpacing: 1.0),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          InkWell(
                            onTap: () => _copyCode(context, code),
                            borderRadius: BorderRadius.circular(4.r),
                            child: const Padding(padding: EdgeInsets.all(3.0), child: Icon(Icons.copy_rounded, size: 15, color: AppColors.adminPrimary)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Text(
                        price > 0 ? '${price.toStringAsFixed(0)} ج.م 💰' : 'كود عام',
                        style: GoogleFonts.cairo(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text('$teacherName ($subject)', style: GoogleFonts.cairo(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Text('الكورس: $courseTitle', style: GoogleFonts.cairo(fontSize: 11.sp, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.print_rounded, color: Color(0xFF0284C7), size: 20),
                tooltip: 'طباعة كارت A4',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onPrint,
              ),
              SizedBox(height: 10.h),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                tooltip: 'إلغاء وحذف الكود',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
