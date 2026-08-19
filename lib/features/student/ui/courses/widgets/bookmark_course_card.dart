import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';

/// Displays a single bookmarked course with cover, subject, and teacher info.
class BookmarkCourseCard extends StatelessWidget {
  const BookmarkCourseCard({
    super.key,
    required this.title,
    required this.subject,
    required this.teacherName,
    required this.coverUrl,
    required this.onTap,
    required this.onRemoveBookmark,
  });

  final String title;
  final String subject;
  final String teacherName;
  final String coverUrl;
  final VoidCallback onTap;
  final VoidCallback onRemoveBookmark;

  @override
  Widget build(BuildContext context) {
    final accent = NotebookColors.green;
    return NotebookCard(
      ruled: true,
      ruledStartY: 116,
      marginTab: true,
      onTap: () { HapticFeedback.lightImpact(); onTap(); },
      child: Row(
        children: [
          _CoverBox(coverUrl: coverUrl, accent: accent),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopRow(subject: subject, onRemoveBookmark: onRemoveBookmark),
                SizedBox(height: 6.h),
                Text(title, style: NotebookText.heading(13.sp), maxLines: 2, overflow: TextOverflow.ellipsis),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.person_outline_rounded, color: NotebookColors.pencil, size: 14.r),
                    SizedBox(width: 4.w),
                    Expanded(child: Text(teacherName, style: NotebookText.note(11.sp), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverBox extends StatelessWidget {
  const _CoverBox({required this.coverUrl, required this.accent});
  final String coverUrl;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96.r, height: 96.r, clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: accent.withAlpha(22),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: accent.withAlpha(90), width: 1.2),
      ),
      child: coverUrl.isNotEmpty
          ? Image.network(coverUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallback())
          : _fallback(),
    );
  }

  Widget _fallback() => Center(child: Icon(Icons.play_circle_fill_rounded, color: accent, size: 36.r));
}

class _TopRow extends StatelessWidget {
  const _TopRow({required this.subject, required this.onRemoveBookmark});
  final String subject;
  final VoidCallback onRemoveBookmark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (subject.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(color: NotebookColors.green, borderRadius: BorderRadius.circular(4.r)),
            child: Text(subject, style: GoogleFonts.cairo(fontSize: 10.sp, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
        GestureDetector(
          onTap: onRemoveBookmark,
          child: Tooltip(message: 'إزالة', child: Icon(Icons.bookmark_rounded, color: NotebookColors.green, size: 20.r)),
        ),
      ],
    );
  }
}
