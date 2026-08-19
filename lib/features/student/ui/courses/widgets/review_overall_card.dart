import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';

/// Displays the overall average rating and star count for a course.
class ReviewOverallCard extends StatelessWidget {
  const ReviewOverallCard({
    super.key,
    required this.average,
    required this.reviewCount,
  });

  /// The average rating value (0–5).
  final double average;

  /// The total number of reviews.
  final int reviewCount;

  /// Constructs the card from a list of rating values.
  factory ReviewOverallCard.fromRatings(List<double> ratings, {required String countLabel}) {
    final avg = ratings.isEmpty
        ? 0.0
        : ratings.reduce((a, b) => a + b) / ratings.length;
    return ReviewOverallCard(average: avg, reviewCount: ratings.length);
  }

  @override
  Widget build(BuildContext context) {
    return NotebookCard(
      ruled: true,
      ruledStartY: 110,
      marginTab: true,
      padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
      child: Column(
        children: [
          Text(average.toStringAsFixed(1), style: NotebookText.heading(36.sp)),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (i) => Icon(
                i < average.round()
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: const Color(0xFFF59E0B),
                size: 24.r,
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            '$reviewCount تقييم',
            style: NotebookText.note(11.sp),
          ),
        ],
      ),
    );
  }
}
