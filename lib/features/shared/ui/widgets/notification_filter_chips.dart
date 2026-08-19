import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

const kNotificationFilters = <({String key, String label})>[
  (key: 'all', label: 'الكل'),
  (key: 'lessons', label: 'الدروس'),
  (key: 'exams', label: 'الامتحانات'),
  (key: 'system', label: 'النظام'),
];

/// Horizontal filter chip row for notification categories.
class NotificationFilterChips extends StatelessWidget {
  const NotificationFilterChips({
    super.key,
    required this.selectedCategory,
    required this.isTeacher,
    required this.onCategoryChanged,
  });

  final String selectedCategory;
  final bool isTeacher;
  final ValueChanged<String> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: kNotificationFilters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final f = kNotificationFilters[index];
          final selected = selectedCategory == f.key;
          void onTap() {
            HapticFeedback.selectionClick();
            onCategoryChanged(f.key);
          }

          if (isTeacher) {
            return DeskChip(label: f.label, selected: selected, onTap: onTap);
          }
          return NotebookChip(label: f.label, selected: selected, onTap: onTap);
        },
      ),
    );
  }
}
