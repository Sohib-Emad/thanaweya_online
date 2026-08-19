import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';

/// Cover card displaying teacher avatar, name, and verified badge.
class TeacherCoverCard extends StatelessWidget {
  final String avatarUrl;
  final String name;
  final String displayName;
  final String verifiedLabel;

  const TeacherCoverCard({
    super.key,
    required this.avatarUrl,
    required this.name,
    required this.displayName,
    required this.verifiedLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: NotebookColors.surfaceBright,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: NotebookColors.ink.withAlpha(35)),
      ),
      child: Row(
        children: [
          NotebookTeacherAvatar(
            avatarUrl: avatarUrl,
            name: name,
            size: 60.r,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName, style: NotebookText.heading(16.sp)),
                SizedBox(height: 3.h),
                Text(verifiedLabel, style: NotebookText.note(11.sp)),
                SizedBox(height: 7.h),
                Container(
                  width: 44.w,
                  height: 2.h,
                  color: NotebookColors.marginRed.withAlpha(160),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
