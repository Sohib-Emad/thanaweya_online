import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'notebook_colors.dart';
import 'notebook_painters.dart';
import 'notebook_text.dart';

/// A paper card: faint border, subtle shadow, optional ruled lines and a red
/// margin tab at the top-start edge.
class NotebookCard extends StatelessWidget {
  const NotebookCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(14),
    this.ruled = false,
    this.ruledStartY = 24,
    this.marginTab = false,
    this.borderRadius = 8,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final bool ruled;
  final double ruledStartY;
  final bool marginTab;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      decoration: BoxDecoration(
        color: NotebookColors.surface,
        borderRadius: BorderRadius.circular(borderRadius.r),
        border: Border.all(color: NotebookColors.ink.withAlpha(38)),
        boxShadow: [
          BoxShadow(
            color: NotebookColors.ink.withAlpha(14),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (ruled)
            Positioned.fill(
              child: CustomPaint(
                painter: RuledLinesPainter(
                  lineGap: 28,
                  startY: ruledStartY.h,
                ),
              ),
            ),
          if (marginTab)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 16.w,
                height: 4.h,
                decoration: const BoxDecoration(
                  color: NotebookColors.marginRed,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(3),
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

/// A calm empty-state note written on a notebook page.
class NotebookEmptyNote extends StatelessWidget {
  const NotebookEmptyNote({
    super.key,
    required this.message,
    this.icon = Icons.edit_note_rounded,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: NotebookColors.surface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: NotebookColors.ink.withAlpha(40)),
      ),
      child: Column(
        children: [
          Icon(icon, color: NotebookColors.pencil, size: 30.r),
          SizedBox(height: 8.h),
          Text(
            message,
            style: NotebookText.note(12.sp),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
