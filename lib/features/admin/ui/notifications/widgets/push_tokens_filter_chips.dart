import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';

class PushTokensFilterChips extends StatelessWidget {
  final String roleFilter;
  final String platformFilter;
  final int totalCount;
  final int studentsCount;
  final int teachersCount;
  final int androidCount;
  final int iosCount;
  final ValueChanged<String> onSelectRole;
  final ValueChanged<String> onSelectPlatform;

  const PushTokensFilterChips({
    super.key,
    required this.roleFilter,
    required this.platformFilter,
    required this.totalCount,
    required this.studentsCount,
    required this.teachersCount,
    required this.androidCount,
    required this.iosCount,
    required this.onSelectRole,
    required this.onSelectPlatform,
  });

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap, {Color selectedColor = AppColors.adminPrimary}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: isSelected ? selectedColor : const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11.5.sp,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildChip('الكل ($totalCount)', roleFilter == 'all', () => onSelectRole('all')),
          SizedBox(width: 8.w),
          _buildChip('طلاب 🎓 ($studentsCount)', roleFilter == 'student', () => onSelectRole('student')),
          SizedBox(width: 8.w),
          _buildChip('معلمين 👨‍🏫 ($teachersCount)', roleFilter == 'teacher', () => onSelectRole('teacher')),
          SizedBox(width: 14.w),
          Container(width: 1.w, height: 24.h, color: const Color(0xFFCBD5E1)),
          SizedBox(width: 14.w),
          _buildChip('Android 🤖 ($androidCount)', platformFilter == 'android', () => onSelectPlatform(platformFilter == 'android' ? 'all' : 'android'), selectedColor: const Color(0xFF334155)),
          SizedBox(width: 8.w),
          _buildChip('iOS 🍏 ($iosCount)', platformFilter == 'ios', () => onSelectPlatform(platformFilter == 'ios' ? 'all' : 'ios'), selectedColor: const Color(0xFF334155)),
        ],
      ),
    );
  }
}
