import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thanaweya_online/core/constants/app_colors.dart';

class AdminModeSwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color activeColor;
  final bool isActive;
  final bool isLoading;
  final ValueChanged<bool> onChanged;

  const AdminModeSwitchTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.activeColor,
    required this.isActive,
    this.isLoading = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isActive ? activeColor.withValues(alpha: 0.08) : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isActive ? activeColor.withValues(alpha: 0.5) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(icon, color: isActive ? activeColor : const Color(0xFF64748B), size: 22.r),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.cairo(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w800,
                          color: isActive ? activeColor : const Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.cairo(fontSize: 10.5.sp, color: const Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isActive,
            activeThumbColor: activeColor,
            onChanged: isLoading ? null : onChanged,
          ),
        ],
      ),
    );
  }
}
