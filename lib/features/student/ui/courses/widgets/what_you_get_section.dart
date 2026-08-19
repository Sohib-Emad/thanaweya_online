import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// List of capabilities the student receives with this course.
class WhatYouGetSection extends StatelessWidget {
  const WhatYouGetSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      l10n.whatYouGet1,
      l10n.whatYouGet2,
      l10n.whatYouGet3,
      l10n.whatYouGet4,
      l10n.whatYouGet5,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NotebookSectionHeader(title: l10n.whatYouGetTitle),
        SizedBox(height: 10.h),
        ...items.map(
          (text) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              children: [
                Container(
                  width: 26.r,
                  height: 26.r,
                  decoration: BoxDecoration(
                    color: NotebookColors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_rounded, color: Colors.white, size: 15.r),
                ),
                SizedBox(width: 12.w),
                Expanded(child: Text(text, style: NotebookText.body(13.sp))),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
