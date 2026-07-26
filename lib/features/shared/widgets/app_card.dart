import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final bool isSelected;
  final bool showBorder;
  final Color? borderColor;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.color,
    this.isSelected = false,
    this.showBorder = true,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: margin ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        padding: padding ?? EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: color ?? AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: showBorder
              ? Border.all(
                  color: isSelected
                      ? (borderColor ?? AppColors.studentPrimary)
                      : AppColors.borderLight,
                  width: isSelected ? 1.5 : 1,
                )
              : null,
        ),
        child: child,
      ),
    );
  }
}
