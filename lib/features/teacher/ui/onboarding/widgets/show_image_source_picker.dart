import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/onboarding/widgets/desk_source_tile.dart';

/// Shows a bottom sheet to pick an image from gallery or camera.
Future<void> showImageSourcePicker({
  required BuildContext context,
  required ImagePicker picker,
  required String title,
  required void Function(XFile?) onImageSelected,
  required void Function(String) onError,
}) async {
  HapticFeedback.lightImpact();
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: const BoxDecoration(
            color: DeskColors.ground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 28.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.h,
                  margin: EdgeInsets.only(top: 10.h, bottom: 12.h),
                  decoration: BoxDecoration(
                    color: DeskColors.faint,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: DeskText.heading(16.sp)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close_rounded,
                      color: DeskColors.muted,
                      size: 24.r,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),
              DeskSourceTile(
                icon: Icons.photo_library_rounded,
                color: DeskColors.primary,
                title: 'اختيار من معرض الصور (Gallery)',
                subtitle: 'اختر صورة واضحة محفوظة على جهازك',
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    final file = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 85,
                    );
                    if (file != null) onImageSelected(file);
                  } catch (_) {
                    onError('تعذر فتح معرض الصور، حاول مرة أخرى');
                  }
                },
              ),
              SizedBox(height: 10.h),
              DeskSourceTile(
                icon: Icons.camera_alt_rounded,
                color: DeskColors.info,
                title: 'التقاط صورة جديدة بالكاميرا (Camera)',
                subtitle: 'استخدم كاميرا الهيدر لتصوير المستند فوراً',
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    final file = await picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 85,
                    );
                    if (file != null) onImageSelected(file);
                  } catch (_) {
                    onError('تعذر فتح الكاميرا، حاول مرة أخرى');
                  }
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
