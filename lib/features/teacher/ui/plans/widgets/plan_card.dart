import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// A selectable plan card displaying icon, title, price, period,
/// badge, and feature list for subscription plan selection.
class PlanCard extends StatelessWidget {
  final int index;
  final IconData icon;
  final String title;
  final String price;
  final String? originalPrice;
  final String period;
  final String? badge;
  final Color? badgeBgColor;
  final Color? badgeTextColor;
  final List<String> features;
  final bool isSelected;
  final VoidCallback onTap;

  const PlanCard({
    super.key,
    required this.index,
    required this.icon,
    required this.title,
    required this.price,
    this.originalPrice,
    required this.period,
    this.badge,
    this.badgeBgColor,
    this.badgeTextColor,
    required this.features,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0F9FF) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? DeskColors.primary : DeskColors.line,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? DeskColors.primary.withAlpha(25)
                  : Colors.black.withAlpha(6),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(7.r),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? DeskColors.primary.withAlpha(25)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          icon,
                          size: 20.r,
                          color: isSelected ? DeskColors.primary : DeskColors.ink,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          title,
                          style: DeskText.heading(14.sp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (badge != null) ...[
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: badgeBgColor ?? const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: (badgeTextColor ?? const Color(0xFFD97706))
                            .withAlpha(80),
                      ),
                    ),
                    child: Text(
                      badge!,
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w900,
                        color: badgeTextColor ?? const Color(0xFFD97706),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    color: DeskColors.primary,
                  ),
                ),
                if (originalPrice != null) ...[
                  SizedBox(width: 8.w),
                  Text(
                    originalPrice!,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.lineThrough,
                      color: DeskColors.faint,
                    ),
                  ),
                ],
                SizedBox(width: 6.w),
                Text(period, style: DeskText.note(12.sp)),
              ],
            ),
            SizedBox(height: 12.h),
            const Divider(color: Color(0xFFF1F5F9)),
            SizedBox(height: 8.h),
            for (final f in features) ...[
              Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 16.r,
                      color: isSelected
                          ? DeskColors.primary
                          : const Color(0xFF10B981),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        f,
                        style: DeskText.body(12.sp).copyWith(
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
