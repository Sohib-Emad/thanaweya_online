import 'package:flutter/material.dart';

/// Dialog asking for a rejection reason before rejecting a teacher.
Future<void> showRejectTeacherDialog({
  required BuildContext context,
  required String teacherName,
  required void Function(String reason) onReject,
}) {
  final controller = TextEditingController();
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('سبب الرفض'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: 'اكتب سبب الرفض...'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('إلغاء'),
        ),
        TextButton(
          onPressed: () {
            onReject(controller.text.trim());
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم رفض $teacherName'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: const Text('رفض'),
        ),
      ],
    ),
  );
}
