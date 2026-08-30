import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_students_repo.dart';
import 'package:thanaweya_online/features/admin/ui/widgets/admin_password_tile.dart';
import '../../../../../core/constants/app_colors.dart';

import 'student_card_header.dart';
import 'student_contact_chips.dart';

class StudentCardItem extends StatelessWidget {
  final Map<String, dynamic> student;
  final VoidCallback onOpenCourses;
  final VoidCallback onGiftPoints;
  final VoidCallback onCreditWallet;

  const StudentCardItem({
    super.key,
    required this.student,
    required this.onOpenCourses,
    required this.onGiftPoints,
    required this.onCreditWallet,
  });

  String _formatGrade(String? grade) => switch (grade) {
        'first' => 'الصف الأول الثانوي',
        'second' => 'الصف الثاني الثانوي',
        'third' => 'الصف الثالث الثانوي',
        _ => 'طالب ثانوي',
      };

  @override
  Widget build(BuildContext context) {
    final user = student['users'] as Map<String, dynamic>? ?? {};
    final name = user['full_name'] as String? ?? 'طالب';
    final phone = user['phone'] as String? ?? '', email = user['email'] as String? ?? '', pPhone = student['parent_phone'] as String? ?? '';
    final grade = _formatGrade(student['grade_level'] as String?);
    final subs = (student['subscriptions'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final sid = student['id'] as String? ?? '';
    final walletBal = (student['wallet_balance'] as num?)?.toDouble() ?? 0.0;
    final appVer = student['app_version'] as String? ?? '1.0.0';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: AppColors.cardBorder),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StudentCardHeader(name: name, grade: grade, subsCount: subs.length),
          SizedBox(height: 8.h),

          // شريط رصيد الخزنة وإصدار التطبيق
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_rounded, size: 16, color: Color(0xFF16A34A)),
                    SizedBox(width: 5.w),
                    Text(
                      'الخزنة: ${walletBal.toStringAsFixed(2)} ج.م',
                      style: GoogleFonts.cairo(fontSize: 12.sp, fontWeight: FontWeight.w800, color: const Color(0xFF16A34A)),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Text(
                    'إصدار: v$appVer',
                    style: GoogleFonts.cairo(fontSize: 10.5.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0284C7)),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 10.h),
          const Divider(height: 1),
          SizedBox(height: 8.h),
          if (phone.isNotEmpty || pPhone.isNotEmpty || email.isNotEmpty)
            StudentContactChips(phone: phone, parentPhone: pPhone, email: email),
          AdminPasswordTile(
            userId: sid, userName: name,
            initialPassword: (student['plain_password'] as String?) ?? (user['plain_password'] as String?) ?? '',
            onPasswordChanged: (newPass) async {
              final res = await AdminStudentsRepo().updateUserPassword(sid, newPass, email: email);
              return res.when(
                success: (_) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحديث كلمة المرور بنجاح ✅'), backgroundColor: AppColors.success)); return true; },
                failure: (err, _) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $err'), backgroundColor: AppColors.error)); return false; },
              );
            },
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onOpenCourses, icon: const Icon(Icons.lock_open_rounded, size: 16),
                  label: Text('الكورسات', style: GoogleFonts.cairo(fontSize: 11.5.sp, fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminPrimary, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: 8.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)), elevation: 0),
                ),
              ),
              SizedBox(width: 6.w),
              OutlinedButton.icon(
                onPressed: onCreditWallet,
                icon: const Icon(Icons.account_balance_wallet_rounded, size: 16, color: Color(0xFF16A34A)),
                label: Text('شحن 💳', style: GoogleFonts.cairo(fontSize: 11.5.sp, fontWeight: FontWeight.w800, color: const Color(0xFF16A34A))),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF16A34A)), padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r))),
              ),
              SizedBox(width: 6.w),
              OutlinedButton.icon(
                onPressed: onGiftPoints, icon: const Icon(Icons.stars_rounded, size: 16, color: Color(0xFFD97706)),
                label: Text('نقاط 🎁', style: GoogleFonts.cairo(fontSize: 11.5.sp, fontWeight: FontWeight.w800, color: const Color(0xFFD97706))),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFF59E0B)), padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
