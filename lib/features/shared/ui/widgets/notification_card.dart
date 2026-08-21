import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:thanaweya_online/core/firebase/notification_storage.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/core/utils/formatters.dart';
import 'package:thanaweya_online/features/shared/models/notification_model.dart';
import 'package:thanaweya_online/features/shared/ui/widgets/notification_category_style.dart';

/// A single notification card displaying icon, title, body, clickable link, and timestamp.
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

  String? _findLink() {
    if (item.link != null && item.link!.trim().isNotEmpty) {
      return NotificationStorage.cleanUrl(item.link!);
    }
    final urlRegex = RegExp(r'(https?://[^\s]+|www\.[^\s]+)');
    final match = urlRegex.firstMatch(item.body) ?? urlRegex.firstMatch(item.title);
    if (match != null) {
      return NotificationStorage.cleanUrl(match.group(0)!);
    }
    return null;
  }

  Future<void> _openLink(String url) async {
    try {
      var clean = NotificationStorage.cleanUrl(url);
      if (!clean.startsWith('http://') && !clean.startsWith('https://')) {
        clean = 'https://$clean';
      }
      final uri = Uri.parse(clean);
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      try {
        var clean = NotificationStorage.cleanUrl(url);
        if (!clean.startsWith('http://') && !clean.startsWith('https://')) {
          clean = 'https://$clean';
        }
        await launchUrl(Uri.parse(clean), mode: LaunchMode.platformDefault);
      } catch (_) {}
    }
  }

  Widget _buildBodyText(String body, Color mutedColor, Color linkColor) {
    final urlRegex = RegExp(r'(https?://[^\s]+|www\.[^\s]+)');
    final matches = urlRegex.allMatches(body);

    if (matches.isEmpty) {
      return Text(
        body,
        style: GoogleFonts.cairo(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: mutedColor,
          height: 1.5,
        ),
      );
    }

    final List<InlineSpan> spans = [];
    int lastIndex = 0;

    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: body.substring(lastIndex, match.start),
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: mutedColor,
              height: 1.5,
            ),
          ),
        );
      }

      final rawUrl = match.group(0)!;
      final cleanUrl = NotificationStorage.cleanUrl(rawUrl);
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: GestureDetector(
            onTap: () => _openLink(cleanUrl),
            child: Text(
              rawUrl,
              textDirection: TextDirection.ltr,
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: linkColor,
                decoration: TextDecoration.underline,
                decorationColor: linkColor,
                height: 1.5,
              ),
            ),
          ),
        ),
      );

      lastIndex = match.end;
    }

    if (lastIndex < body.length) {
      spans.add(
        TextSpan(
          text: body.substring(lastIndex),
          style: GoogleFonts.cairo(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: mutedColor,
            height: 1.5,
          ),
        ),
      );
    }

    return Text.rich(
      TextSpan(children: spans),
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = notificationCategoryStyle(item.category, isTeacher);
    final isRead = item.isRead;
    final ink = isTeacher ? DeskColors.ink : NotebookColors.ink;
    final muted = isTeacher ? DeskColors.muted : NotebookColors.pencil;
    final faint = isTeacher ? DeskColors.faint : NotebookColors.pencil;
    final unreadBg =
        isTeacher ? DeskColors.primarySoft : NotebookColors.surfaceBright;
    final readBg = isTeacher ? DeskColors.surface : NotebookColors.surface;
    final readBorder =
        isTeacher ? DeskColors.line : NotebookColors.ink.withAlpha(38);
    const linkBlue = Color(0xFF0284C7);
    final link = _findLink();

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
                    _buildBodyText(item.body, muted, linkBlue),
                  ],
                  if (link != null) ...[
                    SizedBox(height: 8.h),
                    GestureDetector(
                      onTap: () => _openLink(link),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 7.h,
                        ),
                        decoration: BoxDecoration(
                          color: linkBlue.withAlpha(22),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: linkBlue.withAlpha(100),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.link_rounded,
                              size: 17,
                              color: linkBlue,
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                link,
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.left,
                                style: GoogleFonts.cairo(
                                  fontSize: 11.5.sp,
                                  fontWeight: FontWeight.w800,
                                  color: linkBlue,
                                  decoration: TextDecoration.underline,
                                  decorationColor: linkBlue,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            const Icon(
                              Icons.open_in_new_rounded,
                              size: 14,
                              color: linkBlue,
                            ),
                          ],
                        ),
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
            decoration:
                BoxDecoration(color: style.color, shape: BoxShape.circle),
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

