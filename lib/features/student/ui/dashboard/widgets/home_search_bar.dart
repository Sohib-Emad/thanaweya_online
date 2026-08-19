import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/student/ui/courses/course_filter_screen.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/course_filters.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// A ruled-line search bar with a filter-tune button.
class HomeSearchBar extends StatelessWidget {
  /// Creates a [HomeSearchBar].
  const HomeSearchBar({
    super.key,
    required this.controller,
    required this.onFiltersChanged,
  });

  /// The text controller for the search input.
  final TextEditingController controller;

  /// Called when the user applies filters, receiving the chosen [CourseFilters].
  final ValueChanged<CourseFilters?> onFiltersChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: NotebookColors.pencil,
                size: 20.r,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: NotebookText.body(13.sp),
                  decoration: InputDecoration(
                    hintText: l10n.searchPlaceholder,
                    hintStyle: NotebookText.note(12.sp)
                        .copyWith(color: NotebookColors.pencil.withAlpha(180)),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  final result = await Navigator.pushNamed<CourseFilters>(
                    context,
                    AppRouter.studentFilter,
                  );
                  onFiltersChanged(result);
                },
                child: Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: NotebookColors.surfaceBright,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: NotebookColors.marginRed.withAlpha(140),
                      width: 1.4,
                    ),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: NotebookColors.marginRed,
                    size: 18.r,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 0),
          child: Container(
            height: 1.4,
            color: NotebookColors.ink.withAlpha(70),
          ),
        ),
      ],
    );
  }
}
