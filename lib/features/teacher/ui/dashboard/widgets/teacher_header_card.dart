import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Header card displaying the teacher's greeting, avatar, and action buttons.
class TeacherHeaderCard extends StatelessWidget {
  const TeacherHeaderCard({
    super.key,
    required this.teacherName,
    required this.greetingLabel,
    required this.teacherIdCode,
    required this.onNotificationsTap,
    required this.onSettingsTap,
    required this.onAvatarTap,
  });

  final String teacherName;
  final String greetingLabel;
  final String teacherIdCode;
  final VoidCallback onNotificationsTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onAvatarTap,
            child: CircleAvatar(
              radius: 24.r,
              backgroundColor: const Color(0xFF0284C7),
              child: Text(
                teacherName.isNotEmpty ? teacherName[0] : 'م',
                style: GoogleFonts.cairo(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$greetingLabel، ',
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      teacherName,
                      style: GoogleFonts.cairo(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  'لوحة تحكم المعلم • كود الحساب ($teacherIdCode)',
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded,
                color: Color(0xFF334155)),
            tooltip: 'الإشعارات',
            onPressed: onNotificationsTap,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined,
                color: Color(0xFF64748B)),
            tooltip: 'الإعدادات',
            onPressed: onSettingsTap,
          ),
        ],
      ),
    );
  }
}
