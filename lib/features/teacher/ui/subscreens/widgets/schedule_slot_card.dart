import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Card widget displaying a single schedule slot (lecture/tutorial).
class ScheduleSlotCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const ScheduleSlotCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: DeskColors.line),
      ),
      child: Row(
        children: [
          _buildIcon(),
          SizedBox(width: 12.w),
          Expanded(child: _buildDetails()),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: DeskColors.primarySoft,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(Icons.schedule_rounded, color: DeskColors.primary, size: 22.r),
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                item['title'] as String,
                style: DeskText.strong(13.sp),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(item['status'] as String, style: DeskText.strong(10.5.sp)),
          ],
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            Icon(Icons.access_time_rounded, size: 12.r, color: DeskColors.muted),
            SizedBox(width: 4.w),
            Text(item['time'] as String, style: DeskText.note(11.sp)),
            SizedBox(width: 12.w),
            Icon(Icons.meeting_room_outlined, size: 12.r, color: DeskColors.muted),
            SizedBox(width: 4.w),
            Text(item['hall'] as String, style: DeskText.note(11.sp)),
          ],
        ),
      ],
    );
  }
}
