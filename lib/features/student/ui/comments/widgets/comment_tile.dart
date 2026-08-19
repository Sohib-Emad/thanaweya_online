import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// A notebook-styled comment tile showing user avatar and comment text.
class CommentTile extends StatelessWidget {
  /// Creates a [CommentTile].
  const CommentTile({
    super.key,
    required this.name,
    required this.text,
  });

  /// The display name of the comment author.
  final String name;

  /// The comment body text.
  final String text;

  String get _initial => name.isNotEmpty ? name[0] : 'م';

  @override
  Widget build(BuildContext context) {
    return NotebookCard(
      ruled: true,
      ruledStartY: 56,
      padding: EdgeInsets.all(12.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(),
          SizedBox(width: 10.w),
          Expanded(child: _buildContent(context)),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 34.r,
      height: 34.r,
      decoration: BoxDecoration(
        color: NotebookColors.green.withAlpha(24),
        shape: BoxShape.circle,
        border: Border.all(
          color: NotebookColors.green.withAlpha(90),
          width: 1.2,
        ),
      ),
      child: Center(
        child: Text(
          _initial,
          style: NotebookText.strong(12.sp, color: NotebookColors.green),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name.isNotEmpty ? name : l10n.userGeneric,
          style: NotebookText.strong(11.sp),
        ),
        SizedBox(height: 3.h),
        Text(text, style: NotebookText.body(13.sp)),
      ],
    );
  }
}
