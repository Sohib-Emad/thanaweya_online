import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// A tappable tile for selecting a date, showing a label and formatted value.
class DatePickTile extends StatelessWidget {
  /// The label displayed above the date value.
  final String label;

  /// The formatted date string to display.
  final String value;

  /// The icon shown next to the label.
  final IconData icon;

  /// Callback when the tile is tapped.
  final VoidCallback onTap;

  const DatePickTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: DeskColors.surfaceAlt,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: DeskColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 15.r, color: DeskColors.primary),
                SizedBox(width: 6.w),
                Text(label, style: DeskText.note(11.sp)),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              value,
              style: DeskText.strong(11.5.sp),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
