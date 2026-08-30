import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';

class PushTokensStatsRow extends StatelessWidget {
  final int totalCount;
  final int studentsCount;
  final int teachersCount;

  const PushTokensStatsRow({
    super.key,
    required this.totalCount,
    required this.studentsCount,
    required this.teachersCount,
  });

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: GoogleFonts.cairo(fontSize: 18.sp, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              Container(padding: EdgeInsets.all(6.r), decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8.r)), child: Icon(icon, size: 16.r, color: color)),
            ],
          ),
          SizedBox(height: 4.h),
          Text(title, style: GoogleFonts.cairo(fontSize: 11.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(title: 'إجمالي الأجهزة', value: '$totalCount', icon: Icons.devices_rounded, color: const Color(0xFF6366F1), bgColor: const Color(0xFFEEF2FF))),
        SizedBox(width: 8.w),
        Expanded(child: _buildStatCard(title: 'الطلاب', value: '$studentsCount', icon: Icons.school_rounded, color: const Color(0xFF0EA5E9), bgColor: const Color(0xFFF0F9FF))),
        SizedBox(width: 8.w),
        Expanded(child: _buildStatCard(title: 'المعلمين', value: '$teachersCount', icon: Icons.person_rounded, color: const Color(0xFF10B981), bgColor: const Color(0xFFECFDF5))),
      ],
    );
  }
}
