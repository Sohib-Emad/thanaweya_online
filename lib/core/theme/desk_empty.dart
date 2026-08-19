import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'desk_colors.dart';
import 'desk_text.dart';

/// A calm empty-state note with an optional action.
class DeskEmptyNote extends StatelessWidget {
  const DeskEmptyNote({
    super.key,
    required this.message,
    this.subMessage,
    this.icon = Icons.inbox_outlined,
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
      padding: EdgeInsets.all(28.r),
      decoration: BoxDecoration(
        color: DeskColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: DeskColors.line, width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 60.r,
            height: 60.r,
            decoration: const BoxDecoration(
              color: DeskColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: DeskColors.primary, size: 28.r),
          ),
          SizedBox(height: 14.h),
          Text(
            message,
            style: DeskText.body(13.sp),
            textAlign: TextAlign.center,
          ),
          if (subMessage != null) ...[
            SizedBox(height: 5.h),
            Text(
              subMessage!,
              style: DeskText.note(11.sp),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
