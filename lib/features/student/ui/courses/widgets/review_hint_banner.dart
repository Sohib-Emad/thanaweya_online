import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';

/// Highlighted note encouraging students to leave a review.
class ReviewHintBanner extends StatelessWidget {
  const ReviewHintBanner({super.key, required this.message});

  /// The hint text to display.
  final String message;

  @override
  Widget build(BuildContext context) {
    return NotebookHighlightNote(
      child: Row(
        children: [
          Icon(Icons.edit_note_rounded, color: NotebookColors.ink, size: 16.r),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(message, style: NotebookText.strong(12.sp)),
          ),
        ],
      ),
    );
  }
}
