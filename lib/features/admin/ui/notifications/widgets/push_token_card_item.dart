import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import 'push_token_user_info_row.dart';

class PushTokenCardItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onSendDirect;

  const PushTokenCardItem({super.key, required this.item, required this.onSendDirect});

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) { return iso; }
  }

  @override
  Widget build(BuildContext context) {
    final rawName = item['full_name'] as String? ?? 'مستخدم', email = item['email'] as String? ?? '';
    final role = (item['role'] as String? ?? 'student').toLowerCase(), platform = (item['platform'] as String? ?? 'android').toLowerCase();
    final token = item['token'] as String? ?? '', updatedAt = item['updated_at'] as String? ?? item['created_at'] as String? ?? '';
    final isTeacher = role == 'teacher', isStudent = role == 'student', subName = item['subject_name'] as String? ?? '';
    final displayName = isTeacher ? (rawName.startsWith('أ.') ? rawName : 'أ. $rawName') : rawName;
    final roleLabel = isTeacher ? (subName.isNotEmpty ? 'معلم $subName 👨‍🏫' : 'معلم 👨‍🏫') : isStudent ? 'طالب 🎓' : 'مسؤول 🛡️';
    final (roleColor, roleBg) = isTeacher ? (const Color(0xFF10B981), const Color(0xFFECFDF5)) : isStudent ? (const Color(0xFF0EA5E9), const Color(0xFFF0F9FF)) : (const Color(0xFF8B5CF6), const Color(0xFFF5F3FF));

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: isTeacher ? const Color(0xFF10B981).withValues(alpha: 0.3) : const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: isTeacher ? const Color(0xFF10B981).withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PushTokenUserInfoRow(
            displayName: displayName, email: email, roleLabel: roleLabel,
            roleColor: roleColor, roleBg: roleBg, isAndroid: platform == 'android',
            avatarUrl: item['avatar_url'] as String?,
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10.r), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Row(children: [
              const Icon(Icons.vpn_key_rounded, size: 14, color: Color(0xFF64748B)),
              SizedBox(width: 8.w),
              Expanded(child: Text(token, style: GoogleFonts.sourceCodePro(fontSize: 11.sp, color: const Color(0xFF334155), fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
              SizedBox(width: 6.w),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: token));
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم نسخ توكن $displayName بنجاح!'), backgroundColor: const Color(0xFF16A34A), duration: const Duration(seconds: 2)));
                },
                child: Container(padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h), decoration: BoxDecoration(color: AppColors.adminPrimary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6.r)), child: Text('نسخ', style: GoogleFonts.cairo(fontSize: 10.5.sp, fontWeight: FontWeight.w800, color: AppColors.adminPrimary))),
              ),
            ]),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(updatedAt.isNotEmpty ? 'آخر نشاط: ${_formatDate(updatedAt)}' : '', style: GoogleFonts.cairo(fontSize: 10.5.sp, color: AppColors.textSecondary)),
              InkWell(
                onTap: onSendDirect,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.send_rounded, size: 13, color: Color(0xFF2563EB)),
                  SizedBox(width: 4.w),
                  Text('إرسال إشعار لهذا المستخدم', style: GoogleFonts.cairo(fontSize: 11.sp, fontWeight: FontWeight.w700, color: const Color(0xFF2563EB))),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
