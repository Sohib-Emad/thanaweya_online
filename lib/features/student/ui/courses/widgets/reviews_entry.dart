import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Header row with a "View All" link that navigates to the reviews page.
class ReviewsEntry extends StatelessWidget {
  final String courseId;

  const ReviewsEntry({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.studentReviewsTitle, style: NotebookText.heading(16.sp)),
            GestureDetector(
              onTap: () => Navigator.pushNamed(
                context,
                AppRouter.studentReviews,
                arguments: courseId,
              ),
              child: Row(
                children: [
                  Text(
                    l10n.viewAll,
                    style: NotebookText.strong(12.sp, color: NotebookColors.green),
                  ),
                  Icon(
                    Icons.chevron_left_rounded,
                    color: NotebookColors.green,
                    size: 16.r,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        NotebookEmptyNote(
          icon: Icons.star_border_rounded,
          message: l10n.reviewsAvailableNote,
        ),
      ],
    );
  }
}
