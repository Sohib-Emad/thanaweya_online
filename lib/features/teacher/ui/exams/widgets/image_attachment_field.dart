import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Image attachment row with pick and clear actions.
///
/// Used in the add-question bottom sheet to optionally attach an image.
class ImageAttachmentField extends StatelessWidget {
  const ImageAttachmentField({
    super.key,
    required this.pickedImage,
    required this.onPick,
    required this.onClear,
  });

  final File? pickedImage;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: onPick,
          style: OutlinedButton.styleFrom(
            minimumSize: Size.zero,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          ),
          icon: const Icon(Icons.image_outlined, size: 16),
          label: Text(
              pickedImage != null ? 'تم إرفاق صورة ✓' : 'إرفاق صورة للسؤال',
              style: GoogleFonts.cairo(fontSize: 11.sp)),
        ),
        if (pickedImage != null)
          IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              onPressed: onClear),
      ],
    );
  }
}
