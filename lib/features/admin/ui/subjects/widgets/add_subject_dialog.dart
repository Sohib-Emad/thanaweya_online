import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/features/shared/widgets/app_text_field.dart';

void showAddSubjectDialog({
  required BuildContext context,
  required void Function(String nameAr, String nameEn) onConfirm,
}) {
  final nameArController = TextEditingController();
  final nameEnController = TextEditingController();

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('إضافة مادة'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(controller: nameArController, labelText: 'الاسم بالعربي'),
          SizedBox(height: 12.h),
          AppTextField(controller: nameEnController, labelText: 'الاسم بالإنجليزي'),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text(AppStrings.cancel)),
        TextButton(
          onPressed: () {
            if (nameArController.text.isNotEmpty && nameEnController.text.isNotEmpty) {
              HapticFeedback.lightImpact();
              onConfirm(nameArController.text.trim(), nameEnController.text.trim());
            }
            Navigator.pop(ctx);
          },
          child: const Text(AppStrings.confirm),
        ),
      ],
    ),
  );
}
