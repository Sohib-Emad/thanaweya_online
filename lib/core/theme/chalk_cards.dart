import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'chalk_chips.dart';
import 'chalk_colors.dart';
import 'chalk_painters.dart';
import 'chalk_text.dart';

/// A chalk-framed card: board fill, dashed chalk border, optional accent top edge.
class ChalkCard extends StatelessWidget {
  const ChalkCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(14),
    this.borderRadius = 16,
    this.accent,
    this.accentLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final double borderRadius;
  final Color? accent;
  final String? accentLabel;

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      decoration: BoxDecoration(
        color: ChalkboardColors.surface,
        borderRadius: BorderRadius.circular(borderRadius.r),
        boxShadow: [
          BoxShadow(
            color: ChalkboardColors.groundDeep.withAlpha(120),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: ChalkBorderPainter(
                color: ChalkboardColors.ink.withAlpha(64),
                radius: borderRadius,
              ),
            ),
          ),
          if (accent != null)
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: Container(
                height: 4.h,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(borderRadius.r),
                  ),
                ),
              ),
            ),
          if (accentLabel != null)
            Positioned(
              top: 10.h,
              left: 12.w,
              child: ChalkStamp(label: accentLabel!, color: accent!),
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

/// A calm chalk empty-state note.
class ChalkEmptyNote extends StatelessWidget {
  const ChalkEmptyNote({
    super.key,
    required this.message,
    this.subMessage,
    this.icon = Icons.auto_stories_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? subMessage;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: ChalkboardColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: ChalkboardColors.ink.withAlpha(50)),
      ),
      child: Column(
        children: [
          Container(
            width: 54.r,
            height: 54.r,
            decoration: BoxDecoration(
              color: ChalkboardColors.groundDeep.withAlpha(80),
              shape: BoxShape.circle,
              border: Border.all(color: ChalkboardColors.ink.withAlpha(40)),
            ),
            child: Icon(icon, color: ChalkboardColors.chalkSoft, size: 26.r),
          ),
          SizedBox(height: 12.h),
          Text(
            message,
            style: ChalkboardText.body(13.sp),
            textAlign: TextAlign.center,
          ),
          if (subMessage != null) ...[
            SizedBox(height: 4.h),
            Text(
              subMessage!,
              style: ChalkboardText.note(11.sp),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
