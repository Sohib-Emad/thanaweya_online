import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/student/ui/onboarding/widgets/selection_widgets.dart';

/// A card displaying teacher info with avatar, name, subject, and checkbox.
class TeacherCard extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final String subjectName;
  final bool isSelected;
  final VoidCallback onTap;

  const TeacherCard({
    super.key,
    required this.name,
    this.avatarUrl,
    required this.subjectName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NotebookCard(
      ruled: true,
      ruledStartY: 32,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Row(
        children: [
          NotebookTeacherAvatar(
            avatarUrl: avatarUrl,
            name: name,
            size: 42.r,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: NotebookText.strong(13.sp)),
                SizedBox(height: 2.h),
                Text(subjectName, style: NotebookText.note(11.sp)),
              ],
            ),
          ),
          NotebookCheckbox(isSelected: isSelected),
        ],
      ),
    );
  }
}
