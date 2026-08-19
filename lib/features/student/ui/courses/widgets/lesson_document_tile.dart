import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// A tappable tile representing a single lesson document (handout / PDF).
class LessonDocumentTile extends StatelessWidget {
  const LessonDocumentTile({
    super.key,
    required this.document,
    required this.onTap,
  });

  /// Raw document map from Supabase.
  final Map<String, dynamic> document;

  /// Called when the user taps the tile.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final docTitle =
        document['title'] as String? ?? context.l10n.lessonHandout;

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: NotebookCard(
        ruled: true,
        ruledStartY: 20,
        marginTab: true,
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Row(
          children: [
            Icon(
              Icons.picture_as_pdf_outlined,
              color: NotebookColors.marginRed,
              size: 22.r,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    docTitle,
                    style: NotebookText.body(12.5.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    context.l10n.tapToOpen,
                    style: NotebookText.note(10.sp),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.download_rounded,
              color: NotebookColors.green,
              size: 18.r,
            ),
          ],
        ),
      ),
    );
  }
}
