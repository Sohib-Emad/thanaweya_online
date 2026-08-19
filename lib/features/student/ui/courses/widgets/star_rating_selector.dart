import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Interactive star rating selector widget.
class StarRatingSelector extends StatelessWidget {
  const StarRatingSelector({
    super.key,
    required this.rating,
    required this.onChanged,
  });

  /// Current selected rating (1–5).
  final int rating;

  /// Callback when user taps a star.
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          5,
          (index) => GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(index + 1);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Icon(
                index < rating
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: const Color(0xFFF59E0B),
                size: 40.r,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
