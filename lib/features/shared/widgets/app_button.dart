import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

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
    if (widget.isSecondary) {
      return _Pressable(
        controller: _controller,
        onPressed: widget.isLoading ? null : widget.onPressed,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            height: widget.height ?? 52.h,
            padding: widget.padding ?? EdgeInsets.symmetric(horizontal: 24.w),
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? AppColors.background,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Text(
                widget.text,
                style: AppTextStyles.button.copyWith(color: AppColors.textPrimary),
              ),
            ),
          ),
        ),
      );
    }

    if (widget.isOutlined) {
      return _Pressable(
        controller: _controller,
        onPressed: widget.isLoading ? null : widget.onPressed,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            height: widget.height ?? 52.h,
            padding: widget.padding ?? EdgeInsets.symmetric(horizontal: 24.w),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: widget.backgroundColor ?? AppColors.studentPrimary,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                widget.text,
                style: AppTextStyles.button
                    .copyWith(color: widget.backgroundColor ?? AppColors.studentPrimary),
              ),
            ),
          ),
        ),
      );
    }

    return _Pressable(
      controller: _controller,
      onPressed: widget.isLoading ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: widget.height ?? 52.h,
          padding: widget.padding ?? EdgeInsets.symmetric(horizontal: 24.w),
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? AppColors.studentPrimary,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    height: 20.r,
                    width: 20.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: widget.textColor ?? AppColors.textOnPrimary,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, size: 18.r, color: AppColors.textOnPrimary),
                        SizedBox(width: 8.w),
                      ],
                      Text(
                        widget.text,
                        style: AppTextStyles.button
                            .copyWith(color: widget.textColor ?? AppColors.textOnPrimary),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _Pressable extends StatelessWidget {
  final AnimationController controller;
  final VoidCallback? onPressed;
  final Widget child;

  const _Pressable({
    required this.controller,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: onPressed != null ? (_) => controller.forward() : null,
      onTapUp: onPressed != null
          ? (_) {
              controller.reverse();
              onPressed?.call();
            }
          : null,
      onTapCancel: onPressed != null ? () => controller.reverse() : null,
      child: child,
    );
  }
}
