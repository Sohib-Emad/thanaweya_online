import 'package:flutter/material.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Empty state shown when no notifications match the current filter.
class NotificationsEmptyState extends StatelessWidget {
  const NotificationsEmptyState({
    super.key,
    required this.message,
    required this.isTeacher,
    this.subMessage,
  });

  final String message;
  final bool isTeacher;
  final String? subMessage;

  @override
  Widget build(BuildContext context) {
    if (isTeacher) {
      return DeskEmptyNote(
        message: message,
        subMessage: subMessage ?? 'ستصل هنا إشعارات تفعيل حسابك وأحداث المنصة',
        icon: Icons.notifications_none_rounded,
      );
    }
    return NotebookEmptyNote(
      message: message,
      icon: Icons.notifications_none_rounded,
    );
  }
}
