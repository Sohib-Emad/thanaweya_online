import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// A row widget displaying a single status step with an icon,
/// title, and status badge in the pending review flow.
class StatusStepRow extends StatelessWidget {
  final String title;
  final String statusText;
  final bool isDone;
  final bool isInProgress;
  final bool isPending;

  const StatusStepRow({
    super.key,
    required this.title,
    required this.statusText,
    this.isDone = false,
    this.isInProgress = false,
    this.isPending = false,
  });

  @override
  Widget build(BuildContext context) {
    Color iconColor = DeskColors.faint;
    IconData iconData = Icons.circle_outlined;

    if (isDone) {
      iconColor = DeskColors.success;
      iconData = Icons.check_circle_rounded;
    } else if (isInProgress) {
      iconColor = DeskColors.accent;
      iconData = Icons.hourglass_bottom_rounded;
    }

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.r),
          decoration: BoxDecoration(
            color: iconColor.withAlpha(24),
            shape: BoxShape.circle,
          ),
          child: Icon(iconData, color: iconColor, size: 18.r),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            title,
            style: DeskText.body(13.sp,
                color: isPending ? DeskColors.faint : DeskColors.ink),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: iconColor.withAlpha(20),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: iconColor.withAlpha(90), width: 1),
          ),
          child: Text(
            statusText,
            style: DeskText.strong(11.sp, color: iconColor),
          ),
        ),
      ],
    );
  }
}
