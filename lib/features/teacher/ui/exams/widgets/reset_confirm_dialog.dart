import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Reusable confirmation dialog for reset/reopen actions.
///
/// Returns `true` if the user confirms, `false` or `null` otherwise.
class ResetConfirmDialog extends StatelessWidget {
  const ResetConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
  });

  final String title;
  final String message;
  final String confirmLabel;

  /// Shows the dialog and returns the user's choice.
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => ResetConfirmDialog(
          title: title, message: message, confirmLabel: confirmLabel),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: DeskColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(title, style: DeskText.heading(16.sp)),
        content: Text(message, style: DeskText.body(12.sp)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء',
                style: DeskText.strong(12.sp, color: DeskColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmLabel,
                style: DeskText.strong(12.sp, color: DeskColors.primary)),
          ),
        ],
      ),
    );
  }
}
