import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Card widget displaying a single notification item.
class NotificationCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const NotificationCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isRead = item['isRead'] == true;
    final Color color = item['color'] as Color? ?? DeskColors.primary;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: isRead ? DeskColors.surface : DeskColors.primarySoft.withAlpha(50),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isRead ? DeskColors.line : DeskColors.primary.withAlpha(60),
          width: isRead ? 1 : 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIcon(color),
          SizedBox(width: 12.w),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildIcon(Color color) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(item['icon'] as IconData, color: color, size: 20.r),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(item['title'] as String, style: DeskText.strong(13.5.sp)),
            Text(item['time'] as String, style: DeskText.note(10.5.sp)),
          ],
        ),
        SizedBox(height: 4.h),
        Text(item['body'] as String, style: DeskText.body(12.sp)),
      ],
    );
  }
}
