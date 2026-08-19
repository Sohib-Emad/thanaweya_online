import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';

/// Avatar color palette for review items.
const List<Color> kReviewAvatarColors = [
  Color(0xFF0FA37F),
  Color(0xFF2563EB),
  Color(0xFFD97706),
  Color(0xFFEF4444),
];

/// Formats an ISO date string to dd/MM/yyyy.
String formatReviewDate(String? iso) {
  if (iso == null || iso.isEmpty) return '';
  final dt = DateTime.tryParse(iso);
  if (dt == null) return iso;
  return '${dt.day}/${dt.month}/${dt.year}';
}

/// A single review card showing avatar, name, stars, comment, and date.
class ReviewItemCard extends StatelessWidget {
  const ReviewItemCard({
    super.key,
    required this.name,
    required this.rating,
    required this.comment,
    this.date,
    this.index = 0,
  });

  /// Reviewer display name.
  final String name;

  /// Star rating (1–5).
  final int rating;

  /// Review body text.
  final String comment;

  /// ISO-formatted creation date.
  final String? date;

  /// Index used to pick avatar color.
  final int index;

  @override
  Widget build(BuildContext context) {
    final avatarColor = kReviewAvatarColors[index % kReviewAvatarColors.length];
    final avatarChar = name.isNotEmpty ? name.substring(0, 1) : 'ط';

    return NotebookCard(
      ruled: true,
      ruledStartY: 88,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      color: avatarColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        avatarChar,
                        style: NotebookText.strong(14.sp, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(name, style: NotebookText.strong(13.sp)),
                ],
              ),
              _StarBadge(rating: rating),
            ],
          ),
          SizedBox(height: 10.h),
          Text(comment, style: NotebookText.body(13.sp)),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                color: NotebookColors.pencil,
                size: 13.r,
              ),
              SizedBox(width: 4.w),
              Text(formatReviewDate(date), style: NotebookText.note(11.sp)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StarBadge extends StatelessWidget {
  const _StarBadge({required this.rating});
  final int rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          ...List.generate(
            5,
            (i) => Icon(
              i < rating ? Icons.star_rounded : Icons.star_border_rounded,
              color: const Color(0xFFF59E0B),
              size: 11.r,
            ),
          ),
          SizedBox(width: 3.w),
          Text(
            '$rating',
            style: NotebookText.strong(11.sp, color: const Color(0xFFB45309)),
          ),
        ],
      ),
    );
  }
}
