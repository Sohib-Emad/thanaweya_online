import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/notebook_theme.dart';

/// Avatar picker circle with camera badge for the registration form.
class StudentAvatarPicker extends StatelessWidget {
  final File? avatarFile;
  final VoidCallback onTap;

  const StudentAvatarPicker({
    super.key,
    this.avatarFile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 96.r,
              height: 96.r,
              decoration: BoxDecoration(
                color: NotebookColors.surfaceBright,
                shape: BoxShape.circle,
                border: Border.all(
                  color: NotebookColors.green.withAlpha(90),
                  width: 2,
                ),
                image: avatarFile != null
                    ? DecorationImage(
                        image: FileImage(avatarFile!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: avatarFile == null
                  ? Icon(
                      Icons.person_outlined,
                      size: 46.r,
                      color: NotebookColors.green,
                    )
                  : null,
            ),
            Container(
              padding: EdgeInsets.all(7.r),
              decoration: BoxDecoration(
                color: NotebookColors.green,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                size: 15.r,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
