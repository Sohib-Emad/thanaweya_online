import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Confirmation dialog for deleting an activation card.
class DeleteConfirmDialog extends StatelessWidget {
  final String code;

  const DeleteConfirmDialog({super.key, required this.code});

  /// Shows the dialog and returns true if the user confirmed deletion.
  static Future<bool> show(BuildContext context, {required String code}) async {
    HapticFeedback.warningNotification();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteConfirmDialog(code: code),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: DeskColors.surface,
        title: Text('حذف كرت التفعيل', style: DeskText.strong(15.sp)),
        content: Text(
          'هل تريد حذف الكرت ($code)؟ لن يتمكن أي طالب من استخدامه لاحقاً.',
          style: DeskText.body(13.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء', style: DeskText.strong(13.sp)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'حذف',
              style: DeskText.strong(13.sp, color: DeskColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
