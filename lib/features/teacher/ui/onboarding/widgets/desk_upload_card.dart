import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Upload card widget for National ID front/back & teacher proof.
class DeskUploadCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? fileName;
  final bool isAttached;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  const DeskUploadCard({
    super.key,
    required this.title,
    this.subtitle,
    this.fileName,
    required this.isAttached,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isAttached ? accent.withAlpha(22) : DeskColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isAttached ? accent.withAlpha(190) : DeskColors.line,
            width: isAttached ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: isAttached ? accent : DeskColors.surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAttached ? Icons.check_rounded : icon,
                color: isAttached ? DeskColors.onPrimary : DeskColors.muted,
                size: 18.r,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: DeskText.strong(12.sp,
                        color: isAttached ? accent : DeskColors.ink),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    isAttached
                        ? (fileName != null
                              ? 'تم إرفاق: $fileName ✓'
                              : 'تم إرفاق الصورة ✓')
                        : (subtitle ?? 'انقر لاختيار صورة من جهازك'),
                    style: DeskText.note(10.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
