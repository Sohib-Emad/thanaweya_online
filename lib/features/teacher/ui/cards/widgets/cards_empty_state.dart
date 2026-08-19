import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Empty state shown when no activation cards match the current filter.
class CardsEmptyState extends StatelessWidget {
  const CardsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.subtitles_off_rounded,
            size: 48.r,
            color: DeskColors.faint.withAlpha(120),
          ),
          SizedBox(height: 12.h),
          Text(
            'لا توجد كروت تفعيل في هذه القائمة',
            style: DeskText.body(13.sp),
          ),
        ],
      ),
    );
  }
}
