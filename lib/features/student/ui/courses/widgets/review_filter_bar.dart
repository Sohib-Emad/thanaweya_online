import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';

/// Horizontal list of filter chips for narrowing reviews.
class ReviewFilterBar extends StatelessWidget {
  const ReviewFilterBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  /// Labels for each chip.
  final List<String> labels;

  /// Currently active chip index.
  final int selectedIndex;

  /// Callback when a chip is tapped.
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          return NotebookChip(
            label: labels[index],
            selected: selectedIndex == index,
            onTap: () {
              HapticFeedback.selectionClick();
              onSelected(index);
            },
          );
        },
      ),
    );
  }
}
