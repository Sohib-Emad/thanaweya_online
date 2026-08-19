import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Toggle card that allows marking a lesson as a free preview.
class FreePreviewToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const FreePreviewToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DeskCard(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: DeskColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.card_giftcard_rounded,
              size: 20.r,
              color: DeskColors.primary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('معاينة مجانية', style: DeskText.strong(14.sp)),
                Text(
                  'السماح للطلاب غير المشتركين بمشاهدة هذا الدرس تجريبياً',
                  style: DeskText.note(11.sp),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: DeskColors.primary,
            activeTrackColor: DeskColors.primary.withAlpha(120),
            onChanged: (v) {
              HapticFeedback.selectionClick();
              onChanged(v);
            },
          ),
        ],
      ),
    );
  }
}
