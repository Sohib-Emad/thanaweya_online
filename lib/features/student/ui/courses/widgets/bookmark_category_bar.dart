import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';

/// Horizontal scrollable bar of category filter chips for bookmarks.
class BookmarkCategoryBar extends StatelessWidget {
  const BookmarkCategoryBar({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  /// List of category labels.
  final List<String> categories;

  /// Index of the currently selected category.
  final int selectedIndex;

  /// Callback when a category is tapped.
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        children: List.generate(categories.length, (index) {
          return NotebookChip(
            label: categories[index],
            selected: selectedIndex == index,
            onTap: () {
              HapticFeedback.selectionClick();
              onSelected(index);
            },
          );
        }),
      ),
    );
  }
}
