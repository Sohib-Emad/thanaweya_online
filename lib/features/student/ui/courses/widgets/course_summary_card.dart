import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/notebook_theme.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../l10n/l10n.dart';

/// Displays course title and price inside a notebook card.
class CourseSummaryCard extends StatelessWidget {
  final String courseTitle;
  final double? price;

  const CourseSummaryCard({
    super.key,
    required this.courseTitle,
    this.price,
  });

  bool get _isFree => price == null || price! <= 0;

  @override
  Widget build(BuildContext context) {
    return NotebookCard(
      ruled: true,
      ruledStartY: 64,
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: NotebookColors.surfaceBright,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: NotebookColors.green.withAlpha(90),
                width: 1.2,
              ),
            ),
            child: Icon(
              Icons.menu_book_rounded,
              color: NotebookColors.green,
              size: 24.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  courseTitle.isEmpty
                      ? context.l10n.subscribeToCourse
                      : courseTitle,
                  style: NotebookText.heading(14.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  _isFree
                      ? context.l10n.freeCourse
                      : 'سعر الكورس: ${Formatters.formatEgp(price)}',
                  style: NotebookText.strong(
                    12.sp,
                    color: _isFree
                        ? NotebookColors.green
                        : NotebookColors.marginRed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
