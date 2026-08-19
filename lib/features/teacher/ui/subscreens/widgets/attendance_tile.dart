import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/subscreens/widgets/status_pill.dart';

/// A single student attendance row with present/late/absent status pills.
class AttendanceTile extends StatelessWidget {
  const AttendanceTile({
    super.key,
    required this.name,
    required this.status,
    required this.onStatusChanged,
  });

  final String name;
  final String status;
  final ValueChanged<String> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: DeskColors.line),
      ),
      child: Row(
        children: [
          DeskAvatar(initial: name, radius: 18),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(name, style: DeskText.strong(13.sp)),
          ),
          Row(
            children: [
              StatusPill(
                label: 'حاضر',
                isSelected: status == 'present',
                color: const Color(0xFF10B981),
                onTap: () => onStatusChanged('present'),
              ),
              SizedBox(width: 6.w),
              StatusPill(
                label: 'متأخر',
                isSelected: status == 'late',
                color: const Color(0xFFF59E0B),
                onTap: () => onStatusChanged('late'),
              ),
              SizedBox(width: 6.w),
              StatusPill(
                label: 'غائب',
                isSelected: status == 'absent',
                color: const Color(0xFFEF4444),
                onTap: () => onStatusChanged('absent'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
