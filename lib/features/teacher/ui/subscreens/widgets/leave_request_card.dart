import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Card widget displaying a single leave or absence request.
class LeaveRequestCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const LeaveRequestCard({super.key, required this.item});

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
      child: Icon(Icons.badge_outlined, color: DeskColors.primary, size: 22.r),
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(item['type'] as String, style: DeskText.strong(13.5.sp)),
            DeskStatusChip(
              label: item['status'] as String,
              color: item['statusColor'] as Color,
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text('السبب: ${item['reason']}', style: DeskText.note(11.5.sp)),
        SizedBox(height: 2.h),
        Text(
          'من ${item['startDate']} إلى ${item['endDate']}',
          style: DeskText.note(10.5.sp),
        ),
      ],
    );
  }
}
