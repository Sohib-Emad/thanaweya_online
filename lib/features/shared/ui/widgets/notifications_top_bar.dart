import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/shared/models/notification_model.dart';

/// Top app bar for the notifications screen with unread count and mark-all action.
class NotificationsTopBar extends StatelessWidget implements PreferredSizeWidget {
  const NotificationsTopBar({
    super.key,
    required this.allNotifications,
    required this.isTeacher,
    required this.onMarkAllRead,
  });

  final List<NotificationModel> allNotifications;
  final bool isTeacher;
  final VoidCallback onMarkAllRead;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final unread = allNotifications.where((n) => !n.isRead).length;
    final subtitle =
        unread > 0 ? 'لديك $unread إشعار جديد' : 'لا إشعارات جديدة';
    final action = unread > 0
        ? GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onMarkAllRead();
            },
            child: Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'تحديد الكل كمقروء',
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      color: isTeacher
                          ? DeskColors.primary
                          : NotebookColors.green,
                    ),
                  ),
                ],
              ),
            ),
          )
        : null;
    if (isTeacher) {
      return DeskTopBar(
        title: 'الإشعارات',
        subtitle: subtitle,
        actions: [?action],
      );
    }
    return NotebookTopBar(
      title: 'الإشعارات',
      subtitle: subtitle,
      actions: [?action],
    );
  }
}
