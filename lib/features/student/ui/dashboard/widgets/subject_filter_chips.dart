import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';

/// A horizontal list of subject filter chips for course filtering.
class SubjectFilterChips extends StatelessWidget {
  /// Creates a [SubjectFilterChips].
  const SubjectFilterChips({
    super.key,
    required this.subjects,
    required this.selectedFilter,
    required this.allLabel,
    required this.onFilterChanged,
  });

  /// The list of subject names to display as chips.
  final List<String> subjects;

  /// The currently selected filter value (Arabic 'الكل' for "All").
  final String selectedFilter;

  /// The label for the "All" chip.
  final String allLabel;

  /// Called when the user selects a different filter.
  final ValueChanged<String> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final allFilters = [allLabel, ...subjects];
    return SizedBox(
      height: 34.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        children: allFilters.map((label) {
          final isAll = label == allLabel;
          final filterValue = isAll ? 'الكل' : label;
          return NotebookChip(
            label: label,
            selected: selectedFilter == filterValue,
            onTap: () => onFilterChanged(filterValue),
          );
        }).toList(),
      ),
    );
  }
}
