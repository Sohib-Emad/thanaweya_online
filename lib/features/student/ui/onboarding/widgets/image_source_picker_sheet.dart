import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/theme/notebook_theme.dart';
import '../../../../../l10n/l10n.dart';

/// Bottom sheet that lets the user pick an image from gallery or camera.
Future<void> showImageSourcePicker({
  required BuildContext context,
  required String title,
  required Function(XFile?) onImageSelected,
}) async {
  HapticFeedback.lightImpact();
  final picker = ImagePicker();
  await showModalBottomSheet(
    context: context,
    backgroundColor: NotebookColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (ctx) {
      final l10n = ctx.l10n;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: NotebookText.heading(17.sp)),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: Icon(
                    Icons.close_rounded,
                    color: NotebookColors.pencil,
                    size: 22.r,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: NotebookColors.green.withAlpha(18),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.photo_library_rounded,
                  color: NotebookColors.green,
                  size: 24.r,
                ),
              ),
              title: Text(
                l10n.chooseFromGallery,
                style: NotebookText.strong(14.sp),
              ),
              subtitle: Text(
                l10n.chooseFromGallerySubtitle,
                style: NotebookText.note(11.sp),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  final file = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 85,
                  );
                  if (file != null) onImageSelected(file);
                } catch (_) {
                  onImageSelected(XFile('gallery_image.jpg'));
                }
              },
            ),
            SizedBox(height: 8.h),
            Divider(
              height: 1,
              color: NotebookColors.ink.withAlpha(25),
            ),
            SizedBox(height: 8.h),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: NotebookColors.green.withAlpha(18),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: NotebookColors.green,
                  size: 24.r,
                ),
              ),
              title: Text(
                l10n.takePhoto,
                style: NotebookText.strong(14.sp),
              ),
              subtitle: Text(
                l10n.takePhotoSubtitle,
                style: NotebookText.note(11.sp),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  final file = await picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 85,
                  );
                  if (file != null) onImageSelected(file);
                } catch (_) {
                  onImageSelected(XFile('camera_image.jpg'));
                }
              },
            ),
            SizedBox(height: 12.h),
          ],
        ),
      );
    },
  );
}
