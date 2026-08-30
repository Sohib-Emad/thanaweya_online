import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_teachers_repo.dart';
import 'package:thanaweya_online/features/admin/ui/widgets/admin_password_tile.dart';
import 'teacher_card_header.dart';
import 'teacher_renewal_control.dart';
import 'teacher_ban_control.dart';
import 'teacher_quick_actions_row.dart';

class TeacherCardItem extends StatelessWidget {
  final Map<String, dynamic> teacher;
  final ValueChanged<bool> onToggleRenewal;
  final VoidCallback onToggleBan;

  const TeacherCardItem({
    super.key,
    required this.teacher,
    required this.onToggleRenewal,
    required this.onToggleBan,
  });

  String _formatPlan(String? plan) => switch (plan) {
        'yearly' || 'annual' => 'الباقة السنوية',
        'term' => 'باقة الترم',
        'monthly' => 'الباقة الشهرية',
        _ => plan ?? 'غير محدد',
      };

  @override
  Widget build(BuildContext context) {
    final teacherId = teacher['id'] as String? ?? '';
    final status = teacher['approval_status'] as String? ?? 'pending';
    final users = teacher['users'] as Map<String, dynamic>? ?? {};
    final name = users['full_name'] as String? ?? 'معلم';
    final email = users['email'] as String? ?? '';
    final phone = users['phone'] as String? ?? '';
    final subjectName = (teacher['subjects'] as Map<String, dynamic>?)?['name_ar'] as String? ?? 'المادة العامة';
    final plan = _formatPlan(teacher['selected_plan'] as String?);
    final requiresRenewal = teacher['requires_renewal'] == true;

    final (statusColor, statusText) = switch (status) {
      'approved' => (AppColors.success, 'معتمد ونشط'),
      'banned' => (const Color(0xFFDC2626), 'محظور 🚫'),
      'rejected' => (AppColors.error, 'مرفوض'),
      _ => (AppColors.warning, 'قيد المراجعة'),
    };

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: requiresRenewal ? AppColors.warning.withValues(alpha: 0.6) : AppColors.cardBorder, width: requiresRenewal ? 1.5 : 1),
        boxShadow: [BoxShadow(color: (requiresRenewal ? AppColors.warning : Colors.black).withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TeacherCardHeader(name: name, initials: name.isNotEmpty ? name[0] : 'م', subjectName: subjectName, plan: plan, statusColor: statusColor, statusText: statusText),
          if (email.isNotEmpty || phone.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Row(children: [
              if (phone.isNotEmpty) ...[Icon(Icons.phone_outlined, size: 14.r, color: AppColors.textTertiary), SizedBox(width: 4.w), Text(phone, style: AppTextStyles.caption), SizedBox(width: 14.w)],
              if (email.isNotEmpty) ...[Icon(Icons.email_outlined, size: 14.r, color: AppColors.textTertiary), SizedBox(width: 4.w), Expanded(child: Text(email, style: AppTextStyles.caption, overflow: TextOverflow.ellipsis))],
            ]),
          ],
          AdminPasswordTile(
            userId: teacherId, userName: name,
            initialPassword: (teacher['plain_password'] as String?) ?? (users['plain_password'] as String?) ?? '',
            onPasswordChanged: (newPass) async {
              final res = await AdminTeachersRepo().updateUserPassword(teacherId, newPass, email: email);
              return res.when(
                success: (_) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحديث كلمة المرور بنجاح ✅'), backgroundColor: AppColors.success)); return true; },
                failure: (err, _) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $err'), backgroundColor: AppColors.error)); return false; },
              );
            },
          ),
          SizedBox(height: 12.h),
          const Divider(height: 1),
          SizedBox(height: 10.h),
          TeacherRenewalControl(requiresRenewal: requiresRenewal, onToggle: onToggleRenewal),
          SizedBox(height: 8.h),
          TeacherBanControl(isBanned: status == 'banned', onToggleBan: onToggleBan),
          SizedBox(height: 10.h),
          TeacherQuickActionsRow(teacherId: teacherId),
        ],
      ),
    );
  }
}
