import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'desk_colors.dart';

/// A clean raised desk card with optional top accent edge.
class DeskCard extends StatelessWidget {
  const DeskCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 18,
    this.accent,
    this.label,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final double borderRadius;
  final Color? accent;
  final String? label;

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      decoration: BoxDecoration(
        color: DeskColors.surface,
        borderRadius: BorderRadius.circular(borderRadius.r),
        border: Border.all(color: DeskColors.line, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withAlpha(16),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (accent != null)
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: Container(
                height: 4.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent!, accent!.withAlpha(160)],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
                ),
              ),
            ),
          if (label != null)
            Positioned(
              top: 12.h,
              left: 12.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: (accent ?? DeskColors.primary).withAlpha(22),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: (accent ?? DeskColors.primary).withAlpha(120),
                    width: 1,
                  ),
                ),
                child: Text(
                  label!,
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w900,
                    color: accent ?? DeskColors.primary,
                  ),
                ),
              ),
            ),
          Padding(padding: padding, child: child),
        ],
      ),
    );

    if (onTap != null) {
      content = GestureDetector(onTap: onTap, child: content);
    }
    return content;
  }
}

/// A footer bar of evenly spaced labeled actions inside a card.
class DeskActionFooter extends StatelessWidget {
  const DeskActionFooter({super.key, required this.actions});

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: DeskColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0)
              Container(width: 1, height: 22.h, color: DeskColors.line),
            Expanded(child: actions[i]),
          ],
        ],
      ),
    );
  }
}
