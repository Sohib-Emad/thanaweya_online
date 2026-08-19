import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

/// Animated role-selection card with Lottie icon, badge, and chevron.
class SleekRoleCard extends StatefulWidget {
  final String title;
  final String badge;
  final String description;
  final String lottieAsset;
  final LinearGradient gradient;
  final Color accentColor;
  final Color bgColor;
  final VoidCallback onTap;

  const SleekRoleCard({
    super.key,
    required this.title,
    required this.badge,
    required this.description,
    required this.lottieAsset,
    required this.gradient,
    required this.accentColor,
    required this.bgColor,
    required this.onTap,
  });

  @override
  State<SleekRoleCard> createState() => _SleekRoleCardState();
}

class _SleekRoleCardState extends State<SleekRoleCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: _isPressed
                ? widget.accentColor.withAlpha(150)
                : const Color(0xFFE2E8F0),
            width: _isPressed ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _isPressed
                  ? widget.accentColor.withAlpha(20)
                  : const Color(0x0A0F172A),
              blurRadius: _isPressed ? 16 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildLottieIcon(),
            SizedBox(width: 16.w),
            Expanded(child: _buildContent()),
            SizedBox(width: 8.w),
            Icon(
              Icons.chevron_left_rounded,
              color: const Color(0xFF94A3B8),
              size: 22.r,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLottieIcon() {
    return Container(
      width: 64.r,
      height: 64.r,
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: widget.bgColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Lottie.asset(
        widget.lottieAsset,
        fit: BoxFit.contain,
        repeat: true,
        animate: true,
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.title,
              style: GoogleFonts.outfit(
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: widget.bgColor,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                widget.badge,
                style: GoogleFonts.outfit(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  color: widget.accentColor,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          widget.description,
          style: GoogleFonts.outfit(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF64748B),
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
