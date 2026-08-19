import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/core/utils/formatters.dart';
import 'package:thanaweya_online/features/shared/models/notification_model.dart';
import 'package:thanaweya_online/features/shared/ui/widgets/notification_category_style.dart';

/// A single notification card displaying icon, title, body, and timestamp.
class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.item,
    required this.isTeacher,
    this.onTap,
  });

  final NotificationModel item;
  final bool isTeacher;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final style = notificationCategoryStyle(item.category, isTeacher);
    final isRead = item.isRead;
    final ink = isTeacher ? DeskColors.ink : NotebookColors.ink;
    final muted = isTeacher ? DeskColors.muted : NotebookColors.pencil;
    final faint = isTeacher ? DeskColors.faint : NotebookColors.pencil;
    final unreadBg = isTeacher ? DeskColors.primarySoft : NotebookColors.surfaceBright;
    final readBg = isTeacher ? DeskColors.surface : NotebookColors.surface;
    final readBorder = isTeacher ? DeskColors.line : NotebookColors.ink.withAlpha(38);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: isRead ? readBg : unreadBg,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isRead ? readBorder : style.color.withAlpha(90),
            width: isRead ? 1 : 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: (isTeacher ? DeskColors.primary : NotebookColors.ink)
                  .withAlpha(16),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: style.color.withAlpha(24),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(style.icon, color: style.color, size: 22.r),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleRow(ink, isRead, style),
                  if (item.body.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      item.body,
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: muted,
                        height: 1.5,
                      ),
                    ),
                  ],
                  SizedBox(height: 8.h),
                  _buildFooter(faint, style),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleRow(Color ink, bool isRead, dynamic style) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            item.title,
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: isRead ? FontWeight.w700 : FontWeight.w900,
              color: ink,
              height: 1.3,
            ),
          ),
        ),
        if (!isRead) ...[
          SizedBox(width: 8.w),
          Container(
            width: 9.r,
            height: 9.r,
            decoration: BoxDecoration(color: style.color, shape: BoxShape.circle),
          ),
        ],
      ],
    );
  }

  Widget _buildFooter(Color faint, dynamic style) {
    return Row(
      children: [
        Text(
          style.label,
          style: GoogleFonts.cairo(
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            color: style.color,
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          width: 3.r,
          height: 3.r,
          decoration: BoxDecoration(color: faint, shape: BoxShape.circle),
        ),
        SizedBox(width: 8.w),
        Text(
          Formatters.timeAgo(item.createdAt),
          style: GoogleFonts.cairo(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: faint,
          ),
        ),
      ],
    );
  }
}
