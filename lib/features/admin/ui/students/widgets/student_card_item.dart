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

  const StudentCardItem({
    super.key,
    required this.student,
    required this.onOpenCourses,
    required this.onGiftPoints,
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
                  onPressed: onOpenCourses, icon: const Icon(Icons.lock_open_rounded, size: 17),
                  label: Text('إدارة الكورسات (فتح/قفل)', style: GoogleFonts.cairo(fontSize: 12.sp, fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminPrimary, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: 9.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)), elevation: 0),
                ),
              ),
              SizedBox(width: 8.w),
              OutlinedButton.icon(
                onPressed: onGiftPoints, icon: const Icon(Icons.stars_rounded, size: 17, color: Color(0xFFD97706)),
                label: Text('منح نقاط 🎁', style: GoogleFonts.cairo(fontSize: 12.sp, fontWeight: FontWeight.w800, color: const Color(0xFFD97706))),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFF59E0B)), padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
