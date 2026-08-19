import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/features/shared/widgets/pressable.dart';

/// Reusable animated button with primary, outlined, and secondary variants.
class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isSecondary;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isSecondary = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.height,
    this.padding,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = widget.isLoading ? null : widget.onPressed;

    return Pressable(
      controller: _controller,
      onPressed: effectiveOnPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: widget.height ?? 52.h,
          padding: widget.padding ?? EdgeInsets.symmetric(horizontal: 24.w),
          decoration: _decoration(),
          child: Center(child: _buildChild()),
        ),
      ),
    );
  }

  BoxDecoration _decoration() {
    if (widget.isSecondary) {
      return BoxDecoration(
        color: widget.backgroundColor ?? AppColors.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      );
    }
    if (widget.isOutlined) {
      return BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: widget.backgroundColor ?? AppColors.studentPrimary,
          width: 1.5,
        ),
      );
    }
    return BoxDecoration(
      color: widget.backgroundColor ?? AppColors.studentPrimary,
      borderRadius: BorderRadius.circular(12.r),
    );
  }

  Widget _buildChild() {
    if (widget.isLoading) {
      return SizedBox(
        height: 20.r,
        width: 20.r,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: widget.textColor ?? AppColors.textOnPrimary,
        ),
      );
    }

    final labelColor = widget.isSecondary
        ? AppColors.textPrimary
        : (widget.textColor ?? AppColors.textOnPrimary);

    if (widget.isSecondary || widget.isOutlined) {
      return Text(widget.text, style: AppTextStyles.button.copyWith(color: labelColor));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: 18.r, color: AppColors.textOnPrimary),
          SizedBox(width: 8.w),
        ],
        Text(widget.text, style: AppTextStyles.button.copyWith(color: labelColor)),
      ],
    );
  }
}
